addpath('code');
addpath('classes');
addpath('classifiers');
% addpath('lr');
addpath('plot');
prepareWorkspace();

run('processingProperties.m');
items=dir(wpath);
dirs={items([items.isdir]).name};
patBuf=dirs(3:end);

XTrain=[];
XTest=[];
featuresList={};

% Load all data
patData=cell(numel(patBuf),1);
fNamesList={'euDist av','euDistSort av','MI av'};

for patIdx=1:numel(patBuf)
  [X,fNamesStr]=loadFeaturesList(fNamesList,[reportPath,patBuf{patIdx},'/',trainPath]);
  
  s=load([reportPath,patBuf{patIdx},'/',trainPath,'y.mat']);
  Y=s.y;
  s=load([reportPath,patBuf{patIdx},'/',trainPath,'s.mat']);
  S=s.sequence;
  
  data=struct('X',X,'Y',Y,'S',S);
  patData{patIdx}=data;
end

% {'threshold','nbayes','logit','svm','tree','knn'}
classifierNames={'nbayes','logit'};

clNum=numel(classifierNames);
T=cell(clNum,1);
TWght=cell(clNum,1);
ROCs=cell(clNum,1);
ROCsWght=cell(clNum,1);

for i=1:clNum
  [T{i},TWght{i},ROCs{i},ROCsWght{i},~]=runIndClassification(patData,classifierNames{i},patBuf);
  
  t=cell(1,2);
  t{1,1}=classifierNames{i};
  t{2,1}=fNamesStr;
  t=cell2table(t);
  writetable(t,'classification_results.xlsx','Sheet',i,...
    'WriteRowNames',false,'WriteVariableNames',false,'Range','A1');
  writetable(T{i},'classification_results.xlsx','Sheet',i,...
    'WriteRowNames',true,'Range','A3');
  writetable(TWght{i},'classification_results.xlsx','Sheet',i,...
    'WriteRowNames',false,'Range','K3'); 
end

colors=[0 0 1; 1 0 0; 0 1 0; 1 0.75 0; 1 0 1; 0 0 1];
fig=figure;
set(fig,'PaperPositionMode','auto');
set(fig,'Position',[0 100 2000 1000]);
set(fig,'DefaultAxesLooseInset',[0,0.1,0,0]);
for patIdx=1:numel(patBuf)
  subplot(2,4,patIdx);
  for i=1:clNum
    if (numel(ROCs{i,1}{patIdx,1})>0)
      plot(ROCs{i,1}{patIdx,1}(:,1),ROCs{i,1}{patIdx,1}(:,2), ...
        'Color',colors(i,:),'Linewidth',2); hold on;      
    end
  end
  plot(0:0.1:1,0:0.1:1,'--','Color',[0 0 0]);  
  legend([classifierNames,'0.5'],'Location','SouthEast');
  title(patBuf{patIdx}); 
  xlabel('FPR'); ylabel('TPR'); grid on;
end
suptitle({fNamesStr,'Train/Test = 60/40%, Not weighted data'});
savePlot2File(fig,'png',reportPath,'Classification_results');

fig=figure;
set(fig,'PaperPositionMode','auto');
set(fig,'Position',[0 100 1350 600]);
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
  legend([classifierNames,'0.5'],'Location','SouthEast');
  title(patBuf{patIdx}); 
  xlabel('FPR'); ylabel('TPR'); grid on;
end
suptitle('Train/Test = 60/40%, Weighted data');
savePlot2File(fig,'png',reportPath,'Classification_results_wght');


% t=clock;
% fileID=fopen(['submit_',num2str(t(1)),num2str(t(2)),num2str(t(3)),...
%   '_',num2str(t(4)),num2str(t(5)),'.csv'],'w');
% fprintf(fileID,'clip,preictal\n');
% nOfPi=0;
% for i=1:size(XTest,1)
%   fprintf(fileID,[sNamesBuf_Test{i},',%d\n'],RSLT(i));
% end
% fclose(fileID);
