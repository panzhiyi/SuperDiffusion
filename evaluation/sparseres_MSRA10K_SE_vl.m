clear;

bwPath='../MSRA10K/SRC/';
matRoot='../MSRA10K/main_vl/';
saldir='../MSRA10K/spres_vl/';% the output path of the saliency map
mkdir(saldir);
matnames=dir([matRoot '*' 'mat']);

spA=zeros(1,length(matnames));
normRA=zeros(1,length(matnames));
spL=zeros(1,length(matnames));
normRL=zeros(1,length(matnames));
spLrw=zeros(1,length(matnames));
normRLrw=zeros(1,length(matnames));

conA=zeros(1,length(matnames));
conL=zeros(1,length(matnames));
conLrw=zeros(1,length(matnames));


meanA=zeros(1,101);
meanbA=zeros(1,101);

meanL=zeros(1,101);
meanbL=zeros(1,101);

meanLrw=zeros(1,101);
meanbLrw=zeros(1,101);

for ii=1:length(matnames)
    matname=[matRoot matnames(ii).name];
    input=load(matname);
    dposition=strfind(matnames(ii).name,'.');
    position=dposition(1)-1;
    groundtruth = logical((imread(strcat(bwPath,matnames(ii).name(1:position),'.png'))));
    disp(matname);
    
    hsum=input.out.pad(1);
    wsum=input.out.pad(2);
    invA=input.out.invA;
    D=input.out.D;
    W=input.out.W;
    superpixels=input.out.sp;
    groundtruth=groundtruth(hsum+1:end-hsum,wsum+1:end-wsum);
    [m,n,k] = size(groundtruth);
    spnum=double(max(superpixels(:)));% the actual superpixel number
    
    invD = (D\eye(spnum));
    invL=(D-0.99*W)\eye(spnum);
    invLrw=(invD*(D-0.99*W))\eye(spnum);
    
    %     mz=diag(ones(spnum,1));
    %     mz=~mz;
    %     invA=invA.*mz;
    %     invL=invL.*mz;
    %     invLrw=invLrw.*mz;
    if any(size(superpixels)~=size(groundtruth))
        disp(1);
    end
    
    gr=zeros(spnum,1);
    inds=cell(spnum,1);
    for i=1:spnum
        inds{i}=find(superpixels==i);
        gr(i)=mean(groundtruth(inds{i}));
    end
    gr(gr<0.5)=0;
    gr(gr>=0.5)=1;
    
    
    
    [spn,indxs,res,bres,gnum] = rank_omp_SE(invA, gr, 0);
    normGT=norm(gr);
    pres=[0 (normGT-res)/normGT];pbres=[0 (normGT-bres)/normGT];pbres(pbres<0)=0;
    ns=0:length(indxs);
    interv=100;
    percent=round((ns*interv)/gnum);
    pres = sprescurve(pres,percent,interv);
    pbres = sprescurve(pbres,percent,interv);
    meanA=meanA+pres;
    meanbA=meanbA+pbres;
    
    
    [spn,indxs,res,bres,gnum] = rank_omp_SE(invL, gr, 0);
    normGT=norm(gr);
    pres=[0 (normGT-res)/normGT];pbres=[0 (normGT-bres)/normGT];pbres(pbres<0)=0;
    ns=0:length(indxs);
    interv=100;
    percent=round((ns*interv)/gnum);
    pres = sprescurve(pres,percent,interv);
    pbres = sprescurve(pbres,percent,interv);
    meanL=meanL+pres;
    meanbL=meanbL+pbres;
    
    [spn,indxs,res,bres,gnum] = rank_omp_SE(invLrw, gr, 0);
    normGT=norm(gr);
    pres=[0 (normGT-res)/normGT];pbres=[0 (normGT-bres)/normGT];pbres(pbres<0)=0;
    ns=0:length(indxs);
    interv=100;
    percent=round((ns*interv)/gnum);
    pres = sprescurve(pres,percent,interv);
    pbres = sprescurve(pbres,percent,interv);
    meanLrw=meanLrw+pres;
    meanbLrw=meanbLrw+pbres;
end
meanA=meanA/length(matnames);
meanbA=meanbA/length(matnames);
meanL=meanL/length(matnames);
meanbL=meanbL/length(matnames);
meanLrw=meanLrw/length(matnames);
meanbLrw=meanbLrw/length(matnames);


SPPath1=strcat(saldir,'meanA.txt');
SPPath2=strcat(saldir,'meanbA.txt');
SPPath3=strcat(saldir,'meanL.txt');
SPPath4=strcat(saldir,'meanbL.txt');
SPPath5=strcat(saldir,'meanLrw.txt');
SPPath6=strcat(saldir,'meanbLrw.txt');
dlmwrite(SPPath1,meanA,'delimiter','\x20','newline','pc','-append');
dlmwrite(SPPath2,meanbA,'delimiter','\x20','newline','pc','-append');
dlmwrite(SPPath3,meanL,'delimiter','\x20','newline','pc','-append');
dlmwrite(SPPath4,meanbL,'delimiter','\x20','newline','pc','-append');
dlmwrite(SPPath5,meanLrw,'delimiter','\x20','newline','pc','-append');
dlmwrite(SPPath6,meanbLrw,'delimiter','\x20','newline','pc','-append');



% SPPath1=strcat(saldir,'spA.txt');
% SPPath2=strcat(saldir,'spL.txt');
% SPPath3=strcat(saldir,'spLrw.txt');
% SPPath4=strcat(saldir,'normRA.txt');
% SPPath5=strcat(saldir,'normRL.txt');
% SPPath6=strcat(saldir,'normRLrw.txt');
% SPPath7=strcat(saldir,'condA.txt');
% SPPath8=strcat(saldir,'condL.txt');
% SPPath9=strcat(saldir,'condLrw.txt');
% dlmwrite(SPPath1,spA,'delimiter','\x20','newline','pc','-append');
% dlmwrite(SPPath2,spL,'delimiter','\x20','newline','pc','-append');
% dlmwrite(SPPath3,spLrw,'delimiter','\x20','newline','pc','-append');
% dlmwrite(SPPath4,normRA,'delimiter','\x20','newline','pc','-append');
% dlmwrite(SPPath5,normRL,'delimiter','\x20','newline','pc','-append');
% dlmwrite(SPPath6,normRLrw,'delimiter','\x20','newline','pc','-append');
% dlmwrite(SPPath7,conA,'delimiter','\x20','newline','pc','-append');
% dlmwrite(SPPath8,conL,'delimiter','\x20','newline','pc','-append');
% dlmwrite(SPPath9,conLrw,'delimiter','\x20','newline','pc','-append');


%  presl=ones(1,gnum+1);
%     pres=[0 (normGT-res)/normGT];
%     presl=presl*pres(end);presl(1:length(pres))=pres;
%     pbresl=ones(1,gnum+1);
%     pbres=[0 (normGT-bres)/normGT];pbres(pbres<0)=0;
%     pbresl=pbresl*pbres(end);pbresl(1:length(pbres))=pbres;
%
%     ns=0:gnum;
%     ipres = interp1(ns,presl,0:length(ns)/10:gnum);

plot(meanbA,'r');hold on;
plot(meanbL,'b');hold on;
plot(meanbLrw,'g');hold on;
grid on;hold off;
set(gca,'Fontsize',20)
set(gca,'xlim',[0,100])
set(gca,'ylim',[0,0.7])
%set(gca,'XTick',0:30:100);
xlabel('seed percentage');
ylabel('Accuracy');
l=legend('$$\widetilde{A}^{-1}$$','$$\widetilde{L}^{-1}$$','$$\widetilde{L}_{rw}^{-1}$$','Location','SouthEast');
set(l,'interpreter','latex','FontSize',20);

