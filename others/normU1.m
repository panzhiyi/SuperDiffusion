function [U,sv]=normU1(U0,sv)
[sp_num,~]=size(U0);
fsal = U0*U0'*sv;
fsal_min=min(fsal);
fsal_max=max(fsal);
U1=sqrt(-fsal_min/((fsal_max-fsal_min)));
U=[U1*ones(sp_num,1) U0/sqrt(fsal_max-fsal_min)];