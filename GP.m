addpath('./others/');
%%------------------------set parameters---------------------%%
scale_theta=10:20; % control the edge weight
VA_theta=300;
sp_num=300;
CS_theta={'Lab<-' 'RGB<-' 'HSV<-'};
DRFI=1;
sigma={[1 0;0 1] [0.5 0;0 0.5]};

imgRoot=['./' str1 '/'];% the input path MSRA10k
saldir=['./' str2 '/'];% the output path
mkdir(saldir);
imnames=dir([imgRoot '*' 'jpg']);

%%------------------------select train set---------------------%%
img_train=1:2:length(imnames);
img_test=2:2:length(imnames);
w=gettheta(sp_num,scale_theta,VA_theta,sigma,CS_theta,imgRoot,imnames,img_train,DRFI);
save([saldir 'weight'],'w');
% w=load([saldir 'weight']);
% w=w.w;

parfor ii=1:length(img_test)
    imname=[imgRoot imnames(img_test(ii)).name];
    input_im=imread(imname);
    dposition=strfind(imnames(img_test(ii)).name,'.');
    position=dposition(1)-1;
    [ hsum, wsum, input_im] = ImageCrop(input_im);
    [m,n,k] = size(input_im);
    
    %%----------------------generate superpixels--------------------%%
    
    [superpixels] = mex_ers(double(input_im),sp_num)+1;
    
    %%----------------------design the graph model--------------------------%%
    % compute the feature (mean color in lab color space)
    % for each node (superpixels)
    input_vals=reshape(input_im, m*n, k);
    rgb_vals=zeros(sp_num,1,3);
    inds=cell(sp_num,1);
    for i=1:sp_num
        inds{i}=find(superpixels==i);
        rgb_vals(i,1,:)=mean(input_vals(inds{i},:),1);
    end
    
    %multi-colorspace
    seg_vals=cell(size(CS_theta));
    for i=1:length(CS_theta)
        vals = colorspace(CS_theta{i}, rgb_vals);
        seg_val=reshape(vals,sp_num,3);% feature for each superpixel
        seg_vals{i}=seg_val;
    end
    
    bsa=unique([superpixels(1,:),superpixels(m,:),superpixels(:,1)',superpixels(:,n)']);
    tran=ones(sp_num,1);tran(bsa)=0;
    
    step=0.01;
    x=-step*(m-1)/2:step:step*(m-1)/2;
    y=-step*(n-1)/2:step:step*(n-1)/2;
    [x,y]=meshgrid(x,y);
    mu=[0 0];
    sv2=ones(sp_num,3);
    for j=1:length(sigma)
        z=mvnpdf([x(:) y(:)],mu,sigma{j});
        z=reshape(z,n,m);
        %     z=1/(2*pi)*exp(-x.^2-y.^2);
        for i=1:sp_num
            sv2(i,j)=mean(z(superpixels==i));
        end
    end
    sv2(bsa,:)=0;
    adjloop=FindNeighbours(superpixels,bsa,sp_num);
    
    links=find(adjloop>0);
    edges=zeros(length(links),3);
    [edges(:,1),edges(:,2)]=ind2sub(size(adjloop),links);
    edges(:,3)=adjloop(links);
    edges=edges((edges(:,2)-edges(:,1))>0,:);
    
    %%
    result=zeros(sp_num,1);
    count=0;
    for i=1:length(scale_theta)
        for j=1:length(CS_theta)
            for k=1:length(sigma)+1
                count=count+1;
                if w(count)~=0
                    weights = makeweights2(edges,seg_vals{j},scale_theta(i));
                    W = adjacency(double(edges),weights,sp_num)+sparse(eye(sp_num));
                    
                    %eigenvectors(Ur) and eigenvalues(LL) of Lrw
                    dd = sum(W); D = sparse(1:sp_num,1:sp_num,dd);
                    invD = (D\eye(sp_num));
                    Lsym=(invD^0.5)*(D-W)*(invD^0.5);
                    [Us, LL] = eigenshuffle(Lsym);
                    Ur = (invD^0.5)*Us;
                    
                    invLL=LL.^-1;
                    
                    difL=[LL(2:end);0]-LL;
                    difL=difL(1:end-1);
                    [~,IX]=sort(difL,'descend');
                    
                    %variance of each eigenvector after normalizing to [0 255]
                    minUr=ones(sp_num,1)*min(Ur);
                    maxUr=ones(sp_num,1)*max(Ur);
                    FU=uint8(((Ur-minUr)./(maxUr-minUr))*255);FU(:,1)=255;
                    VA=var(double(FU),0,1);
                    %eigengap
                    egap=IX(1);
                    if(egap==1)
                        egap=IX(2);
                    end
                    invLLegap=invLL(2:egap);
                    VAegap=VA(2:egap);VAegap=VAegap>VA_theta;
                    if VAegap==0
                        VAegap=ones(1,egap-1);
                    end
                    
                    %re-synthesize diffusion matrix
                    U1=Ur(:,2:egap)*(diag(invLLegap)*diag(VAegap))^0.5;
                    if k==3
                        sv = U1*U1'*tran;
                    else
                        sv = sv2(:,k);
                    end
                    [U,sv]=normU(U1,sv);
                    fsal=U*U'*sv;%final saliency;
                    result=result+w(count)*fsal;
                    
                end
            end
        end
    end
    if DRFI==1&&w(count+1)~=0
        imname_drfi=[imgRoot(1:end-1) '_DRFI/' imnames(img_test(ii)).name(1:position) '_DRFI.png'];
        drfi=computeSalienceVector(imname_drfi,hsum,wsum,m,n,superpixels,sp_num);
        [U,tran1]=normU(drfi,tran);
        fsal=U*U.'*tran1;
        result=result+w(count+1)*fsal;
    end
    result=real(result);
    result=mat2gray(result);
    tmapstage1=ToImage(result,inds,[m n],[hsum wsum],1);
    outname=[saldir imnames(img_test(ii)).name(1:position) '_GP' '.png'];
    imwrite(tmapstage1,outname);
end
%matlabpool close;