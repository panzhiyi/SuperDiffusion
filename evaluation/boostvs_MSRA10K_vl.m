clear;

type={'IT','AIM','GB','SR','SUN','SeR','SIM','SS','COV'};
matRoot='../MSRA10K/main_vl/';
matnames=dir([matRoot '*' 'mat']);

for t=1:length(type)
    
    sigtype=type{t};
    sigPath=['../MSRA10K/others/' sigtype '/'];
    saldir=['../MSRA10K/bosigadj_vl/' sigtype '/'];% the output path of the saliency map
    mkdir(saldir);
    
    parfor ii=1:length(matnames)
        matname=[matRoot matnames(ii).name];
        input=load(matname);
        dposition=strfind(matnames(ii).name,'.');
        position=dposition(1)-1;
        sigmap = imread(strcat(sigPath,matnames(ii).name(1:position),'_',sigtype,'.png'));
        disp(matname);
        
        hsum=input.out.pad(1);
        wsum=input.out.pad(2);
        invA=input.out.invA;
        D=input.out.D;
        W=input.out.W;
        superpixels=input.out.sp;
        sigmap=sigmap(hsum+1:end-hsum,wsum+1:end-wsum);
        [m,n,k] = size(sigmap);
        spnum=double(max(superpixels(:)));% the actual superpixel number
        
        if any(size(superpixels)~=size(sigmap))
            error(matname);
        end
              
        invD = (D\eye(spnum));
        invL=(D-0.99*W)\eye(spnum);
        invLrw=(invD*(D-0.99*W))\eye(spnum);
        
        sig=zeros(spnum,1);
        inds=cell(spnum,1);
        for i=1:spnum
            inds{i}=find(superpixels==i);
            sig(i)=mean(sigmap(inds{i}));
        end
        
%         mz=diag(ones(spnum,1));
%         mz=~mz;
        invAmz=invA;
        invLmz=invL;
        invLrwmz=invLrw;
        
        invAsig = invAmz*sig;
        invLsig = invLmz*sig;
        invLrwsig = invLrwmz*sig;
        
        invAsig=mat2gray(invAsig);
        outname=[saldir matnames(ii).name(1:position) '_invA_' sigtype '.png'];        
        tmapstage1=ToImage(invAsig,inds,[m n],[hsum wsum],1);
        %tmapstage2=imadjust(tmapstage1,stretchlim(tmapstage1,0.03),[]);    
        imwrite(tmapstage1,outname); 
              
        invLsig=mat2gray(invLsig);
        outname=[saldir matnames(ii).name(1:position) '_invL_' sigtype '.png'];
        tmapstage1=ToImage(invLsig,inds,[m n],[hsum wsum],1);
        %tmapstage2=imadjust(tmapstage1,stretchlim(tmapstage1,0.03),[]);    
        imwrite(tmapstage1,outname); 
        
        invLrwsig=mat2gray(invLrwsig);
        outname=[saldir matnames(ii).name(1:position) '_invLrw_' sigtype '.png'];
        tmapstage1=ToImage(invLrwsig,inds,[m n],[hsum wsum],1);
        %tmapstage2=imadjust(tmapstage1,stretchlim(tmapstage1,0.03),[]);    
        imwrite(tmapstage1,outname); 
    end
    
end
