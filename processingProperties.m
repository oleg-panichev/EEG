% Processing parameters
miWindowSize=0.5; % Seconds
patientsIdxBuf=[1,5];
medianCoef=0.9; 
nOfInterIctal=16;

nOfIterations=300;
trainNumCoef=0.6;
nOfThresholds=500;

% Data location
wpath='D:/eeg db/aes_spc/'; % Directory containing db
reportPath='kaggle_reports/';
trainPath='train/';
testPath='test/';