function [t1,t2,meanROCs,meanROCsWght,RSLT]=runClassification(XTrain,Y,...
  XTest,ITrain,ITest,sequence,classifierName,patBuf)

  optTh=zeros(numel(patBuf)+3,1);
  avTh=zeros(numel(patBuf)+3,1);
  ACC=zeros(numel(patBuf)+3,1);
  PPV=zeros(numel(patBuf)+3,1);
  TPR=zeros(numel(patBuf)+3,1);
  SPC=zeros(numel(patBuf)+3,1);
  FPR=zeros(numel(patBuf)+3,1);
  F1=zeros(numel(patBuf)+3,1);
  SS=zeros(numel(patBuf)+3,1);
  AUC=zeros(numel(patBuf)+3,1);

  optThWght=zeros(numel(patBuf)+3,1);
  avThWght=zeros(numel(patBuf)+3,1);
  ACCWght=zeros(numel(patBuf)+3,1);
  PPVWght=zeros(numel(patBuf)+3,1);
  TPRWght=zeros(numel(patBuf)+3,1);
  SPCWght=zeros(numel(patBuf)+3,1);
  FPRWght=zeros(numel(patBuf)+3,1);
  F1Wght=zeros(numel(patBuf)+3,1);
  SSWght=zeros(numel(patBuf)+3,1);
  AUCWght=zeros(numel(patBuf)+3,1);
  XTrainWght=[];
  YWght=[];
  sequenceWght=[];
  ITrainWght=[];

  meanROCs=cell(10,1);
  meanROCsWght=cell(10,1);

  % Classification for each patient
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

    if (strcmpi(classifierName,'threshold'))
      [optTh(patIdx),avTh(patIdx),ACC(patIdx),PPV(patIdx),TPR(patIdx),...
        SPC(patIdx),FPR(patIdx),F1(patIdx),SS(patIdx),AUC(patIdx),...
        meanROCs{patIdx},rslt]=...
        classifierThreshold(xTrain,y,XTest,seq,[patBuf{patIdx}]);
      [optThWght(patIdx),avThWght(patIdx),ACCWght(patIdx),PPVWght(patIdx),...
        TPRWght(patIdx),SPCWght(patIdx),FPRWght(patIdx),F1Wght(patIdx),...
        SSWght(patIdx),AUCWght(patIdx),meanROCsWght{patIdx},~]=classifierThreshold(xTrainWght,yWght,...
        XTest,seqWght,[patBuf{patIdx},', Wght Set']);
    elseif (strcmpi(classifierName,'nbayes'))  
      [avTh(patIdx),ACC(patIdx),PPV(patIdx),TPR(patIdx),...
        SPC(patIdx),FPR(patIdx),F1(patIdx),SS(patIdx),AUC(patIdx),meanROCs{patIdx},rslt]=...
        classifierNaiveBayes(xTrain,y,XTest);
      [avThWght(patIdx),ACCWght(patIdx),PPVWght(patIdx),...
        TPRWght(patIdx),SPCWght(patIdx),FPRWght(patIdx),F1Wght(patIdx),...
        SSWght(patIdx),meanROCsWght{patIdx},AUCWght(patIdx),~]=...
        classifierNaiveBayes(xTrainWght,yWght,XTest);
    elseif (strcmpi(classifierName,'logit'))  

    end
    RSLT=[RSLT;rslt];
  %   close all; 
  %   sTree = TreeBagger(1000, trainDog1(:,2:size(trainDog1,2)), trainDog1(:,1), 'options', options);
  end

  % Work with dogs only
  idx=(ITrain<=5);
  xTrain=XTrain(idx);
  y=Y(idx);
  seq=sequence(idx);
  xTest=XTest(ITest<=5);

  idx=(ITrainWght<=5);
  xTrainWght=XTrainWght(idx);
  yWght=YWght(idx);
  seqWght=sequenceWght(idx);

  patIdx=8;
  if (strcmpi(classifierName,'threshold'))
    [optTh(patIdx),avTh(patIdx),ACC(patIdx),PPV(patIdx),TPR(patIdx),...
      SPC(patIdx),FPR(patIdx),F1(patIdx),SS(patIdx),AUC(patIdx),meanROCs{patIdx},~]=...
      classifierThreshold(xTrain,y,[],seq,['All Dogs']);
    [optThWght(patIdx),avThWght(patIdx),ACCWght(patIdx),PPVWght(patIdx),...
      TPRWght(patIdx),SPCWght(patIdx),FPRWght(patIdx),F1Wght(patIdx),...
      SSWght(patIdx),AUCWght(patIdx),meanROCsWght{patIdx},~]=classifierThreshold(xTrainWght,yWght,...
      [],seqWght,['All Dogs, Wght Set']);
  elseif (strcmpi(classifierName,'nbayes'))  
    [avTh(patIdx),ACC(patIdx),PPV(patIdx),TPR(patIdx),...
      SPC(patIdx),FPR(patIdx),F1(patIdx),SS(patIdx),meanROCs{patIdx},AUC(patIdx),~]=...
      classifierNaiveBayes(xTrain,y,[]);
    [avThWght(patIdx),ACCWght(patIdx),PPVWght(patIdx),...
      TPRWght(patIdx),SPCWght(patIdx),FPRWght(patIdx),F1Wght(patIdx),...
      SSWght(patIdx),meanROCsWght{patIdx},AUCWght(patIdx),~]=...
      classifierNaiveBayes(xTrainWght,yWght,[]);
  elseif (strcmpi(classifierName,'logit'))  

  end

  % Work with patients only
  idx=(ITrain>=6);
  xTrain=XTrain(idx);
  y=Y(idx);
  seq=sequence(idx);
  xTest=XTest(ITest>=6);

  idx=(ITrainWght>=6);
  xTrainWght=XTrainWght(idx);
  yWght=YWght(idx);
  seqWght=sequenceWght(idx);

  patIdx=9;
  if (strcmpi(classifierName,'threshold'))
    [optTh(patIdx),avTh(patIdx),ACC(patIdx),PPV(patIdx),TPR(patIdx),...
      SPC(patIdx),FPR(patIdx),F1(patIdx),SS(patIdx),AUC(patIdx),meanROCs{patIdx},~]=...
      classifierThreshold(xTrain,y,[],seq,['All People']);
    [optThWght(patIdx),avThWght(patIdx),ACCWght(patIdx),PPVWght(patIdx),...
      TPRWght(patIdx),SPCWght(patIdx),FPRWght(patIdx),F1Wght(patIdx),...
      SSWght(patIdx),AUCWght(patIdx),meanROCsWght{patIdx},~]=classifierThreshold(xTrainWght,yWght,...
      [],seqWght,['All People, Wght Set']);
  elseif (strcmpi(classifierName,'nbayes'))  
    [avTh(patIdx),ACC(patIdx),PPV(patIdx),TPR(patIdx),...
      SPC(patIdx),FPR(patIdx),F1(patIdx),SS(patIdx),AUC(patIdx),meanROCs{patIdx},~]=...
      classifierNaiveBayes(xTrain,y,[]);
    [avThWght(patIdx),ACCWght(patIdx),PPVWght(patIdx),...
      TPRWght(patIdx),SPCWght(patIdx),FPRWght(patIdx),F1Wght(patIdx),...
      SSWght(patIdx),meanROCsWght{patIdx},AUCWght(patIdx),~]=...
      classifierNaiveBayes(xTrainWght,yWght,[]);
  elseif (strcmpi(classifierName,'logit'))  

  end

  % Work with all
  patIdx=10;
  if (strcmpi(classifierName,'threshold'))
    [optTh(patIdx),avTh(patIdx),ACC(patIdx),PPV(patIdx),TPR(patIdx),...
      SPC(patIdx),FPR(patIdx),F1(patIdx),SS(patIdx),AUC(patIdx),meanROCs{patIdx},~]=...
      classifierThreshold(XTrain,Y,[],sequence,['Dogs and people']);
    [optThWght(patIdx),avThWght(patIdx),ACCWght(patIdx),PPVWght(patIdx),...
      TPRWght(patIdx),SPCWght(patIdx),FPRWght(patIdx),F1Wght(patIdx),...
      SSWght(patIdx),AUCWght(patIdx),meanROCsWght{patIdx},~]=classifierThreshold(XTrainWght,YWght,...
      [],seqWght,['Dogs and people, Wght Set']);
  elseif (strcmpi(classifierName,'nbayes'))  
    [avTh(patIdx),ACC(patIdx),PPV(patIdx),TPR(patIdx),...
      SPC(patIdx),FPR(patIdx),F1(patIdx),SS(patIdx),AUC(patIdx),meanROCs{patIdx},~]=...
      classifierNaiveBayes(XTrain,Y,[]);
    [avThWght(patIdx),ACCWght(patIdx),PPVWght(patIdx),...
      TPRWght(patIdx),SPCWght(patIdx),FPRWght(patIdx),F1Wght(patIdx),...
      SSWght(patIdx),meanROCsWght{patIdx},AUCWght(patIdx),~]=...
      classifierThreshold(XTrainWght,YWght,[]);
  elseif (strcmpi(classifierName,'logit'))  

  end

  % Form result tables
  rowNames=[patBuf,{'Dogs','Patients','All'}];
  t1=table(avTh,ACC,PPV,TPR,SPC,F1,SS,AUC,'RowNames',rowNames,...
    'VariableNames',{'Threshold','ACC','PPV','TPR','SPC','F1','SS','AUC'});
  t2=table(avThWght,ACCWght,PPVWght,TPRWght,SPCWght,F1Wght,SSWght,AUCWght,...
    'RowNames',rowNames,...
    'VariableNames',{'Threshold','ACC','PPV','TPR','SPC','F1','SS','AUC'});
end