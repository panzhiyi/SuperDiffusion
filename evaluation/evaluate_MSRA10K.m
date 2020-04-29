% function []=evaluate_MSRA10K(str1,str2)
% clear;
% clc;
% type={'AIM','COV','GB','IT','SeR','SIM','SR','SS','SUN'};
%a=['AIM','BMS','CB','COV','DRFI','DSR','FT','GB','GS','HC','IT','LC'];
type={'GP'};
bwPath='C:\Users\lenovo\Desktop\实验\publish\ECSSD\';
imnames=dir([bwPath '*' 'png']);
for t=1:length(type)
    
    inPath=strcat('C:\Users\lenovo\Desktop\实验\publish\ECSSD_GP\');
    filelist=dir(fullfile(inPath,'*.png'));
    len=length(filelist);
    
    [re,pre]=DrawPRCurve(inPath, ['_',type{t},'.png'], bwPath, '.png', true, true);
    [TPR, FPR, AUC]=DrawROCCurve(inPath, ['_',type{t},'.png'], bwPath, '.png', true, true);
    [rec, prec, fb] = DrawFbeta(inPath, ['_',type{t},'.png'], bwPath, '.png', true, true);
    [mae] = DrawMAE(inPath, ['_',type{t},'.png'], bwPath, '.png');
    [ol] = DrawOL(inPath, ['_',type{t},'.png'], bwPath, '.png');
    
end

%  PRPath=strcat(inPath,'PR.txt');
%  %dlmwrite(PRPath,'PR=[','delimiter','\x20','newline','pc');
%  dlmwrite(PRPath,Mean_Precision,'delimiter','\x20','newline','pc','-append');
%  dlmwrite(PRPath,Mean_Recall,'delimiter','\x20','newline','pc','-append');

% figure;
% hold on;
% grid on;
% plot(Mean_Recall, Mean_Precision, 'b', 'linewidth', 2);
%    b=bar(results);
%    grid on;
%    ch = get(b,'children');
%    set(gca,'XTickLabel',{'Ours' 'GS_GD' 'GS_SP' 'SF' 'LR' 'RC' 'HC' 'FT'});
%    set(gca,'Fontsize',15)
%    set(gca,'xlim',[0,8]);
%    set(gca,'ylim',[0.3,0.95]);
%    legend('Precision','Recall','F-beta','Overlap','Location','SouthWest');
%    xlabel('x axis ');
%    ylabel('y axis');
%[rec,pre]=DrawPRCurve('../MSRA10K/SF', '_SF.png', '../MSRA10K/SRC/', '.png', true, true, 'r');