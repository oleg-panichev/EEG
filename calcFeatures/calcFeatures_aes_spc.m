% Loader function for AES SPC database.
%
% Input:
% wpath - string with location of AES SPC database.
%
function calcFeatures_aes_spc(wpath)
  % Load list of patients
  items=dir(wpath);
  dirs={items([items.isdir]).name};
  patBuf=dirs(3:end);
  
  for patIdx=1:numel(patBuf)
    % Prepare report dir for patient
    if (~exist([wpath,'_features/',patBuf{patIdx}],'dir'))
      mkdir([wpath,'_features/',patBuf{patIdx}]);
    end 
    % Load parameters of all patient's signals
    items=dir([wpath,'/',patBuf{patIdx},'/pi/']);
    dirs={items.name};
    piBuf=dirs(3:end);
    piNum=numel(piBuf); % Number of preictal signals to process 

    s=load([wpath,'/',patBuf{patIdx},'/pi/',piBuf{1}]);
    names=fieldnames(s);
    s=eval(['s.',names{1}]);
    items=dir([wpath,'/',patBuf{patIdx},'/ii/']);
    dirs={items.name};
    iiBuf=dirs(3:end);
    iiNum=numel(iiBuf); % Number of interictal signals to process    
    nOfObservations=piNum+iiNum;
    sequence=zeros(nOfObservations,1);

    features=cell(nOfObservations,1);
    featureIdx=1;

    % Processing preictal data
    disp([piBuf{1},'...']);
    s=load([wpath,'/',patBuf{patIdx},'/pi/',piBuf{1}]);
    names=fieldnames(s);
    s=eval(['s.',names{1}]); 
    [features{featureIdx},labels]=prepareFeatures(s); 
    featureIdx=featureIdx+1;
    sequence(1)=s.sequence;
    for i=2:piNum
      disp([piBuf{i},'...']);
      s=load([wpath,'/',patBuf{patIdx},'/pi/',piBuf{i}]);
      names = fieldnames(s);
      s=eval(['s.',names{1}]);
      [features{featureIdx},~]=prepareFeatures(s); 
      featureIdx=featureIdx+1;
      sequence(i)=s.sequence;
    end

    % Processing interictal data
    for i=1:iiNum
      disp([iiBuf{i},'...']);
      s=load([wpath,'/',patBuf{patIdx},'/ii/',iiBuf{i}]);
      names=fieldnames(s);
      s=eval(['s.',names{1}]);
      [features{featureIdx},~]=prepareFeatures(s); 
      featureIdx=featureIdx+1;
      sequence(i+piNum)=s.sequence;
    end
    
    if (~exist([reportPath,'/',patBuf{patIdx},'/train/'],'dir'))
      mkdir([reportPath,'/',patBuf{patIdx},'/train/']);
    end
    intChNum=sum(1:(numel(s.channels)-1));
    
    for k=1:numel(labels)
      featureName=labels{k};
      x=getFeaturesFromCell(features,k); 
      save([wpath,'_features/',patBuf{patIdx},'/train/',featureName,'.mat'],'x');
    end

    i=ones(nOfObservations,1)*patIdx;
    save([wpath,'_features/',patBuf{patIdx},'/train/','i','.mat'],'i');
    y=[ones(piNum,1);zeros(iiNum,1)];
    save([wpath,'_features/',patBuf{patIdx},'/train/','y','.mat'],'y');
    save([wpath,'_features/',patBuf{patIdx},'/train/','s','.mat'],'sequence');
  end
end