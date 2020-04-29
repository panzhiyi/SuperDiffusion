function [TPR, FPR] = CalROC(smapImg, gtImg, targetIsFg, targetIsHigh)
% Code Author: Wangjiang Zhu
% Email: wangjiang88119@gmail.com
% Date: 3/24/2014
smapImg = smapImg(:,:,1);
if ~islogical(gtImg)
    gtImg = gtImg(:,:,1) > 128;
end
if any(size(smapImg) ~= size(gtImg))
    error('saliency map and ground truth mask have different size');
end

if ~targetIsFg
    gtImg = ~gtImg;
end

gtPxlNum = sum(gtImg(:));
bgPxlNum = sum(~gtImg(:));
if 0 == gtPxlNum
    error('no foreground region is labeled');
end

TP = histc(smapImg(gtImg), 0:255);
FP = histc(smapImg(~gtImg), 0:255);

if targetIsHigh
    TP = flipud(TP);
    FP = flipud(FP);
end
TP = cumsum( TP );
FP = cumsum( FP );


TPR = TP/gtPxlNum;
if any(isnan(TPR))
    TPR(isnan(TPR)) = 0;
    %warning('there exists NAN in recall, this is because  your saliency map do not range from 0 to 255\n');
end
FPR = FP/bgPxlNum;
if any(isnan(FPR))
    FPR(isnan(FPR)) = 0;
    %warning('there exists NAN in FPR, this is because  your saliency map do not range from 0 to 255\n');
end


