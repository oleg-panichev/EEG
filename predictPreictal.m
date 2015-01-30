function predictPreictal(propertiesFunction)
  addpath('calcFeatures');
  addpath('classes');
  addpath('code');
  addpath('plot');
  prepareWorkspace();
  propertiesFunction();

  % Prepare dirs for features
  if (~exist(repLocation,'dir'))
    mkdir(repLocation);
  end
  
  % Load feature list and choose same features for all patients
  fNamesList=cell(numel(sigId),numel(fList));
  for sigIdx=1:numel(signalsWorkList.id)
    tic;
    disp(signalsWorkList.mat_address{sigIdx});
    switch signalsWorkList.sigType{sigIdx}
      case 'aes_spc'

      case 'mat_zhukov'    
        dir2open=[ftLocation,signalsWorkList.mat_address{sigIdx}(1:end-4),'/'];
        for fIdx=1:numel(fList)
          s=load([dir2open,fList{fIdx}],'fLabels');
          fNamesList{sigIdx,fIdx}=s.fLabels;
        end
      otherwise
        warning(['There are np aproriate method to process signals of ',...
          'type ',signalsWorkList.sigType(sigIdx),'! Signal with ID = ',...
          num2str(signalsWorkList.id(sigIdx)),' has been skipped.']);
    end
    t=toc;
    disp(['Elapsed time: ',num2str(t),'s']);
  end

  disp('Selecting features...');
  tic;
  fIdxMatrices=selectSameFeatures(fNamesList);
  t=toc;
  disp(['Elapsed time: ',num2str(t),'s']);
  
  % Load all features in one buffer
  X=[];
  tBeforeSz=[];
  tAfterSz=[];
  for sigIdx=1:numel(signalsWorkList.id)
    tic;
    disp(signalsWorkList.mat_address{sigIdx});
    switch signalsWorkList.sigType{sigIdx}
      case 'aes_spc'

      case 'mat_zhukov'    
        dir2open=[ftLocation,signalsWorkList.mat_address{sigIdx}(1:end-4),'/'];
        for fIdx=1:numel(fList)
          s=load([dir2open,fList{fIdx}]);
          X=[X;s.x(:,fIdxMatrices{fIdx}(sigIdx,:))];
          tBeforeSz=[tBeforeSz,s.tBeforeSz];
          tAfterSz=[tAfterSz,s.tAfterSz];
        end
      otherwise
        warning(['There are np aproriate method to process signals of ',...
          'type ',signalsWorkList.sigType(sigIdx),'! Signal with ID = ',...
          num2str(signalsWorkList.id(sigIdx)),' has been skipped.']);
    end
    t=toc;
    disp(['Elapsed time: ',num2str(t),'s']);
  end
  
  size(X)
  size(tBeforeSz)
  size(tAfterSz)
  
  % Form Y using tBeforeSz and tAfterSz
  yIdx=tBeforeSz>5 & tAfterSz>120;
  tbsz=tBeforeSz(yIdx);
  tasz=tAfterSz(yIdx);
  X=X(yIdx,:);
  Y=tbsz<600;
  
  size(X)
  size(Y)
  
  % Run classification
end
