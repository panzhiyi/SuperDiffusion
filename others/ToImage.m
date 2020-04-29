function [ output ] = ToImage( ori,inds,mn,pad,to1 )
% assign the saliency value of node to the corresponding pixels
% ori=mat2gray(ori);
spnum=size(inds,1);
output=zeros(mn);
for i=1:spnum
    output(inds{i})=ori(i);
end
if to1==1
    output=mat2gray(output);
    output=uint8(output*255);
end
output = padarray(output,pad,'replicate','both');
    
end

