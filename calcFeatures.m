function calcFeatures(propertiesFunction)
  addpath('calcFeatures');
  addpath('classes');
  addpath('code');
  addpath('plot');
  prepareWorkspace();
  propertiesFunction();

  % Prepare dirs for features
  if (~exist(featuresLocation,'dir'))
    mkdir(featuresLocation);
  end

  % Run feature calculation
  for sigIdx=1:numel(signalsWorkList.id)
    switch signalsWorkList.sigType(sigIdx)
      case 'aes_spc'
        calcFeatures_aes_spc(signalsWorkList.mat_address(sigIdx));
      case 'mat_zhukov'
        calcFeatures_ch_sleep_kharitonov(propertiesFunction,...
          signalsWorkList.mat_address(sigIdx)); 
      otherwise
        warning(['There are np aproriate method to process signals of ',...
          'type ',signalsWorkList.sigType(sigIdx),'! Signal with ID = ',...
          num2str(signalsWorkList.id(sigIdx)),' has been skipped.']);
    end
  end
end
