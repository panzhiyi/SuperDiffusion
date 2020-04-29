% clear;
% 
% bwPath='F:\pzy\ÏÔÖøÐÔ\MSRA10K\';
% matRoot1='F:\pzy\ÏÔÖøÐÔ\MSRA10K_mat1\';
% matRoot2='F:\pzy\ÏÔÖøÐÔ\MSRA10K_mat22\';
% saldir='F:\pzy\ÏÔÖøÐÔ\MSRA10K_ex1\';% the output path of the saliency map
% mkdir(saldir);
% matnames=dir([matRoot1 '*' 'mat']);
% 
% len=length(matnames);
% spA=zeros(1,len);
% normRA=zeros(1,len);
% spL=zeros(1,len);
% normRL=zeros(1,len);
% spLrw=zeros(1,len);
% normRLrw=zeros(1,len);
% 
% conA=zeros(1,len);
% conL=zeros(1,len);
% conLrw=zeros(1,len);
% 
% 
% meanA=zeros(1,101);
% meanbA=zeros(1,101);
% 
% meanL=zeros(1,101);
% meanbL=zeros(1,101);
% 
% meanLrw=zeros(1,101);
% meanbLrw=zeros(1,101);
% 
% %%
% spLn=zeros(1,len);
% normRLn=zeros(1,len);
% conLn=zeros(1,len);
% meanLn=zeros(1,101);
% meanbLn=zeros(1,101);
% %%
% for ii=1:len
%     matname=[matRoot1 matnames(ii).name];
%     input=load(matname);
%     dposition=strfind(matnames(ii).name,'.');
%     position=dposition(1)-1;
%     groundtruth = logical((imread(strcat(bwPath,matnames(ii).name(1:position),'.png'))));
%     if mod(ii,100)==0
%         disp(ii/100);
%     end
%     matname=[matRoot2 matnames(ii).name];
%     in=load(matname);
%     invAn=in.invA;
%     invAn=real(invAn);
%     invAn=invAn/max(invAn(:));
%     
%     hsum=input.out.hsum;
%     wsum=input.out.wsum;
%     invA=input.out.invA;
%     invA=real(invA);
%     
%     D=input.out.D;
%     W=input.out.W;
%     superpixels=input.out.sp;
%     groundtruth=groundtruth(hsum+1:end-hsum,wsum+1:end-wsum);
%     [m,n,k] = size(groundtruth);
%     spnum=double(max(superpixels(:)));% the actual superpixel number
%     
%     invD = (D\eye(spnum));
%     invL=(D-0.99*W)\eye(spnum);
%     invLrw=(invD*(D-0.99*W))\eye(spnum);
%     
%     %     mz=diag(ones(spnum,1));
%     %     mz=~mz;
%     %     invA=invA.*mz;
%     %     invL=invL.*mz;
%     %     invLrw=invLrw.*mz;
%     if any(size(superpixels)~=size(groundtruth))
%         disp(1);
%     end
%     
%     gr=zeros(spnum,1);
%     inds=cell(spnum,1);
%     for i=1:spnum
%         inds{i}=find(superpixels==i);
%         gr(i)=mean(groundtruth(inds{i}));
%     end
%     gr(gr<0.5)=0;
%     gr(gr>=0.5)=1;
%     
%     
%     
%     [spn,indxs,res,bres,gnum] = rank_omp_SE(invAn, gr, 0);
%     normGT=norm(gr);
%     pres=[0 (normGT-res)/normGT];pbres=[0 (normGT-bres)/normGT];pbres(pbres<0)=0;
%     ns=0:length(indxs);
%     interv=100;
%     percent=round((ns*interv)/gnum);
%     pres = sprescurve(pres,percent,interv);
%     pbres = sprescurve(pbres,percent,interv);
%     meanLn=meanLn+pres;
%     meanbLn=meanbLn+pbres;
%     
%     [spn,indxs,res,bres,gnum] = rank_omp_SE(invA, gr, 0);
%     normGT=norm(gr);
%     pres=[0 (normGT-res)/normGT];pbres=[0 (normGT-bres)/normGT];pbres(pbres<0)=0;
%     ns=0:length(indxs);
%     interv=100;
%     percent=round((ns*interv)/gnum);
%     pres = sprescurve(pres,percent,interv);
%     pbres = sprescurve(pbres,percent,interv);
%     meanA=meanA+pres;
%     meanbA=meanbA+pbres;
%     
%     
%     [spn,indxs,res,bres,gnum] = rank_omp_SE(invL, gr, 0);
%     normGT=norm(gr);
%     pres=[0 (normGT-res)/normGT];pbres=[0 (normGT-bres)/normGT];pbres(pbres<0)=0;
%     ns=0:length(indxs);
%     interv=100;
%     percent=round((ns*interv)/gnum);
%     pres = sprescurve(pres,percent,interv);
%     pbres = sprescurve(pbres,percent,interv);
%     meanL=meanL+pres;
%     meanbL=meanbL+pbres;
%     
%     [spn,indxs,res,bres,gnum] = rank_omp_SE(invLrw, gr, 0);
%     normGT=norm(gr);
%     pres=[0 (normGT-res)/normGT];pbres=[0 (normGT-bres)/normGT];pbres(pbres<0)=0;
%     ns=0:length(indxs);
%     interv=100;
%     percent=round((ns*interv)/gnum);
%     pres = sprescurve(pres,percent,interv);
%     pbres = sprescurve(pbres,percent,interv);
%     meanLrw=meanLrw+pres;
%     meanbLrw=meanbLrw+pbres;
% end
% meanA=meanA/len;
% meanbA=meanbA/len;
% meanL=meanL/len;
% meanbL=meanbL/len;
% meanLrw=meanLrw/len;
% meanbLrw=meanbLrw/len;
% meanLn=meanLn/len;
% meanbLn=meanbLn/len;
% 
% % 
% SPPath1=strcat(saldir,'meanA.txt');
% SPPath2=strcat(saldir,'meanbA.txt');
% SPPath3=strcat(saldir,'meanL.txt');
% SPPath4=strcat(saldir,'meanbL.txt');
% SPPath5=strcat(saldir,'meanLrw.txt');
% SPPath6=strcat(saldir,'meanbLrw.txt');
% dlmwrite(SPPath1,meanA,'delimiter','\x20','newline','pc','-append');
% dlmwrite(SPPath2,meanbA,'delimiter','\x20','newline','pc','-append');
% dlmwrite(SPPath3,meanL,'delimiter','\x20','newline','pc','-append');
% dlmwrite(SPPath4,meanbL,'delimiter','\x20','newline','pc','-append');
% dlmwrite(SPPath5,meanLrw,'delimiter','\x20','newline','pc','-append');
% dlmwrite(SPPath6,meanbLrw,'delimiter','\x20','newline','pc','-append');
% SPPath7=strcat(saldir,'meanLn.txt');
% SPPath8=strcat(saldir,'meanbLn.txt');
% dlmwrite(SPPath7,meanLn,'delimiter','\x20','newline','pc','-append');
% dlmwrite(SPPath8,meanbLn,'delimiter','\x20','newline','pc','-append');
meanA=load('F:\pzy\ÏÔÖøÐÔ\MSRA10K_ex1\meanbA.txt');
meanL=load('F:\pzy\ÏÔÖøÐÔ\MSRA10K_ex1\meanbL.txt');
meanLrw=load('F:\pzy\ÏÔÖøÐÔ\MSRA10K_ex1\meanbLrw.txt');
meanLn=load('F:\pzy\ÏÔÖøÐÔ\MSRA10K_ex1\meanbLn.txt');
% % SPPath1=strcat(saldir,'spA.txt');
% % SPPath2=strcat(saldir,'spL.txt');
% % SPPath3=strcat(saldir,'spLrw.txt');
% % SPPath4=strcat(saldir,'normRA.txt');
% % SPPath5=strcat(saldir,'normRL.txt');
% % SPPath6=strcat(saldir,'normRLrw.txt');
% % SPPath7=strcat(saldir,'condA.txt');
% % SPPath8=strcat(saldir,'condL.txt');
% % SPPath9=strcat(saldir,'condLrw.txt');
% % dlmwrite(SPPath1,spA,'delimiter','\x20','newline','pc','-append');
% % dlmwrite(SPPath2,spL,'delimiter','\x20','newline','pc','-append');
% % dlmwrite(SPPath3,spLrw,'delimiter','\x20','newline','pc','-append');
% % dlmwrite(SPPath4,normRA,'delimiter','\x20','newline','pc','-append');
% % dlmwrite(SPPath5,normRL,'delimiter','\x20','newline','pc','-append');
% % dlmwrite(SPPath6,normRLrw,'delimiter','\x20','newline','pc','-append');
% % dlmwrite(SPPath7,conA,'delimiter','\x20','newline','pc','-append');
% % dlmwrite(SPPath8,conL,'delimiter','\x20','newline','pc','-append');
% % dlmwrite(SPPath9,conLrw,'delimiter','\x20','newline','pc','-append');
% 
% 
% %  presl=ones(1,gnum+1);
% %     pres=[0 (normGT-res)/normGT];
% %     presl=presl*pres(end);presl(1:length(pres))=pres;
% %     pbresl=ones(1,gnum+1);
% %     pbres=[0 (normGT-bres)/normGT];pbres(pbres<0)=0;
% %     pbresl=pbresl*pbres(end);pbresl(1:length(pbres))=pbres;
% %
% %     ns=0:gnum;
% %     ipres = interp1(ns,presl,0:length(ns)/10:gnum);

plot(meanA,'r');hold on;
plot(meanL,'b');hold on;
plot(meanLrw,'g');hold on;
plot(meanLn,'k');hold on;
grid on;hold off;
set(gca,'Fontsize',20)
set(gca,'xlim',[0,100])
set(gca,'ylim',[0,0.8])
%set(gca,'XTick',0:30:100);
xlabel('seed percentage');
ylabel('Accuracy');
l=legend('$$\widetilde{A}^{-1}$$','$$\widetilde{L}^{-1}$$','$$\widetilde{L}_{rw}^{-1}$$','synthetize','Location','SouthEast');
set(l,'interpreter','latex','FontSize',20);

