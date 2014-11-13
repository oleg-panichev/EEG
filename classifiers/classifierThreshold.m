% Function for estimation of classification results 
% based on one feature. 
%
% Inputs:
% x - feature vector
% y - output vector
% s - sequence vectore
% th - threshold values to test
% featureName - name of the feature to analyse
%
function [optTh,avTh,ACC,PPV,TPR,SPC,FPR,F1,SS,AUC,meanROC,rslt]=...
  classifierThreshold(x,y,xUnknownTest,s,featureName)

  disp(['Threshold classifier: ',featureName,'...']);
  run('processingProperties.m');
  m=size(x,2);
  N=numel(y);
  
%   % Feature boxplots
%   f=figure; 
%   xBuf=x(y==1);
%   sBuf=s(y==1);
%   for i=1:6
%     hx(i)=subplot(1,7,i);
%     bp=boxplot(xBuf(sBuf==i)',[num2str((i-1)*10),'-',num2str(i*10)]);
%     set(bp,'linewidth',2);
%     grid on;
%   end
%   hx(7)=subplot(1,7,7);
%   bp=boxplot(x(y==0)','Interictal');
%   set(bp,'linewidth',2);
%   grid on;
%   linkaxes(hx,'y');
%   suptitle(featureName);
%   
%   figure
%   clear hx;
%   hx(1)=subplot(1,2,1);
%   bp=boxplot(x(y==1)','Preictal');
%   set(bp,'linewidth',2);
%   grid on;
%   hx(2)=subplot(1,2,2);
%   bp=boxplot(x(y==0)','Interictal');
%   set(bp,'linewidth',2);
%   grid on;
%   linkaxes(hx,'y');
%   suptitle(featureName);
%   
%   figure
%   clear hx;
%   hx(1)=subplot(2,1,1);
%   [nelements,centers]=hist(x(y==1),20);
%   bar(centers,log(nelements+1));
%   title('Preictal');
%   grid on;
%   hx(2)=subplot(2,1,2);
%   [nelements,centers]=hist(x(y==0),20);
%   bar(centers,log(nelements+1));
%   title('Interictal');
%   grid on;
%   linkaxes(hx,'x');
%   suptitle(featureName);
  
  % 
  idxBuf=1:N;
  piIdx=idxBuf(y==1);
  nOfPi=numel(piIdx);
  nOfPiTrain=round(nOfPi*trainNumCoef);
  nOfPiTest=nOfPi-nOfPiTrain;
  iiIdx=idxBuf(y==0);
  nOfIi=numel(iiIdx);
  nOfIiTrain=round(nOfIi*trainNumCoef);
  nOfIiTest=nOfIi-nOfIiTrain;

  

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

    xTrain=[x(piTrainIdx);x(iiTrainIdx)];
    yTrain=[y(piTrainIdx);y(iiTrainIdx)];
    xTest=[x(piTestIdx);x(iiTestIdx)];
    yTest=[y(piTestIdx);y(iiTestIdx)]; 
    
    [th]=getThresholds(xTrain,nOfThresholds);
    [xSign]=getSign(xTrain,yTrain);
    [TP(:,iter),TN(:,iter),FP(:,iter),FN(:,iter),ACC(:,iter),PPV(:,iter),...
      TPR(:,iter),SPC(:,iter),FPR(:,iter),F1(:,iter),SS(:,iter),~]=perfCurvesTh(yTrain,xTrain,th,xSign);
    
    % Estimation on the test data    
    [~,optIdx]=max(SS(:,iter));
    if (xSign>0)
      res=xTest>=th(optIdx);
    elseif (xSign<0)
      res=xTest<=th(optIdx);
    end

    [~,~,~,~,~,~,~,~,~,~,~,AUC_Test(iter)]=perfCurvesTh(yTest,xTest,th,xSign);
    [TP_Test(iter),TN_Test(iter),FP_Test(iter),FN_Test(iter),ACC_Test(iter),...
      PPV_Test(iter),TPR_Test(iter),SPC_Test(iter),FPR_Test(iter),...
      F1_Test(iter),SS_Test(iter)]=estBinClass(yTest,res);
  
    thBuf(iter)=th(optIdx);
  end
    
  meanROC=[mean(FPR,2),mean(TPR,2)];
%   f=figure;
%   set(f,'PaperPositionMode','auto');
%   set(f,'Position',[0 100 1130 570]);
%   set(f,'DefaultAxesLooseInset',[0,0.1,0,0]);
%   subplot(2,3,1);
%   plot(th,max(ACC,[],2),'g'); hold on;
%   plot(th,mean(ACC,2),'Linewidth',2); hold on;
%   plot(th,min(ACC,[],2),'r');
%   ylabel('Accuracy'); xlabel('threshold'); xlim([th(1) th(end)]); grid on;
%   legend('Max','Mean','Min');
%   subplot(2,3,2);
%   plot(th,max(PPV,[],2),'g'); hold on;
%   plot(th,mean(PPV,2),'Linewidth',2); hold on; 
%   plot(th,min(PPV,[],2),'r');
%   ylabel('Precision'); xlabel('threshold'); xlim([th(1) th(end)]); grid on;
%   legend('Max','Mean','Min');
%   subplot(2,3,3);
%   plot(th,max(TPR,[],2),'g'); hold on;
%   plot(th,mean(TPR,2),'Linewidth',2); hold on;  
%   plot(th,min(TPR,[],2),'r');
%   ylabel('Recall'); xlabel('threshold'); xlim([th(1) th(end)]); grid on;
%   legend('Max','Mean','Min');
%   subplot(2,3,4);
%   plot(th,max(F1,[],2),'g'); hold on;
%   plot(th,mean(F1,2),'Linewidth',2); hold on; 
%   plot(th,min(F1,[],2),'r'); hold on;
  meanF1=mean(F1,2);
  [~,idx]=max(meanF1);
%   plot(th(idx),meanF1(idx),'r*');
%   ylabel('F1 score'); xlabel('threshold'); xlim([th(1) th(end)]); grid on;
%   legend('Max','Mean','Min');
%   subplot(2,3,5);
%   plot(th,max(AUC,[],2),'g'); hold on;
%   plot(th,mean(AUC,2),'Linewidth',2); hold on; 
%   plot(th,min(AUC,[],2),'r'); hold on;
%   ylabel('AUC'); xlabel('threshold'); xlim([th(1) th(end)]); grid on;
%   legend('Max','Mean','Min');
%   subplot(2,3,6);
%   plot(max(TPR,[],2),max(PPV,[],2),'g'); hold on;
%   plot(mean(TPR,2),mean(PPV,2),'Linewidth',2); hold on;
%   plot(min(TPR,[],2),min(PPV,[],2),'r'); 
%   ylabel('Precision'); xlabel('Recall'); xlim([min(min(TPR,[],2)) max(max(TPR,[],2))]); grid on;
%   legend('Max','Mean','Min');
%   
%   f=figure;
%   set(f,'PaperPositionMode','auto');
%   set(f,'Position',[0 100 600 300]);
%   set(f,'DefaultAxesLooseInset',[0,0.1,0,0]);
%   subplot(1,2,1);
%   barVal=[min(mean(TP,2)),mean(mean(TP,2)),max(mean(TP,2));
%       min(mean(TN,2)),mean(mean(TN,2)),max(mean(TN,2));
%       min(mean(FP,2)),mean(mean(FP,2)),max(mean(FP,2));
%       min(mean(FN,2)),mean(mean(FN,2)),max(mean(FN,2));].*100/NTrain;
%   b1=bar(barVal);
%   set(gca,'XTickLabel',{'TP','TN','FP','FN'}); xlim([0.5 4.5]);
%   colormap(gca,'cool');
%   ylabel('%');
%   title('Train');
%   grid on;
%   subplot(1,2,2);
%   barVal=[min(TP_Test),mean(TP_Test),max(TP_Test);
%     min(TN_Test),mean(TN_Test),max(TN_Test);
%     min(FP_Test),mean(FP_Test),max(FP_Test);
%     min(FN_Test),mean(FN_Test),max(FN_Test);].*100/NTest;
%   bar(barVal);
%   set(gca,'XTickLabel',{'TP','TN','FP','FN'}); xlim([0.5 4.5]);
%   colormap(gca,'cool');
%   ylabel('%');
%   title('Test');
%   grid on;
 
  % Return
  optTh=th(idx);
  avTh=mean(thBuf);
  ACC=mean(ACC_Test);
  PPV=mean(PPV_Test(~isnan(PPV_Test)));
  TPR=mean(TPR_Test(~isnan(TPR_Test)));
  SPC=mean(SPC_Test(~isnan(SPC_Test)));
  FPR=mean(FPR_Test(~isnan(FPR_Test)));
  F1=mean(F1_Test(~isnan(F1_Test)));
  SS=mean(SS_Test(~isnan(SS_Test)));
  AUC=mean(AUC_Test);

  if (xSign>0)
    rslt=xUnknownTest>=avTh;
  elseif (xSign<0)
    rslt=xUnknownTest<=avTh;
  end
  
  % Disp
  disp(['Optimal th (max(mean(F1 Score))): ',num2str(optTh)]);
  disp(['Av. th from all iterations: ',num2str(avTh)]);
  disp(['ACC: ',num2str(ACC)]);
  disp(['PPV: ',num2str(PPV)]);
  disp(['TPR: ',num2str(TPR)]);
  disp(['SPC: ',num2str(SPC)]);
  disp(['F1: ',num2str(F1)]);
  disp(['SS: ',num2str(SS)]);
  disp(['AUC: ',num2str(AUC)]);
  
%   [X,Y,T,AUC] = perfcurve(labels,scores,posclass);
end