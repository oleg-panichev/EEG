close all;
clear all;
clc;

addpath('code');
addpath('classes');
if (exist('fileName','var'))
  oldFileName=fileName;
end

path='eeg_data/chbmit_mat/'; % Directory containing db
% 'eeg_data/physionet.org/physiobank/database/chbmit/'
% 'eeg_data/chbmit_mat/'
reportPath='reports_by_patient/';
recordsFileName='RECORDS'; % File with list of signals
% 'RECORDS'
% 'RECORDS-WITH-SEIZURES'
subjectInfoFileName='SUBJECT-INFO'; % Name of the file that contains info about patients

items=dir(path);
dirs={items([items.isdir]).name};
dirs=dirs(3:end);
for i=1:numel(dirs)
  disp('>---------------------------------------------------------------');
  disp(['Processing data from ',dirs{i},'...']);
  tic;
  % Create patient data file:
  if (exist([path,dirs{i},'/PatientData.mat'],'file'))
    warning(['File ',[path,dirs{i},'/PatientData.mat'],' already exist!']);
  end
  p=Patient();
  p.updateFields(i,[path,dirs{i}]);
  p.save([path,dirs{i}]);
  t=toc;
  disp(['Done! Elapsed time: ',num2str(t),'s']);
end
