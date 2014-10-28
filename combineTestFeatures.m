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
sNamesBuf=[];
x1=[];
x2=[];
x3=[];

for patIdx=1:numel(patBuf)
  s=load([reportPath,'/test/',patBuf{patIdx},'/','Euc Distance mean.mat']);
  x1=[x1;s.x];
  s=load([reportPath,'/test/',patBuf{patIdx},'/','Euc Distance variance.mat']);
  x2=[x2;s.x];
  s=load([reportPath,'/test/',patBuf{patIdx},'/','Squared Euc Distance variance.mat']);
  x3=[x3;s.x];
  s=load([reportPath,'/test/',patBuf{patIdx},'/','i.mat']);
  I=[I;s.i];
  s=load([reportPath,'/test/',patBuf{patIdx},'/','sNamesBuf.mat']);
  sNamesBuf=[sNamesBuf,s.testBuf];
end

x=x1;
featureName='Euc Distance mean';
save([testPath,featureName,'.mat'],'x');
x=x2;
featureName='Euc Distance variance';
save([testPath,featureName,'.mat'],'x');
x=x3;
featureName='Squared Euc Distance variance';
save([testPath,featureName,'.mat'],'x');
save([testPath,'i','.mat'],'I');
save([testPath,'sNamesBuf.mat'],'sNamesBuf');