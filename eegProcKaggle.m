addpath('code');
addpath('classes');
addpath('plot');
prepareWorkspace();

run('processingProperties.m');

% Prepare report dir
if (~exist(reportwpath,'dir'))
  mkdir(reportwpath);
end

% Load list of patients
items=dir(wpath);
dirs={items([items.isdir]).name};
patBuf=dirs(3:end);

X=[]; % Total features matrix
Y=[]; % Total output matrix

% Data and features research
for patIdx=1:numel(patBuf)
  disp(['Processing: ',patBuf{patIdx}]);
  % Prepare report dir for patient
  if (~exist([reportwpath,patBuf{patIdx}],'dir'))
    mkdir([reportwpath,patBuf{patIdx}]);
  end 
  % Load parameters of all patient's signals
  items=dir([wpath,'/',patBuf{patIdx},'/pi/']);
  dirs={items.name};
  piBuf=dirs(3:end);
  piNum=numel(piBuf); % Number of preictal signals to process 
   
  s=load([wpath,'/',patBuf{patIdx},'/pi/',piBuf{1}]);
  names = fieldnames(s);
  s=eval(['s.',names{1}]);
  items=dir([wpath,'/',patBuf{patIdx},'/ii/']);
  dirs={items.name};
  iiBuf=dirs(3:end);
  iiNum=90; %numel(iiBuf); % Number of interictal signals to process    
  nOfObservations=piNum+iiNum; 
  
  %Processing preictal data
  disp([piBuf{1},'...']);
  s=load([wpath,'/',patBuf{patIdx},'/pi/',piBuf{1}]);
  names = fieldnames(s);
  s=eval(['s.',names{1}]);
  [features,yLabels]=prepareFeatures(s);
  featuresBuf=zeros(numel(features),nOfObservations);
  featuresBuf(:,1)=features;
  featureIdx=2;
  for i=2:piNum
    disp([piBuf{i},'...']);
    s=load([wpath,'/',patBuf{patIdx},'/pi/',piBuf{i}]);
    names = fieldnames(s);
    s=eval(['s.',names{1}]);
    [featuresBuf(:,featureIdx),~]=prepareFeatures(s);
    featureIdx=featureIdx+1;
  end
  
  % Processing interictal data
  for i=1:iiNum
    disp([iiBuf{i},'...']);
    s=load([wpath,'/',patBuf{patIdx},'/ii/',iiBuf{i}]);
    names=fieldnames(s);
    s=eval(['s.',names{1}]);
    [featuresBuf(:,featureIdx),~]=prepareFeatures(s);
    featureIdx=featureIdx+1;
  end
  
  % Observation labels
  xLabels=cell(1,nOfObservations);
  for i=1:nOfObservations
    if (i<=piNum)
      xLabels{i}=['PI',num2str(i)];
    else
      xLabels{i}=['II',num2str(i-piNum)];
    end
  end
  
  % Analyze features
  disp(['Mean preictal value: ',num2str(mean(features(1:30)))]);
  disp(['Mean interictal value: ',num2str(mean(features(31:end)))]);
  
  f=figure;
  features=[mean(featuresBuf,1);var(featuresBuf,1,1)];
  plot(features(1,1:30),features(2,1:30),'r.'); hold on;
  plot(features(1,31:end),features(2,31:end),'b.');  
  
  f=figure;
  for i=1:6
    hx(i)=subplot(1,7,i);
    titleStr={'Preictal','Variance'};
    bp=boxplot(features(2,[i+6*(0:4)]),[num2str((i-1)*10),'-',num2str(i*10)]);
    title(titleStr);
    set(bp,'linewidth',2);
    grid on;
  end
  hx(7)=subplot(1,7,7);
  titleStr={'Interictal','Variance'};
  bp=boxplot(features(2,31:end));
  set(bp,'linewidth',2);
  title(titleStr);
  grid on;
  linkaxes(hx,'y');
  
  figure
  clear hx;
  hx(1)=subplot(1,2,1);
  bp=boxplot(features(2,1:30));
  set(bp,'linewidth',2);
  title(['Preictal var. ',num2str(i)]);
  grid on;
  hx(2)=subplot(1,2,2);
  bp=boxplot(features(2,31:end));
  set(bp,'linewidth',2);
  title('Interictal variance');
  grid on;
  linkaxes(hx,'y');
  
%   % Feature reduction
%   avPi=mean(featuresBuf(:,1:60),2);
%   avIi=mean(featuresBuf(:,61:120),2);
% %   for i=1:size(featuresBuf,1)
% %     featuresBuf(i,:)=(featuresBuf(i,:)-mean(featuresBuf(i,:)))/std(featuresBuf(i,:));
% %   end boxplot
%   changes=abs(avPi-avIi);
%   [B,I]=sort(changes);
%   featuresBuf=featuresBuf(I(end-10:end),:);
%   miLabels=miLabels(I(end-10:end));
  
  % Plot features 
  titleStr=({'Features'});
  f=plotData(featuresBuf,xLabels,yLabels,titleStr);
  savePlot2File(f,'png',[reportwpath,'/',patBuf{patIdx},'/'],['MI_Image_miWinSz',num2str(miWindowSize),'s']);
  savePlot2File(f,'fig',[reportwpath,'/',patBuf{patIdx},'/'],['MI_Image_miWinSz',num2str(miWindowSize),'s']);
          
  % Boxplots        
  titleStr={['Features, ',patBuf{patIdx}],['miWindowSize = ',...
    num2str(miWindowSize),'s']};
  f=plotDataBoxplot(featuresBuf,xLabels,titleStr);
  savePlot2File(f,'png',[reportwpath,'/',patBuf{patIdx},'/'],...
    ['MI_BPlot_miWinSz=',num2str(miWindowSize),'s']);
  
  % Distance between MI-points in multidim. space
  [euDist,brcudiss,brcusim,chsqDist,cbDist]=distances(featuresBuf);
  titleStr=['miWindowSize = ',num2str(miWindowSize),'s'];
  f=plotDistances(euDist,brcudiss,chsqDist,cbDist,xLabels,titleStr);
  savePlot2File(f,'png',[reportwpath,'/',patBuf{patIdx},'/'],['MI_Distance_miWinSz=', ...
    num2str(miWindowSize),'s']);
  
  % Store calculated data in total buffers
  X=[X;featuresBuf'];
  Y=[Y;ones(piNum,1);zeros(iiNum,1)];
end

% Analysis
m=size(X,2);
N=numel(Y);
th=[0.5:0.02:2].*1e5;
accuracy=zeros(size(th));
precision=zeros(size(th));
recall=zeros(size(th));
F1=zeros(size(th));
TP=zeros(size(th));
FP=zeros(size(th));
FN=zeros(size(th));
TN=zeros(size(th));
idx=1;
for i=th
  res=features(2,:)<i;
  for j=1:N
    if (Y(j)==1 && res(j)==1)
      TP(idx)=TP(idx)+1;
    elseif (Y(j)==0 && res(j)==1)
      FP(idx)=FP(idx)+1;
    elseif (Y(j)==1 && res(j)==0)
      FN(idx)=FN(idx)+1;
    elseif (Y(j)==0 && res(j)==0)
      TN(idx)=TN(idx)+1;
    end
  end
  accuracy(idx)=(TP(idx)+TN(idx))/N;
  precision(idx)=TP(idx)/(TP(idx)+FP(idx));
  recall(idx)=TP(idx)/(TP(idx)+FN(idx));
  F1(idx)=2*precision(idx)*recall(idx)/(precision(idx)+recall(idx));
  idx=idx+1;
end

f=figure;
set(f,'PaperPositionMode','auto');
set(f,'Position',[0 100 1200 600]);
set(f,'DefaultAxesLooseInset',[0,0.1,0,0]);
subplot(2,3,1);
plot(th,accuracy,'Linewidth',2);
ylabel('Accuracy'); xlabel('threshold'); xlim([th(1) th(end)]); grid on;
subplot(2,3,2);
plot(th,precision,'Linewidth',2);
ylabel('Precision'); xlabel('threshold'); xlim([th(1) th(end)]); grid on;
subplot(2,3,3);
plot(th,recall,'Linewidth',2);
ylabel('Recall'); xlabel('threshold'); xlim([th(1) th(end)]); grid on;
subplot(2,3,4);
plot(th,F1,'Linewidth',2); hold on;
[val,idx]=max(F1);
plot(th(idx),F1(idx),'r*');
ylabel('F1 score'); xlabel('threshold'); xlim([th(1) th(end)]); grid on;
subplot(2,3,5);
plot(recall,precision,'Linewidth',2);
ylabel('Precision'); xlabel('Recall'); xlim([recall(1) recall(end)]); grid on;
subplot(2,3,6);
bar([1:4],[TP(idx),TN(idx),FP(idx),FN(idx)]./N,'r');
set(gca,'XTickLabel',{'TP','TN','FP','FN'});
ylabel('%');
grid on;

% Prepare all features
for patIdx=1:numel(patBuf)
  
end