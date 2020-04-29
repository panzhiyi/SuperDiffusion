function [ out ] = sprescurve( res,percent, interv )
%SPRESCURVE Summary of this function goes here
%   Detailed explanation goes here

out=zeros(1,interv+1);
out(percent+1)=res;

for i=2:interv+1
    if out(i)==0
        out(i)=out(i-1);
    end   
end

end

