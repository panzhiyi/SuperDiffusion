function [gt]=computeSalienceVector(imname,h,w,m,n,superpixels,sp_num)
im_gt=imread(imname);
if numel(size(im_gt))>2
    im_gt=im_gt(h+1:h+m,w+1:w+n,:);
    im_gt=rgb2gray(im_gt);
else
    im_gt=im_gt(h+1:h+m,w+1:w+n);
end
im_gt=mat2gray(im_gt);
gt=zeros(sp_num,1);
for i=1:sp_num
    gt(i)=mean(im_gt(superpixels==i));
end