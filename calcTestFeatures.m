addpath('code');
addpath('classes');
addpath('plot');
prepareWorkspace();

run('processingProperties.m');

% Prepare report dir
if (~exist(reportPath,'dir'))
  mkdir(reportPath);
end

% Load list of patients
items=dir(wpath);
dirs={items([items.isdir]).name};
patBuf=dirs(3:end);

X=[]; % Total features matrix
I=[]; % Total patient index
sNamesBuf=[];

% Data and features research
for patIdx=1:1%numel(patBuf)
  disp(['Processing: ',patBuf{patIdx}]);
  % Prepare report dir for patient
  if (~exist([reportPath,patBuf{patIdx}],'dir'))
    mkdir([reportPath,patBuf{patIdx}]);
  end 
  % Load parameters of all patient's signals
  items=dir([wpath,'/',patBuf{patIdx},'/test/']);
  dirs={items.name};
  testBuf=dirs(3:end);
  testNum=numel(testBuf); % Number of preictal signals to process 
   
  s=load([wpath,'/',patBuf{patIdx},'/test/',testBuf{1}]);
  names=fieldnames(s);
  s=eval(['s.',names{1}]);  
  
  I=[I;ones(testNum,1)*patIdx];
  
  %Processing preictal data
  disp([testBuf{1},'...']);
  s=load([wpath,'/',patBuf{patIdx},'/test/',testBuf{1}]);
  names = fieldnames(s);
  s=eval(['s.',names{1}]);
  [features,yLabels]=prepareFeatures(s);
  featuresBuf=zeros(numel(features),testNum);
  featuresBuf(:,1)=features;
  featureIdx=2;
  for i=2:testNum
    disp([testBuf{i},'...']);
    s=load([wpath,'/',patBuf{patIdx},'/test/',testBuf{i}]);
    names = fieldnames(s);
    s=eval(['s.',names{1}]);
    [featuresBuf(:,featureIdx),~]=prepareFeatures(s);
    featureIdx=featureIdx+1;
  end
  
  % Store calculated data in total buffers
  X=[X;featuresBuf'];
  sNamesBuf=[sNamesBuf,testBuf];
  
  Z=featuresBuf';
  x=Z(:,1);
  featureName='Euc Distance mean';
  save([reportPath,'/',patBuf{patIdx},'/',featureName,'.mat'],'x');
  x=Z(:,2);
  featureName='Euc Distance variance';
  save([reportPath,'/',patBuf{patIdx},'/',featureName,'.mat'],'x');
  x=Z(:,3);
  featureName='Squared Euc Distance variance';
  save([reportPath,'/',patBuf{patIdx},'/',featureName,'.mat'],'x');
  save([reportPath,'/',patBuf{patIdx},'/','sNamesBuf.mat'],'testBuf');
  i=ones(testNum,1)*patIdx;
  save([reportPath,'/',patBuf{patIdx},'/','i','.mat'],'i');
end


x=X(:,1);
featureName='Euc Distance mean';
save([testPath,featureName,'.mat'],'x');
x=X(:,2);
featureName='Euc Distance variance';
save([testPath,featureName,'.mat'],'x');
x=X(:,3);
featureName='Squared Euc Distance variance';
save([testPath,featureName,'.mat'],'x');
save([testPath,'i','.mat'],'I');
save([testPath,'sNamesBuf.mat'],'sNamesBuf');