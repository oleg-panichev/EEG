addpath('code');
addpath('classes');
addpath('lr');
addpath('plot');
prepareWorkspace();

run('processingProperties.m');
items=dir(wpath);
dirs={items([items.isdir]).name};
patBuf=dirs(3:end);

% Load all data
fName='Euc Distance mean';
s=load([trainPath,fName,'.mat']);
XTrain=[XTrain,s.x];
s=load([testPath,fName,'.mat']);
XTest=[XTest,s.x];
featuresList=[featuresList,fName];
  
fName='Euc Distance variance';
s=load([trainPath,fName,'.mat']);
XTrain=[XTrain,s.x];
s=load([testPath,fName,'.mat']);
XTest=[XTest,s.x];
featuresList=[featuresList,fName];

% fName='Squared Euc Distance variance';
% s=load([trainPath,fName,'.mat']);
% XTrain=[XTrain,s.x];
% s=load([testPath,fName,'.mat']);
% XTest=[XTest,s.x];
% featuresList=[featuresList,fName];

% fName='ChSq Distance mean';
% s=load([trainPath,fName,'.mat']);
% XTrain=[XTrain,s.x];
% s=load([testPath,fName,'.mat']);
% XTest=[XTest,s.x];
% featuresList=[featuresList,fName];
% 
% fName='ChSq Distance variance';
% s=load([trainPath,fName,'.mat']);
% XTrain=[XTrain,s.x];
% s=load([testPath,fName,'.mat']);
% XTest=[XTest,s.x];
% featuresList=[featuresList,fName];

fName='MI mean';
s=load([trainPath,fName,'.mat']);
XTrain=[XTrain,s.x];
s=load([testPath,fName,'.mat']);
XTest=[XTest,s.x];
featuresList=[featuresList,fName];

fName='MI variance';
s=load([trainPath,fName,'.mat']);
XTrain=[XTrain,s.x];
s=load([testPath,fName,'.mat']);
XTest=[XTest,s.x];
featuresList=[featuresList,fName];

% fName='iAmpl mean';
% s=load([trainPath,fName,'.mat']);
% XTrain=[XTrain,s.x];
% s=load([testPath,fName,'.mat']);
% XTest=[XTest,s.x];
% featuresList=[featuresList,fName];
% 
% fName='iAmpl variance';
% s=load([trainPath,fName,'.mat']);
% XTrain=[XTrain,s.x];
% s=load([testPath,fName,'.mat']);
% XTest=[XTest,s.x];
% featuresList=[featuresList,fName];

fName='iPhase mean';
s=load([trainPath,fName,'.mat']);
XTrain=[XTrain,s.x];
s=load([testPath,fName,'.mat']);
XTest=[XTest,s.x];
featuresList=[featuresList,fName];

fName='iPhase variance';
s=load([trainPath,fName,'.mat']);
XTrain=[XTrain,s.x];
s=load([testPath,fName,'.mat']);
XTest=[XTest,s.x];
featuresList=[featuresList,fName];

s=load([trainPath,'i.mat']);
ITrain=s.I;
s=load([trainPath,'y.mat']);
Y=s.Y;
s=load([trainPath,'s.mat']);
sequence=s.S;

s=load([testPath,'i.mat']);
ITest=s.I;
s=load([testPath,'sNamesBuf.mat']);
sNamesBuf_Test=s.sNamesBuf;
res=zeros(size(XTest,1),1);

optTh=zeros(numel(patBuf)+3,1);
avTh=zeros(numel(patBuf)+3,1);
ACC=zeros(numel(patBuf)+3,1);
PPV=zeros(numel(patBuf)+3,1);
TPR=zeros(numel(patBuf)+3,1);
SPC=zeros(numel(patBuf)+3,1);
F1=zeros(numel(patBuf)+3,1);

optThWght=zeros(numel(patBuf)+3,1);
avThWght=zeros(numel(patBuf)+3,1);
ACCWght=zeros(numel(patBuf)+3,1);
PPVWght=zeros(numel(patBuf)+3,1);
TPRWght=zeros(numel(patBuf)+3,1);
SPCWght=zeros(numel(patBuf)+3,1);
F1Wght=zeros(numel(patBuf)+3,1);
XTrainWght=[];
YWght=[];
sequenceWght=[];
ITrainWght=[];



% t=clock;
% fileID=fopen(['submit_',num2str(t(1)),num2str(t(2)),num2str(t(3)),...
%   '_',num2str(t(4)),num2str(t(5)),'.csv'],'w');
% fprintf(fileID,'clip,preictal\n');
% nOfPi=0;
% for i=1:numel(XTest)
%   fprintf(fileID,[sNamesBuf_Test{i},',%d\n'],res(i));
% end
% fclose(fileID);

%%%%%%%%%%%%
RSLT=[];
for patIdx=1:numel(patBuf)
  idx=(ITrain==patIdx);
  xTrain=XTrain(idx,:);
  y=Y(idx);
  seq=sequence(idx);
  xTest=XTest(ITest==patIdx,:);
  
  idxPi=(y==1);
  idxIi=(y==0);
  xTrainPi=xTrain(idxPi,:);
  xTrainIi=xTrain(idxIi,:);
  yPi=y(idxPi);
  yIi=y(idxIi);
  seqPi=seq(idxPi);
  seqIi=seq(idxIi);
  randIdx=randperm(size(xTrainIi,1));
  xTrainIiWght=xTrainIi(randIdx,:);
  xTrainIiWght=xTrainIiWght(1:size(xTrainPi,1),:);
  seqIiWght=seqIi(randIdx);
  seqIiWght=seqIiWght(1:size(xTrainPi,1));
  yIiWght=yIi(randIdx);
  yIiWght=yIiWght(1:size(xTrainPi,1));
  xTrainWght=[xTrainPi;xTrainIiWght];
  seqWght=[seqPi;seqIiWght];
  yWght=[yPi;yIiWght];
  iTrainWght=patIdx*ones(numel(yWght),1);
  
  XTrainWght=[XTrainWght;xTrainWght];
  YWght=[YWght;yWght];
  sequenceWght=[sequenceWght;seqWght];
  ITrainWght=[ITrainWght;iTrainWght];
    
%   s=sNamesBuf{idx};
  
%   [optTh(patIdx),avTh(patIdx),ACC(patIdx),PPV(patIdx),TPR(patIdx),SPC(patIdx),F1(patIdx)]=...
%     analyzeFeature(xTrain,y,seq,[],[patBuf{patIdx},', Euc Distance variance']);
%   [optThWght(patIdx),avThWght(patIdx),ACCWght(patIdx),PPVWght(patIdx),TPRWght(patIdx),...
%     SPCWght(patIdx),F1Wght(patIdx)]=analyzeFeature(xTrainWght,yWght,...
%     seqWght,[],[patBuf{patIdx},', Euc Distance variance, Wght Set']);
  
  b = glmfit(xTrain,y,'binomial');
  p = glmval(b,xTrain,'logit');
  [fpr,tpr,T,AUC] = perfcurve(y,p,1);
  disp([patBuf{patIdx},' AUC: ',num2str(AUC)]);
  PPV=zeros(numel(T),1);
  TPR=zeros(numel(T),1);
  F1=zeros(numel(T),1);
  for i=1:10:numel(T)
    reslt=(p>=T(i));
    TP=0;
    TN=0;
    FP=0;
    FN=0;
    for j=1:numel(y)
      if (y(j)==1 && reslt(j)==1)
        TP=TP+1;
      elseif (y(j)==0 && reslt(j)==1)
        FP=FP+1;
      elseif (y(j)==1 && reslt(j)==0)
        FN=FN+1;
      elseif (y(j)==0 && reslt(j)==0)
        TN=TN+1;
      end
    end
    PPV(i)=TP/(TP+FP);
    TPR(i)=TP/(TP+FN);
    F1(i)=2*PPV(i)*TPR(i)/(PPV(i)+TPR(i));
  end
  [~,idx]=max(F1);
  optTh=T(idx);
  p = glmval(b,xTest,'logit'); 
  res=p>optTh;
  RSLT=[RSLT;res];
%   pause;
  close all;
end

% Work with dogs only
idx=(ITrain<=5);
xDogs=XTrain(idx);
yDogs=Y(idx);
seqDogs=sequence(idx);
xDogsTest=XTest(ITest<=5);

idx=(ITrainWght<=5);
xDogsWght=XTrainWght(idx);
yDogsWght=YWght(idx);
seqDogsWght=sequenceWght(idx);

% [optTh(8),avTh(8),ACC(8),PPV(8),TPR(8),SPC(8),F1(8)]=...
%     analyzeFeature(xDogs,yDogs,seqDogs,[],['All Dogs, Euc Distance variance']);
% [optThWght(8),avThWght(8),ACCWght(8),PPVWght(8),TPRWght(8),...
%   SPCWght(8),F1Wght(8)]=analyzeFeature(xDogsWght,yDogsWght,...
%   seqDogsWght,[],['All Dogs, Euc Distance variance, Wght Set']);

% Work with patients only
idx=(ITrain>=6);
xDogs=XTrain(idx);
yDogs=Y(idx);
seqDogs=sequence(idx);
xDogsTest=XTest(ITest<=5);

idx=(ITrainWght>=6);
xDogsWght=XTrainWght(idx);
yDogsWght=YWght(idx);
seqDogsWght=sequenceWght(idx);

% [optTh(9),avTh(9),ACC(9),PPV(9),TPR(9),SPC(9),F1(9)]=...
%     analyzeFeature(xDogs,yDogs,seqDogs,[],['All patients, Euc Distance variance']);
% [optThWght(9),avThWght(9),ACCWght(9),PPVWght(9),TPRWght(9),...
%   SPCWght(9),F1Wght(9)]=analyzeFeature(xDogsWght,yDogsWght,...
%   seqDogsWght,[],['All patients, Euc Distance variance, Wght Set']);

% Work with all
% [optTh(10),avTh(10),ACC(10),PPV(10),TPR(10),SPC(10),F1(10)]=...
%     analyzeFeature(XTrain,Y,sequence,[],['Dogs and patients, Euc Distance variance']);
% [optThWght(10),avThWght(10),ACCWght(10),PPVWght(10),TPRWght(10),...
%   SPCWght(10),F1Wght(10)]=analyzeFeature(XTrainWght,YWght,...
%   sequenceWght,[],['Dogs and patients, Euc Distance variance, Wght Set']);

% rowNames=[patBuf,{'Dogs','Patients','All'}];
% t1=table(avTh,ACC,PPV,TPR,SPC,F1,'RowNames',rowNames,...
%   'VariableNames',{'Threshold','ACC','PPV','TPR','SPC','F1'});
% t2=table(avThWght,ACCWght,PPVWght,TPRWght,SPCWght,F1Wght,'RowNames',rowNames,...
%   'VariableNames',{'Threshold','ACC','PPV','TPR','SPC','F1'});
% 
% writetable(t1,'classification_results.xlsx','WriteRowNames',true);
% writetable(t2,'classification_results.xlsx','WriteRowNames',true,'Range','A13');

t=clock;
fileID=fopen(['submit_',num2str(t(1)),num2str(t(2)),num2str(t(3)),...
  '_',num2str(t(4)),num2str(t(5)),'.csv'],'w');
fprintf(fileID,'clip,preictal\n');
nOfPi=0;
for i=1:size(XTest,1)
%   if (XTest(i)<optTh(ITest(i))/2)
%     res=1;
%     nOfPi=nOfPi+1;
%   else
%     res=0;
%   end
  fprintf(fileID,[sNamesBuf_Test{i},',%d\n'],RSLT(i));
end
fclose(fileID);

close all;

% logistic regression
% Setup the data matrix appropriately, and add ones for the intercept term
plotData(XTrain, Y);
XTrain=[XTrain,XTrain.^2];
[m, n] = size(XTrain);

% Add intercept term to x and X_test
X = [ones(m, 1) XTrain];

% Initialize fitting parameters
initial_theta = zeros(n + 1, 1);

% Compute and display initial cost and gradient
[cost, grad] = costFunction(initial_theta, X, Y);

%  Set options for fminunc
options = optimset('GradObj', 'on', 'MaxIter', 400);

%  Run fminunc to obtain the optimal theta
%  This function will return theta and the cost 
[theta, cost] = ...
	fminunc(@(t)(costFunction(t, X, Y)), initial_theta, options);

p = predict(theta,X);

% table
% perfcurve