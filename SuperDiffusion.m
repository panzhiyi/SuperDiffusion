addpath('./others/');
%%------------------------set parameters---------------------%%
args.scale_theta=10:20; % control the edge weight
args.VA_theta=300;
args.sp_num=300;
args.CS_theta={'Lab<-' 'RGB<-' 'HSV<-'};
args.extra_methods={};
args.sigma={[1 0;0 1] [0.5 0;0 0.5]};

%%------------------------divide data set---------------------%%
imgRoot='./MSRA10K/';% the input path MSRA10k
saldir='./salientobject/';% the output path
if ~exist(saldir,'dir')
    mkdir(saldir);
end
args.imnames=dir([imgRoot '*' 'jpg']);
img_train=1:2:length(args.imnames);
img_test=2:2:length(args.imnames);

%%------------------------compute closed-form solutions---------------------%%
if ~exist([saldir 'weight.mat'],'file')
    w=GetTheta(args,imgRoot,img_train);
    save([saldir 'weight'],'w');
else
    weight=load([saldir 'weight']);
    w=weight.w;
end

%%------------------------generate saliency images---------------------%%
GetSalientObject(args,imgRoot,img_test,w,saldir);
