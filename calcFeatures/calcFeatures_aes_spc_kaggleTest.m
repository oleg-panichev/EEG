function calcFeatures_aes_spc_kaggleTest(wpath)
  % Load list of patients
  items=dir(wpath);
  dirs={items([items.isdir]).name};
  patBuf=dirs(3:end);
  
  for patIdx=1:numel(patBuf)
    disp(['Processing: ',patBuf{patIdx}]);
    % Prepare report dir for patient
    if (~exist([wpath,'_features/',patBuf{patIdx}],'dir'))
      mkdir([wpath,'_features/',patBuf{patIdx}]);
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
    nOfObservations=testNum;
    features=cell(nOfObservations,1);
    featureIdx=1;

    %Processing preictal data
    disp([testBuf{1},'...']);
    s=load([wpath,'/',patBuf{patIdx},'/test/',testBuf{1}]);
    names = fieldnames(s);
    s=eval(['s.',names{1}]);
    [features{featureIdx},labels]=prepareFeatures(s); 
    featureIdx=featureIdx+1;
    for i=2:nOfObservations
      disp([testBuf{i},'...']);
      s=load([wpath,'/',patBuf{patIdx},'/test/',testBuf{i}]);
      names = fieldnames(s);
      s=eval(['s.',names{1}]);
      [features{featureIdx},~]=prepareFeatures(s);
      featureIdx=featureIdx+1;
    end

    % Store calculated data in total buffers
    for k=1:numel(labels)
      featureName=labels{k};
      x=getFeaturesFromCell(features,k); 
      save([wpath,'_features/',patBuf{patIdx},'/test/',featureName,'.mat'],'x');
    end

    save([wpath,'_features/',patBuf{patIdx},'/test/','sNamesBuf.mat'],'testBuf');
    i=ones(testNum,1)*patIdx;
    save([wpath,'_features/',patBuf{patIdx},'/test/','i','.mat'],'i');
  end
end