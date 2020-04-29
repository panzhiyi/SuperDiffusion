function [mae] = DrawMAE(SMAP, smapSuffix, GT, gtSuffix)
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
ALLAE = zeros(num, 1);
parfor k = 1:num
    smapName = files(k).name;
    smapImg = imread(fullfile(SMAP, smapName));    
    smapImg=im2double(smapImg);
    
    gtName = strrep(smapName, smapSuffix, gtSuffix);
    gtImg = imread(fullfile(GT, gtName));
    gtImg=im2double(gtImg);
      
    ALLAE(k, :) = sum(sum(abs(smapImg-gtImg)))/(size(gtImg,1)*size(gtImg,2));
end

mae = mean(ALLAE, 1);   %function 'mean' will give NaN for columns in which NaN appears.


PRPath=strcat([SMAP,'/'],'MAE' ,smapSuffix(1:end-4), '.txt');
dlmwrite(PRPath,['MAE' smapSuffix(1:end-4) '=['],'delimiter','','newline','pc','-append');
dlmwrite(PRPath,mae,'delimiter','\x20','newline','pc','-append');
dlmwrite(PRPath,'];','delimiter','','newline','pc','-append');

%[rec,pre]=DrawPRCurve('../MSRA10K/demo_us new', '_Adj.png', '../MSRA10K/SRC/', '.png', true, true, 'r');
