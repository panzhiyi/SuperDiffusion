
function [sp, indxs, ress, bress, gnum]=rank_omp_SE(invA,GT,criteria)
GT=double(GT);
gtn=GT>0;
snum=length(GT);
% preres=0;
% preindx=zeros(snum,1);
% pres=0;
gnum=sum(GT>0);
residual=GT;
binvAs=zeros(size(residual));
indx=zeros(gnum,1);
rindx=find(GT>0);
indxs=[];ress=[];bress=[];
for j=1:gnum
    residual=double(residual);
    invA=double(invA);
    
    proj=abs(invA'*residual).*gtn;
    
    pos=find(proj==max(proj(rindx)));
    pos=intersect(pos,rindx);    
    pos=setdiff(pos,indx);
    pos=pos(1);
    rindx=setdiff(rindx,pos);
    indx(j)=pos;
    indxs=[indxs pos];
    s = lsqnonneg(invA(:,indx(1:j)),GT);
    
    invAs=invA(:,indx(1:j))*s;
    invAs=mapminmax(invAs,0,1);
    
    binvAs(invAs>=0.5)=1;
    binvAs(invAs<0.5)=0;
%     binvAs(invAs>=2*mean(invAs))=1;
%     binvAs(invAs<2*mean(invAs))=0;
    
    residual=GT-invAs;
    
    res=norm(residual);
    bres=norm(GT-binvAs);
    ress=[ress res];
    bress=[bress bres];
    if bres<=criteria
        break;
    end
    %         if preres==res&&isequal(pres(pres~=0),s(s~=0))
    %             s=pres;
    %             indx=preindx;
    %             break;
    %         end
    %         preres=res;
    %         pres=s;
    %         preindx=indx;
end
temp=zeros(snum,1);
temp(indx(indx>0))=s;

sp=temp;
end
