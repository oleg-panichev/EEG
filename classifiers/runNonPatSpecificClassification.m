function S=runNonPatSpecificClassification(propertiesFunction,X,Y,classifierName)
  propertiesFunction();
  
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
  
  AUC_tr=zeros(1,nOfIterations);
  TPR_ROC_tr=zeros(nOfThresholds,nOfIterations);
  FPR_ROC_tr=zeros(nOfThresholds,nOfIterations);
  
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
  
  AUC_cv=zeros(1,nOfIterations);
  TPR_ROC_cv=zeros(nOfThresholds,nOfIterations);
  FPR_ROC_cv=zeros(nOfThresholds,nOfIterations);
  
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
  
  AUC_ts=zeros(1,nOfIterations);
  TPR_ROC_ts=zeros(nOfThresholds,nOfIterations);
  FPR_ROC_ts=zeros(nOfThresholds,nOfIterations);
  
  for iteration=1:nOfIterations
    % Split data on train, cv and test sets
    [X_tr,X_cv,X_ts,Y_tr,Y_cv,Y_ts,PID_tr,PID_cv,PID_ts]=...
      divideDataOnTrainCvTest(X,Y,PID);
    
    if (strcmpi(classifierName,'nbayes'))      
      % Train model
      mdl=fitNaiveBayes(X_tr,Y_tr);
      p=posterior(mdl,X_tr);
      p=p(:,2);
      
      [T]=getThresholds([0 1],nOfThresholds);
      
      % Performance curves on train data
      [TP_th_tr(:,iteration),TN_th_tr(:,iteration),FP_th_tr(:,iteration),FN_th_tr(:,iteration),...
        ACC_th_tr(:,iteration),PPV_th_tr(:,iteration),TPR_th_tr(:,iteration),SPC_th_tr(:,iteration),...
        FPR_th_tr(:,iteration),F1_th_tr(:,iteration),SS_th_tr(:,iteration),AUC_tr(iteration)]=...
        perfCurvesTh(Y_tr,p,T,1);
      
      % Interpolating FRP to average ROCs
      FPR_ROC_tr(:,iteration)=0:1/(nOfThresholds-1):1;
      [fpr,idxSort]=sort(FPR_tr(:,iteration));
      tpr=TPR_tr(idxSort,iteration);
      TPR_ROC_tr(:,iteration)=interp1q(fpr,tpr,FPR_ROC_tr);
      
      % Selecting optimal threshold based on SS-score
      [~,optIdx]=max(SS_tr(:,iteration));
      TH_tr(iteration)=T(optIdx);
      
      % Reluts with optimal threshold
%       RSLT_tr=predict(mdl,X_tr);
      RSLT_tr=p>T(optIdx);
      
      % Results for train set with optimal threshold
      [TP_tr(iteration),TN_tr(iteration),FP_tr(iteration),FN_tr(iteration),...
        ACC_tr(iteration),PPV_tr(iteration),TPR_tr(iteration),SPC_tr(iteration),...
        FPR_tr(iteration),F1_tr(iteration),SS_tr(iteration)]=estBinClass(Y_tr,RSLT_tr);
      
      % Obtaining results for CV set
      p=posterior(mdl,X_cv);
      p=p(:,2);
      
      % Performance curves on CV data
      [TP_th_cv(:,iteration),TN_th_cv(:,iteration),FP_th_cv(:,iteration),FN_th_cv(:,iteration),...
        ACC_th_cv(:,iteration),PPV_th_cv(:,iteration),TPR_th_cv(:,iteration),SPC_th_cv(:,iteration),...
        FPR_th_cv(:,iteration),F1_th_cv(:,iteration),SS_th_cv(:,iteration),AUC_cv(iteration)]=...
        perfCurvesTh(Y_cv,p,T,1);
      
      % Interpolating FRP to average ROCs
      FPR_ROC_cv(:,iteration)=0:1/(nOfThresholds-1):1;
      [fpr,idxSort]=sort(FPR_cv(:,iteration));
      tpr=TPR_cv(idxSort,iteration);
      TPR_ROC_cv(:,iteration)=interp1q(fpr,tpr,FPR_ROC_cv(:,iteration));
      
      % Selecting optimal threshold based on SS-score
      [~,optIdx]=max(SS_cv(:,iteration));
      TH_cv(iteration)=T(optIdx);
      
      % Reluts with optimal threshold
%       RSLT_cv=predict(mdl,X_cv);
      RSLT_cv=p>T(optIdx);
      
      % Results for CV set with optimal threshold
      [TP_cv(iteration),TN_cv(iteration),FP_cv(iteration),FN_cv(iteration),...
        ACC_cv(iteration),PPV_cv(iteration),TPR_cv(iteration),SPC_cv(iteration),...
        FPR_cv(iteration),F1_cv(iteration),SS_cv(iteration)]=estBinClass(Y_cv,RSLT_cv);

      % Obtaining results for Test set
      p=posterior(mdl,X_ts);
      p=p(:,2);
      
      % Performance curves on train data
      [TP_th_ts(:,iteration),TN_th_ts(:,iteration),FP_th_ts(:,iteration),FN_th_ts(:,iteration),...
        ACC_th_ts(:,iteration),PPV_th_ts(:,iteration),TPR_th_ts(:,iteration),SPC_th_ts(:,iteration),...
        FPR_th_ts(:,iteration),F1_th_ts(:,iteration),SS_th_ts(:,iteration),AUC_ts(iteration)]=...
        perfCurvesTh(Y_ts,p,T,1);
      
      % Interpolating FRP to average ROCs
      FPR_ROC_ts(:,iteration)=0:1/(nOfThresholds-1):1;
      [fpr,idxSort]=sort(FPR_ts(:,iteration));
      tpr=TPR_ts(idxSort,iteration);
      TPR_ROC_ts(:,iteration)=interp1q(fpr,tpr,FPR_ROC_ts(:,iteration));
      
      % Selecting optimal threshold based on SS-score
      [~,optIdx]=max(SS_ts(:,iteration));
      TH_ts(iteration)=T(optIdx);
      
      % Reluts with optimal threshold
%       RSLT_ts=predict(mdl,X_ts);
      RSLT_ts=p>T(optIdx);

      % Results for CV set with optimal threshold
      [TP_ts(iteration),TN_ts(iteration),FP_ts(iteration),FN_ts(iteration),...
        ACC_ts(iteration),PPV_ts(iteration),TPR_ts(iteration),SPC_ts(iteration),...
        FPR_ts(iteration),F1_ts(iteration),SS_ts(iteration)]=estBinClass(Y_ts,RSLT_ts);
    elseif (strcmpi(classifierName,'logit'))
      % Train model
      mdl=fitglm(X_tr,Y_tr,'Distribution','binomial');
      p=predict(mdl,X_tr);
      
      [T]=getThresholds([0 1],nOfThresholds);
      
      % Performance curves on train data
      [TP_th_tr(:,iteration),TN_th_tr(:,iteration),FP_th_tr(:,iteration),FN_th_tr(:,iteration),...
        ACC_th_tr(:,iteration),PPV_th_tr(:,iteration),TPR_th_tr(:,iteration),SPC_th_tr(:,iteration),...
        FPR_th_tr(:,iteration),F1_th_tr(:,iteration),SS_th_tr(:,iteration),AUC_tr(iteration)]=...
        perfCurvesTh(Y_tr,p,T,1);
      
      % Interpolating FRP to average ROCs
      FPR_ROC_tr(:,iteration)=0:1/(nOfThresholds-1):1;
      [fpr,idxSort]=sort(FPR_tr(:,iteration));
      tpr=TPR_tr(idxSort,iteration);
      TPR_ROC_tr(:,iteration)=interp1q(fpr,tpr,FPR_ROC_tr);
      
      % Selecting optimal threshold based on SS-score
      [~,optIdx]=max(SS_tr(:,iteration));
      TH_tr(iteration)=T(optIdx);
      
      % Reluts with optimal threshold
      RSLT_tr=p>T(optIdx);
      
      % Results for train set with optimal threshold
      [TP_tr(iteration),TN_tr(iteration),FP_tr(iteration),FN_tr(iteration),...
        ACC_tr(iteration),PPV_tr(iteration),TPR_tr(iteration),SPC_tr(iteration),...
        FPR_tr(iteration),F1_tr(iteration),SS_tr(iteration)]=estBinClass(Y_tr,RSLT_tr);
      
      % Obtaining results for CV set
      p=predict(mdl,X_cv);
      
      % Performance curves on CV data
      [TP_th_cv(:,iteration),TN_th_cv(:,iteration),FP_th_cv(:,iteration),FN_th_cv(:,iteration),...
        ACC_th_cv(:,iteration),PPV_th_cv(:,iteration),TPR_th_cv(:,iteration),SPC_th_cv(:,iteration),...
        FPR_th_cv(:,iteration),F1_th_cv(:,iteration),SS_th_cv(:,iteration),AUC_cv(iteration)]=...
        perfCurvesTh(Y_cv,p,T,1);
      
      % Interpolating FRP to average ROCs
      FPR_ROC_cv(:,iteration)=0:1/(nOfThresholds-1):1;
      [fpr,idxSort]=sort(FPR_cv(:,iteration));
      tpr=TPR_cv(idxSort,iteration);
      TPR_ROC_cv(:,iteration)=interp1q(fpr,tpr,FPR_ROC_cv(:,iteration));
      
      % Selecting optimal threshold based on SS-score
      [~,optIdx]=max(SS_cv(:,iteration));
      TH_cv(iteration)=T(optIdx);
      
      % Reluts with optimal threshold
      RSLT_cv=p>T(optIdx);
      
      % Results for CV set with optimal threshold
      [TP_cv(iteration),TN_cv(iteration),FP_cv(iteration),FN_cv(iteration),...
        ACC_cv(iteration),PPV_cv(iteration),TPR_cv(iteration),SPC_cv(iteration),...
        FPR_cv(iteration),F1_cv(iteration),SS_cv(iteration)]=estBinClass(Y_cv,RSLT_cv);

      % Obtaining results for Test set
      p=predict(mdl,X_ts);
      
      % Performance curves on train data
      [TP_th_ts(:,iteration),TN_th_ts(:,iteration),FP_th_ts(:,iteration),FN_th_ts(:,iteration),...
        ACC_th_ts(:,iteration),PPV_th_ts(:,iteration),TPR_th_ts(:,iteration),SPC_th_ts(:,iteration),...
        FPR_th_ts(:,iteration),F1_th_ts(:,iteration),SS_th_ts(:,iteration),AUC_ts(iteration)]=...
        perfCurvesTh(Y_ts,p,T,1);
      
      % Interpolating FRP to average ROCs
      FPR_ROC_ts(:,iteration)=0:1/(nOfThresholds-1):1;
      [fpr,idxSort]=sort(FPR_ts(:,iteration));
      tpr=TPR_ts(idxSort,iteration);
      TPR_ROC_ts(:,iteration)=interp1q(fpr,tpr,FPR_ROC_ts(:,iteration));
      
      % Selecting optimal threshold based on SS-score
      [~,optIdx]=max(SS_ts(:,iteration));
      TH_ts(iteration)=T(optIdx);
      
      % Reluts with optimal threshold
      RSLT_ts=p>T(optIdx);

      % Results for CV set with optimal threshold
      [TP_ts(iteration),TN_ts(iteration),FP_ts(iteration),FN_ts(iteration),...
        ACC_ts(iteration),PPV_ts(iteration),TPR_ts(iteration),SPC_ts(iteration),...
        FPR_ts(iteration),F1_ts(iteration),SS_ts(iteration)]=estBinClass(Y_ts,RSLT_ts);
    elseif (strcmpi(classifierName,'svm'))
      % Train model
      mdl=fitcsvm(X_tr,Y_tr);
      [~,p]=predict(mdl,X_tr);
      p=p(:,2);
      
      [T]=getThresholds(p,nOfThresholds);
      
      % Performance curves on train data
      [TP_th_tr(:,iteration),TN_th_tr(:,iteration),FP_th_tr(:,iteration),FN_th_tr(:,iteration),...
        ACC_th_tr(:,iteration),PPV_th_tr(:,iteration),TPR_th_tr(:,iteration),SPC_th_tr(:,iteration),...
        FPR_th_tr(:,iteration),F1_th_tr(:,iteration),SS_th_tr(:,iteration),AUC_tr(iteration)]=...
        perfCurvesTh(Y_tr,p,T,1);
      
      % Interpolating FRP to average ROCs
      FPR_ROC_tr(:,iteration)=0:1/(nOfThresholds-1):1;
      [fpr,idxSort]=sort(FPR_tr(:,iteration));
      tpr=TPR_tr(idxSort,iteration);
      TPR_ROC_tr(:,iteration)=interp1q(fpr,tpr,FPR_ROC_tr);
      
      % Selecting optimal threshold based on SS-score
      [~,optIdx]=max(SS_tr(:,iteration));
      TH_tr(iteration)=T(optIdx);
      
      % Reluts with optimal threshold
%       RSLT_tr=predict(mdl,X_tr);
      RSLT_tr=p>T(optIdx);
      
      % Results for train set with optimal threshold
      [TP_tr(iteration),TN_tr(iteration),FP_tr(iteration),FN_tr(iteration),...
        ACC_tr(iteration),PPV_tr(iteration),TPR_tr(iteration),SPC_tr(iteration),...
        FPR_tr(iteration),F1_tr(iteration),SS_tr(iteration)]=estBinClass(Y_tr,RSLT_tr);
      
      % Obtaining results for CV set
      [~,p]=predict(mdl,X_cv);
      p=p(:,2);
      
      % Performance curves on CV data
      [TP_th_cv(:,iteration),TN_th_cv(:,iteration),FP_th_cv(:,iteration),FN_th_cv(:,iteration),...
        ACC_th_cv(:,iteration),PPV_th_cv(:,iteration),TPR_th_cv(:,iteration),SPC_th_cv(:,iteration),...
        FPR_th_cv(:,iteration),F1_th_cv(:,iteration),SS_th_cv(:,iteration),AUC_cv(iteration)]=...
        perfCurvesTh(Y_cv,p,T,1);
      
      % Interpolating FRP to average ROCs
      FPR_ROC_cv(:,iteration)=0:1/(nOfThresholds-1):1;
      [fpr,idxSort]=sort(FPR_cv(:,iteration));
      tpr=TPR_cv(idxSort,iteration);
      TPR_ROC_cv(:,iteration)=interp1q(fpr,tpr,FPR_ROC_cv(:,iteration));
      
      % Selecting optimal threshold based on SS-score
      [~,optIdx]=max(SS_cv(:,iteration));
      TH_cv(iteration)=T(optIdx);
      
      % Reluts with optimal threshold
%       RSLT_cv=predict(mdl,X_cv);
      RSLT_cv=p>T(optIdx);
      
      % Results for CV set with optimal threshold
      [TP_cv(iteration),TN_cv(iteration),FP_cv(iteration),FN_cv(iteration),...
        ACC_cv(iteration),PPV_cv(iteration),TPR_cv(iteration),SPC_cv(iteration),...
        FPR_cv(iteration),F1_cv(iteration),SS_cv(iteration)]=estBinClass(Y_cv,RSLT_cv);

      % Obtaining results for Test set
      [~,p]=predict(mdl,X_ts);
      p=p(:,2);
      
      % Performance curves on train data
      [TP_th_ts(:,iteration),TN_th_ts(:,iteration),FP_th_ts(:,iteration),FN_th_ts(:,iteration),...
        ACC_th_ts(:,iteration),PPV_th_ts(:,iteration),TPR_th_ts(:,iteration),SPC_th_ts(:,iteration),...
        FPR_th_ts(:,iteration),F1_th_ts(:,iteration),SS_th_ts(:,iteration),AUC_ts(iteration)]=...
        perfCurvesTh(Y_ts,p,T,1);
      
      % Interpolating FRP to average ROCs
      FPR_ROC_ts(:,iteration)=0:1/(nOfThresholds-1):1;
      [fpr,idxSort]=sort(FPR_ts(:,iteration));
      tpr=TPR_ts(idxSort,iteration);
      TPR_ROC_ts(:,iteration)=interp1q(fpr,tpr,FPR_ROC_ts(:,iteration));
      
      % Selecting optimal threshold based on SS-score
      [~,optIdx]=max(SS_ts(:,iteration));
      TH_ts(iteration)=T(optIdx);
      
      % Reluts with optimal threshold
%       RSLT_ts=predict(mdl,X_ts);
      RSLT_ts=p>T(optIdx);

      % Results for CV set with optimal threshold
      [TP_ts(iteration),TN_ts(iteration),FP_ts(iteration),FN_ts(iteration),...
        ACC_ts(iteration),PPV_ts(iteration),TPR_ts(iteration),SPC_ts(iteration),...
        FPR_ts(iteration),F1_ts(iteration),SS_ts(iteration)]=estBinClass(Y_ts,RSLT_ts);
    elseif (strcmpi(classifierName,'tree'))
      % Train model
      mdl=fitctree(X_tr,Y_tr);
      [~,p]=predict(mdl,X_tr);
      p=p(:,2);
      
      [T]=getThresholds([0 1],nOfThresholds);
      
      % Performance curves on train data
      [TP_th_tr(:,iteration),TN_th_tr(:,iteration),FP_th_tr(:,iteration),FN_th_tr(:,iteration),...
        ACC_th_tr(:,iteration),PPV_th_tr(:,iteration),TPR_th_tr(:,iteration),SPC_th_tr(:,iteration),...
        FPR_th_tr(:,iteration),F1_th_tr(:,iteration),SS_th_tr(:,iteration),AUC_tr(iteration)]=...
        perfCurvesTh(Y_tr,p,T,1);
      
      % Interpolating FRP to average ROCs
      FPR_ROC_tr(:,iteration)=0:1/(nOfThresholds-1):1;
      [fpr,idxSort]=sort(FPR_tr(:,iteration));
      tpr=TPR_tr(idxSort,iteration);
      TPR_ROC_tr(:,iteration)=interp1q(fpr,tpr,FPR_ROC_tr);
      
      % Selecting optimal threshold based on SS-score
      [~,optIdx]=max(SS_tr(:,iteration));
      TH_tr(iteration)=T(optIdx);
      
      % Reluts with optimal threshold
%       RSLT_tr=predict(mdl,X_tr);
      RSLT_tr=p>T(optIdx);
      
      % Results for train set with optimal threshold
      [TP_tr(iteration),TN_tr(iteration),FP_tr(iteration),FN_tr(iteration),...
        ACC_tr(iteration),PPV_tr(iteration),TPR_tr(iteration),SPC_tr(iteration),...
        FPR_tr(iteration),F1_tr(iteration),SS_tr(iteration)]=estBinClass(Y_tr,RSLT_tr);
      
      % Obtaining results for CV set
      [~,p]=predict(mdl,X_cv);
      p=p(:,2);
      
      % Performance curves on CV data
      [TP_th_cv(:,iteration),TN_th_cv(:,iteration),FP_th_cv(:,iteration),FN_th_cv(:,iteration),...
        ACC_th_cv(:,iteration),PPV_th_cv(:,iteration),TPR_th_cv(:,iteration),SPC_th_cv(:,iteration),...
        FPR_th_cv(:,iteration),F1_th_cv(:,iteration),SS_th_cv(:,iteration),AUC_cv(iteration)]=...
        perfCurvesTh(Y_cv,p,T,1);
      
      % Interpolating FRP to average ROCs
      FPR_ROC_cv(:,iteration)=0:1/(nOfThresholds-1):1;
      [fpr,idxSort]=sort(FPR_cv(:,iteration));
      tpr=TPR_cv(idxSort,iteration);
      TPR_ROC_cv(:,iteration)=interp1q(fpr,tpr,FPR_ROC_cv(:,iteration));
      
      % Selecting optimal threshold based on SS-score
      [~,optIdx]=max(SS_cv(:,iteration));
      TH_cv(iteration)=T(optIdx);
      
      % Reluts with optimal threshold
%       RSLT_cv=predict(mdl,X_cv);
      RSLT_cv=p>T(optIdx);
      
      % Results for CV set with optimal threshold
      [TP_cv(iteration),TN_cv(iteration),FP_cv(iteration),FN_cv(iteration),...
        ACC_cv(iteration),PPV_cv(iteration),TPR_cv(iteration),SPC_cv(iteration),...
        FPR_cv(iteration),F1_cv(iteration),SS_cv(iteration)]=estBinClass(Y_cv,RSLT_cv);

      % Obtaining results for Test set
      [~,p]=predict(mdl,X_ts);
      p=p(:,2);
      
      % Performance curves on train data
      [TP_th_ts(:,iteration),TN_th_ts(:,iteration),FP_th_ts(:,iteration),FN_th_ts(:,iteration),...
        ACC_th_ts(:,iteration),PPV_th_ts(:,iteration),TPR_th_ts(:,iteration),SPC_th_ts(:,iteration),...
        FPR_th_ts(:,iteration),F1_th_ts(:,iteration),SS_th_ts(:,iteration),AUC_ts(iteration)]=...
        perfCurvesTh(Y_ts,p,T,1);
      
      % Interpolating FRP to average ROCs
      FPR_ROC_ts(:,iteration)=0:1/(nOfThresholds-1):1;
      [fpr,idxSort]=sort(FPR_ts(:,iteration));
      tpr=TPR_ts(idxSort,iteration);
      TPR_ROC_ts(:,iteration)=interp1q(fpr,tpr,FPR_ROC_ts(:,iteration));
      
      % Selecting optimal threshold based on SS-score
      [~,optIdx]=max(SS_ts(:,iteration));
      TH_ts(iteration)=T(optIdx);
      
      % Reluts with optimal threshold
%       RSLT_ts=predict(mdl,X_ts);
      RSLT_ts=p>T(optIdx);

      % Results for CV set with optimal threshold
      [TP_ts(iteration),TN_ts(iteration),FP_ts(iteration),FN_ts(iteration),...
        ACC_ts(iteration),PPV_ts(iteration),TPR_ts(iteration),SPC_ts(iteration),...
        FPR_ts(iteration),F1_ts(iteration),SS_ts(iteration)]=estBinClass(Y_ts,RSLT_ts);
    elseif (strcmpi(classifierName,'knn'))
      % Train model
      mdl=fitcknn(X_tr,Y_tr);
      [~,p]=predict(mdl,X_tr);
      p=p(:,2);
      
      [T]=getThresholds(p,nOfThresholds);
      
      % Performance curves on train data
      [TP_th_tr(:,iteration),TN_th_tr(:,iteration),FP_th_tr(:,iteration),FN_th_tr(:,iteration),...
        ACC_th_tr(:,iteration),PPV_th_tr(:,iteration),TPR_th_tr(:,iteration),SPC_th_tr(:,iteration),...
        FPR_th_tr(:,iteration),F1_th_tr(:,iteration),SS_th_tr(:,iteration),AUC_tr(iteration)]=...
        perfCurvesTh(Y_tr,p,T,1);
      
      % Interpolating FRP to average ROCs
      FPR_ROC_tr(:,iteration)=0:1/(nOfThresholds-1):1;
      [fpr,idxSort]=sort(FPR_tr(:,iteration));
      tpr=TPR_tr(idxSort,iteration);
      TPR_ROC_tr(:,iteration)=interp1q(fpr,tpr,FPR_ROC_tr);
      
      % Selecting optimal threshold based on SS-score
      [~,optIdx]=max(SS_tr(:,iteration));
      TH_tr(iteration)=T(optIdx);
      
      % Reluts with optimal threshold
%       RSLT_tr=predict(mdl,X_tr);
      RSLT_tr=p>T(optIdx);
      
      % Results for train set with optimal threshold
      [TP_tr(iteration),TN_tr(iteration),FP_tr(iteration),FN_tr(iteration),...
        ACC_tr(iteration),PPV_tr(iteration),TPR_tr(iteration),SPC_tr(iteration),...
        FPR_tr(iteration),F1_tr(iteration),SS_tr(iteration)]=estBinClass(Y_tr,RSLT_tr);
      
      % Obtaining results for CV set
      [~,p]=predict(mdl,X_cv);
      p=p(:,2);
      
      % Performance curves on CV data
      [TP_th_cv(:,iteration),TN_th_cv(:,iteration),FP_th_cv(:,iteration),FN_th_cv(:,iteration),...
        ACC_th_cv(:,iteration),PPV_th_cv(:,iteration),TPR_th_cv(:,iteration),SPC_th_cv(:,iteration),...
        FPR_th_cv(:,iteration),F1_th_cv(:,iteration),SS_th_cv(:,iteration),AUC_cv(iteration)]=...
        perfCurvesTh(Y_cv,p,T,1);
      
      % Interpolating FRP to average ROCs
      FPR_ROC_cv(:,iteration)=0:1/(nOfThresholds-1):1;
      [fpr,idxSort]=sort(FPR_cv(:,iteration));
      tpr=TPR_cv(idxSort,iteration);
      TPR_ROC_cv(:,iteration)=interp1q(fpr,tpr,FPR_ROC_cv(:,iteration));
      
      % Selecting optimal threshold based on SS-score
      [~,optIdx]=max(SS_cv(:,iteration));
      TH_cv(iteration)=T(optIdx);
      
      % Reluts with optimal threshold
%       RSLT_cv=predict(mdl,X_cv);
      RSLT_cv=p>T(optIdx);
      
      % Results for CV set with optimal threshold
      [TP_cv(iteration),TN_cv(iteration),FP_cv(iteration),FN_cv(iteration),...
        ACC_cv(iteration),PPV_cv(iteration),TPR_cv(iteration),SPC_cv(iteration),...
        FPR_cv(iteration),F1_cv(iteration),SS_cv(iteration)]=estBinClass(Y_cv,RSLT_cv);

      % Obtaining results for Test set
      [~,p]=predict(mdl,X_ts);
      p=p(:,2);
      
      % Performance curves on train data
      [TP_th_ts(:,iteration),TN_th_ts(:,iteration),FP_th_ts(:,iteration),FN_th_ts(:,iteration),...
        ACC_th_ts(:,iteration),PPV_th_ts(:,iteration),TPR_th_ts(:,iteration),SPC_th_ts(:,iteration),...
        FPR_th_ts(:,iteration),F1_th_ts(:,iteration),SS_th_ts(:,iteration),AUC_ts(iteration)]=...
        perfCurvesTh(Y_ts,p,T,1);
      
      % Interpolating FRP to average ROCs
      FPR_ROC_ts(:,iteration)=0:1/(nOfThresholds-1):1;
      [fpr,idxSort]=sort(FPR_ts(:,iteration));
      tpr=TPR_ts(idxSort,iteration);
      TPR_ROC_ts(:,iteration)=interp1q(fpr,tpr,FPR_ROC_ts(:,iteration));
      
      % Selecting optimal threshold based on SS-score
      [~,optIdx]=max(SS_ts(:,iteration));
      TH_ts(iteration)=T(optIdx);
      
      % Reluts with optimal threshold
%       RSLT_ts=predict(mdl,X_ts);
      RSLT_ts=p>T(optIdx);

      % Results for CV set with optimal threshold
      [TP_ts(iteration),TN_ts(iteration),FP_ts(iteration),FN_ts(iteration),...
        ACC_ts(iteration),PPV_ts(iteration),TPR_ts(iteration),SPC_ts(iteration),...
        FPR_ts(iteration),F1_ts(iteration),SS_ts(iteration)]=estBinClass(Y_ts,RSLT_ts);
    elseif (strcmpi(classifierName,'discr'))
      % Train model
      mdl=fitcdiscr(X_tr,Y_tr);
      [~,p]=predict(mdl,X_tr);
      p=p(:,2);
      
      [T]=getThresholds([0 1],nOfThresholds);
      
      % Performance curves on train data
      [TP_th_tr(:,iteration),TN_th_tr(:,iteration),FP_th_tr(:,iteration),FN_th_tr(:,iteration),...
        ACC_th_tr(:,iteration),PPV_th_tr(:,iteration),TPR_th_tr(:,iteration),SPC_th_tr(:,iteration),...
        FPR_th_tr(:,iteration),F1_th_tr(:,iteration),SS_th_tr(:,iteration),AUC_tr(iteration)]=...
        perfCurvesTh(Y_tr,p,T,1);
      
      % Interpolating FRP to average ROCs
      FPR_ROC_tr(:,iteration)=0:1/(nOfThresholds-1):1;
      [fpr,idxSort]=sort(FPR_tr(:,iteration));
      tpr=TPR_tr(idxSort,iteration);
      TPR_ROC_tr(:,iteration)=interp1q(fpr,tpr,FPR_ROC_tr);
      
      % Selecting optimal threshold based on SS-score
      [~,optIdx]=max(SS_tr(:,iteration));
      TH_tr(iteration)=T(optIdx);
      
      % Reluts with optimal threshold
%       RSLT_tr=predict(mdl,X_tr);
      RSLT_tr=p>T(optIdx);
      
      % Results for train set with optimal threshold
      [TP_tr(iteration),TN_tr(iteration),FP_tr(iteration),FN_tr(iteration),...
        ACC_tr(iteration),PPV_tr(iteration),TPR_tr(iteration),SPC_tr(iteration),...
        FPR_tr(iteration),F1_tr(iteration),SS_tr(iteration)]=estBinClass(Y_tr,RSLT_tr);
      
      % Obtaining results for CV set
      [~,p]=predict(mdl,X_cv);
      p=p(:,2);
      
      % Performance curves on CV data
      [TP_th_cv(:,iteration),TN_th_cv(:,iteration),FP_th_cv(:,iteration),FN_th_cv(:,iteration),...
        ACC_th_cv(:,iteration),PPV_th_cv(:,iteration),TPR_th_cv(:,iteration),SPC_th_cv(:,iteration),...
        FPR_th_cv(:,iteration),F1_th_cv(:,iteration),SS_th_cv(:,iteration),AUC_cv(iteration)]=...
        perfCurvesTh(Y_cv,p,T,1);
      
      % Interpolating FRP to average ROCs
      FPR_ROC_cv(:,iteration)=0:1/(nOfThresholds-1):1;
      [fpr,idxSort]=sort(FPR_cv(:,iteration));
      tpr=TPR_cv(idxSort,iteration);
      TPR_ROC_cv(:,iteration)=interp1q(fpr,tpr,FPR_ROC_cv(:,iteration));
      
      % Selecting optimal threshold based on SS-score
      [~,optIdx]=max(SS_cv(:,iteration));
      TH_cv(iteration)=T(optIdx);
      
      % Reluts with optimal threshold
%       RSLT_cv=predict(mdl,X_cv);
      RSLT_cv=p>T(optIdx);
      
      % Results for CV set with optimal threshold
      [TP_cv(iteration),TN_cv(iteration),FP_cv(iteration),FN_cv(iteration),...
        ACC_cv(iteration),PPV_cv(iteration),TPR_cv(iteration),SPC_cv(iteration),...
        FPR_cv(iteration),F1_cv(iteration),SS_cv(iteration)]=estBinClass(Y_cv,RSLT_cv);

      % Obtaining results for Test set
      [~,p]=predict(mdl,X_ts);
      p=p(:,2);
      
      % Performance curves on train data
      [TP_th_ts(:,iteration),TN_th_ts(:,iteration),FP_th_ts(:,iteration),FN_th_ts(:,iteration),...
        ACC_th_ts(:,iteration),PPV_th_ts(:,iteration),TPR_th_ts(:,iteration),SPC_th_ts(:,iteration),...
        FPR_th_ts(:,iteration),F1_th_ts(:,iteration),SS_th_ts(:,iteration),AUC_ts(iteration)]=...
        perfCurvesTh(Y_ts,p,T,1);
      
      % Interpolating FRP to average ROCs
      FPR_ROC_ts(:,iteration)=0:1/(nOfThresholds-1):1;
      [fpr,idxSort]=sort(FPR_ts(:,iteration));
      tpr=TPR_ts(idxSort,iteration);
      TPR_ROC_ts(:,iteration)=interp1q(fpr,tpr,FPR_ROC_ts(:,iteration));
      
      % Selecting optimal threshold based on SS-score
      [~,optIdx]=max(SS_ts(:,iteration));
      TH_ts(iteration)=T(optIdx);
      
      % Reluts with optimal threshold
%       RSLT_ts=predict(mdl,X_ts);
      RSLT_ts=p>T(optIdx);

      % Results for CV set with optimal threshold
      [TP_ts(iteration),TN_ts(iteration),FP_ts(iteration),FN_ts(iteration),...
        ACC_ts(iteration),PPV_ts(iteration),TPR_ts(iteration),SPC_ts(iteration),...
        FPR_ts(iteration),F1_ts(iteration),SS_ts(iteration)]=estBinClass(Y_ts,RSLT_ts);
    else
      error(['No approriate classification method ',classifierName,'!']);
    end
  end
  
  % Mean and std data over iterations (train)
  TH_tr_av=mean(TH_tr); 
  TP_tr_av=mean(TP_tr); 
  TN_tr_av=mean(TN_tr); 
  FP_tr_av=mean(FP_tr); 
  FN_tr_av=mean(FN_tr); 
  ACC_tr_av=mean(ACC_tr); 
  PPV_tr_av=mean(PPV_tr); 
  TPR_tr_av=mean(TPR_tr); 
  SPC_tr_av=mean(SPC_tr); 
  FPR_tr_av=mean(FPR_tr); 
  F1_tr_av=mean(F1_tr); 
  SS_tr_av=mean(SS_tr);   
  AUC_tr_av=mean(AUC_tr); 
  
  TH_tr_std=std(TH_tr); 
  TP_tr_std=std(TP_tr); 
  TN_tr_std=std(TN_tr); 
  FP_tr_std=std(FP_tr); 
  FN_tr_std=std(FN_tr); 
  ACC_tr_std=std(ACC_tr); 
  PPV_tr_std=std(PPV_tr); 
  TPR_tr_std=std(TPR_tr); 
  SPC_tr_std=std(SPC_tr); 
  FPR_tr_std=std(FPR_tr); 
  F1_tr_std=std(F1_tr); 
  SS_tr_std=std(SS_tr);   
  AUC_tr_std=std(AUC_tr); 
  
  TPR_ROC_tr=mean(TPR_ROC_tr,2);
  TPR_ROC_tr_std=std(TPR_ROC_tr,[],2);
  FPR_ROC_tr=mean(FPR_ROC_tr,2);
  
  % Mean and std data over iterations (CV)
  TH_cv_av=mean(TH_cv); 
  TP_cv_av=mean(TP_cv); 
  TN_cv_av=mean(TN_cv); 
  FP_cv_av=mean(FP_cv); 
  FN_cv_av=mean(FN_cv); 
  ACC_cv_av=mean(ACC_cv); 
  PPV_cv_av=mean(PPV_cv); 
  TPR_cv_av=mean(TPR_cv); 
  SPC_cv_av=mean(SPC_cv); 
  FPR_cv_av=mean(FPR_cv); 
  F1_cv_av=mean(F1_cv); 
  SS_cv_av=mean(SS_cv);   
  AUC_cv_av=mean(AUC_cv); 
  
  TH_cv_std=std(TH_cv); 
  TP_cv_std=std(TP_cv); 
  TN_cv_std=std(TN_cv); 
  FP_cv_std=std(FP_cv); 
  FN_cv_std=std(FN_cv); 
  ACC_cv_std=std(ACC_cv); 
  PPV_cv_std=std(PPV_cv); 
  TPR_cv_std=std(TPR_cv); 
  SPC_cv_std=std(SPC_cv); 
  FPR_cv_std=std(FPR_cv); 
  F1_cv_std=std(F1_cv); 
  SS_cv_std=std(SS_cv);   
  AUC_cv_std=std(AUC_cv); 
  
  TPR_ROC_cv=mean(TPR_ROC_cv,2);
  TPR_ROC_cv_std=std(TPR_ROC_cv,[],2);
  FPR_ROC_cv=mean(FPR_ROC_cv,2);

  % Mean and std data over iterations (test)
  TH_ts_av=mean(TH_ts); 
  TP_ts_av=mean(TP_ts); 
  TN_ts_av=mean(TN_ts); 
  FP_ts_av=mean(FP_ts); 
  FN_ts_av=mean(FN_ts); 
  ACC_ts_av=mean(ACC_ts); 
  PPV_ts_av=mean(PPV_ts); 
  TPR_ts_av=mean(TPR_ts); 
  SPC_ts_av=mean(SPC_ts); 
  FPR_ts_av=mean(FPR_ts); 
  F1_ts_av=mean(F1_ts); 
  SS_ts_av=mean(SS_ts);   
  AUC_ts_av=mean(AUC_ts); 
  
  TH_ts_std=std(TH_ts); 
  TP_ts_std=std(TP_ts); 
  TN_ts_std=std(TN_ts); 
  FP_ts_std=std(FP_ts); 
  FN_ts_std=std(FN_ts); 
  ACC_ts_std=std(ACC_ts); 
  PPV_ts_std=std(PPV_ts); 
  TPR_ts_std=std(TPR_ts); 
  SPC_ts_std=std(SPC_ts); 
  FPR_ts_std=std(FPR_ts); 
  F1_ts_std=std(F1_ts); 
  SS_ts_std=std(SS_ts);   
  AUC_ts_std=std(AUC_ts); 
  
  TPR_ROC_ts=mean(TPR_ROC_ts,2);
  TPR_ROC_ts_std=std(TPR_ROC_ts,[],2);
  FPR_ROC_ts=mean(FPR_ROC_ts,2);
  
  % Return struct with all results
  S=struct(...
    ... % Train results
    'TH_tr_av',TH_tr_av,... 
    'TP_tr_av',TP_tr_av,... 
    'TN_tr_av',TN_tr_av,...
    'FP_tr_av',FP_tr_av,...
    'FN_tr_av',FN_tr_av,... 
    'ACC_tr_av',ACC_tr_av,...
    'PPV_tr_av',PPV_tr_av,...
    'TPR_tr_av',TPR_tr_av,...
    'SPC_tr_av',SPC_tr_av,...
    'FPR_tr_av',FPR_tr_av,...
    'F1_tr_av',F1_tr_av,...
    'SS_tr_av',SS_tr_av,...   
    'AUC_tr_av',AUC_tr_av,...  
    'TH_tr_std',TH_tr_std,... 
    'TP_tr_std',TP_tr_std,... 
    'TN_tr_std',TN_tr_std,...  
    'FP_tr_std',FP_tr_std,... 
    'FN_tr_std',FN_tr_std,...  
    'ACC_tr_std',ACC_tr_std,... 
    'PPV_tr_std',PPV_tr_std,... 
    'TPR_tr_std',TPR_tr_std,... 
    'SPC_tr_std',SPC_tr_std,... 
    'FPR_tr_std',FPR_tr_std,... 
    'F1_tr_std',F1_tr_std,... 
    'SS_tr_std',SS_tr_std,...   
    'AUC_tr_std',AUC_tr_std,...    
    'TPR_ROC_tr',TPR_ROC_tr,... 
    'TPR_ROC_tr_std',TPR_ROC_tr_std,... 
    'FPR_ROC_tr',FPR_ROC_tr,... 
    ... % CV results
    'TH_cv_av',TH_cv_av,... 
    'TP_cv_av',TP_cv_av,... 
    'TN_cv_av',TN_cv_av,...
    'FP_cv_av',FP_cv_av,...
    'FN_cv_av',FN_cv_av,... 
    'ACC_cv_av',ACC_cv_av,...
    'PPV_cv_av',PPV_cv_av,...
    'TPR_cv_av',TPR_cv_av,...
    'SPC_cv_av',SPC_cv_av,...
    'FPR_cv_av',FPR_cv_av,...
    'F1_cv_av',F1_cv_av,...
    'SS_cv_av',SS_cv_av,...   
    'AUC_cv_av',AUC_cv_av,...  
    'TH_cv_std',TH_cv_std,... 
    'TP_cv_std',TP_cv_std,... 
    'TN_cv_std',TN_cv_std,...  
    'FP_cv_std',FP_cv_std,... 
    'FN_cv_std',FN_cv_std,...  
    'ACC_cv_std',ACC_cv_std,... 
    'PPV_cv_std',PPV_cv_std,... 
    'TPR_cv_std',TPR_cv_std,... 
    'SPC_cv_std',SPC_cv_std,... 
    'FPR_cv_std',FPR_cv_std,... 
    'F1_cv_std',F1_cv_std,... 
    'SS_cv_std',SS_cv_std,...   
    'AUC_cv_std',AUC_cv_std,...    
    'TPR_ROC_cv',TPR_ROC_cv,... 
    'TPR_ROC_cv_std',TPR_ROC_cv_std,... 
    'FPR_ROC_cv',FPR_ROC_cv,...
    ... % Test results
    'TH_ts_av',TH_ts_av,... 
    'TP_ts_av',TP_ts_av,... 
    'TN_ts_av',TN_ts_av,...
    'FP_ts_av',FP_ts_av,...
    'FN_ts_av',FN_ts_av,... 
    'ACC_ts_av',ACC_ts_av,...
    'PPV_ts_av',PPV_ts_av,...
    'TPR_ts_av',TPR_ts_av,...
    'SPC_ts_av',SPC_ts_av,...
    'FPR_ts_av',FPR_ts_av,...
    'F1_ts_av',F1_ts_av,...
    'SS_ts_av',SS_ts_av,...   
    'AUC_ts_av',AUC_ts_av,...  
    'TH_ts_std',TH_ts_std,... 
    'TP_ts_std',TP_ts_std,... 
    'TN_ts_std',TN_ts_std,...  
    'FP_ts_std',FP_ts_std,... 
    'FN_ts_std',FN_ts_std,...  
    'ACC_ts_std',ACC_ts_std,... 
    'PPV_ts_std',PPV_ts_std,... 
    'TPR_ts_std',TPR_ts_std,... 
    'SPC_ts_std',SPC_ts_std,... 
    'FPR_ts_std',FPR_ts_std,... 
    'F1_ts_std',F1_ts_std,... 
    'SS_ts_std',SS_ts_std,...   
    'AUC_ts_std',AUC_ts_std,...    
    'TPR_ROC_ts',TPR_ROC_ts,... 
    'TPR_ROC_ts_std',TPR_ROC_ts_std,... 
    'FPR_ROC_ts',FPR_ROC_ts...
  );
end