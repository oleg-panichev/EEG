addpath('code');
addpath('classes');
addpath('plot');
prepareWorkspace();

run('processingProperties.m');
items=dir(wpath);
dirs={items([items.isdir]).name};
patBuf=dirs(3:end);

X=[];
I=[];
S=[];
Y=[];
x1=[];
x2=[];
x3=[];

for patIdx=1:numel(patBuf)
  s=load([reportPath,patBuf{patIdx},'/train/','/','Euc Distance mean.mat']);
  x1=[x1;s.x];
  s=load([reportPath,patBuf{patIdx},'/train/','/','Euc Distance variance.mat']);
  x2=[x2;s.x];
  s=load([reportPath,patBuf{patIdx},'/train/','/','Squared Euc Distance variance.mat']);
  x3=[x3;s.x];
  s=load([reportPath,patBuf{patIdx},'/train/','/','i.mat']);
  I=[I;s.i];
  s=load([reportPath,patBuf{patIdx},'/train/','/','s.mat']);
  S=[S;s.sequence];
  s=load([reportPath,patBuf{patIdx},'/train/','/','y.mat']);
  Y=[Y;s.y];
end

x=x1;
featureName='Euc Distance mean';
save([trainPath,featureName,'.mat'],'x');
x=x2;
featureName='Euc Distance variance';
save([trainPath,featureName,'.mat'],'x');
x=x3;
featureName='Squared Euc Distance variance';
save([trainPath,featureName,'.mat'],'x');
save([trainPath,'y','.mat'],'Y');
save([trainPath,'s','.mat'],'S');
save([trainPath,'i','.mat'],'I');
