
clear;
run('../vlfeat-0.9.19/toolbox/vl_setup');
addpath('./others/');
%%------------------------set parameters---------------------%%
theta=10; % control the edge weight 
imgRoot='../MSRA10K/VA/';
%imgRoot='./test/';
bwPath='../MSRA10K/SRC/';
salPath1='../MSRA10K/others/PCA/';
salPath2='../MSRA10K/others/MR/stage2/';
salPath3='../MSRA10K/others/MC/';
salPath4='../MSRA10K/others/DSR/';
salPath5='../MSRA10K/others/BMS/';
salPath6='../MSRA10K/others/HS/';
salPath7='../MSRA10K/others/HDCT/';
salPath8='../MSRA10K/others/wCtr_Optimized/';
salPath9='../MSRA10K/vlslic_final/';

saldir='../MSRA10K/test/';% the output path of the saliency map
mkdir(saldir);
imnames=dir([imgRoot '*' 'jpg']);
ngap=zeros(1,length(imnames));

for ii=1:length(imnames)   
    imname=[imgRoot imnames(ii).name];
    input_im=im2double(imread(imname));
    [m,n,k] = size(input_im);
    
    dposition=strfind(imnames(ii).name,'.');
    position=dposition(1)-1;
    disp(imname);
    groundtruth = (imread(strcat(bwPath,imnames(ii).name(1:position),'.png')));  
    groundtruth=im2double(cat(3,groundtruth,groundtruth,groundtruth));
    
    sal1 = (imread(strcat(salPath1,imnames(ii).name(1:position),'_PCA.png')));
    sal{1}=im2double(cat(3,sal1,sal1,sal1));
    sal2 = (imread(strcat(salPath2,imnames(ii).name(1:position),'_stage2.png')));
    sal{2}=im2double(cat(3,sal2,sal2,sal2));
    sal3 = (imread(strcat(salPath3,imnames(ii).name(1:position),'.png')));
    sal{3}=im2double(cat(3,sal3,sal3,sal3));
    sal4 = (imread(strcat(salPath4,imnames(ii).name(1:position),'_DSR.png')));
    sal{4}=im2double(cat(3,sal4,sal4,sal4));
    sal5 = (imread(strcat(salPath5,imnames(ii).name(1:position),'_BMS.png')));
    sal{5}=im2double(cat(3,sal5,sal5,sal5));
    sal6 = (imread(strcat(salPath6,imnames(ii).name(1:position),'_HS.png')));
    sal{6}=im2double(cat(3,sal6,sal6,sal6));
    sal7 = (imread(strcat(salPath7,imnames(ii).name(1:position),'.png')));
    sal{7}=im2double(cat(3,sal7,sal7,sal7));
    sal8 = (imread(strcat(salPath8,imnames(ii).name(1:position),'_wCtr_Optimized.png')));
    sal{8}=im2double(cat(3,sal8,sal8,sal8));
    sal9 = (imread(strcat(salPath9,imnames(ii).name(1:position),'_OurAdj.png')));
    sal{9}=im2double(cat(3,sal9,sal9,sal9));
    
    out=ones(m+10,n*11+10*5,3);
    
    out(6:m+5,1:n,:)=input_im;
    out(6:m+5,5+n+1:2*n+5,:)=groundtruth;
    
    for i=1:9     
        out(6:m+5,(i+1)*(n+5)+1:(i+1)*(n+5)+n,:)=sal{i};
    end
    imwrite(uint8(mat2gray(out)*255),[saldir imnames(ii).name(1:position) '_com.png']);   
end

SPPath1=strcat(saldir,'ngap.txt');
dlmwrite(SPPath1,ngap,'delimiter','\x20','newline','pc','-append');



