% Function for one feature productivity analysis
% Inputs:
% x - feature vector
% y - output vector
function analyzeFeature(x,y,s,th,featureName)
  disp(['Analyzing feature ',featureName,'...']);
  m=size(x,2);
  N=numel(y);
  
  % Feature boxplots
  f=figure; 
  xBuf=x(y==1);
  sBuf=s(y==1);
  for i=1:6
    hx(i)=subplot(1,7,i);
    bp=boxplot(xBuf(sBuf==i)',[num2str((i-1)*10),'-',num2str(i*10)]);
    set(bp,'linewidth',2);
    grid on;
  end
  hx(7)=subplot(1,7,7);
  bp=boxplot(x(y==0)','Interictal');
  set(bp,'linewidth',2);
  grid on;
  linkaxes(hx,'y');
  suptitle(featureName);
  
  figure
  clear hx;
  hx(1)=subplot(1,2,1);
  bp=boxplot(x(y==1)','Preictal');
  set(bp,'linewidth',2);
  grid on;
  hx(2)=subplot(1,2,2);
  bp=boxplot(x(y==0)','Interictal');
  set(bp,'linewidth',2);
  grid on;
  linkaxes(hx,'y');
  suptitle(featureName);
  
  % 
  idxBuf=1:N;
  piIdx=idxBuf(y==1);
  nOfPi=numel(piIdx);
  nOfPiTrain=round(nOfPi*0.7);
  nOfPiTest=nOfPi-nOfPiTrain;
  iiIdx=idxBuf(y==0);
  nOfIi=numel(iiIdx);
  nOfIiTrain=round(nOfIi*0.7);
  nOfIiTest=nOfIi-nOfIiTrain;
  
  startIdx=round(nOfPi/2-nOfPi*0.3);
  stopIdx=round(nOfPi/2+nOfPi*0.3);
  sortedPi=sort(xBuf);
  meanPi=mean(xBuf);
  varPi=var(xBuf);
  thStep=4*varPi/100;
  th=(sortedPi(startIdx)):((sortedPi(stopIdx)-sortedPi(startIdx))/100):(sortedPi(stopIdx));
  nOfIterations=200;
  accuracy=zeros(numel(th),nOfIterations);
  precision=zeros(numel(th),nOfIterations);
  recall=zeros(numel(th),nOfIterations);
  F1=zeros(numel(th),nOfIterations);
  TP=zeros(numel(th),nOfIterations);
  FP=zeros(numel(th),nOfIterations);
  FN=zeros(numel(th),nOfIterations);
  TN=zeros(numel(th),nOfIterations);
  TP_Test=zeros(nOfIterations,1);
  FP_Test=zeros(nOfIterations,1);
  FN_Test=zeros(nOfIterations,1);
  TN_Test=zeros(nOfIterations,1);
  accuracy_Test=zeros(nOfIterations,1);
  precision_Test=zeros(nOfIterations,1);
  recall_Test=zeros(nOfIterations,1);
  F1_Test=zeros(nOfIterations,1);
  NTrain=nOfIiTrain+nOfPiTrain;
  
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
    
    idx=1;
    for i=th
      res=xTrain<i;
      for j=1:NTrain
        if (yTrain(j)==1 && res(j)==1)
          TP(idx,iter)=TP(idx,iter)+1;
        elseif (yTrain(j)==0 && res(j)==1)
          FP(idx,iter)=FP(idx,iter)+1;
        elseif (yTrain(j)==1 && res(j)==0)
          FN(idx,iter)=FN(idx,iter)+1;
        elseif (yTrain(j)==0 && res(j)==0)
          TN(idx,iter)=TN(idx,iter)+1;
        end
      end
      accuracy(idx,iter)=(TP(idx,iter)+TN(idx,iter))/NTrain;
      precision(idx,iter)=TP(idx,iter)/(TP(idx,iter)+FP(idx,iter));
      recall(idx,iter)=TP(idx,iter)/(TP(idx,iter)+FN(idx,iter));
      F1(idx,iter)=2*precision(idx,iter)*recall(idx,iter)/(precision(idx,iter)+recall(idx,iter));
      idx=idx+1;
    end
    
    % Estimation on the test data    
    NTest=numel(yTest);
    [~,optIdx]=max(F1(:,iter));
    res=xTest<th(optIdx);
    for j=1:NTest
      if (yTest(j)==1 && res(j)==1)
        TP_Test(iter)=TP_Test(iter)+1;
      elseif (yTest(j)==0 && res(j)==1)
        FP_Test(iter)=FP_Test(iter)+1;
      elseif (yTest(j)==1 && res(j)==0)
        FN_Test(iter)=FN_Test(iter)+1;
      elseif (yTest(j)==0 && res(j)==0)
        TN_Test(iter)=TN_Test(iter)+1;
      end
    end
    accuracy_Test(iter)=(TP_Test(iter)+TN_Test(iter))/NTest;
    precision_Test(iter)=TP_Test(iter)/(TP_Test(iter)+FP_Test(iter));
    recall_Test(iter)=TP_Test(iter)/(TP_Test(iter)+FN_Test(iter));
    F1_Test(iter)=2*precision_Test(iter)*recall_Test(iter)/(precision_Test(iter)+recall_Test(iter)+eps);
  end
    
  f=figure;
  set(f,'PaperPositionMode','auto');
  set(f,'Position',[0 100 1130 570]);
  set(f,'DefaultAxesLooseInset',[0,0.1,0,0]);
  subplot(2,3,1);
  plot(th,max(accuracy,[],2),'g'); hold on;
  plot(th,mean(accuracy,2),'Linewidth',2); hold on;
  plot(th,min(accuracy,[],2),'r');
  ylabel('Accuracy'); xlabel('threshold'); xlim([th(1) th(end)]); grid on;
  legend('Max','Mean','Min');
  subplot(2,3,2);
  plot(th,max(precision,[],2),'g'); hold on;
  plot(th,mean(precision,2),'Linewidth',2); hold on; 
  plot(th,min(precision,[],2),'r');
  ylabel('Precision'); xlabel('threshold'); xlim([th(1) th(end)]); grid on;
  legend('Max','Mean','Min');
  subplot(2,3,3);
  plot(th,max(recall,[],2),'g'); hold on;
  plot(th,mean(recall,2),'Linewidth',2); hold on;  
  plot(th,min(recall,[],2),'r');
  ylabel('Recall'); xlabel('threshold'); xlim([th(1) th(end)]); grid on;
  legend('Max','Mean','Min');
  subplot(2,3,4);
  plot(th,max(F1,[],2),'g'); hold on;
  plot(th,mean(F1,2),'Linewidth',2); hold on; 
  plot(th,min(F1,[],2),'r'); hold on;
  meanF1=mean(F1,2);
  [~,idx]=max(meanF1);
  plot(th(idx),meanF1(idx),'r*');
  ylabel('F1 score'); xlabel('threshold'); xlim([th(1) th(end)]); grid on;
  legend('Max','Mean','Min');
  subplot(2,3,5);
  plot(max(recall,[],2),max(precision,[],2),'g'); hold on;
  plot(mean(recall,2),mean(precision,2),'Linewidth',2); hold on;
  plot(min(recall,[],2),min(precision,[],2),'r'); 
  ylabel('Precision'); xlabel('Recall'); xlim([min(min(recall,[],2)) max(max(recall,[],2))]); grid on;
  legend('Max','Mean','Min');
  subplot(2,3,6);
  barVal=[min(mean(TP,2)),mean(mean(TP,2)),max(mean(TP,2));
    min(mean(TN,2)),mean(mean(TN,2)),max(mean(TN,2));
    min(mean(FP,2)),mean(mean(FP,2)),max(mean(FP,2));
    min(mean(FN,2)),mean(mean(FN,2)),max(mean(FN,2));].*100/NTrain;
  bar(barVal);
  set(gca,'XTickLabel',{'TP','TN','FP','FN'}); xlim([0.5 4.5]); 
  colormap('cool');
  ylabel('%');
  grid on;
  suptitle(['Train results, ',featureName]);
  
  disp(['Optimal threshold (train): ',num2str(th(idx))]);
  f=figure;
  set(f,'PaperPositionMode','auto');
  set(f,'Position',[0 100 600 300]);
  set(f,'DefaultAxesLooseInset',[0,0.1,0,0]);
  subplot(1,2,1);
  barVal=[min(mean(TP,2)),mean(mean(TP,2)),max(mean(TP,2));
      min(mean(TN,2)),mean(mean(TN,2)),max(mean(TN,2));
      min(mean(FP,2)),mean(mean(FP,2)),max(mean(FP,2));
      min(mean(FN,2)),mean(mean(FN,2)),max(mean(FN,2));].*100/NTrain;
  b1=bar(barVal);
  set(gca,'XTickLabel',{'TP','TN','FP','FN'}); xlim([0.5 4.5]);
  colormap(gca,'cool');
  ylabel('%');
  title('Train');
  grid on;
  subplot(1,2,2);
  barVal=[min(TP_Test),mean(TP_Test),max(TP_Test);
    min(TN_Test),mean(TN_Test),max(TN_Test);
    min(FP_Test),mean(FP_Test),max(FP_Test);
    min(FN_Test),mean(FN_Test),max(FN_Test);].*100/NTest;
  bar(barVal);
  set(gca,'XTickLabel',{'TP','TN','FP','FN'}); xlim([0.5 4.5]);
  colormap(gca,'cool');
  ylabel('%');
  title('Test');
  grid on;
  
  disp(['Accuracy: ',num2str(mean(accuracy_Test))]);
  disp(['Precision: ',num2str(mean(precision_Test))]);
  disp(['Recall: ',num2str(mean(recall_Test))]);
  disp(['F1 score: ',num2str(mean(F1_Test))]);
end