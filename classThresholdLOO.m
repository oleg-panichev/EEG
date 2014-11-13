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
fName='Euc Distance variance';
fName='ChSq Distance mean';
fName='ChSq Distance variance';
fName='MI mean';
fName='MI variance';
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
optTh=zeros(numel(patBuf)+3,1);
avTh=zeros(numel(patBuf)+3,1);

thBuf=zeros(nOfIterations,1);
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

tTh=zeros(2,1);
tACC=zeros(2,1);
tPPV=zeros(2,1);
tTPR=zeros(2,1);
tSPC=zeros(2,1);
tFPR=zeros(2,1);
tF1=zeros(2,1);
tSS=zeros(2,1);
tTrAUC=zeros(2,1);

tStdTh=zeros(2,1);
tStdACC=zeros(2,1);
tStdPPV=zeros(2,1);
tStdTPR=zeros(2,1);
tStdSPC=zeros(2,1);
tStdFPR=zeros(2,1);
tStdF1=zeros(2,1);
tStdSS=zeros(2,1);
tStdTrAUC=zeros(2,1);

disp('Dogs...');
for k=1:nOfIterations
  XTrainWght=[];
  YWght=[];
  sequenceWght=[];
  ITrainWght=[];
  P=[];
  RSLT=[];
  
  for patIdx=1:numel(patBuf)
    % Get data only for current patient
    idx=(ITrain==patIdx);
    xTrain=XTrain(idx,:);
    y=Y(idx);
    seq=sequence(idx);
    xTest=XTest(ITest==patIdx,:);

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
  end

  % Work with dogs only
  idx=(ITrain<=5);
  xDogs=XTrain(idx);
  yDogs=Y(idx);
  seqDogs=sequence(idx);
  xDogsTest=XTest(ITest<=5);

  idx=(ITrainWght<=5);
  xTrainDogsWght=XTrainWght(idx);
  yDogsWght=YWght(idx);
  seqDogsWght=sequenceWght(idx);

  % Leave one out test
  xTrainPi=xTrainDogsWght(yDogsWght==1);
  nOfPi=size(xTrainPi,1);
  xTrainIiWght=xTrainDogsWght(yDogsWght==0);
  yPi=yDogsWght(yDogsWght==1);
  yIiWght=yDogsWght(yDogsWght==0);
  R_LOO=[];
  Y_LOO=[];
  X_tr_LOO=[];
  Y_tr_LOO=[];
  X_test_LOO=[];
  Y_test_LOO=[];
  optThBuf=zeros(nOfPi,1);
  trAUC=zeros(nOfPi,1);
  
  idx=1:nOfPi;
  for i=1:nOfPi   
    X_tr_LOO=[xTrainPi(idx~=i,:);xTrainIiWght(idx~=i,:)];
    X_test_LOO=[xTrainPi(idx==i,:);xTrainIiWght(idx==i,:)];
    Y_tr_LOO=[yPi(idx~=i);yIiWght(idx~=i)];
    Y_test_LOO=[yPi(idx==i);yIiWght(idx==i)];
    
    [T,xSign]=getThresholds(X_tr_LOO,Y_tr_LOO,200);
    
    nb=fitNaiveBayes(X_tr_LOO,Y_tr_LOO);
    p=predict(nb,X_tr_LOO);
    [XX,YY,T,trAUC(i),optTh,~,~]=perfcurve(Y_tr_LOO,p,1);
    [TP,TN,FP,FN,ACC,PPV,TPR,SPC,FPR,F1,SS,~]=perfCurvesTh(Y_tr_LOO,p,T,xSign);
    
%     [TP,TN,FP,FN,ACC,PPV,TPR,SPC,FPR,F1,SS,trAUC(i)]=perfCurvesTh(Y_tr_LOO,X_tr_LOO,T,xSign);

%     f=plotPerfCurves(ACC,PPV,TPR,SPC,FPR,F1,trAUC(i),T);
%     figure; plot(FPR,TPR,'Linewidth',3); hold on;
%     plot(0:0.01:1,0:0.01:1,'r-.','Linewidth',2); xlabel('FPR'); ylabel('TPR');
%     title({'ROC Curve',['AUC = ',num2str(trAUC(i))]}); grid on;
    
% F1=2*XX.*YY./(XX+YY);
    [~,idx]=max(SS);
    optTh=T(idx);
    optThBuf(i)=optTh;
%     if (xSign>0)
%       R_LOO=[R_LOO;(X_test_LOO>=optTh)];
%     elseif (xSign<0)
%       R_LOO=[R_LOO;(X_test_LOO<=optTh)];
%     end
    
    
    p=predict(nb,X_test_LOO);
    R_LOO=[R_LOO;p>optTh];
    Y_LOO=[Y_LOO;Y_test_LOO];
    
  end 
  meanTrAUC(k)=mean(trAUC);
  stdTrAUC(k)=std(trAUC);
  thBuf(k)=mean(optThBuf);
%   figure
%   boxplot([xTrainPi,xTrainIiWght],{'PI','II'}); 
  [TPbuf(k),TNbuf(k),FPbuf(k),FNbuf(k),ACCbuf(k),PPVbuf(k),TPRbuf(k),...
    SPCbuf(k),FPRbuf(k),F1buf(k),SSbuf(k)]=estBinClass(Y_LOO,R_LOO);
end

tACC(1,1)=mean(ACCbuf);
tPPV(1,1)=mean(PPVbuf(~isnan(PPVbuf)));
tTPR(1,1)=mean(TPRbuf);
tSPC(1,1)=mean(SPCbuf);
tFPR(1,1)=mean(FPRbuf);
tF1(1,1)=mean(F1buf(~isnan(F1buf)));
tSS(1,1)=mean(SSbuf);
tTrAUC(1,1)=mean(meanTrAUC);
tTh(1,1)=mean(thBuf);

tStdACC(1,1)=std(ACCbuf);
tStdPPV(1,1)=std(PPVbuf(~isnan(PPVbuf)));
tStdTPR(1,1)=std(TPRbuf);
tStdSPC(1,1)=std(SPCbuf);
tStdFPR(1,1)=std(FPRbuf);
tStdF1(1,1)=std(F1buf(~isnan(F1buf)));
tStdSS(1,1)=std(SSbuf);
tStdTrAUC(1,1)=mean(stdTrAUC);
tStdTh(1,1)=std(thBuf);

% People
disp('People...');
for k=1:nOfIterations
  XTrainWght=[];
  YWght=[];
  sequenceWght=[];
  ITrainWght=[];
  P=[];
  RSLT=[];
  
  for patIdx=1:numel(patBuf)
    % Get data only for current patient
    idx=(ITrain==patIdx);
    xTrain=XTrain(idx,:);
    y=Y(idx);
    seq=sequence(idx);
    xTest=XTest(ITest==patIdx,:);

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
  end

  % Work with dogs only
  idx=(ITrain>5);
  xDogs=XTrain(idx);
  yDogs=Y(idx);
  seqDogs=sequence(idx);
  xDogsTest=XTest(ITest<=5);

  idx=(ITrainWght>5);
  xTrainDogsWght=XTrainWght(idx);
  yDogsWght=YWght(idx);
  seqDogsWght=sequenceWght(idx);

  % Leave one out test
  xTrainPi=xTrainDogsWght(yDogsWght==1);
  nOfPi=size(xTrainPi,1);
  xTrainIiWght=xTrainDogsWght(yDogsWght==0);
  yPi=yDogsWght(yDogsWght==1);
  yIiWght=yDogsWght(yDogsWght==0);
  R_LOO=[];
  Y_LOO=[];
  X_tr_LOO=[];
  Y_tr_LOO=[];
  X_test_LOO=[];
  Y_test_LOO=[];
  optThBuf=zeros(nOfPi,1);
  trAUC=zeros(nOfPi,1);
  for i=1:nOfPi
    idx=1:nOfPi;
    X_tr_LOO=[xTrainPi(idx~=i,:);xTrainIiWght(idx~=i,:)];
    X_test_LOO=[xTrainPi(idx==i,:);xTrainIiWght(idx==i,:)];
    Y_tr_LOO=[yPi(idx~=i);yIiWght(idx~=i)];
    Y_test_LOO=[yPi(idx==i);yIiWght(idx==i)];

    minXtr=min(X_tr_LOO);
    maxXtr=max(X_tr_LOO);
    medPi=median(X_tr_LOO(Y_tr_LOO==1));
    medIi=median(X_tr_LOO(Y_tr_LOO==0));
    T=minXtr:abs(maxXtr-minXtr)/200:maxXtr;
    xSign=sign(medPi-medIi);
    
    nb=fitNaiveBayes(X_tr_LOO,Y_tr_LOO);
    p=predict(nb,X_tr_LOO);
    [XX,YY,T,trAUC(i),optTh,~,~]=perfcurve(Y_tr_LOO,p,1);
    [TP,TN,FP,FN,ACC,PPV,TPR,SPC,FPR,F1,SS,~]=perfCurvesTh(Y_tr_LOO,p,T,xSign);
    
%     [TP,TN,FP,FN,ACC,PPV,TPR,SPC,FPR,F1,SS,trAUC(i)]=perfCurvesTh(Y_tr_LOO,X_tr_LOO,T,xSign);
    
%     figure; plot(FPR,TPR,'Linewidth',3); hold on;
%     plot(0:0.01:1,0:0.01:1,'r-.','Linewidth',2); xlabel('FPR'); ylabel('TPR');
%     title({'ROC Curve',['AUC = ',num2str(trAUC(i))]}); grid on;
    
%     F1=2*TPR.*SPC./(TPR+SPC);
    [~,idx]=max(SS);
    optTh=T(idx);
    optThBuf(i)=optTh;
%     if (xSign>0)
%       R_LOO=[R_LOO;(X_test_LOO>=optTh)];
%     elseif (xSign<0)
%       R_LOO=[R_LOO;(X_test_LOO<=optTh)];
%     end

    p=predict(nb,X_test_LOO);
    R_LOO=[R_LOO;p>optTh];
    Y_LOO=[Y_LOO;Y_test_LOO];
  end 
  meanTrAUC(k)=mean(trAUC);
  stdTrAUC(k)=std(trAUC);
  thBuf(k)=mean(optThBuf);

  [TPbuf(k),TNbuf(k),FPbuf(k),FNbuf(k),ACCbuf(k),PPVbuf(k),TPRbuf(k),...
    SPCbuf(k),FPRbuf(k),F1buf(k),SSbuf(k)]=estBinClass(Y_LOO,R_LOO);
%   if (isnan(PPVbuf(k)) || PPVbuf(k)==0)
%     pause;
%   end
  
%   F1buf(k)=2*TPRbuf(k)*SPCbuf(k)/(TPRbuf(k)+SPCbuf(k));
end

tACC(2,1)=mean(ACCbuf);
tPPV(2,1)=mean(PPVbuf(~isnan(PPVbuf)));
tTPR(2,1)=mean(TPRbuf);
tSPC(2,1)=mean(SPCbuf);
tFPR(2,1)=mean(FPRbuf);
tF1(2,1)=mean(F1buf(~isnan(F1buf)));
tSS(2,1)=mean(SSbuf);
tTrAUC(2,1)=mean(meanTrAUC);
tTh(2,1)=mean(thBuf);

tStdACC(2,1)=std(ACCbuf);
tStdPPV(2,1)=std(PPVbuf(~isnan(PPVbuf)));
tStdTPR(2,1)=std(TPRbuf);
tStdSPC(2,1)=std(SPCbuf);
tStdFPR(2,1)=std(FPRbuf);
tStdF1(2,1)=std(F1buf(~isnan(F1buf)));
tStdSS(2,1)=std(SSbuf);
tStdTrAUC(2,1)=mean(stdTrAUC);
tStdTh(2,1)=std(thBuf);
%---------------------------------

rowNames={'Dogs','People'};
t1=table(tACC,tPPV,tTPR,tSPC,tFPR,tF1,tSS,tTrAUC,tTh,'RowNames',rowNames,...
  'VariableNames',{'ACC','PPV','TPR','SPC','FPR','F1','SS','Mean_TrainAUC','Mean_Th'});
t2=table(tStdACC,tStdPPV,tStdTPR,tStdSPC,tStdFPR,tStdF1,tStdSS,tStdTrAUC,...
  tStdTh,'RowNames',rowNames,'VariableNames',{'Std_ACC','Std_PPV','Std_TPR',...
  'Std_SPC','Std_FPR','Std_F1','Std_SS','Std_TrainAUC','Std_Th'});
writetable(t1,'th_Loo_results.xlsx','WriteRowNames',true);
writetable(t2,'th_Loo_results.xlsx','WriteRowNames',true,'Range','A6');
disp('Done.');
