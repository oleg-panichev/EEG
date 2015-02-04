function runNonPatSpecificClassification(propertiesFunction,X,Y,classifierName)
  propertiesFunction();
  
  [T]=getThresholds([0 1],nOfThresholds);
  
  % Train set results
  TP_th_tr=zeros(nOfThresholds,nOfIterations);
  TN_th_tr=zeros(nOfThresholds,nOfIterations);
  FP_th_tr=zeros(nOfThresholds,nOfIterations);
  FN_th_tr=zeros(nOfThresholds,nOfIterations);
  ACC_th_tr=zeros(nOfThresholds,nOfIterations);
  PPV_th_tr=zeros(nOfThresholds,nOfIterations);
  TPR_th_tr=zeros(nOfThresholds,nOfIterations);
  SPC_th_tr=zeros(nOfThresholds,nOfIterations);
  FPR_th_tr=zeros(nOfThresholds,nOfIterations);
  F1_th_tr=zeros(nOfThresholds,nOfIterations);
  SS_th_tr=zeros(nOfThresholds,nOfIterations);
  
  TH_tr=zeros(1,nOfIterations); % Optimal threshold based on train results
  TP_tr=zeros(1,nOfIterations);
  TN_tr=zeros(1,nOfIterations);
  FP_tr=zeros(1,nOfIterations);
  FN_tr=zeros(1,nOfIterations);
  ACC_tr=zeros(1,nOfIterations);
  PPV_tr=zeros(1,nOfIterations);
  TPR_tr=zeros(1,nOfIterations);
  SPC_tr=zeros(1,nOfIterations);
  FPR_tr=zeros(1,nOfIterations);
  F1_tr=zeros(1,nOfIterations);
  SS_tr=zeros(1,nOfIterations);
  
  % CV set results
  TP_th_cv=zeros(nOfThresholds,nOfIterations);
  TN_th_cv=zeros(nOfThresholds,nOfIterations);
  FP_th_cv=zeros(nOfThresholds,nOfIterations);
  FN_th_cv=zeros(nOfThresholds,nOfIterations);
  ACC_th_cv=zeros(nOfThresholds,nOfIterations);
  PPV_th_cv=zeros(nOfThresholds,nOfIterations);
  TPR_th_cv=zeros(nOfThresholds,nOfIterations);
  SPC_th_cv=zeros(nOfThresholds,nOfIterations);
  FPR_th_cv=zeros(nOfThresholds,nOfIterations);
  F1_th_cv=zeros(nOfThresholds,nOfIterations);
  SS_th_cv=zeros(nOfThresholds,nOfIterations);
  
  TH_cv=zeros(1,nOfIterations); % Optimal threshold based on CV results
  TP_cv=zeros(1,nOfIterations);
  TN_cv=zeros(1,nOfIterations);
  FP_cv=zeros(1,nOfIterations);
  FN_cv=zeros(1,nOfIterations);
  ACC_cv=zeros(1,nOfIterations);
  PPV_cv=zeros(1,nOfIterations);
  TPR_cv=zeros(1,nOfIterations);
  SPC_cv=zeros(1,nOfIterations);
  FPR_cv=zeros(1,nOfIterations);
  F1_cv=zeros(1,nOfIterations);
  SS_cv=zeros(1,nOfIterations);
  
  % Test set results
  TP_th_ts=zeros(nOfThresholds,nOfIterations);
  TN_th_ts=zeros(nOfThresholds,nOfIterations);
  FP_th_ts=zeros(nOfThresholds,nOfIterations);
  FN_th_ts=zeros(nOfThresholds,nOfIterations);
  ACC_th_ts=zeros(nOfThresholds,nOfIterations);
  PPV_th_ts=zeros(nOfThresholds,nOfIterations);
  TPR_th_ts=zeros(nOfThresholds,nOfIterations);
  SPC_th_ts=zeros(nOfThresholds,nOfIterations);
  FPR_th_ts=zeros(nOfThresholds,nOfIterations);
  F1_th_ts=zeros(nOfThresholds,nOfIterations);
  SS_th_ts=zeros(nOfThresholds,nOfIterations);
  
  TH_ts=zeros(1,nOfIterations); % Optimal threshold based on test results
  TP_ts=zeros(1,nOfIterations);
  TN_ts=zeros(1,nOfIterations);
  FP_ts=zeros(1,nOfIterations);
  FN_ts=zeros(1,nOfIterations);
  ACC_ts=zeros(1,nOfIterations);
  PPV_ts=zeros(1,nOfIterations);
  TPR_ts=zeros(1,nOfIterations);
  SPC_ts=zeros(1,nOfIterations);
  FPR_ts=zeros(1,nOfIterations);
  F1_ts=zeros(1,nOfIterations);
  SS_ts=zeros(1,nOfIterations);
  
  
  for iteration=1:nOfIterations
    % Split data on train, cv and test sets
    [X_tr,X_cv,X_ts,Y_tr,Y_cv,Y_ts,PID_tr,PID_cv,PID_ts]=...
      divideDataOnTrainCvTest(X,Y,PID);
    
    if (strcmpi(classifierName,'nbayes'))
      
      % Train model
      mdl=fitNaiveBayes(X_tr,Y_tr);
      p=posterior(mdl,X_tr);
      p=p(:,2);
      
      % Performance curves on train data
      [TP(:,iteration),TN(:,iteration),FP(:,iteration),FN(:,iteration),...
        ACC(:,iteration),PPV(:,iteration),TPR(:,iteration),SPC(:,iteration),...
        FPR(:,iteration),F1(:,iteration),SS(:,iteration),~]=...
        perfCurvesTh(Y_tr,p,T,1);
      
      % Selecting optimal threshold based on SS-score
      [~,optIdx]=max(SS(:,iteration));
      
      % Obtaining results for CV set
      p=posterior(mdl,X_cv);
      p=p(:,2);
      res=predict(mdl,X_cv);
      
      % Estimating results for CV set
      [fpr,tpr,~,AUC_Test(iteration)]=perfcurve(Y_cv,p,1);
      
      % Interpolating FRP to average ROCs
      FPR(:,iter)=0:1/(nOfThresholds-1):1;
      [fpr,idxSort]=sort(fpr);
      tpr=tpr(idxSort);
      TPR(:,iteration)=interp1q(fpr,tpr,FPR(:,iteration));

      % Obtaining results for Test set
      p=posterior(mdl,X_tr);
      p=p(:,2);
      res=predict(mdl,X_tr);
      
      [TP(:,iteration),TN(:,iteration),FP(:,iteration),FN(:,iteration),...
        ACC(:,iteration),PPV(:,iteration),~,SPC(:,iteration),~,F1(:,iteration),...
        SS(:,iteration),~]=perfCurvesTh(yTest,p,T,1);

      [TP_Test(iteration),TN_Test(iteration),FP_Test(iteration),FN_Test(iteration),ACC_Test(iteration),...
        PPV_Test(iteration),TPR_Test(iteration),SPC_Test(iteration),FPR_Test(iteration),...
        F1_Test(iteration),SS_Test(iteration)]=estBinClass(yTest,res);
    end
  end
  
end