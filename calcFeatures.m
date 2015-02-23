function calcFeatures(propertiesFunction)
  addpath('calcFeatures');
  addpath('classes');
  addpath('code');
  addpath('plot');
  prepareWorkspace();
  propertiesFunction();

  % Prepare dirs for features
  if (~exist(ftLocation,'dir'))
    mkdir(ftLocation);
  end

  % Run feature calculation
  for sigIdx=1:numel(signalsWorkList.id)
    tic;
    disp(signalsWorkList.mat_address{sigIdx});
    switch signalsWorkList.sigType{sigIdx}
      case 'aes_spc'
        calcFeatures_aes_spc(signalsWorkList.mat_address{sigIdx});
      case 'mat_zhukov'    
        dir2save=[ftLocation,signalsWorkList.mat_address{sigIdx}(1:end-4),'/'];
        if (~exist(dir2save,'dir'))
          mkdir(dir2save);
        end
        calcFeatures_MatZhukov(propertiesFunction,...
          [dbLocation,signalsWorkList.mat_address{sigIdx}],dir2save);
      otherwise
        warning(['There are np aproriate method to process signals of ',...
          'type ',signalsWorkList.sigType(sigIdx),'! Signal with ID = ',...
          num2str(signalsWorkList.id(sigIdx)),' has been skipped.']);
    end
    t=toc;
    disp(['Elapsed time: ',num2str(t),'s']);
  end
end
