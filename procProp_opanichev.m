% Processing Properties File
%
%% Data locations
dbLocation='D:/eeg_db/'; % Location of all databases
signalsListFname='signals_list.xlsx'; % Name of file that contains list of signals

ftLocation='D:/eeg_db/features/'; % Folder name to store features
repLocation='D:/eeg_db/reports/'; % Folder name to store the results

signalsList=SignalsList([dbLocation,signalsListFname]);

%% Construct list of signals to process
sigId=[1:10,12:16,20:25,29:32]; 
% Focal seizures: [1:10,12:16]
% Generalized seizured: [20:25,29:32]
signalsWorkList=signalsList.getSubListById(sigId).getTable; % Get list if signals by ID

%% Features list to use in classification
fList={'Delta_mean_w10_s10.mat','Theta_mean_w10_s10.mat',...
  'Alpha_mean_w10_s10.mat','Beta_mean_w10_s10.mat'};

%% Classifiers list to use in classification
allClassifierNames={'nbayes','logit','svm','tree','knn','discr'};
classifierNames={'nbayes','logit','svm','tree','knn','discr'};

%% Flags
runOnTestDataFlag=0; % Flag to run features extraction on test data (like Kaggle)
clResultNumber=1;

%% Features calculation parameters:
% Correlation between EEG channels features:
corrcWinSize=10; % Seconds
corrcStepSize=10; % Seconds
% if corrcStepSize>2
%   corrcStepSize=2;
% end
  
%% Classification parameters:
divideTrainCvTestMode='balanced'; % Mode to divide data on sets:
  % Available modes:
  % 'all' - numel(Y_POS)~=numel(Y_NEG)
  % 'balanced' - numel(Y_POS)==numel(Y_NEG)
divideByPatientsFlag=1; % Flag to divide train/cv/test by patients
% If divideByPatientsFlag==1, please, select signals to use 
trainSID=[1:2,4:10,12:16];
cvSID=[3];
testSID=[3];
% trainSID=[20:22];
% cvSID=[25];
% testSID=[20:22];


nOfIterations=10; % Number of iterations of classification
trainNumCoef=0.6; % Percent of db, which is used to train
nOfThresholds=500; % Number of threshold for perfCurves

earlyDetection=5; % Seconds
afterSzStart=180; % Seconds
preictalTime=600; % Seconds
