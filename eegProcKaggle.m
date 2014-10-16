addpath('code');
addpath('classes');
addpath('plot');
prepareWorkspace();

% Data location
wpath='eeg_data/aes_spc/'; % Directory containing db
reportwpath='kaggle_reports/';

if (~exist(reportwpath,'dir'))
  mkdir(reportwpath);
end

items=dir(wpath);
dirs={items([items.isdir]).name};
patBuf=dirs(3:end);

% Processing parameters
miWindowSize=0.25; % Seconds
patientsIdxBuf=[1,3,4,5,8,9,10,15,18,19,20,23];
medianCoef=0.9; 
nOfInterIctal=16;

% Data and features research
for patIdx=1:numel(patBuf)
  disp(['Processing: ',patBuf{patIdx}]);
  
  if (~exist([reportwpath,patBuf{patIdx}],'dir'))
    mkdir([reportwpath,patBuf{patIdx}]);
  end
  
  % Processing preictal data
  items=dir([wpath,'/',patBuf{patIdx},'/pi/']);
  dirs={items.name};
  piBuf=dirs(3:end);
  piNum=numel(piBuf);
  
  shiftLabels=cell(1,2*piNum);
  for i=1:piNum
    shiftLabels{i}=['PI',num2str(i)];
    shiftLabels{i+piNum}=['II',num2str(i)];
  end
  
  s=load([wpath,'/',patBuf{patIdx},'/pi/',piBuf{1}]);
  names = fieldnames(s);
  s=eval(['s.',names{1}]);
  
  chNum=numel(s.channels);
  fs=s.sampling_frequency;
  miChNum=sum(1:(chNum-1));
  featuresBuf=zeros(miChNum,2*piNum);
  
  for i=1:piNum
    disp([piBuf{i},'...']);
    s=load([wpath,'/',patBuf{patIdx},'/pi/',piBuf{i}]);
    names = fieldnames(s);
    s=eval(['s.',names{1}]);
    featuresBuf(:,i)=muinfoMultiChannel(s.data,1, ...
      round(miWindowSize*fs),s.channels);
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
    featuresBuf(:,i+piNum)=muinfoMultiChannel(s.data,1, ...
      round(miWindowSize*fs),s.channels);
  end
  
  titleStr={['Mutual information, ',patBuf{patIdx}],['miWindowSize = ',...
    num2str(miWindowSize),'s']};
  f=plotDataBoxplot(featuresBuf,shiftLabels,titleStr);
  savePlot2File(f,'png',[reportwpath,'/',patBuf{patIdx},'/'],...
    ['MI_BPlot_miWinSz=',num2str(miWindowSize),'s']);
  
  % Distance between MI-points in multidim. space
  [euDist,brcudiss,brcusim]=distances(featuresBuf);
  titleStr=['miWindowSize = ',num2str(miWindowSize),'s'];
  f=plotDistances(euDist,brcudiss,brcusim,shiftLabels,titleStr);
  savePlot2File(f,'png',[reportwpath,'/',patBuf{patIdx},'/'],['MI_Distance_miWinSz=', ...
    num2str(miWindowSize),'s']);
end

% Prepare all features
for patIdx=1:numel(patBuf)
  
end