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
S=[]; % Total sequence vector

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
  iiNum=numel(iiBuf); % Number of interictal signals to process    
  nOfObservations=piNum+iiNum;
  sequence=zeros(nOfObservations,1);
  
  %Processing preictal data
  disp([piBuf{1},'...']);
  s=load([wpath,'/',patBuf{patIdx},'/pi/',piBuf{1}]);
  names = fieldnames(s);
  s=eval(['s.',names{1}]);
  [features,yLabels]=prepareFeatures(s);
  featuresBuf=zeros(numel(features),nOfObservations);
  featuresBuf(:,1)=features;
  sequence(1)=s.sequence;
  featureIdx=2;
  for i=2:piNum
    disp([piBuf{i},'...']);
    s=load([wpath,'/',patBuf{patIdx},'/pi/',piBuf{i}]);
    names = fieldnames(s);
    s=eval(['s.',names{1}]);
    [featuresBuf(:,featureIdx),~]=prepareFeatures(s);
    featureIdx=featureIdx+1;
    sequence(i)=s.sequence;
  end
  
  % Processing interictal data
  for i=1:iiNum
    disp([iiBuf{i},'...']);
    s=load([wpath,'/',patBuf{patIdx},'/ii/',iiBuf{i}]);
    names=fieldnames(s);
    s=eval(['s.',names{1}]);
    [featuresBuf(:,featureIdx),~]=prepareFeatures(s);
    featureIdx=featureIdx+1;
    sequence(i+piNum)=s.sequence;
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
  S=[S;sequence];
end

save trainFeatures.mat X Y S 
% Analysis
analyzeFeature(X(:,1),Y,S,[],'Eu. Distance mean');
analyzeFeature(X(:,2),Y,S,[],'Eu. Distance variance');
analyzeFeature(X(:,3),Y,S,[],'Squared Eu. Distance variance');

perfcurve
