addpath('code');
addpath('classes');
addpath('lr');
addpath('plot');
prepareWorkspace();

run('processingProperties.m');
items=dir(wpath);
dirs={items([items.isdir]).name};
patBuf=dirs(3:end);

XTrain=[];
XTest=[];
featuresList={};

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

fName='ChSq Distance mean';
s=load([trainPath,fName,'.mat']);
XTrain=[XTrain,s.x];
s=load([testPath,fName,'.mat']);
XTest=[XTest,s.x];
featuresList=[featuresList,fName];

fName='ChSq Distance variance';
s=load([trainPath,fName,'.mat']);
XTrain=[XTrain,s.x];
s=load([testPath,fName,'.mat']);
XTest=[XTest,s.x];
featuresList=[featuresList,fName];

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

fName='iAmpl mean';
s=load([trainPath,fName,'.mat']);
XTrain=[XTrain,s.x];
s=load([testPath,fName,'.mat']);
XTest=[XTest,s.x];
featuresList=[featuresList,fName];

fName='iAmpl variance';
s=load([trainPath,fName,'.mat']);
XTrain=[XTrain,s.x];
s=load([testPath,fName,'.mat']);
XTest=[XTest,s.x];
featuresList=[featuresList,fName];

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

% Allocate buffers
optTh=zeros(numel(patBuf)+3,1);
avTh=zeros(numel(patBuf)+3,1);
ACC=zeros(numel(patBuf)+3,1);
PPV=zeros(numel(patBuf)+3,1);
TPR=zeros(numel(patBuf)+3,1);
SPC=zeros(numel(patBuf)+3,1);

F1buf=zeros(numel(patBuf),nOfIterations);
AUCbuf=zeros(numel(patBuf),nOfIterations);

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
P=[];
RSLT=[];

for patIdx=1:numel(patBuf)
  disp([patBuf{patIdx}]);
  % Get data only for current patient
  idx=(ITrain==patIdx);
  xTrain=XTrain(idx,:);
  y=Y(idx);
  seq=sequence(idx);
  xTest=XTest(ITest==patIdx,:);
  
  for k=1:nOfIterations
    % Make data weighted
    idxPi=(y==1);
    idxIi=(y==0);
    xTrainPi=xTrain(idxPi,:);
    xTrainIi=xTrain(idxIi,:);
    nOfPi=size(xTrainPi,1);
    yPi=y(idxPi);
    yIi=y(idxIi);
    seqPi=seq(idxPi);
    seqIi=seq(idxIi);
    randIdx=randperm(size(xTrainIi,1));
    xTrainIiWght=xTrainIi(randIdx,:);
    xTrainIiWght=xTrainIiWght(1:nOfPi,:);
    seqIiWght=seqIi(randIdx);
    seqIiWght=seqIiWght(1:nOfPi);
    yIiWght=yIi(randIdx);
    yIiWght=yIiWght(1:nOfPi);
    xTrainWght=[xTrainPi;xTrainIiWght];
    seqWght=[seqPi;seqIiWght];
    yWght=[yPi;yIiWght];
    iTrainWght=patIdx*ones(numel(yWght),1);

    XTrainWght=[XTrainWght;xTrainWght];
    YWght=[YWght;yWght];
    sequenceWght=[sequenceWght;seqWght];
    ITrainWght=[ITrainWght;iTrainWght];

    % Leave one out test
    P_OVA=[];
    R_OVA=[];
    Y_OVA=[];
    X_tr_OVA=[];
    Y_tr_OVA=[];
    X_test_OVA=[];
    Y_test_OVA=[];
    optThBuf=zeros(nOfPi,1);
    for i=1:nOfPi
      idx=1:nOfPi;
      X_tr_OVA=[xTrainPi(idx~=i,:);xTrainIiWght(idx~=i,:)];
      X_test_OVA=[xTrainPi(idx==i,:);xTrainIiWght(idx==i,:)];
      Y_tr_OVA=[yPi(idx~=i);yIiWght(idx~=i)];
      Y_test_OVA=[yPi(idx==i);yIiWght(idx==i)];
      b=glmfit(X_tr_OVA,Y_tr_OVA,'binomial');
      p=glmval(b,X_tr_OVA,'logit');
      [fpr,tpr,T,AUC]=perfcurve(Y_tr_OVA,p,1);
      PPV=zeros(numel(T),1);
      TPR=zeros(numel(T),1);
      F1=zeros(numel(T),1);
      for j=1:10:numel(T)
        result=(p>=T(j));
        [TP,TN,FP,FN,PPV(j),TPR(j),F1(j)]=estBinClass(Y_tr_OVA,result);
      end

      [~,idx]=max(F1);
      optTh=T(idx);
      optThBuf(i)=optTh;
      p=glmval(b,X_test_OVA,'logit'); 
      P_OVA=[P_OVA;p];
      R_OVA=[R_OVA;(p>=optTh)];
      Y_OVA=[Y_OVA;Y_test_OVA];
    end 
    [fpr,tpr,T,AUCbuf(patIdx,k)]=perfcurve(Y_OVA,P_OVA,1);  
    [TP,TN,FP,FN,PPV,TPR,F1buf(patIdx,k)]=estBinClass(Y_OVA,R_OVA);
  end
  
  disp(['AUC: ',num2str(mean(AUCbuf(patIdx,:))),'(',num2str(min(AUCbuf(patIdx,:))), ...
    '-',num2str(max(AUCbuf(patIdx,:))),')']);
  disp(['F1: ',num2str(mean(F1buf(patIdx,:))),'(',num2str(min(F1buf(patIdx,:))), ...
    '-',num2str(max(F1buf(patIdx,:))),')']);
  
  % Kaggle test
%   optTh=mean(optThBuf);
  b=glmfit(xTrainWght,yWght,'binomial');
  p=glmval(b,xTrainWght,'logit'); 
  for j=1:10:numel(T)
    result=(p>=T(j));
    [~,~,~,~,~,~,F1(j)]=estBinClass(yWght,result);
  end
  [~,idx]=max(F1);
  optTh=T(idx);
  p=glmval(b,xTest,'logit'); 
  res=p>optTh;
  RSLT=[RSLT;res];
end

t=clock;
fileID=fopen(['submit_',num2str(t(1)),num2str(t(2)),num2str(t(3)),...
  '_',num2str(t(4)),num2str(t(5)),'.csv'],'w');
fprintf(fileID,'clip,preictal\n');
nOfPi=0;
for i=1:size(XTest,1)
  fprintf(fileID,[sNamesBuf_Test{i},',%d\n'],RSLT(i));
end
fclose(fileID);

rowNames=[];
for i=1:numel(featuresList)
  rowNames=[rowNames,'+',featuresList{i}];
end
rowNames=rowNames(2:end);
t1=table(mean(AUCbuf(1,:)),mean(AUCbuf(2,:)),mean(AUCbuf(3,:)),...
  mean(AUCbuf(4,:)),mean(AUCbuf(5,:)),mean(AUCbuf(6,:)),...
  mean(AUCbuf(7,:)),'RowNames',{rowNames},...
  'VariableNames',{'Dog1','Dog2','Dog3','Dog4','Dog5','Pat1','Pat2'});
t2=table(mean(F1buf(1,:)),mean(F1buf(2,:)),mean(F1buf(3,:)),...
  mean(F1buf(4,:)),mean(F1buf(5,:)),mean(F1buf(6,:)),...
  mean(F1buf(7,:)),'RowNames',{rowNames},...
  'VariableNames',{'Dog1','Dog2','Dog3','Dog4','Dog5','Pat1','Pat2'});
writetable(t1,'gen_feature_results.xlsx','WriteRowNames',true);
writetable(t2,'gen_feature_results.xlsx','WriteRowNames',true,'Range','J1');
% cvpartition
