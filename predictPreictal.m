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
  
  % Load feature list and chose same for all patients
  % struct sigList,features
  fNamesList=cell(numel(sigId),numel(fList));
  for sigIdx=1:numel(signalsWorkList.id)
    tic;
    disp(signalsWorkList.mat_address{sigIdx});
    switch signalsWorkList.sigType{sigIdx}
      case 'aes_spc'

      case 'mat_zhukov'    
        dir2open=[ftLocation,signalsWorkList.mat_address{sigIdx}(1:end-4),'/'];
        for fIdx=1:numel(fList)
          fNamesList{sigIdx,fIdx}=load([dir2open,fList{fIdx}],'fLabels');
        end
      otherwise
        warning(['There are np aproriate method to process signals of ',...
          'type ',signalsWorkList.sigType(sigIdx),'! Signal with ID = ',...
          num2str(signalsWorkList.id(sigIdx)),' has been skipped.']);
    end
    t=toc;
    disp(['Elapsed time: ',num2str(t),'s']);
  end
  selectFeatures(fNamesList);
end
