function [TPR, FPR, AUC] = DrawROCCurve(SMAP, smapSuffix, GT, gtSuffix, targetIsFg, targetIsHigh)
% Draw PR Curves for all the image with 'smapSuffix' in folder SMAP
% GT is the folder for ground truth masks
% targetIsFg = true means we draw PR Curves for foreground, and otherwise
% we draw PR Curves for background
% targetIsHigh = true means feature values for our interest region (fg or
% bg) is higher than the remaining regions.
% color specifies the curve color

% Code Author: Wangjiang Zhu
% Email: wangjiang88119@gmail.com
% Date: 3/24/2014

files = dir(fullfile(SMAP, strcat('*', smapSuffix)));
num = length(files);
if 0 == num
    error('no saliency map with suffix %s are found in %s', smapSuffix, SMAP);
end

%precision and recall of all images
ALLTPR = zeros(num, 256);
ALLFPR = zeros(num, 256);
parfor k = 1:num
    smapName = files(k).name;
    smapImg = imread(fullfile(SMAP, smapName));    
    
    gtName = strrep(smapName, smapSuffix, gtSuffix);
    gtImg = imread(fullfile(GT, gtName));
    
    [tprate, fprate] = CalROC(smapImg, gtImg, targetIsFg, targetIsHigh);
    
    ALLTPR(k, :) = tprate;
    ALLFPR(k, :) = fprate;
end

TPR = mean(ALLTPR, 1);   %function 'mean' will give NaN for columns in which NaN appears.
FPR = mean(ALLFPR, 1);


rectW=FPR-[0 FPR(1:end-1)];
rectH=(TPR+[0 TPR(1:end-1)])/2;
AUC=sum(rectH.*rectW);


PRPath=strcat([SMAP,'/'],'ROC' ,smapSuffix(1:end-4), '.txt');
dlmwrite(PRPath,['TPR' smapSuffix(1:end-4) '=['],'delimiter','','newline','pc','-append');
dlmwrite(PRPath,TPR,'delimiter','\x20','newline','pc','-append');
dlmwrite(PRPath,'];','delimiter','','newline','pc','-append');
dlmwrite(PRPath,['FPR' smapSuffix(1:end-4) '=['],'delimiter','','newline','pc','-append');
dlmwrite(PRPath,FPR,'delimiter','\x20','newline','pc','-append');  
dlmwrite(PRPath,'];','delimiter','','newline','pc','-append');
dlmwrite(PRPath,['AUC' smapSuffix(1:end-4) '=['],'delimiter','','newline','pc','-append');
dlmwrite(PRPath,AUC,'delimiter','\x20','newline','pc','-append');  
dlmwrite(PRPath,'];','delimiter','','newline','pc','-append');

%[rec,pre]=DrawPRCurve('../MSRA10K/demo_us new', '_Adj.png', '../MSRA10K/SRC/', '.png', true, true, 'r');
