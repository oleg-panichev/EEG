function [t1,t2,meanROCs,meanROCsWght,RSLT]=runIndClassification(data,...
  classifierName,patBuf)

  run('processingProperties.m');

  patNum=numel(patBuf);

  optTh=zeros(patNum,1);
  avTh=zeros(patNum,1);
  ACC=zeros(patNum,1);
  PPV=zeros(patNum,1);
  TPR=zeros(patNum,1);
  SPC=zeros(patNum,1);
  FPR=zeros(patNum,1);
  F1=zeros(patNum,1);
  SS=zeros(patNum,1);
  AUC=zeros(patNum,1);

  optThWght=zeros(patNum,1);
  avThWght=zeros(patNum,1);
  ACCWght=zeros(patNum,1);
  PPVWght=zeros(patNum,1);
  TPRWght=zeros(patNum,1);
  SPCWght=zeros(patNum,1);
  FPRWght=zeros(patNum,1);
  F1Wght=zeros(patNum,1);
  SSWght=zeros(patNum,1);
  AUCWght=zeros(patNum,1);
  XTrainWght=[];
  YWght=[];
  sequenceWght=[];
  ITrainWght=[];

  meanROCs=cell(patNum,1);
  meanROCsWght=cell(patNum,1);

  % Classification for each patient
  RSLT=[];
  for patIdx=1:patNum
    if (runOnTestDataFlag>0)
      X_test=data{patIdx}.X_test;
    else
      X_test=[];
    end
  
    disp(patBuf{patIdx});
    X=data{patIdx}.X;
    Y=data{patIdx}.Y;
    S=data{patIdx}.S;   
    
    X=featureNormalize(X);

    idxPi=(Y==1);
    idxIi=(Y==0);
    xTrainPi=X(idxPi,:);
    xTrainIi=X(idxIi,:);
    yPi=Y(idxPi);
    yIi=Y(idxIi);
    seqPi=S(idxPi);
    seqIi=S(idxIi);
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

    if (strcmpi(classifierName,'threshold'))
      [optTh(patIdx),avTh(patIdx),ACC(patIdx),PPV(patIdx),TPR(patIdx),...
        SPC(patIdx),FPR(patIdx),F1(patIdx),SS(patIdx),AUC(patIdx),...
        meanROCs{patIdx},rslt]=...
        classifierThreshold(X,Y,X_test,S,[patBuf{patIdx}]);
      [optThWght(patIdx),avThWght(patIdx),ACCWght(patIdx),PPVWght(patIdx),...
        TPRWght(patIdx),SPCWght(patIdx),FPRWght(patIdx),F1Wght(patIdx),...
        SSWght(patIdx),AUCWght(patIdx),meanROCsWght{patIdx},~]=classifierThreshold(xTrainWght,yWght,...
        X_test,seqWght,[patBuf{patIdx},', Wght Set']);
    elseif (strcmpi(classifierName,'nbayes'))  
      [avTh(patIdx),ACC(patIdx),PPV(patIdx),TPR(patIdx),...
        SPC(patIdx),FPR(patIdx),F1(patIdx),SS(patIdx),AUC(patIdx),meanROCs{patIdx},rslt]=...
        classifierNaiveBayes(X,Y,X_test);
      [avThWght(patIdx),ACCWght(patIdx),PPVWght(patIdx),...
        TPRWght(patIdx),SPCWght(patIdx),FPRWght(patIdx),F1Wght(patIdx),...
        SSWght(patIdx),AUCWght(patIdx),meanROCsWght{patIdx},~]=...
        classifierNaiveBayes(xTrainWght,yWght,X_test);
    elseif (strcmpi(classifierName,'logit'))  
      [avTh(patIdx),ACC(patIdx),PPV(patIdx),TPR(patIdx),...
        SPC(patIdx),FPR(patIdx),F1(patIdx),SS(patIdx),AUC(patIdx),meanROCs{patIdx},rslt]=...
        classifierLogit(X,Y,X_test);
      [avThWght(patIdx),ACCWght(patIdx),PPVWght(patIdx),...
        TPRWght(patIdx),SPCWght(patIdx),FPRWght(patIdx),F1Wght(patIdx),...
        SSWght(patIdx),AUCWght(patIdx),meanROCsWght{patIdx},~]=...
        classifierLogit(xTrainWght,yWght,X_test);
    elseif (strcmpi(classifierName,'svm')) 
      [avTh(patIdx),ACC(patIdx),PPV(patIdx),TPR(patIdx),...
        SPC(patIdx),FPR(patIdx),F1(patIdx),SS(patIdx),AUC(patIdx),meanROCs{patIdx},rslt]=...
        classifierSVM(X,Y,X_test);
      [avThWght(patIdx),ACCWght(patIdx),PPVWght(patIdx),...
        TPRWght(patIdx),SPCWght(patIdx),FPRWght(patIdx),F1Wght(patIdx),...
        SSWght(patIdx),AUCWght(patIdx),meanROCsWght{patIdx},~]=...
        classifierSVM(xTrainWght,yWght,X_test);   
    elseif (strcmpi(classifierName,'tree')) 
      [avTh(patIdx),ACC(patIdx),PPV(patIdx),TPR(patIdx),...
        SPC(patIdx),FPR(patIdx),F1(patIdx),SS(patIdx),AUC(patIdx),meanROCs{patIdx},rslt]=...
        classifierTree(X,Y,X_test);
      [avThWght(patIdx),ACCWght(patIdx),PPVWght(patIdx),...
        TPRWght(patIdx),SPCWght(patIdx),FPRWght(patIdx),F1Wght(patIdx),...
        SSWght(patIdx),AUCWght(patIdx),meanROCsWght{patIdx},~]=...
        classifierTree(xTrainWght,yWght,X_test);  
    elseif (strcmpi(classifierName,'knn')) 
      [avTh(patIdx),ACC(patIdx),PPV(patIdx),TPR(patIdx),...
        SPC(patIdx),FPR(patIdx),F1(patIdx),SS(patIdx),AUC(patIdx),meanROCs{patIdx},rslt]=...
        classifierKNN(X,Y,X_test);
      [avThWght(patIdx),ACCWght(patIdx),PPVWght(patIdx),...
        TPRWght(patIdx),SPCWght(patIdx),FPRWght(patIdx),F1Wght(patIdx),...
        SSWght(patIdx),AUCWght(patIdx),meanROCsWght{patIdx},~]=...
        classifierKNN(xTrainWght,yWght,X_test);
    elseif (strcmpi(classifierName,'discr')) 
      [avTh(patIdx),ACC(patIdx),PPV(patIdx),TPR(patIdx),...
        SPC(patIdx),FPR(patIdx),F1(patIdx),SS(patIdx),AUC(patIdx),meanROCs{patIdx},rslt]=...
        classifierDiscr(X,Y,X_test);
      [avThWght(patIdx),ACCWght(patIdx),PPVWght(patIdx),...
        TPRWght(patIdx),SPCWght(patIdx),FPRWght(patIdx),F1Wght(patIdx),...
        SSWght(patIdx),AUCWght(patIdx),meanROCsWght{patIdx},~]=...
        classifierDiscr(xTrainWght,yWght,X_test); 
    elseif (strcmpi(classifierName,'treebagger')) 
      [avTh(patIdx),ACC(patIdx),PPV(patIdx),TPR(patIdx),...
        SPC(patIdx),FPR(patIdx),F1(patIdx),SS(patIdx),AUC(patIdx),meanROCs{patIdx},rslt]=...
        classifierTreeBagger(X,Y,X_test);
      [avThWght(patIdx),ACCWght(patIdx),PPVWght(patIdx),...
        TPRWght(patIdx),SPCWght(patIdx),FPRWght(patIdx),F1Wght(patIdx),...
        SSWght(patIdx),AUCWght(patIdx),meanROCsWght{patIdx},~]=...
        classifierTreeBagger(xTrainWght,yWght,X_test); 
    end
    RSLT=[RSLT;rslt];
  %   close all; 
  %   sTree = TreeBagger(1000, trainDog1(:,2:size(trainDog1,2)), trainDog1(:,1), 'options', options);
  end

  % Form result tables
  rowNames=patBuf;
  t1=table(avTh,ACC,PPV,TPR,SPC,F1,SS,AUC,'RowNames',rowNames,...
    'VariableNames',{'Threshold','ACC','PPV','TPR','SPC','F1','SS','AUC'});
  t2=table(avThWght,ACCWght,PPVWght,TPRWght,SPCWght,F1Wght,SSWght,AUCWght,...
    'RowNames',rowNames,...
    'VariableNames',{'Threshold','ACC','PPV','TPR','SPC','F1','SS','AUC'});
end