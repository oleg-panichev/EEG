function [avTh,ACC,PPV,TPR,SPC,FPR,F1,SS,AUC,meanROC,rslt]=...
  classifierDiscr(x,y,xUnknownTest)

  disp(['Discriminant Analysis: ']);
  run('processingProperties.m');
  m=size(x,2);
  N=numel(y);
  
  % Split data on train and test
  idxBuf=1:N;
  piIdx=idxBuf(y==1);
  nOfPi=numel(piIdx);
  nOfPiTrain=round(nOfPi*trainNumCoef);
  nOfPiTest=nOfPi-nOfPiTrain;
  iiIdx=idxBuf(y==0);
  nOfIi=numel(iiIdx);
  nOfIiTrain=round(nOfIi*trainNumCoef);
  nOfIiTest=nOfIi-nOfIiTrain;
  
  % Allocate buffers
  [T]=getThresholds([-1 1],nOfThresholds);
  ACC=zeros(nOfThresholds,nOfIterations);
  PPV=zeros(nOfThresholds,nOfIterations);
  TPR=zeros(nOfThresholds,nOfIterations);
  SPC=zeros(nOfThresholds,nOfIterations);
  FPR=zeros(nOfThresholds,nOfIterations);
  F1=zeros(nOfThresholds,nOfIterations);
  SS=zeros(nOfThresholds,nOfIterations);
  AUC=zeros(nOfThresholds,nOfIterations);
  TP=zeros(nOfThresholds,nOfIterations);
  FP=zeros(nOfThresholds,nOfIterations);
  FN=zeros(nOfThresholds,nOfIterations);
  TN=zeros(nOfThresholds,nOfIterations);
  TP_Test=zeros(nOfIterations,1);
  FP_Test=zeros(nOfIterations,1);
  FN_Test=zeros(nOfIterations,1);
  TN_Test=zeros(nOfIterations,1);
  ACC_Test=zeros(nOfIterations,1);
  PPV_Test=zeros(nOfIterations,1);
  TPR_Test=zeros(nOfIterations,1);
  SPC_Test=zeros(nOfIterations,1);
  FPR_Test=zeros(nOfIterations,1);
  F1_Test=zeros(nOfIterations,1);
  SS_Test=zeros(nOfIterations,1);
  AUC_Test=zeros(nOfIterations,1);
  NTrain=nOfIiTrain+nOfPiTrain;
  thBuf=zeros(nOfIterations,1);
  
  for iter=1:nOfIterations
    piPermIdx=randperm(numel(piIdx));
    iiPermIdx=randperm(numel(iiIdx));
    piTrainIdx=piIdx(piPermIdx(1:nOfPiTrain));
    piTestIdx=piIdx(piPermIdx(nOfPiTrain+1:end));
    iiTrainIdx=iiIdx(iiPermIdx(1:nOfIiTrain));
    iiTestIdx=iiIdx(iiPermIdx(nOfIiTrain+1:end));

    xTrain=[x(piTrainIdx,:);x(iiTrainIdx,:)];
    yTrain=[y(piTrainIdx);y(iiTrainIdx)];
    xTest=[x(piTestIdx,:);x(iiTestIdx,:)];
    yTest=[y(piTestIdx);y(iiTestIdx)]; 

    mdl=fitcdiscr(xTrain,yTrain);
    [~,p]=predict(mdl,xTrain);
    p=p(:,2);
    [TP(:,iter),TN(:,iter),FP(:,iter),FN(:,iter),ACC(:,iter),PPV(:,iter),...
      TPR(:,iter),SPC(:,iter),FPR(:,iter),F1(:,iter),SS(:,iter),~]=...
      perfCurvesTh(yTrain,p,T,1);
    [~,optIdx]=max(SS(:,iter));
    [~,p]=predict(mdl,xTest);
    p=p(:,2);
    res=p>T(optIdx);
    
    [fpr,tpr,~,AUC_Test(iter)]=perfcurve(yTest,p,1);
    FPR(:,iter)=0:1/(nOfThresholds-1):1;
    [fpr,idxSort]=sort(fpr);
    tpr=tpr(idxSort);
    TPR(:,iter)=interp1q(fpr,tpr,FPR(:,iter));
    
    [TP(:,iter),TN(:,iter),FP(:,iter),FN(:,iter),ACC(:,iter),PPV(:,iter),...
      ~,SPC(:,iter),~,F1(:,iter),SS(:,iter),~]=...
      perfCurvesTh(yTest,p,T,1);

    [TP_Test(iter),TN_Test(iter),FP_Test(iter),FN_Test(iter),ACC_Test(iter),...
      PPV_Test(iter),TPR_Test(iter),SPC_Test(iter),FPR_Test(iter),...
      F1_Test(iter),SS_Test(iter)]=estBinClass(yTest,res);
  
    thBuf(iter)=T(optIdx);
  end
  
  meanROC=[mean(FPR,2),mean(TPR,2)];
  
  % Return
  avTh=mean(thBuf);
  ACC=mean(ACC_Test);
  PPV=mean(PPV_Test(~isnan(PPV_Test)));
  TPR=mean(TPR_Test(~isnan(TPR_Test)));
  SPC=mean(SPC_Test(~isnan(SPC_Test)));
  FPR=mean(FPR_Test(~isnan(FPR_Test)));
  F1=mean(F1_Test(~isnan(F1_Test)));
  SS=mean(SS_Test(~isnan(SS_Test)));
  AUC=mean(AUC_Test);
  
  if (numel(xUnknownTest)>0)
    mdl=fitcdiscr(x,y);
    [~,p]=predict(mdl,x);
    p=p(:,2);
    figure
    hist(p,20);
    [~,~,~,~,~,~,~,~,~,~,SS_utest,AUC_utest]=...
      perfCurvesTh(y,p,T,1);
    [~,optIdx]=max(SS_utest);
    disp(['AUC TEST = ',num2str(AUC_utest)]);
    
    [~,p]=predict(mdl,xUnknownTest);
    p=p(:,2);
    figure
    hist(p,20);
    rslt=p>T(optIdx);
    disp(['# of preictals = ',num2str(sum(rslt))]);
  else
    rslt=[];
  end
  
  % Disp
  disp(['Av. th from all iterations: ',num2str(avTh)]);
  disp(['ACC: ',num2str(ACC)]);
  disp(['PPV: ',num2str(PPV)]);
  disp(['TPR: ',num2str(TPR)]);
  disp(['SPC: ',num2str(SPC)]);
  disp(['F1: ',num2str(F1)]);
  disp(['SS: ',num2str(SS)]);
  disp(['AUC: ',num2str(AUC)]);
end