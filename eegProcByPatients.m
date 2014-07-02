function eegProcByPatients()
  addpath('code');
  addpath('classes');
  prepareWorkspace();

  wpath='eeg_data/chbmit_mat/'; % Directory containing db
  % 'eeg_data/physionet.org/physiobank/database/chbmit/'
  % 'eeg_data/chbmit_mat/'
  reportwpath='reports_by_patient/';
  % 'RECORDS'
  % 'RECORDS-WITH-SEIZURES'
  subjectInfoFileName='SUBJECT-INFO'; % Name of the file that contains info about patients

  parallelFlag=0;
  verbose=1; % Flag to make plots

  if (~exist(reportwpath,'dir'))
      mkdir(reportwpath);
  end

  items=dir(wpath);
  dirs={items([items.isdir]).name};
  dirs=dirs(3:end);
  windowSizesBuf=[0.25]; % Seconds
  shiftBuf=[14400:-300:300]; % Backshift values from seizure, seconds
  shiftLabels=cell(1,numel(shiftBuf));
  for i=1:numel(shiftBuf)
    shiftLabels{i}=num2str(shiftBuf(i)/60);
  end
  shiftLabels{i+1}='Pre';
  shiftLabels{i+2}='SZ';
  if (parallelFlag>0)
    parpool;
  end
  for miIdx=1:numel(windowSizesBuf)
    miWindowSize=windowSizesBuf(miIdx);
    disp(['MI WINDOW SIZE = ',num2str(miWindowSize)]);
    for i=1:numel(dirs)-2
      disp('>---------------------------------------------------------------');
      tic;
      % Load patient data
      o=load([wpath,'/',dirs{i},'/PatientData.mat']);
      p=o.obj;
      disp(['Processing data from ',p.name,'...']);

      % Create report folder for PATIENT
      if (~exist([reportwpath,dirs{i}],'dir'))
        mkdir([reportwpath,dirs{i}]);
      end

      % Processing
      sigNum=size(p.signalsAll,1);
      sIdx=1:sigNum;
      seizuresSigIdx=[];
      for n=sIdx
        if (p.signalsAll{n,4}>0)
          seizuresSigIdx=[seizuresSigIdx,n];
        end
      end
      sIdx=1;
      mi=[];
      prevSeizureStartTime=0;
      miAllSz=cell(numel(seizuresSigIdx),1);
      for k=seizuresSigIdx
        % Load signal with seizure for proccessing
        disp(['Loading signal with seizure ',p.signalsAll{k,1},'...']);
        s=loadRecord(wpath,[dirs{i},'/',p.signalsAll{k,1}],subjectInfoFileName,...
          1,1,1);
        sStartTime=s.seizureTimings(1,1);
        sDuration=s.seizureTimings(1,2)-sStartTime; % Seizure duration, seconds
        ia=informationAnalysis(s);
        % Calculate MI during the seizure and right before the seizure
        sigIdxBuf=p.signalsAll{k,5}(1:p.minChNum);
        % Calculate number of interconnected channels
        tmp=numel(sigIdxBuf)-1;
        miChNum=0;
        while tmp>0
          miChNum=miChNum+tmp;
          tmp=tmp-1;
        end     
        mi=zeros(miChNum,numel(shiftBuf)+2);
        miSur=zeros(miChNum,numel(shiftBuf)+2);
        [mi(:,end),miSur(:,end),miLabels]=ia.windowedShortTimeMi(s,sigIdxBuf,sStartTime,sDuration,miWindowSize);
        [mi(:,end-1),miSur(:,end-1),~]=ia.windowedShortTimeMi(s,sigIdxBuf,(sStartTime-sDuration),sDuration, ...
          miWindowSize);

        % Calculating MI with shifts back before seizure
        tmp=numel(shiftBuf);
        idxPrev=k;
        absStartTime=sStartTime+p.signalsAll{k,2};
        while tmp>0
          startTime=absStartTime-shiftBuf(tmp);
          if (startTime > prevSeizureStartTime)
            [mi(:,tmp),miSur(:,tmp),~,s,idxPrev]=calcShiftedMi(ia,s,p,startTime,sDuration, ...
              miWindowSize,idxPrev,wpath,dirs{i},subjectInfoFileName);         
          else
            break;
          end
          tmp=tmp-1;
        end   
        prevSeizureStartTime=absStartTime;

        % Plot results for current SEIZURE
        f=figure('Visible','Off');
        set(f,'PaperPositionMode','auto');
        set(f, 'Position', [0 100 1350 400]);
        set(f,'DefaultAxesLooseInset',[0,0,0,0]);
        boxplot(mi,shiftLabels);
        ylabel('MI');
        title({'Mutual information',['Seizure ',num2str(sIdx),' at ',num2str(absStartTime),...
          's, duration: ',num2str(sDuration),'s, MI Win. size: ',num2str(miWindowSize),'s']});
        grid on;
        savePlot2File(f,'png',[reportwpath,'/',dirs{i},'/'],['MI_Sz',num2str(sIdx),'_win', ...
          num2str(miWindowSize)]);
        savePlot2File(f,'fig',[reportwpath,'/',dirs{i},'/'],['MI_Sz',num2str(sIdx),'_win', ...
          num2str(miWindowSize)]);

        % Store calculated data
        saveWrapper([reportwpath,'/',dirs{i},'/','MI_Sz',num2str(sIdx),'_win', ...
          num2str(miWindowSize),'.mat'],mi,miSur);
        miAllSz{sIdx}=mi;
        sIdx=sIdx+1;
      end
      cntBuf=zeros(size(seizuresSigIdx));
      if (size(miAllSz,1)>0 && size(miAllSz,2)>0)
        miAv=zeros(size(mi));
        for m=1:size(miAv,2)
          cnt=0;
          for n=1:numel(seizuresSigIdx)
            if (miAllSz{n}(1,m) ~= 0)
              miAv(:,m)=miAv(:,m)+miAllSz{n}(:,m);
              cnt=cnt+1;
            end
          end
          miAv(:,m)=miAv(:,m)/cnt;
          cntBuf(m)=cnt;
        end
        % Plot results for current PATIENT
        f=figure('Visible','Off');
        set(f,'PaperPositionMode','auto');
        set(f, 'Position', [0 100 1350 400]);
        set(f,'DefaultAxesLooseInset',[0,0,0,0]);
        boxplot(miAv,shiftLabels);
        ylabel('MI');
        title({'Mutual information',['All seizures, MI Win. size: ', ...
          num2str(miWindowSize),'s']});
        grid on;
        savePlot2File(f,'png',[reportwpath,'/',dirs{i},'/'],['MI_AllSz','_win',num2str(miWindowSize)]);
        savePlot2File(f,'fig',[reportwpath,'/',dirs{i},'/'],['MI_AllSz','_win',num2str(miWindowSize)]);
        saveWrapper([reportwpath,'/',dirs{i},'/MI_Total_win',num2str(miWindowSize),'.mat'],mi,miSur);
             
        f=figure('Visible','Off');
        set(f,'PaperPositionMode','auto');
        set(f,'Position', [0 100 1350 400]);
        set(f,'DefaultAxesLooseInset',[0,0,0,0]);
        bar(cntBuf);
        set(gca,'XTickLabel',shiftLabels,'XTick',1:numel(shiftLabels));
        title('Number of probes in averaging in av.MI for patient');
        grid on;
        savePlot2File(f,'png',[reportwpath,'/',dirs{i},'/'],['MI_AllSzCnt','_win',num2str(miWindowSize)]);
        savePlot2File(f,'fig',[reportwpath,'/',dirs{i},'/'],['MI_AllSzCnt','_win',num2str(miWindowSize)]);
        
        disp(['Elapsed time: ',num2str(toc),' s']);
      end
      close all;
    end
  end
  if (parallelFlag>0)
    delete(gcp);
  end
end

function [mi,miSur,miLabels,s,idxPrev]=calcShiftedMi(ia,s,p,startTime,sDuration, ...
  miWindowSize,idxPrev,wpath,pdir,subjectInfoFileName)
  % Calculate number of interconnected channels
  tmp=p.minChNum-1;
  miChNum=0;
  while tmp>0
    miChNum=miChNum+tmp;
    tmp=tmp-1;
  end     
  mi=zeros(miChNum,1);
  miSur=zeros(miChNum,1);
  miLabels=[];
  n=1;
  while (p.signalsAll{n,2}<startTime && n<size(p.signalsAll,1))
    n=n+1;
  end
  sigNum=size(p.signalsAll,1);
  if (n<=sigNum)
    idx=n-1;
  else
    idx=sigNum;
  end
  disp(['Processing ',pdir,'/',p.signalsAll{idx,1}]);
  if (idx~=idxPrev)
    s=loadRecord(wpath,[pdir,'/',p.signalsAll{idx,1}],subjectInfoFileName,...
      1,1,1);
  end
  startTime=startTime-p.signalsAll{idx,2};
  if (startTime+sDuration-s.records<11)
    if (startTime+sDuration>s.records)
      startTime=s.records-sDuration-miWindowSize-1;
    end
    sigIdxBuf=p.signalsAll{idx,5}(1:p.minChNum);
    [mi,miSur,miLabels]=ia.windowedShortTimeMi(s,sigIdxBuf,startTime,sDuration,miWindowSize);
  end
  idxPrev=idx;
end
