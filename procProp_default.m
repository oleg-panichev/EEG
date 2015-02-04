% Processing Properties File
%
%% Data locations
dbLocation='D:/eeg_db/'; % Location of all databases
signalsListFname='signals_list.xlsx'; % Name of file that contains list of signals
reportPath='reports/'; % Folder name to store the results
trainPath='train/';
testPath='test/';

ftLocation='D:/eeg_db/features/';
repLocation='D:/eeg_db/reports/';

signalsList=SignalsList([dbLocation,signalsListFname]);

%% Construct list of signals to process
sigId=[2,4];
signalsWorkList=signalsList.getSubListById(sigId).getTable; % Get list if signals by ID

%% Features list to use in classification
fList={'corrc_w30_s15'};

%% Classifiers list to use in classification
classifierNames={'nbayes','logit','svm','tree','knn','discr'};

%% Flags
runOnTestDataFlag=0; % Flag to run features extraction on test data (like Kaggle)
clResultNumber=1;

%% Processing parameters:
nOfIterations=100; % Number of iterations of classification
trainNumCoef=0.6; % Percent of db, which is used to train
nOfThresholds=500;