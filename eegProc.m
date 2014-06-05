close all;
clearvars -except fileName s;
clc;

addpath('code');
if (exist('fileName','var'))
  oldFileName=fileName;
end

path='eeg_data/physionet.org/physiobank/database/chbmit/'; % Directory containing db
reportPath='reports/';
recordsFileName='RECORDS-WITH-SEIZURES'; % File with list of signals
subjectInfoFileName='SUBJECT-INFO'; % Name of the file that contains info about patients

useAllSignalsFl=0; % Flag to use all signals in db
forceReloadFl=0; % Flag to force data reloading
loadRecordFl=1; % Flag to load main data and signals
loadPatientInfoFl=1; % Flag to load data about patient
loadSeizuresAnnotationFl=1; % Flag to load data about seizures
allPatientsDataAnalysisFl=0; % FLag to perform analysis for all patients

sigIdx=[1]; % File index to load

if (~exist(reportPath,'dir'))
  mkdir(reportPath);
end
file=fopen([path,recordsFileName]);
recordsList=textscan(file,'%s');
recordsNum=numel(recordsList{1,1});
disp(['Records number in list ',recordsFileName,': ',num2str(recordsNum)]);
if (useAllSignalsFl>0 && recordsNum>0)
  sigIdx=1:recordsNum;
end

if (allPatientsDataAnalysisFl>0)
  seizuresLength=[];
  idx=1;
end
for i=sigIdx
  disp('>---------------------------------------------------------------');
  if (numel(sigIdx)>1)
    clear s;
  end
  fileName=recordsList{1,1}(i);
  fullFileName=strcat(path,recordsList{1,1}(i));
  fullFileName=[fullFileName{1}];
  reportPathRecord=[reportPath,fileName{1}(1:5),'/'];
  if (~exist(reportPathRecord,'dir'))
    mkdir(reportPathRecord);
  end
  reportPathRecord=[reportPathRecord,fileName{1}(6:end-4),'/'];
  if (~exist(reportPathRecord,'dir'))
    mkdir(reportPathRecord);
  end
  disp(['Loading data from ',fullFileName]);
  if (exist('oldFileName','var') && forceReloadFl==0)
    if(~strcmp(fileName,oldFileName))
      s=loadRecord(path,fileName,subjectInfoFileName,...
        loadRecordFl,loadPatientInfoFl,loadSeizuresAnnotationFl);
    end
  else
    s=loadRecord(path,fileName,subjectInfoFileName,...
      loadRecordFl,loadPatientInfoFl,loadSeizuresAnnotationFl);
  end
  
  disp('Processing...');
  % Place your processing functions here ----------------------------------
  % Example:
  simplePlot(s,reportPathRecord);
  
  % Save data to .mat file
%   mkdir('eeg_data/chbmit_mat/');
%   mkdir(['eeg_data/chbmit_mat/',fileName{1}(1:5)]);
%   exportToMat(['eeg_data/chbmit_mat/',fileName{1}(1:end-3),'mat'],s);

  if (allPatientsDataAnalysisFl>0)
    % Seizure length statistics, [1:52,54:140]
    for k=1:(numel(s.seizureTimings)/2)
      seizuresLength(idx)=s.seizureTimings(k,2)-s.seizureTimings(k,1);
      idx=idx+1;
    end
  end
  
%   estInformationTransfer(s);
  estInfTransfer(s,reportPathRecord);
  % -----------------------------------------------------------------------
  disp('Processing is done!');
end

if (allPatientsDataAnalysisFl>0)
  % Seizure length statistics
  nbins=sturges(seizuresLength);
  f=figure;
  hist(seizuresLength,nbins);
  M=mode(seizuresLength);
  title(['Seizures length distribution, mode=',num2str(M)]);
  xlabel('Seizure length, s');
  ylabel('Number of seizures');
  grid on;
  savePlot2File(f,'png',reportPath,'seizuresLengthDistribution');
end
