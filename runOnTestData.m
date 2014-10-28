addpath('code');
addpath('classes');
addpath('plot');
prepareWorkspace();

run('processingProperties.m');
items=dir(wpath);
dirs={items([items.isdir]).name};
patBuf=dirs(3:end);

s=load([trainPath,'Euc Distance variance.mat']);
XTrain=s.x;
s=load([trainPath,'i.mat']);
ITrain=s.I;
s=load([trainPath,'y.mat']);
Y=s.Y;
s=load([trainPath,'s.mat']);
sequence=s.S;
s=load([testPath,'Euc Distance variance.mat']);
XTest=s.x;
s=load([testPath,'i.mat']);
ITest=s.I;
s=load([testPath,'sNamesBuf.mat']);
sNamesBuf_Test=s.sNamesBuf;
res=zeros(numel(X),1);

for patIdx=7:numel(patBuf)
  idx=(I==patIdx);
  xTrain=XTrain(idx);
  y=Y(idx);
  seq=sequence(idx);
  xTest=XTest(ITest==patIdx);
%   s=sNamesBuf{idx};
  
  analyzeFeature(xTrain,y,seq,[],patBuf{patIdx});

  pause;
end