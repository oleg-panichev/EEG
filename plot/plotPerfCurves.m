function f=plotPerfCurves(ACC,PPV,TPR,SPC,FPR,F1,AUC,T)
  f=figure;
  set(f,'PaperPositionMode','auto');
  set(f,'Position',[0 100 1130 570]);
  set(f,'DefaultAxesLooseInset',[0,0.1,0,0]);
%   subplot(2,3,1);
%   plot(T,max(ACC,[],1),'g'); hold on;
%   plot(T,mean(ACC,1),'LinewidT',2); hold on;
%   plot(T,min(ACC,[],1),'r');
%   ylabel('Accuracy'); xlabel('Treshold'); xlim([T(1) T(end)]); grid on;
%   legend('Max','Mean','Min');
  subplot(2,3,1);
  plot(T,max(PPV,[],1),'g'); hold on;
  plot(T,mean(PPV,1),'LinewidT',2); hold on; 
  plot(T,min(PPV,[],1),'r');
  ylabel('Precision'); xlabel('Treshold'); xlim([T(1) T(end)]); grid on;
  legend('Max','Mean','Min');
  
  subplot(2,3,2);
  plot(T,max(TPR,[],1),'g'); hold on;
  plot(T,mean(TPR,1),'LinewidT',2); hold on;  
  plot(T,min(TPR,[],1),'r');
  ylabel('Sensitivity'); xlabel('Treshold'); xlim([T(1) T(end)]); grid on;
  legend('Max','Mean','Min');
  
  subplot(2,3,3);
  plot(T,max(SPC,[],1),'g'); hold on;
  plot(T,mean(SPC,1),'LinewidT',2); hold on;  
  plot(T,min(SPC,[],1),'r');
  ylabel('Specificity'); xlabel('Treshold'); xlim([T(1) T(end)]); grid on;
  legend('Max','Mean','Min'); 
  
  subplot(2,3,4);
  SS=2*TPR.*SPC./(TPR+SPC);
  plot(T,max(SS,[],1),'g'); hold on;
  plot(T,mean(SS,1),'LinewidT',2); hold on; 
  plot(T,min(SS,[],1),'r'); hold on;
  meanSS=mean(SS,1);
  [~,idx]=max(meanSS);
  plot(T(idx),meanSS(idx),'r*');
  ylabel('SS score'); xlabel('Treshold'); xlim([T(1) T(end)]); grid on;
  legend('Max','Mean','Min');
  
  subplot(2,3,5);
  plot(T,max(F1,[],1),'g'); hold on;
  plot(T,mean(F1,1),'LinewidT',2); hold on; 
  plot(T,min(F1,[],1),'r'); hold on;
  meanF1=mean(F1,1);
  [~,idx]=max(meanF1);
  plot(T(idx),meanF1(idx),'r*');
  ylabel('F1 score'); xlabel('Treshold'); xlim([T(1) T(end)]); grid on;
  legend('Max','Mean','Min');
  
  subplot(2,3,6);
%   plot(max(FPR,1),max(TPR,1),'g'); hold on;
  plot(mean(FPR,1),mean(TPR,1),'Linewidth',2); hold on; 
  plot(0:0.01:1,0:0.01:1,'r-.');
%   plot(min(FPR,1),min(TPR,1),'r'); hold on;
  ylabel('TPR'); xlabel('FPR'); title({'ROC Curve',['mean(AUC)=',...
    num2str(mean(AUC)),', std(AUC)=',num2str(std(AUC))]}); 
  xlim([0 1]); ylim([0 1]); grid on;
%   legend('Max','Mean','Min');
end