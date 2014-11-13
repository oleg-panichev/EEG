addpath('code');
addpath('classes');
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
% fName='Euc Distance variance';
% fName='ChSq Distance mean';
% fName='ChSq Distance variance';
% fName='MI mean';
% fName='MI variance';
s=load([trainPath,fName,'.mat']);
XTrain=[XTrain,s.x];
s=load([testPath,fName,'.mat']);
XTest=[XTest,s.x];
featuresList=[featuresList,fName];
disp(fName);

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
nOfT=200; % Number of threshold values
optTh=zeros(numel(patBuf)+3,1);
avTh=zeros(numel(patBuf)+3,1);

ACC_th=zeros(nOfIterations,nOfT);
PPV_th=zeros(nOfIterations,nOfT);
TPR_th=zeros(nOfIterations,nOfT);
SPC_th=zeros(nOfIterations,nOfT);
FPR_th=zeros(nOfIterations,nOfT);
F1_th=zeros(nOfIterations,nOfT);
SS_th=zeros(nOfIterations,nOfT);
AUC_th=zeros(nOfIterations,1);

TPbuf=zeros(nOfIterations,1);
TNbuf=zeros(nOfIterations,1);
FPbuf=zeros(nOfIterations,1);
FNbuf=zeros(nOfIterations,1);
ACCbuf=zeros(nOfIterations,1);
PPVbuf=zeros(nOfIterations,1);
TPRbuf=zeros(nOfIterations,1);
SPCbuf=zeros(nOfIterations,1);
FPRbuf=zeros(nOfIterations,1);
F1buf=zeros(nOfIterations,1);
SSbuf=zeros(nOfIterations,1);
AUCbuf=zeros(nOfIterations,1);
meanTrAUC=zeros(nOfIterations,1);
stdTrAUC=zeros(nOfIterations,1);
tData=zeros(2,8);

tACC=zeros(2,1);
tPPV=zeros(2,1);
tTPR=zeros(2,1);
tSPC=zeros(2,1);
tFPR=zeros(2,1);
tF1=zeros(2,1);
tTrAUC=zeros(2,1);

tStdACC=zeros(2,1);
tStdPPV=zeros(2,1);
tStdTPR=zeros(2,1);
tStdSPC=zeros(2,1);
tStdFPR=zeros(2,1);
tStdF1=zeros(2,1);
tStdTrAUC=zeros(2,1);

disp('Dogs...');
RSLT=[];

% Work with dogs only
idx=(ITrain<=5);
xDogs=XTrain(idx);
yDogs=Y(idx);
seqDogs=sequence(idx);
xDogsTest=XTest(ITest<=5);
xDogsPi=xDogs(yDogs==1);
xDogsIi=xDogs(yDogs==0);
yDogsPi=yDogs(yDogs==1);
yDogsIi=yDogs(yDogs==0);
avMinXtr=0;
avMaxXtr=0;
for k=1:nOfIterations 
  % Calculate numbers of PI and II for train and test
  idxBuf=1:numel(yDogs);
  piIdx=idxBuf(yDogs==1);
  nOfPi=numel(piIdx);
  nOfPiTrain=round(nOfPi*0.7);
  nOfPiTest=nOfPi-nOfPiTrain;
  iiIdx=idxBuf(yDogs==0);
  nOfIi=numel(iiIdx);
  nOfIiTrain=round(nOfIi*0.7);
  nOfIiTest=nOfIi-nOfIiTrain;
  
  % Divide data on train and test
  piPermIdx=randperm(numel(piIdx));
  iiPermIdx=randperm(numel(iiIdx));
  piTrainIdx=piIdx(piPermIdx(1:nOfPiTrain));
  piTestIdx=piIdx(piPermIdx(nOfPiTrain+1:end));
  iiTrainIdx=iiIdx(iiPermIdx(1:nOfIiTrain));
  iiTestIdx=iiIdx(iiPermIdx(nOfIiTrain+1:end));

  xTrain=[xDogs(piTrainIdx);xDogs(iiTrainIdx)];
  yTrain=[yDogs(piTrainIdx);yDogs(iiTrainIdx)];
  xTest=[xDogs(piTestIdx);xDogs(iiTestIdx)];
  yTest=[yDogs(piTestIdx);yDogs(iiTestIdx)]; 

  % Train to find optimal threshold
  minXtr=min(xTrain);
  avMinXtr=avMinXtr+minXtr;
  maxXtr=max(xTrain);
  avMaxXtr=avMaxXtr+maxXtr;
  medPi=median(xTrain(yTrain==1));
  medIi=median(xTrain(yTrain==0));
  T=minXtr-eps:abs(maxXtr-minXtr)/(nOfT-1):maxXtr;
  xSign=sign(medPi-medIi);
  
  [TP,TN,FP,FN,ACC,PPV,TPR,SPC,FPR,F1,AUC]=perfCurvesTh(yTrain,xTrain,T,xSign);
  SS=2*TPR.*SPC./(TPR+SPC);
  [~,idx]=max(SS);
  optTh=T(idx);
  if (xSign>0)
    RSLT=(xTest>optTh);
  elseif (xSign<0)
    RSLT=(xTest<=optTh);
  end
    
  [~,~,~,~,ACC_th(k,:),PPV_th(k,:),TPR_th(k,:),SPC_th(k,:),FPR_th(k,:),...
    F1_th(k,:),AUC_th(k)]=perfCurvesTh(yTest,xTest,T,xSign);
  [TPbuf(k),TNbuf(k),FPbuf(k),FNbuf(k),ACCbuf(k),PPVbuf(k),TPRbuf(k),...
    SPCbuf(k),FPRbuf(k),F1buf(k)]=estBinClass(yTest,RSLT);  
  figure; hx(1)=subplot(1,2,1); boxplot(xTrain(yTrain==1)); 
  hx(2)=subplot(1,2,2); boxplot(xTrain(yTrain==0));  
%     figure; plot(FPR,TPR,'Linewidth',3); hold on;
%     plot(0:0.01:1,0:0.01:1,'r-.','Linewidth',2); xlabel('FPR'); ylabel('TPR');
%     title({'ROC Curve',['AUC = ',num2str(trAUC(i))]}); grid on;
    
    
%     optThBuf(i)=optTh;
    
%     Y_OVA=[Y_OVA;Y_test_OVA]; 
%   meanTrAUC(k)=mean(trAUC);
%   stdTrAUC(k)=std(trAUC); 
end
avMinXtr=avMinXtr/nOfIterations;
avMaxXtr=avMaxXtr/nOfIterations;
f=plotPerfCurves(ACC_th,PPV_th,TPR_th,SPC_th,FPR_th,F1_th,AUC_th,T);

tACC(1,1)=mean(ACCbuf);
tPPV(1,1)=mean(PPVbuf);
tTPR(1,1)=mean(TPRbuf);
tSPC(1,1)=mean(SPCbuf);
tFPR(1,1)=mean(FPRbuf);
tF1(1,1)=mean(F1buf);
tTrAUC(1,1)=mean(AUC_th);

tStdACC(1,1)=std(ACCbuf);
tStdPPV(1,1)=std(PPVbuf);
tStdTPR(1,1)=std(TPRbuf);
tStdSPC(1,1)=std(SPCbuf);
tStdFPR(1,1)=std(FPRbuf);
tStdF1(1,1)=std(F1buf);
tStdTrAUC(1,1)=mean(stdTrAUC);

% People
disp('People...');
idx=(ITrain>5);
xDogs=XTrain(idx);
yDogs=Y(idx);
seqDogs=sequence(idx);
xDogsTest=XTest(ITest>5);
xDogsPi=xDogs(yDogs==1);
xDogsIi=xDogs(yDogs==0);
yDogsPi=yDogs(yDogs==1);
yDogsIi=yDogs(yDogs==0);
avMinXtr=0;
avMaxXtr=0;
for k=1:nOfIterations 
  % Calculate numbers of PI and II for train and test
  idxBuf=1:numel(yDogs);
  piIdx=idxBuf(yDogs==1);
  nOfPi=numel(piIdx);
  nOfPiTrain=round(nOfPi*0.7);
  nOfPiTest=nOfPi-nOfPiTrain;
  iiIdx=idxBuf(yDogs==0);
  nOfIi=numel(iiIdx);
  nOfIiTrain=round(nOfIi*0.7);
  nOfIiTest=nOfIi-nOfIiTrain;
  
  % Divide data on train and test
  piPermIdx=randperm(numel(piIdx));
  iiPermIdx=randperm(numel(iiIdx));
  piTrainIdx=piIdx(piPermIdx(1:nOfPiTrain));
  piTestIdx=piIdx(piPermIdx(nOfPiTrain+1:end));
  iiTrainIdx=iiIdx(iiPermIdx(1:nOfIiTrain));
  iiTestIdx=iiIdx(iiPermIdx(nOfIiTrain+1:end));

  xTrain=[xDogs(piTrainIdx);xDogs(iiTrainIdx)];
  yTrain=[yDogs(piTrainIdx);yDogs(iiTrainIdx)];
  xTest=[xDogs(piTestIdx);xDogs(iiTestIdx)];
  yTest=[yDogs(piTestIdx);yDogs(iiTestIdx)]; 

  % Train to find optimal threshold
  minXtr=min(xTrain);
  avMinXtr=avMinXtr+minXtr;
  maxXtr=max(xTrain);
  avMaxXtr=avMaxXtr+maxXtr;
  medPi=median(xTrain(yTrain==1));
  medIi=median(xTrain(yTrain==0));
  T=minXtr-eps:abs(maxXtr-minXtr)/(nOfT-1):maxXtr;
  xSign=sign(medPi-medIi);
  
  [TP,TN,FP,FN,ACC,PPV,TPR,SPC,FPR,F1,AUC]=perfCurvesTh(yTrain,xTrain,T,xSign);
  SS=2*TPR.*SPC./(TPR+SPC);
  [~,idx]=max(SS);
  optTh=T(idx);
  if (xSign>0)
    RSLT=(xTest>optTh);
  elseif (xSign<0)
    RSLT=(xTest<=optTh);
  end
    
  [~,~,~,~,ACC_th(k,:),PPV_th(k,:),TPR_th(k,:),SPC_th(k,:),FPR_th(k,:),...
    F1_th(k,:),AUC_th(k)]=perfCurvesTh(yTest,xTest,T,xSign);
  [TPbuf(k),TNbuf(k),FPbuf(k),FNbuf(k),ACCbuf(k),PPVbuf(k),TPRbuf(k),...
    SPCbuf(k),FPRbuf(k),F1buf(k)]=estBinClass(yTest,RSLT);  
    
%     figure; plot(FPR,TPR,'Linewidth',3); hold on;
%     plot(0:0.01:1,0:0.01:1,'r-.','Linewidth',2); xlabel('FPR'); ylabel('TPR');
%     title({'ROC Curve',['AUC = ',num2str(trAUC(i))]}); grid on;
    
    
%     optThBuf(i)=optTh;
    
%     Y_OVA=[Y_OVA;Y_test_OVA]; 
%   meanTrAUC(k)=mean(trAUC);
%   stdTrAUC(k)=std(trAUC); 
end
avMinXtr=avMinXtr/nOfIterations;
avMaxXtr=avMaxXtr/nOfIterations;
f=plotPerfCurves(ACC_th,PPV_th,TPR_th,SPC_th,FPR_th,F1_th,AUC_th,T);

tACC(2,1)=mean(ACCbuf);
tPPV(2,1)=mean(PPVbuf);
tTPR(2,1)=mean(TPRbuf);
tSPC(2,1)=mean(SPCbuf);
tFPR(2,1)=mean(FPRbuf);
tF1(2,1)=mean(F1buf);
tTrAUC(2,1)=mean(AUC_th);

tStdACC(2,1)=std(ACCbuf);
tStdPPV(2,1)=std(PPVbuf);
tStdTPR(2,1)=std(TPRbuf);
tStdSPC(2,1)=std(SPCbuf);
tStdFPR(2,1)=std(FPRbuf);
tStdF1(2,1)=std(F1buf);
tStdTrAUC(2,1)=mean(stdTrAUC);
%---------------------------------

rowNames={'Dogs','People'};
t1=table(tACC,tPPV,tTPR,tSPC,tFPR,tF1,tTrAUC,'RowNames',rowNames,...
  'VariableNames',{'ACC','PPV','TPR','SPC','FPR','F1','Mean_TrainAUC'});
t2=table(tStdACC,tStdPPV,tStdTPR,tStdSPC,tStdFPR,tStdF1,tStdTrAUC,'RowNames',rowNames,...
  'VariableNames',{'Std_ACC','Std_PPV','Std_TPR','Std_SPC','Std_FPR','Std_F1','Std_TrainAUC'});
writetable(t1,'th_Loo_results.xlsx','WriteRowNames',true);
writetable(t2,'th_Loo_results.xlsx','WriteRowNames',true,'Range','A6');
disp('Done.');
