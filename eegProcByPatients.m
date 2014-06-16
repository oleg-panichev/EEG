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

verbose=1; % Flag to make plots
createPatientDataFlag=0; % Flag to forced patient data-files creation

if (~exist(reportPath,'dir'))
    mkdir(reportPath);
end
  
items=dir(path);
dirs={items([items.isdir]).name};
dirs=dirs(3:end);
miWindowSize=2; % Seconds
for i=1:numel(dirs)-1
  disp('>---------------------------------------------------------------');
  tic;
  % Load patient data
  if (createPatientDataFlag>0)
    if (exist([path,dirs{i},'/PatientData.mat'],'file'))
      warning(['File ',[path,dirs{i},'/PatientData.mat'],' already exist!']);
    end
    p=Patient();
    p.updateFields(i,[path,dirs{i}]);
    p.save([path,dirs{i}]);
  else
    load([path,'/',dirs{i},'/PatientData.mat']);
    p=obj;
  end
  disp(['Processing data from ',p.name,'...']);
  
  % Create report folder for PATIENT
  if (~exist([reportPath,dirs{i}],'dir'))
    mkdir([reportPath,dirs{i}]);
  end
  
  % Processing
  [sigNum,~]=size(p.signalsAll);
  sIdx=1:sigNum;
  seizuresSigIdx=[];
  for n=sIdx
    if (p.signalsAll{n,4}>0)
      seizuresSigIdx=[seizuresSigIdx,n];
    end
  end
  sIdx=1;
  mi=[];
  for k=seizuresSigIdx
    if (sIdx>1)
      % Check for non-overlapping current preseizure with previous parts in
      % 4 hours window
      if((p.signalsAll{k,2}-p.signalsAll{seizuresSigIdx(sIdx-1),2})>14400 && ...
          p.signalsAll{k,2}>14400 && (k-seizuresSigIdx(sIdx-1))>1)
        % load signal with seizure for proccessing
        disp(['Loading signal with seizure ',p.signalsAll{k,1},'...']);
        s=loadRecord(path,[dirs{i},'/',p.signalsAll{k,1}],subjectInfoFileName,...
          1,1,1);
        sStartTime=s.seizureTimings(1,1);
        sDuration=s.seizureTimings(1,2)-sStartTime; % Seizure duration, seconds
        ia=informationAnalysis(s);
        % Calculate MI during the seizure and right before the seizure
        mi_Seizure=ia.windowedShortTimeMi(s,sStartTime,sDuration,miWindowSize);
        mi_PreSeizure=ia.windowedShortTimeMi(s,(sStartTime-sDuration),sDuration, ...
          miWindowSize);
        
        absStartTime=sStartTime+p.signalsAll{k,2};
        % 1 Hour before the seizure
        startTime=absStartTime-3600;
        n=1;
        while (p.signalsAll{n,2}<startTime && n<sigNum)
          n=n+1;
        end
        idxPrev=k;
        if (n<=sigNum)
          idx=n-1;
        else
          idx=sigNum;
        end
        if (idx~=idxPrev)
          disp(['1H: Loading ',p.signalsAll{idx,1},'...']);
          s=loadRecord(path,[dirs{i},'/',p.signalsAll{idx,1}],subjectInfoFileName,...
            1,1,1);
        else
          disp(['1H: Loaded from ',p.signalsAll{idx,1},'.']);
        end
        startTime=absStartTime-p.signalsAll{idx,2};
        if (startTime+sDuration>s.records)
          startTime=s.records-sDuration-miWindowSize-1;
        end
        mi_1H_PreSeizure=ia.windowedShortTimeMi(s,startTime,sDuration,miWindowSize);
        % 2 Hours before the seizure
        startTime=absStartTime-7200;
        n=1;
        while (p.signalsAll{n,2}<startTime && n<sigNum)
          n=n+1;
        end
        idxPrev=idx;
        if (n<=sigNum)
          idx=n-1;
        else
          idx=sigNum;
        end
        if (idx~=idxPrev)
          disp(['2H: Loading ',p.signalsAll{idx,1},'...']);
          s=loadRecord(path,[dirs{i},'/',p.signalsAll{idx,1}],subjectInfoFileName,...
            1,1,1);
        else
          disp(['2H: Loaded from ',p.signalsAll{idx,1},'.']);
        end
        startTime=absStartTime-p.signalsAll{idx,2};
        if (startTime+sDuration>s.records)
          startTime=s.records-sDuration-miWindowSize-1;
        end
        mi_2H_PreSeizure=ia.windowedShortTimeMi(s,startTime,sDuration,miWindowSize);
        % 3 Hours before the seizure
        startTime=absStartTime-10800;
        n=1;
        while (p.signalsAll{n,2}<startTime && n<sigNum)
          n=n+1;
        end
        idxPrev=idx;
        if (n<=sigNum)
          idx=n-1;
        else
          idx=sigNum;
        end
        if (idx~=idxPrev)
          disp(['3H: Loading ',p.signalsAll{idx,1},'...']);
          s=loadRecord(path,[dirs{i},'/',p.signalsAll{idx,1}],subjectInfoFileName,...
            1,1,1);
        else
          disp(['3H: Loaded from ',p.signalsAll{idx,1},'.']);
        end
        startTime=absStartTime-p.signalsAll{idx,2};
        if (startTime+sDuration>s.records)
          startTime=s.records-sDuration-miWindowSize-1;
        end
        mi_3H_PreSeizure=ia.windowedShortTimeMi(s,startTime,sDuration,miWindowSize);
        % 4 Hours before the seizure
        startTime=absStartTime-14400;
        n=1;
        while (p.signalsAll{n,2}<startTime && n<sigNum)
          n=n+1;
        end
        idxPrev=idx;
        if (n<=sigNum)
          idx=n-1;
        else
          idx=sigNum;
        end
        if (idx~=idxPrev)
          disp(['4H: Loading ',p.signalsAll{idx,1},'...']);
          s=loadRecord(path,[dirs{i},'/',p.signalsAll{idx,1}],subjectInfoFileName,...
            1,1,1);
        else
          disp(['4H: Loaded from ',p.signalsAll{idx,1},'.']);
        end
        startTime=absStartTime-p.signalsAll{idx,2};
        if (startTime+sDuration>s.records)
          startTime=s.records-sDuration-miWindowSize-1;
        end
        mi_4H_PreSeizure=ia.windowedShortTimeMi(s,startTime,sDuration,miWindowSize);
        
        % Plot results for current SEIZURE
        f=figure;
        boxplot([mi_4H_PreSeizure(:,1),mi_3H_PreSeizure(:,1),mi_2H_PreSeizure(:,1), ...
          mi_1H_PreSeizure(:,1),mi_PreSeizure(:,1),mi_Seizure(:,1)], ...
          {'4 Hours','3 Hours','2 Hours','1 Hour','Pre-seizure','Seizure'});
        ylabel('MI');
        title({'Mutual information',['Seizure duration: ',num2str(sDuration),...
          ', MI Win. size: ',num2str(miWindowSize),'s']});
        grid on;
        savePlot2File(f,'png',[reportPath,'/',dirs{i},'/'],['boxPlot_sz',num2str(sIdx)]);
        savePlot2File(f,'fig',[reportPath,'/',dirs{i},'/'],['boxPlot_sz',num2str(sIdx)]);
        
        % Store calculated data
        mi=[mi;mi_4H_PreSeizure,mi_3H_PreSeizure,mi_2H_PreSeizure,mi_1H_PreSeizure, ... 
          mi_PreSeizure,mi_Seizure];
        save([reportPath,'/',dirs{i},'/','mi_',num2str(sIdx),'.mat'], ...
          'mi_4H_PreSeizure','mi_3H_PreSeizure','mi_2H_PreSeizure', ...
          'mi_1H_PreSeizure','mi_PreSeizure','mi_Seizure');
      end
    else
      if(p.signalsAll{k,2}>14400)
        % load signal with seizure for proccessing
        disp(['Loading signal with seizure ',p.signalsAll{k,1},'...']);
        s=loadRecord(path,[dirs{i},'/',p.signalsAll{k,1}],subjectInfoFileName,...
          1,1,1);
        sStartTime=s.seizureTimings(1,1);
        sDuration=s.seizureTimings(1,2)-sStartTime; % Seizure duration, seconds
        ia=informationAnalysis(s);
        % Calculate MI during the seizure and right before the seizure
        mi_Seizure=ia.windowedShortTimeMi(s,sStartTime,sDuration,miWindowSize);
        mi_PreSeizure=ia.windowedShortTimeMi(s,(sStartTime-sDuration),sDuration, ...
          miWindowSize);
        
        absStartTime=sStartTime+p.signalsAll{k,2};
        % 1 Hour before the seizure
        startTime=absStartTime-3600;
        n=1;
        while (p.signalsAll{n,2}<startTime && n<sigNum)
          n=n+1;
        end
        idxPrev=k;
        if (n<=sigNum)
          idx=n-1;
        else
          idx=sigNum;
        end
        if (idx~=idxPrev)
          disp(['1H: Loading ',p.signalsAll{idx,1},'...']);
          s=loadRecord(path,[dirs{i},'/',p.signalsAll{idx,1}],subjectInfoFileName,...
            1,1,1);
        else
          disp(['1H: Loaded from ',p.signalsAll{idx,1},'.']);
        end
        startTime=startTime-p.signalsAll{idx,2};
        if (startTime+sDuration>s.records)
          startTime=s.records-sDuration-miWindowSize-1;
        end
        mi_1H_PreSeizure=ia.windowedShortTimeMi(s,startTime,sDuration,miWindowSize);
        % 2 Hours before the seizure
        startTime=absStartTime-7200;
        n=1;
        while (p.signalsAll{n,2}<startTime && n<sigNum)
          n=n+1;
        end
        idxPrev=idx;
        if (n<=sigNum)
          idx=n-1;
        else
          idx=sigNum;
        end
        if (idx~=idxPrev)
          disp(['2H: Loading ',p.signalsAll{idx,1},'...']);
          s=loadRecord(path,[dirs{i},'/',p.signalsAll{idx,1}],subjectInfoFileName,...
            1,1,1);
        else
          disp(['2H: Loaded from ',p.signalsAll{idx,1},'.']);
        end
        startTime=startTime-p.signalsAll{idx,2};
        if (startTime+sDuration>s.records)
          startTime=s.records-sDuration-miWindowSize-1;
        end
        mi_2H_PreSeizure=ia.windowedShortTimeMi(s,startTime,sDuration,miWindowSize);
        % 3 Hours before the seizure
        startTime=absStartTime-10800;
        n=1;
        while (p.signalsAll{n,2}<startTime && n<sigNum)
          n=n+1;
        end
        idxPrev=idx;
        if (n<=sigNum)
          idx=n-1;
        else
          idx=sigNum;
        end
        if (idx~=idxPrev)
          disp(['3H: Loading ',p.signalsAll{idx,1},'...']);
          s=loadRecord(path,[dirs{i},'/',p.signalsAll{idx,1}],subjectInfoFileName,...
            1,1,1);
        else
          disp(['3H: Loaded from ',p.signalsAll{idx,1},'.']);
        end
        startTime=startTime-p.signalsAll{idx,2};
        if (startTime+sDuration>s.records)
          startTime=s.records-sDuration-miWindowSize-1;
        end
        mi_3H_PreSeizure=ia.windowedShortTimeMi(s,startTime,sDuration,miWindowSize);
        % 4 Hours before the seizure
        startTime=absStartTime-14400;
        n=1;
        while (p.signalsAll{n,2}<startTime && n<sigNum)
          n=n+1;
        end
        idxPrev=idx;
        if (n<=sigNum)
          idx=n-1;
        else
          idx=sigNum;
        end
        if (idx~=idxPrev)
          disp(['4H: Loading ',p.signalsAll{idx,1},'...']);
          s=loadRecord(path,[dirs{i},'/',p.signalsAll{idx,1}],subjectInfoFileName,...
            1,1,1);
        else
          disp(['4H: Loaded from ',p.signalsAll{idx,1},'.']);
        end
        startTime=startTime-p.signalsAll{idx,2};
        if (startTime+sDuration>s.records)
          startTime=s.records-sDuration-miWindowSize-1;
        end
        mi_4H_PreSeizure=ia.windowedShortTimeMi(s,startTime,sDuration,miWindowSize);
        
        % Plot results for current SEIZURE
        f=figure;
        boxplot([mi_4H_PreSeizure(:,1),mi_3H_PreSeizure(:,1),mi_2H_PreSeizure(:,1), ...
          mi_1H_PreSeizure(:,1),mi_PreSeizure(:,1),mi_Seizure(:,1)], ...
          {'4 Hours','3 Hours','2 Hours','1 Hour','Pre-seizure','Seizure'});
        ylabel('MI');
        title({'Mutual information',['Seizure duration: ',num2str(sDuration),...
          ', MI Win. size: ',num2str(miWindowSize),'s']});
        grid on;
        savePlot2File(f,'png',[reportPath,'/',dirs{i},'/'],['boxPlot_sz',num2str(sIdx)]);
        savePlot2File(f,'fig',[reportPath,'/',dirs{i},'/'],['boxPlot_sz',num2str(sIdx)]);
        
        % Store calculated data
        mi=[mi;mi_4H_PreSeizure,mi_3H_PreSeizure,mi_2H_PreSeizure,mi_1H_PreSeizure, ... 
          mi_PreSeizure,mi_Seizure];
        save([reportPath,'/',dirs{i},'/','mi_',num2str(sIdx),'.mat'], ...
          'mi_4H_PreSeizure','mi_3H_PreSeizure','mi_2H_PreSeizure', ...
          'mi_1H_PreSeizure','mi_PreSeizure','mi_Seizure');
      end
    end
    sIdx=sIdx+1;
  end
  % Plot results for current PATIENT
  f=figure;
  boxplot([mi(:,1),mi(:,3),mi(:,5),mi(:,7),mi(:,9),mi(:,11)], ...
    {'4 Hours','3 Hours','2 Hours','1 Hour','Pre-seizure','Seizure'});
  ylabel('MI');
  title({'Mutual information',['All seizures, MI Win. size: ', ...
    num2str(miWindowSize),'s']});
  grid on;
  savePlot2File(f,'png',[reportPath,'/',dirs{i},'/'],['boxPlot_AllSz','_win_',num2str(miWindowSize)]);
  savePlot2File(f,'fig',[reportPath,'/',dirs{i},'/'],['boxPlot_AllSz','_win_',num2str(miWindowSize)]);
  save([reportPath,'/',dirs{i},'/Total_Mi.mat'],'mi');
  disp(['Elapsed time: ',num2str(toc),' s']);
  
  close all;
end
