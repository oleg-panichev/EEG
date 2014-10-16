addpath('code');
addpath('classes');
addpath('plot');
prepareWorkspace();

run('properties.m');

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
  nOfObservations=2*piNum;  
  s=load([wpath,'/',patBuf{patIdx},'/pi/',piBuf{1}]);
  names = fieldnames(s);
  s=eval(['s.',names{1}]);
  
  % Observation labels
  xLabels=cell(1,nOfObservations);
  for i=1:piNum
    xLabels{i}=['PI',num2str(i)];
    xLabels{i+piNum}=['II',num2str(i)];
  end
  
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
  items=dir([wpath,'/',patBuf{patIdx},'/ii/']);
  dirs={items.name};
  iiBuf=dirs(3:end);
  iiNum=numel(iiBuf);  
  for i=1:piNum
    disp([iiBuf{i},'...']);
    s=load([wpath,'/',patBuf{patIdx},'/ii/',iiBuf{i}]);
    names=fieldnames(s);
    s=eval(['s.',names{1}]);
    [featuresBuf(:,featureIdx),~]=prepareFeatures(s);
    featureIdx=featureIdx+1;
  end
  
  
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
  
  % Plot MI 
  titleStr=({'MI between channels'});
  f=plotData(featuresBuf,xLabels,yLabels,titleStr);
  savePlot2File(f,'png',[reportwpath,'/',patBuf{patIdx},'/'],['MI_Image_miWinSz',num2str(miWindowSize),'s']);
  savePlot2File(f,'fig',[reportwpath,'/',patBuf{patIdx},'/'],['MI_Image_miWinSz',num2str(miWindowSize),'s']);
          
  % Boxplots        
  titleStr={['Mutual information, ',patBuf{patIdx}],['miWindowSize = ',...
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

% Prepare all features
for patIdx=1:numel(patBuf)
  
end