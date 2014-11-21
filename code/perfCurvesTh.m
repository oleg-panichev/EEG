% Fucntion for classification estimation.
%
% Input:
% Y - output vector (0 | 1)
% X - feature vector
% T - thresholds
% xSign - if > 0 then positive class have X > threshold
%         if < 0 then positive class have X < threshold
%
function [TP,TN,FP,FN,ACC,PPV,TPR,SPC,FPR,F1,SS,AUC]=perfCurvesTh(Y,X,T,xSign)
  T=getThresholds(X,500);
  TP=zeros(size(T));
  TN=zeros(size(T));
  FP=zeros(size(T));
  FN=zeros(size(T));
  ACC=zeros(size(T));
  PPV=zeros(size(T));
  TPR=zeros(size(T));
  SPC=zeros(size(T));
  FPR=zeros(size(T));
  F1=zeros(size(T));
  SS=zeros(size(T));
  for i=1:numel(T)
    if (xSign>0)
      result=(X>=T(i));
    elseif (xSign<0)
      result=(X<=T(i));
    end
    [TP(i),TN(i),FP(i),FN(i),ACC(i),PPV(i),TPR(i),SPC(i),FPR(i),F1(i),SS(i)]=estBinClass(Y,result);
  end
  AUC=abs(0.5*sum( (FPR(2:end)-FPR(1:end-1)).*(TPR(2:end)+TPR(1:end-1)) ));
end