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

for patIdx=1:numel(patBuf)
  X=[];
%   fName='MI';
%   s=load([reportPath,patBuf{patIdx},'/',trainPath,fName,'.mat']);
%   X=[X,s.x];
%   featuresList=[featuresList,fName];
  
  fName='MI av';
  s=load([reportPath,patBuf{patIdx},'/',trainPath,fName,'.mat']);
  X=[X,s.x];
  featuresList=[featuresList,fName];
  
  fName='euDist av';
  s=load([reportPath,patBuf{patIdx},'/',trainPath,fName,'.mat']);
  X=[X,s.x];
  featuresList=[featuresList,fName];
  
  fName='euDistSort av';
  s=load([reportPath,patBuf{patIdx},'/',trainPath,fName,'.mat']);
  X=[X,s.x];
  featuresList=[featuresList,fName];
  
  s=load([reportPath,patBuf{patIdx},'/',trainPath,'y.mat']);
  Y=s.y;
  s=load([reportPath,patBuf{patIdx},'/',trainPath,'s.mat']);
  S=s.sequence;
  
  data=struct('X',X,'Y',Y,'S',S);
  patData{patIdx}=data;
end

% {'threshold','nbayes','logit','svm','tree','knn'}
classifierNames={'nbayes','logit','svm','tree','knn'};

clNum=numel(classifierNames);
T=cell(clNum,1);
TWght=cell(clNum,1);
ROCs=cell(clNum,1);
ROCsWght=cell(clNum,1);

for i=1:clNum
  [T{i},TWght{i},ROCs{i},ROCsWght{i},~]=runIndClassification(patData,classifierNames{i},patBuf);
  
%   writetable(t1,'classification_results.xlsx','Sheet',i,'WriteRowNames',true);
%   writetable(t2,'classification_results.xlsx','Sheet',i,'WriteRowNames',false,'Range','K1'); 

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
suptitle('Train/Test = 60/40%, Not weighted data');
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
