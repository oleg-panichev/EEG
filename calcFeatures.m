addpath('calcFeatures');
addpath('code');
addpath('classes');
addpath('plot');
prepareWorkspace();

run('processingProperties.m');

X=[]; % Total features matrix
Y=[]; % Total output matrix
S=[]; % Total sequence vector
I=[]; % Total patient index

% Prepare dirs for features
for db_idx=1:numel(db_list)
  if (~exist([db_location,'/',db_list{db_idx},'_features'],'dir'))
    mkdir([db_location,'/',db_list{db_idx},'_features']);
  end
end

% Run feature calculation
for db_idx=1:numel(db_list)
  if (strcmp(db_list{db_idx},'aes_spc'))
    calcFeatures_aes_spc([db_location,'/',db_list{db_idx},'/']);
    calcFeatures_aes_spc_kaggleTest([db_location,'/',db_list{db_idx},'/']);
  elseif (strcmp(db_list{db_idx},'ch_sleep_kharitonov'))
    calcFeatures_ch_sleep_kharitonov();
  else
    warning(['No feature calculation function for ',db_list{db_idx},...
      ' database!']);
  end
end
