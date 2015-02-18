function fig=plotROCs(propertiesFunction,R)
  propertiesFunction();
  clNum=numel(classifierNames);

  sigList=[];
  for sigIdx=1:numel(signalsWorkList.id)
    sigList=[sigList,',',num2str(signalsWorkList.id(sigIdx))];
  end
  sigList=sigList(2:end);
  fNamesStr=[];
  for fListIdx=1:numel(fList)
    fNamesStr=[fNamesStr,fList{fListIdx},','];
  end
  fNamesStr=fNamesStr(1:end-1); % List of used features
  
  colors=[0 0 1; 1 0 0; 0 1 0; 1 0.75 0; 1 0 1; 0 1 1];
  fig=figure;
  set(fig,'PaperPositionMode','auto');
  set(fig,'Position',[0 100 1300 400]);
  set(fig,'DefaultAxesLooseInset',[0,0.1,0,0]);
  
  subplot(1,3,1);
  leg=[classifierNames,'0.5'];
  for i=1:clNum
    plot(R(i).FPR_ROC_tr,R(i).TPR_ROC_tr, ...
      'Color',colors(i,:),'Linewidth',2); hold on;    
    leg{i}=[leg{i},', AUC=',num2str(R(i).AUC_tr_av)];
  end  
  plot(0:0.1:1,0:0.1:1,'--','Color',[0 0 0]);  
  legend(leg,'Location','SouthEast');
  title('ROC Train'); xlabel('FPR'); ylabel('TPR'); grid on;
  
  subplot(1,3,2);
  leg=[classifierNames,'0.5'];
  for i=1:clNum
    plot(R(i).FPR_ROC_cv,R(i).TPR_ROC_cv, ...
      'Color',colors(i,:),'Linewidth',2); hold on;    
    leg{i}=[leg{i},', AUC=',num2str(R(i).AUC_cv_av)];
  end  
  plot(0:0.1:1,0:0.1:1,'--','Color',[0 0 0]);  
  legend(leg,'Location','SouthEast');
  title('ROC CV'); xlabel('FPR'); ylabel('TPR'); grid on;
  
  subplot(1,3,3);
  leg=[classifierNames,'0.5'];
  for i=1:clNum
    plot(R(i).FPR_ROC_ts,R(i).TPR_ROC_ts, ...
      'Color',colors(i,:),'Linewidth',2); hold on;    
    leg{i}=[leg{i},', AUC=',num2str(R(i).AUC_ts_av)];
  end  
  plot(0:0.1:1,0:0.1:1,'--','Color',[0 0 0]);  
  legend(leg,'Location','SouthEast');
  title('ROC Test'); xlabel('FPR'); ylabel('TPR'); grid on;

  ttl=suptitle({fNamesStr;['Signal IDs: ',sigList,', PI length: ',...
    num2str(preictalTime),', Train/CV/Test: 60/20/20%']});
  set(ttl,'Interpreter','none','Fontsize',10);
  legend(leg,'Location','SouthEast'); 
end