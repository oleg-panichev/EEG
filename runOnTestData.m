addpath('code');
addpath('classes');
addpath('classifiers');
% addpath('lr');
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
fName='Euc Distance variance';
s=load([trainPath,fName,'.mat']);
XTrain=[XTrain,s.x];
s=load([testPath,fName,'.mat']);
XTest=[XTest,s.x];
featuresList=[featuresList,fName];
  
% fName='Euc Distance variance';
% s=load([trainPath,fName,'.mat']);
% XTrain=[XTrain,s.x];
% s=load([testPath,fName,'.mat']);
% XTest=[XTest,s.x];
% featuresList=[featuresList,fName];

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

% fName='MI mean';
% s=load([trainPath,fName,'.mat']);
% XTrain=[XTrain,s.x];
% s=load([testPath,fName,'.mat']);
% XTest=[XTest,s.x];
% featuresList=[featuresList,fName];
% 
% fName='MI variance';
% s=load([trainPath,fName,'.mat']);
% XTrain=[XTrain,s.x];
% s=load([testPath,fName,'.mat']);
% XTest=[XTest,s.x];
% featuresList=[featuresList,fName];

% XTrain=[XTrain,XTrain.*XTrain];
% XTest=[XTest,XTest.*XTest];

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

% fName='iPhase mean';
% s=load([trainPath,fName,'.mat']);
% XTrain=[XTrain,s.x];
% s=load([testPath,fName,'.mat']);
% XTest=[XTest,s.x];
% featuresList=[featuresList,fName];
% 
% fName='iPhase variance';
% s=load([trainPath,fName,'.mat']);
% XTrain=[XTrain,s.x];
% s=load([testPath,fName,'.mat']);
% XTest=[XTest,s.x];
% featuresList=[featuresList,fName];

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


classifierNames={'nbayes','threshold'};
for i=1:numel(classifierNames)
  [t1,t2,meanROCs,meanROCsWght,RSLT]=runClassification(XTrain,Y,XTest,...
    ITrain,ITest,sequence,classifierNames{i},patBuf);
  
  writetable(t1,'classification_results.xlsx','Sheet',i,'WriteRowNames',true);
  writetable(t2,'classification_results.xlsx','Sheet',i,'WriteRowNames',false,'Range','K1'); 
end




% t=clock;
% fileID=fopen(['submit_',num2str(t(1)),num2str(t(2)),num2str(t(3)),...
%   '_',num2str(t(4)),num2str(t(5)),'.csv'],'w');
% fprintf(fileID,'clip,preictal\n');
% nOfPi=0;
% for i=1:size(XTest,1)
%   fprintf(fileID,[sNamesBuf_Test{i},',%d\n'],RSLT(i));
% end
% fclose(fileID);
