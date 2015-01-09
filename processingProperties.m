% Processing parameters:
nOfIterations=100; % Number of iterations of classification
trainNumCoef=0.6; % Percent of db, which is used to train
nOfThresholds=500;

% Existing databases list:
%{
  'aes_spc',...
  'ch_sleep_kharitonov'...
%}
% Databases list used in processing:
db_list={...
%   'aes_spc',...
  'ch_sleep_kharitonov'...
  };

% Data locations
db_location='D:/eeg db/';
wpath='D:/eeg db/aes_spc/'; % Directory containing db
reportPath='reports/';
trainPath='train/';
testPath='test/';

% Flags
runOnTestDataFlag=0;
clResultNumber=1;