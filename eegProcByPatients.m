close all;
clearvars -except fileName s;
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

createPatientDataFlag=1;
items=dir(path);
dirs={items([items.isdir]).name};
dirs=dirs(3:end);
parfor i=1:numel(dirs)-1
  if (createPatientDataFlag>0)
    if (exist([path,dirs{i},'/PatientData.mat'],'file'))
      warning(['File ',[path,dirs{i},'/PatientData.mat'],' already exist!']);
    end
    p=Patient();
    p.updateFields(i,[path,dirs{i}]);
    p.save([path,dirs{i}]);
  else
    p=load([dirs(i),'/PatientData.mat']);
  end
end
