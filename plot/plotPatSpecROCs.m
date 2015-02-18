function plotPatSpecROCs(classifierNames,patBuf,ROCs,ROCsWght,T,TWght,fNamesStr)
  run('processingProperties.m');
  clNum=numel(classifierNames);

  colors=[0 0 1; 1 0 0; 0 1 0; 1 0.75 0; 1 0 1; 0 1 1];
  fig=figure;
  set(fig,'PaperPositionMode','auto');
  set(fig,'Position',[0 100 1300 600]);
  set(fig,'DefaultAxesLooseInset',[0,0.1,0,0]);
  avAUC=zeros(clNum,1);
  avAUCWght=zeros(clNum,1);
  leg=[classifierNames,'0.5'];
  legWght=[classifierNames,'0.5'];
  for i=1:clNum
    avAUC(i)=mean(T{i}.AUC);
    leg{i}=[leg{i},', AUC=',num2str(avAUC(i))];
    avAUCWght(i)=mean(TWght{i}.AUC);
    legWght{i}=[legWght{i},', AUC=',num2str(avAUCWght(i))];
  end
  for patIdx=1:numel(patBuf)
    subplot(2,4,patIdx);
    for i=1:clNum
      if (numel(ROCs{i,1}{patIdx,1})>0)
        plot(ROCs{i,1}{patIdx,1}(:,1),ROCs{i,1}{patIdx,1}(:,2), ...
          'Color',colors(i,:),'Linewidth',2); hold on;      
      end
    end
    plot(0:0.1:1,0:0.1:1,'--','Color',[0 0 0]);  
    if (patIdx==1)
      legend(leg,'Location','SouthEast');
    end
    title(patBuf{patIdx}); 
    xlabel('FPR'); ylabel('TPR'); grid on;
  end
  suptitle([fNamesStr;'Train/Test = 60/40%, Not weighted data']);
  pause;
  savePlot2File(fig,'png',reportPath,'Classification_results');

  fig=figure;
  set(fig,'PaperPositionMode','auto');
  set(fig,'Position',[0 100 1300 600]);
  set(fig,'DefaultAxesLooseInset',[0,0.1,0,0]);
  for patIdx=1:numel(patBuf)
    subplot(2,4,patIdx);
    for i=1:clNum
      if (numel(ROCsWght{i,1}{patIdx,1})>0)
        plot(ROCsWght{i,1}{patIdx,1}(:,1),ROCsWght{i,1}{patIdx,1}(:,2), ...
          'Color',colors(i,:),'Linewidth',2); hold on;      
      end
    end
    plot(0:0.1:1,0:0.1:1,'--','Color',[0 0 0]);  
    if (patIdx==1)
      legend(leg,'Location','SouthEast');
    end
    title(patBuf{patIdx}); 
    xlabel('FPR'); ylabel('TPR'); grid on;
  end
  suptitle('Train/Test = 60/40%, Weighted data');
  pause;
  savePlot2File(fig,'png',reportPath,'Classification_results_wght');
end