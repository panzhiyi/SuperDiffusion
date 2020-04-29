function w=gettheta(sp_num,scale_theta,VA_theta,sigma,CS_theta,imgRoot,imnames,img_train,DRFI)

featurenum=length(CS_theta)*length(scale_theta)*(length(sigma)+1)+DRFI;
wf=zeros(featurenum,1);
wff=zeros(featurenum,featurenum);
for ii=1:length(img_train)
    imname=[imgRoot imnames(img_train(ii)).name];
    input_im=imread(imname);
    dposition=strfind(imnames(img_train(ii)).name,'.');
    position=dposition(1)-1;
    [ hsum, wsum, input_im] = ImageCrop(input_im);
    [m,n,k] = size(input_im);
    
    %%----------------------generate superpixels--------------------%%
    [superpixels] = mex_ers(double(input_im),sp_num)+1;
    
    %计算gound turth的显著性向量
    imname_gt=[imgRoot imnames(img_train(ii)).name(1:position) '.png'];
    gt=computeSalienceVector(imname_gt,hsum,wsum,m,n,superpixels,sp_num);
    
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
    
    %多颜色空间
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
    H=[];
    for i=1:length(scale_theta)
        for j=1:length(CS_theta)
            weights = makeweights2(edges,seg_vals{j},scale_theta(i));
            W = adjacency(double(edges),weights,sp_num)+sparse(eye(sp_num));%sparse为稀疏矩阵的表示形式，W的稀疏表达形式
            
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
            sv=U1*U1'*tran;
            [U,sv]=normU(U1,sv);
            H1=U*U'*sv;
            
            for t=1:length(sigma)
                [U,sv]=normU(U1,sv2(:,t));
                H2=U*U'*sv;%final saliency
                H=[H H2];
            end
            H=[H H1];
        end
    end
    
    if DRFI==1
        imname_drfi=[imgRoot(1:end-1) '_DRFI/' imnames(img_train(ii)).name(1:position) '_DRFI.png'];
        drfi=computeSalienceVector(imname_drfi,hsum,wsum,m,n,superpixels,sp_num);
        [U,tran1]=normU(drfi,tran);
        H_drfi=U*U.'*tran1;
        H=[H H_drfi];
    end
    wf=wf+H.'*gt;
    wff=wff+H.'*H;
end

%最小二乘法计算权重
wff=real(wff);wf=real(wf);
theta=1/100000000;
w=lsqnonneg(wff*theta,wf);