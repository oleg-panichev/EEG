close all;
clearvars -except fileName s;
clc;

addpath('code');
if (exist('fileName','var'))
  oldFileName=fileName;
end

path='eeg_data/physionet.org/physiobank/database/chbmit/'; % Directory containing db
reportPath='reports/';
recordsFileName='RECORDS'; % File with list of signals
subjectInfoFileName='SUBJECT-INFO'; % Name of the file that contains info about patients

useAllSignalsFl=0; % Flag to use all signals in db
forceReloadFl=1; % Flag to force data reloading
loadRecordFl=1; % Flag to load main data and signals
loadPatientInfoFl=1; % Flag to load data about patient
loadSeizuresAnnotationFl=1; % Flag to load data about seizures

allPatientsDataAnalysisFl=0; % FLag to perform analysis for all patients
verbose=0; % Flag to do plots

sigIdx=[1:332,334:664]; % File index to load
% [1:332,334:664] % Confirmed data RECORDS
% [1:52,54:140] % Confirmed data with seizures RECORDS-WITH-SEIZURES

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
disp(['Number of signals to proccess: ',num2str(numel(sigIdx))]);

miChBuf=[];
miCellBuf={};

if (allPatientsDataAnalysisFl>0)
  seizuresLength=[];
  miSzChBuf=[];
  totalNofSeizures=0;
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
%   simplePlot(s,reportPathRecord);
  
  % Save data to .mat file
%   mkdir('eeg_data/chbmit_mat/');
%   mkdir(['eeg_data/chbmit_mat/',fileName{1}(1:5)]);
%   exportToMat(['eeg_data/chbmit_mat/',fileName{1}(1:end-3),'mat'],s);

  estInfTr=informationAnalysis(s);
  [miCh,miCell]=estInfTr.estMutualInfTimeDomain(s,reportPathRecord,verbose);
  miChBuf=[miChBuf;miCh];
  miCellBuf=[miCellBuf;miCell];
  
  if (allPatientsDataAnalysisFl>0)
    % Seizure length statistics, [1:52,54:140]
    for k=1:(numel(s.seizureTimings)/2)
      seizuresLength(idx)=s.seizureTimings(k,2)-s.seizureTimings(k,1);
      idx=idx+1;
    end

    % MI in seizure-length-dependent window
    [miSzCh,nOfSeizures]=estInfTr.estMiAllPairs(s,reportPathRecord);
    miSzChBuf=[miSzChBuf;miSzCh];
    totalNofSeizures=totalNofSeizures+nOfSeizures;
  end
 
  close all;
  % -----------------------------------------------------------------------
  disp('Processing is done!');
end

chPairsNum=length(miChBuf(:,3));
patients={'chb01','chb02','chb03','chb04','chb05', ...
  'chb06','chb07','chb08','chb09','chb10','chb11', ...
  'chb12','chb13','chb14','chb15','chb16','chb17', ...
  'chb18','chb19','chb20','chb21','chb22','chb23'};
for i=1:numel(patients) 
  idx=false(chPairsNum,1);
  cnt=0;
  for k=1:chPairsNum
    if (strcmp(miCellBuf{k,2},patients{i}))
      idx(k)=true;
      cnt=cnt+1;
    end
  end
  if (cnt>0)
    f=figure;
    hs(1)=subplot(1,2,1);
    boxplot([miChBuf(idx,1:2)], ...
      {'Pre-seizure','Pre-seizure surrogate'}); hold on;
    title({'MI all data',['Patient: ',patients{i}]});
    grid on;
    hs(2)=subplot(1,2,2);
    idx=logical(idx & ~isnan(miChBuf(:,3)));
    boxplot([(miChBuf(idx,3:4))], ...
      {'Seizure','Seizure surrogate'}); hold on;
    title({'MI all data',['Patient: ',patients{i}]});
    grid on;
    linkaxes(hs, 'y');
    savePlot2File(f,'png',[reportPath,patients{i},'/'],'avMi_allSignals_2sWindow');
    savePlot2File(f,'fig',[reportPath,patients{i},'/'],'avMi_allSignals_2sWindow');
  
    close all;
  end
end

f=figure;
hs(1)=subplot(1,2,1);
boxplot([miChBuf(:,1:2)], ...
  {'Pre-seizure','Pre-seizure surrogate'}); hold on;
title({'MI all data',['Number of signals: ',num2str(length(sigIdx))]});
grid on;
hs(2)=subplot(1,2,2);
idx=false(chPairsNum,1);
idx=logical(idx+~isnan(miChBuf(:,3)));
boxplot([miChBuf(idx,3:4)], ...
  {'Seizure','Seizure surrogate'}); hold on;
title({'MI all data',['Number of signals: ',num2str(length(sigIdx))]});
grid on;
linkaxes(hs, 'y');
savePlot2File(f,'png',reportPath,'avMi_allSignals_2sWindow');
savePlot2File(f,'fig',reportPath,'avMi_allSignals_2sWindow');

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
  savePlot2File(f,'fig',reportPath,'seizuresLengthDistribution');
  
  f=figure;
  boxplot(miSzChBuf,{'Pre-seizure','Pre-seizure surrogate','Seizure','Seizure surrogate'}); 
  title({'MI box plot',['Number of seizures: ',num2str(totalNofSeizures)]});
  grid on;
  savePlot2File(f,'png',reportPath,'AllEpiSignals_AllPairs_BoxPlot');
  savePlot2File(f,'fig',reportPath,'AllEpiSignals_AllPairs_BoxPlot');
end
