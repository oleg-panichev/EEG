function [X_tr,X_cv,X_ts,Y_tr,Y_cv,Y_ts,SID_tr,SID_cv,SID_ts]=divideDataOnTrainCvTest(X,Y,SID,mode)  

  IDX_POS=(Y==1);
  IDX_NEG=(Y==0);
  N_POS=sum(IDX_POS);
  if (strcmp(mode,'normal'))
    N_NEG=sum(IDX_NEG);
  elseif (strcmp(mode,'balanced'))
    N_NEG=N_POS;
  end
  
  % Divide data on two classes
  X_POS=X(IDX_POS,:);
  X_NEG=X(IDX_NEG,:);
  Y_POS=Y(IDX_POS);
  Y_NEG=Y(IDX_NEG);
  SID_POS=SID(IDX_POS);
  SID_NEG=SID(IDX_NEG);
  
  % Form random data permutation
  rIdx_POS=randperm(N_POS);
  rIdx_NEG=randperm(sum(IDX_NEG));
  if (strcmp(mode,'balanced'))
    rIdx_NEG=rIdx_NEG(1:N_NEG);
  end
  
  % 60/20/20
  N_tr_POS=round(0.6*N_POS);
  N_tr_NEG=round(0.6*N_NEG);
  N_cv_POS=round(0.2*N_POS);
  N_cv_NEG=round(0.2*N_NEG);
  
  % Getting indexes of three datasets
  rIdx_tr_POS=rIdx_POS(1:N_tr_POS);
  rIdx_tr_NEG=rIdx_NEG(1:N_tr_NEG);
  rIdx_cv_POS=rIdx_POS(N_tr_POS+1:N_tr_POS+N_cv_POS);
  rIdx_cv_NEG=rIdx_NEG(N_tr_NEG+1:N_tr_NEG+N_cv_NEG);
  rIdx_ts_POS=rIdx_POS(N_tr_POS+N_cv_POS+1:end);
  rIdx_ts_NEG=rIdx_NEG(N_tr_NEG+N_cv_NEG+1:end);
  
  % Train Set
  X_tr=[X_POS(rIdx_tr_POS,:);X_NEG(rIdx_tr_NEG,:)];
  Y_tr=[Y_POS(rIdx_tr_POS);Y_NEG(rIdx_tr_NEG)];
  SID_tr=[SID_POS(rIdx_tr_POS);SID_NEG(rIdx_tr_NEG)];
  
  % Cross Validation Set
  X_cv=[X_POS(rIdx_cv_POS,:);X_NEG(rIdx_cv_NEG,:)];
  Y_cv=[Y_POS(rIdx_cv_POS);Y_NEG(rIdx_cv_NEG)];
  SID_cv=[SID_POS(rIdx_cv_POS);SID_NEG(rIdx_cv_NEG)];
  
  % Test Set
  X_ts=[X_POS(rIdx_ts_POS,:);X_NEG(rIdx_ts_NEG,:)];
  Y_ts=[Y_POS(rIdx_ts_POS);Y_NEG(rIdx_ts_NEG)];
  SID_ts=[SID_POS(rIdx_ts_POS);SID_NEG(rIdx_ts_NEG)];
end