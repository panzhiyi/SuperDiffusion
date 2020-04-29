function [ol] = DrawOL(SMAP, smapSuffix, GT, gtSuffix)
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
ALLOL = zeros(num, 1);
parfor k = 1:num
    smapName = files(k).name;
    smapImg = imread(fullfile(SMAP, smapName));    
    %smapImg=im2double(smapImg);
    th=mean(mean(smapImg));
    Deteted=smapImg>=2*th;
    
    gtName = strrep(smapName, smapSuffix, gtSuffix);
    gtImg = imread(fullfile(GT, gtName));
    %gtImg=im2double(gtImg);   
    gti=gtImg>0;
         
    ALLOL(k, :) = sum(sum(Deteted&gti))/sum(sum(Deteted|gti));
end

ol = mean(ALLOL, 1);   %function 'mean' will give NaN for columns in which NaN appears.


PRPath=strcat([SMAP,'/'],'OL' ,smapSuffix(1:end-4), '.txt');
dlmwrite(PRPath,['OL' smapSuffix(1:end-4) '=['],'delimiter','','newline','pc','-append');
dlmwrite(PRPath,ol,'delimiter','\x20','newline','pc','-append');
dlmwrite(PRPath,'];','delimiter','','newline','pc','-append');

%[rec,pre]=DrawPRCurve('../MSRA10K/demo_us new', '_Adj.png', '../MSRA10K/SRC/', '.png', true, true, 'r');
