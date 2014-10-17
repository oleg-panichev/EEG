addpath('code');
addpath('classes');
addpath('plot');
prepareWorkspace();

run('processingProperties.m');

% Data location
wpath='eeg_data/aes_spc/'; % Directory containing db
reportwpath='kaggle_reports/';

% Prepare report dir
if (~exist(reportwpath,'dir'))
  mkdir(reportwpath);
end

% List of patients
items=dir(wpath);
dirs={items([items.isdir]).name};
patBuf=dirs(3:end);

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
  piNum=numel(piBuf);
   
  s=load([wpath,'/',patBuf{patIdx},'/pi/',piBuf{1}]);
  names = fieldnames(s);
  s=eval(['s.',names{1}]);
  items=dir([wpath,'/',patBuf{patIdx},'/ii/']);
  dirs={items.name};
  iiBuf=dirs(3:end);
  iiNum=numel(iiBuf);    
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
  for n=2:piNum
    disp([piBuf{n},'...']);
    s=load([wpath,'/',patBuf{patIdx},'/pi/',piBuf{n}]);
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
  
  figure
  features=var(featuresBuf,1,1);
  plot(features)
  mean(features(1:30))
  mean(features(31:end))
  
  figure
  features=[mean(featuresBuf,1);var(featuresBuf,1,1)];
  plot(features(1,1:30),features(2,1:30),'r.'); hold on;
  plot(features(1,31:end),features(2,31:end),'b.');
  
  
  figure
  idx=1;
  for i=1:6
    hx(i)=subplot(1,7,i*idx);
    bp=boxplot(features(2,[i+6*(0:4)]));
    set(bp,'linewidth',2);
    title(['Preictal var. ',num2str(i)]);
    grid on;
  end
  hx(7)=subplot(1,7,7);
  bp=boxplot(features(2,31:end));
  set(bp,'linewidth',2);
  title('Interictal variance');
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
  
  piDeu=[];
  piDchsq=[];
  for m=1:nOfObservations/2
    for n=m+1:nOfObservations/2
      piDeu=[piDeu,euDist(n,m)];
      piDchsq=[piDchsq,chsqDist(n,m)];
    end
  end
  
  iiDeu=[];
  iiDchsq=[];
  for m=nOfObservations/2+1:nOfObservations
    for n=m+1:nOfObservations
      iiDeu=[iiDeu,euDist(n,m)];
      iiDchsq=[iiDchsq,chsqDist(n,m)];
    end
  end
  
  iipiDeu=[];
  iipiDchsq=[];
  for m=1:nOfObservations/2
    for n=nOfObservations/2+1:nOfObservations
      iipiDeu=[iipiDeu,euDist(n,m)];
      iipiDchsq=[iipiDchsq,chsqDist(n,m)];
    end
  end
  
  figure
  plot(piDeu,piDchsq,'b.'); hold on;
  plot(iiDeu,iiDchsq,'g.'); hold on;
  plot(iipiDeu,iipiDchsq,'r.'); hold on;
  legend('pi-pi','ii-ii','ii-pi');
end

% Analysis
p=randperm(30);
trainPI=featuresBuf(p(1:21));
testPI=featuresBuf(p(22:30));

y=[ones(30,1);zeros(450,1)];
th=[0.5:0.1:2].*1e5;
acuuracy==zeros(size(th));
precision=zeros(size(th));
recall=zeros(size(th));
F1=zeros(size(th));
idx=1;
for i=th
  res=features(2,:)<i;
  TP=0;
  FP=0;
  FN=0;
  TN=0;
  for m=1:length(y)
    if (y(m)==1 && res(m)==1)
      TP=TP+1;
    elseif (y(m)==0 && res(m)==1)
      FP=FP+1;
    elseif (y(m)==1 && res(m)==0)
      FN=FN+1;
    elseif (y(m)==0 && res(m)==0)
      TN=TN+1;
    end
  end
  accuracy(idx)=(TP+TN)/numel(y);
  precision(idx)=TP/(TP+FP);
  recall(idx)=TP/(TP+FN);
  F1(idx)=2*precision(idx)*recall(idx)/(precision(idx)+recall(idx));
  idx=idx+1;
end

figure
subplot(2,2,1);
plot(th,accuracy,'Linewidth',2);
ylabel('Accuracy'); xlabel('threshold'); grid on;
subplot(2,2,2);
plot(th,precision,'Linewidth',2);
ylabel('Precesion'); xlabel('threshold'); grid on;
subplot(2,2,3);
plot(th,recall,'Linewidth',2);
ylabel('Recall'); xlabel('threshold'); grid on;
subplot(2,2,4);
plot(th,F1,'Linewidth',2);
ylabel('F1 score'); xlabel('threshold'); grid on;

% Prepare all features
for patIdx=1:numel(patBuf)
  
end