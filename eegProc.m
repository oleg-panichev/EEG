close all;
clearvars -except fileName s;
clc;

addpath('code');
if (exist('fileName','var'))
  oldFileName=fileName;
end

path='eeg_data/physionet.org/physiobank/database/chbmit/'; % Directory containing db
recordsFileName='RECORDS'; % File with list of signals
subjectInfoFileName='SUBJECT-INFO'; % Name of the file that contains info about patients

useAllSignalsFl=0; % Flag to use all signals in db
forceReloadFl=0; % Flag to force data reloading
sigIdx=[1]; % File index to load

file=fopen([path,recordsFileName]);
recordsList=textscan(file,'%s');
recordsNum=numel(recordsList{1,1});
if (useAllSignalsFl>0 && recordsNum>0)
  sigIdx=1:recordsNum;
end

for i=sigIdx
  disp('>---------------------------------------------------------------');
  if (numel(sigIdx)>1)
    clear s;
  end
  fileName=recordsList{1,1}(i);
  fullFileName=strcat(path,recordsList{1,1}(i));
  fullFileName=[fullFileName{1}];
  disp(['Loading data from ',fullFileName]);
  if (exist('oldFileName','var') && forceReloadFl==0)
    if(~strcmp(fileName,oldFileName))
      s=loadRecord(path,fileName,subjectInfoFileName);
    end
  else
    s=loadRecord(path,fileName,subjectInfoFileName);
  end
  
  disp('Processing...');
  % Place your processing functions here ----------------------------------
  % Example:
  simplePlot(s);
  
  % Save data to .mat file
%   mkdir('eeg_data/chbmit_mat/');
%   mkdir(['eeg_data/chbmit_mat/',fileName{1}(1:5)]);
%   exportToMat(['eeg_data/chbmit_mat/',fileName{1}(1:end-3),'mat'],s);
  
%   estInformationTransfer(s);
  % -----------------------------------------------------------------------
  disp('Processing is done!');
end