close all;
clearvars -except fileName s;
clc;

addpath('code');
if (exist('fileName','var'))
  oldFileName=fileName;
end

path='eeg_data/physionet.org/physiobank/database/chbmit/'; % Directory containing db
recordsFileName='RECORDS'; % File with list of signals
useAllSignalsFl=0; % Flag to use all signals in db
forceReloadFl=0; % Flag to force data reloading
sigIdx=[668]; % File index to load

file=fopen([path,recordsFileName]);
recordsList=textscan(file,'%s');
recordsNum=numel(recordsList);
if (useAllSignalsFl>0 && recordsNum>0)
  sigIdx=1:recordsNum;
end

for i=sigIdx
  disp('>---------------------------------------------------------------');
  fileName=strcat(path,recordsList{1,1}(i));
  fileName=[fileName{1}];
  disp(['Loading data from ',fileName]);
  if (exist('oldFileName','var') && forceReloadFl==0)
    if(~strcmp(fileName,oldFileName))
      s=loadRecord(fileName);
    end
  else
    s=loadRecord(fileName);
  end
  
  disp('Processing...');
  % Place your processing functions here ----------------------------------  
  % Example:
  simplePlot(s);

  estInformationTransfer(s);
  % -----------------------------------------------------------------------
  disp('Processing is done!');
end
