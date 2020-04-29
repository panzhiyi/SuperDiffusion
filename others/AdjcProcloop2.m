function adjcMerge = AdjcProcloop2(M,N,Mcenter,regionsize)
% $Description:
%    -compute the adjacent matrix
% $Agruments
% Input;
%    -M: superpixel label matrix
%    -N: superpixel number 
%    -Mcenter: each row contains mean coordinate of a superpixel
% Output:
%    -adjcMerge: adjacent matrix

adjcMerge = zeros(N,N);
[m, n] = size(M);
bd=unique([M(1,:),M(m,:),M(:,1)',M(:,n)']);

for i=1:N 
        minx=min([Mcenter(i,1)*ones(N,1) Mcenter(:,1)],[],2);
        maxx=max([Mcenter(i,1)*ones(N,1) Mcenter(:,1)],[],2);
        miny=min([Mcenter(i,2)*ones(N,1) Mcenter(:,2)],[],2);
        maxy=max([Mcenter(i,2)*ones(N,1) Mcenter(:,2)],[],2);
        
        d=sqrt((maxx-minx).^2+(maxy-miny).^2);        
        dx=minx-1+n-maxx+min(maxy-miny,m-maxy+miny);
        dy=miny-1+m-maxy+min(maxx-minx,n-maxx+minx);
        
        adjcMerge(i,:)=min([d dx dy],[],2);
        if ismember(i, bd)
            adjcMerge(i,setdiff(bd,i))=regionsize;
        end
end

adjcMerge=round(adjcMerge/regionsize);

    