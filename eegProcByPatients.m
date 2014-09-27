function eegProcByPatients()
  addpath('code');
  addpath('classes');
  addpath('MIToolbox');
  addpath('plot');
  prepareWorkspace();

  % Data location
  wpath='eeg_data/chbmit_mat/'; % Directory containing db
  % 'eeg_data/physionet.org/physiobank/database/chbmit/'
  % 'eeg_data/chbmit_mat/'
  reportwpath='reports_20140927/';
  % 'RECORDS'
  % 'RECORDS-WITH-SEIZURES'
  subjectInfoFileName='SUBJECT-INFO'; % Name of the file that contains info about patients

  parallelFlag=0;

  if (~exist(reportwpath,'dir'))
  	mkdir(reportwpath);
  end

  items=dir(wpath);
  dirs={items([items.isdir]).name};
  dirs=dirs(4:end);
  
  % Processing parameters
  windowSizesBuf=[0.5]; % Seconds
  avWinDuration=0.5; % Large window size, seconds
  shiftBuf=[14400,12600,10800,9000,7200:-300:3600,3300:-300:30]; % Backshift values from seizure, seconds
  patientsIdxBuf=[1,3,4,5,8,9,10,15,18,19,20,23];
  medianCoef=0.9; 
  
  totalTime=0;
  shiftLabels=cell(1,numel(shiftBuf));
  for i=1:numel(shiftBuf)
    shiftLabels{i}=num2str(round(shiftBuf(i)/60*100)/100);
  end
  shiftLabels{i+1}='Pre';
  shiftLabels{i+2}='SZ1';
  shiftLabels{i+3}='SZ2';
  shiftLabels{i+4}='SZ3';
  if (parallelFlag>0)
    parpool;
  end
  
  disp(['Averaging window size = ',num2str(avWinDuration),' s']);
  for miIdx=1:numel(windowSizesBuf)
    miWindowSize=windowSizesBuf(miIdx);
    disp(['MI window size = ',num2str(miWindowSize),' s']);
    for i=patientsIdxBuf
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
      nOfSeizures=0;
      for n=sIdx
        if (p.signalsAll{n,4}>0)
          seizuresSigIdx=[seizuresSigIdx,n];
          nOfSeizures=nOfSeizures+p.signalsAll{n,4};
        end
      end
      disp(['Number of patient''s seizures: ',num2str(nOfSeizures)]);
      sIdx=1;
      
      % Prepare buffers
      mi=[];
      prevSeizureStartTime=0;
      miAllSz=cell(nOfSeizures,1);
      miDistanceAllSz=cell(nOfSeizures,1);
      
      for k=seizuresSigIdx
        % Load signal with seizure for proccessing
        disp(['Loading signal with seizure ',p.signalsAll{k,1},'...']);
        sSigName=p.signalsAll{k,1};
        s=loadRecord(wpath,[dirs{i},'/',p.signalsAll{k,1}],subjectInfoFileName,...
          1,1,1);
        idxPrev=k;  
        goog_seizures_idx=1:p.signalsAll{k,4};
        goog_seizures_idx=goog_seizures_idx(s.good_seizures_numbers);
        if numel(goog_seizures_idx)==0
          disp('There are no good seizures!');
        end
        for m=goog_seizures_idx
          if (k~=idxPrev)
            disp(['Loading signal with seizure ',p.signalsAll{k,1},'...']);
            s=loadRecord(wpath,[dirs{i},'/',p.signalsAll{k,1}],subjectInfoFileName,...
              1,1,1);
          end
          sStartTime=s.seizureTimings(m,1);

          ia=informationAnalysis(s);
          % Calculate MI during the seizure and right before the seizure
          sigIdxBuf=p.signalsAll{k,5}(1:p.minChNum);
          % Calculate number of interconnected channels
          miChNum=sum(1:(numel(sigIdxBuf)-1));
          mi=zeros(miChNum,numel(shiftBuf)+4);
          miVar=zeros(miChNum,numel(shiftBuf)+4);
          miSur=zeros(miChNum,numel(shiftBuf)+4);
          miVarSur=zeros(miChNum,numel(shiftBuf)+4);
          
          % Seizure and preseizure
          sDuration=s.seizureTimings(m,2)-s.seizureTimings(m,1);
          disp(['Seizure start at ',num2str(sStartTime),' s, length: ',num2str(sDuration),' s']);
          if (sDuration>11)
            sSkipSec=8; % Number of seconds to skip after seizure begins
          else
            sSkipSec=0;
          end
          [mi(:,end),miVar(:,end),miSur(:,end),miVarSur(:,end),miLabels]= ...
            ia.windowedShortTimeMi(s,sigIdxBuf,(sStartTime+sSkipSec+2),avWinDuration,miWindowSize);
          [mi(:,end-1),miVar(:,end-1),miSur(:,end-1),miVarSur(:,end-1),~]= ...
            ia.windowedShortTimeMi(s,sigIdxBuf,(sStartTime+sSkipSec+1),avWinDuration,miWindowSize);
          [mi(:,end-2),miVar(:,end-2),miSur(:,end-2),miVarSur(:,end-2),~]= ...
            ia.windowedShortTimeMi(s,sigIdxBuf,(sStartTime+sSkipSec),avWinDuration,miWindowSize);
          [mi(:,end-3),miVar(:,end-3),miSur(:,end-3),miVarSur(:,end-3),~]= ...
            ia.windowedShortTimeMi(s,sigIdxBuf,(sStartTime-5),avWinDuration, ...
            miWindowSize);

          % Calculating MI with shifts back before seizure and abs(diff(MI))
          tmp=numel(shiftBuf);
          idxPrev=k;
          absStartTime=sStartTime+p.signalsAll{k,2};
          while tmp>0
            startTime=absStartTime-shiftBuf(tmp);
            if (startTime > prevSeizureStartTime)
              [mi(:,tmp),miVar(:,tmp),miSur(:,tmp),miVarSur(:,tmp),~,s,idxPrev]=...
                calcShiftedMi(ia,s,p,startTime,avWinDuration,miWindowSize,...
                idxPrev,wpath,dirs{i},subjectInfoFileName);         
            else
              break;
            end
            tmp=tmp-1;
          end   
          prevSeizureStartTime=absStartTime;
          
          % Plot MI 
          titleStr=({'MI between channels',['Seizure ',num2str(sIdx),' from ',...
            sSigName,' at ',num2str(absStartTime),'s, Averaging win. size: ',...
            num2str(avWinDuration),'s, MI Win. size: ',num2str(miWindowSize),'s. ' ...
            ]});
          f=plotData(mi,shiftLabels,miLabels,titleStr);
          savePlot2File(f,'png',[reportwpath,'/',dirs{i},'/'],['Mi_Image_Sz',num2str(sIdx),'_win', ...
            num2str(miWindowSize)]);
          savePlot2File(f,'fig',[reportwpath,'/',dirs{i},'/'],['Mi_Image_Sz',num2str(sIdx),'_win', ...
            num2str(miWindowSize)]);

          % Using only median kernel elements for boxplot
          if (medianCoef<1 && medianCoef>0)
            elNum=round(size(mi,1)*medianCoef);
            skipNum=round((size(mi,1)-elNum)/2);
            miBox=zeros(elNum,size(mi,2));
            for tmp=1:size(mi,2)
              medMi=sort(mi(:,tmp));
              miBox(:,tmp)=medMi((1+skipNum):(1+skipNum+elNum-1));
            end
          else
            miBox=mi;
          end
          
          % Distance between MI-points in multidim. space
          Rfull=zeros(size(miBox,2),size(miBox,2));
          for tmp1=1:size(miBox,2)
            for tmp2=1:size(miBox,2)
              if (miBox(1,tmp1)~=0 && miBox(1,tmp2)~=0)
                Rfull(tmp1,tmp2)=distance(miBox(:,tmp1),miBox(:,tmp2));
              end
            end
          end
          titleStr=({'Distance between MI-points',['Seizure ',num2str(sIdx),' from ',...
            sSigName,' at ',num2str(absStartTime),'s, Averaging win. size: ',...
            num2str(avWinDuration),'s, MI Win. size: ',num2str(miWindowSize),'s. ' ...
            ]});
          f=plotDistances(Rfull,shiftLabels,titleStr);
          savePlot2File(f,'png',[reportwpath,'/',dirs{i},'/'],['MiDistance_Sz',num2str(sIdx),'_win', ...
            num2str(miWindowSize)]);
          
          % Plot boxplots of MI for SEIZURE
          titleStr={'Mutual information',['Seizure ',num2str(sIdx),' from ',...
            sSigName,' at ',num2str(absStartTime),'s, Averaging win. size: ',...
            num2str(avWinDuration),'s, MI Win. size: ',num2str(miWindowSize),'s']};
          f=plotDataBoxplot(miBox,shiftLabels,titleStr);
          savePlot2File(f,'png',[reportwpath,'/',dirs{i},'/'],['Mi_BoxPlot_Sz',num2str(sIdx),'_win', ...
            num2str(miWindowSize)]);
          savePlot2File(f,'fig',[reportwpath,'/',dirs{i},'/'],['Mi_BoxPlot_Sz',num2str(sIdx),'_win', ...
            num2str(miWindowSize)]);
          
          % Statistical Tests       
          f=statTests(mi,shiftLabels);
          savePlot2File(f,'png',[reportwpath,'/',dirs{i},'/'],['Mi_Tests_Sz',num2str(sIdx),'_win', ...
            num2str(miWindowSize)]);
          savePlot2File(f,'fig',[reportwpath,'/',dirs{i},'/'],['Mi_Tests_Sz',num2str(sIdx),'_win', ...
            num2str(miWindowSize)]);          

          % Store calculated data
          save([reportwpath,'/',dirs{i},'/','Mi_Sz',num2str(sIdx),'_win', ...
            num2str(miWindowSize),'.mat'],'mi','miSur');
          
          % Store data for averaging
          if (numel(mi)>0)
            miAllSz{sIdx}=mi;
            miDistanceAllSz{sIdx}=Rfull;
            sIdx=sIdx+1;
          end
          
          close all;
        end
      end
      
      disp(['Number of processed good seizures: ',num2str(sIdx-1)]);      
      cntBuf=zeros(size(seizuresSigIdx));
      if (size(miAllSz,1)>0 && size(miAllSz,2)>0)
        % Averaging results all over seizures for current patient
        miAv=zeros(size(mi));
        for j=1:size(miAv,2)
          cnt=0;
          for n=1:sIdx-1
            if (numel(miAllSz{n}) > 0)
              if (miAllSz{n}(1,j) ~= 0)
                miAv(:,j)=miAv(:,j)+miAllSz{n}(:,j);
                cnt=cnt+1;
              end
            end
          end
          miAv(:,j)=miAv(:,j)/cnt;
          cntBuf(j)=cnt;
        end
        
        % Plot averaged MI 
        titleStr=({'Averaged MI between channels for all seizures',['Averaging win. size: ',...
          num2str(avWinDuration),'s, MI Win. size: ',num2str(miWindowSize),'s. ' ...
          ]});
        f=plotData(miAv,shiftLabels,miLabels,titleStr);
        savePlot2File(f,'png',[reportwpath,'/',dirs{i},'/'],['Mi_Image_AllSz_win', ...
          num2str(miWindowSize)]);
        savePlot2File(f,'fig',[reportwpath,'/',dirs{i},'/'],['Mi_Image_AllSz_win', ...
          num2str(miWindowSize)]);
        
        % Using only median kernel elements for boxplot
        if (medianCoef<1 && medianCoef>0)
          elNum=round(size(miAv,1)*medianCoef);
          skipNum=round((size(miAv,1)-elNum)/2);
          miAvBox=zeros(elNum,size(miAv,2));
          for tmp=1:size(mi,2)
            medMi=sort(miAv(:,tmp));
            miAvBox(:,tmp)=medMi((1+skipNum):(1+skipNum+elNum-1));
          end
        else
          miAvBox=miAv;
        end
          
        % Plot boxplots of MI for PATIENT
        titleStr={'Mutual information',['All seizures, MI Win. size: ', ...
          num2str(miWindowSize),'s']};
        f=plotDataBoxplot(miAvBox,shiftLabels,titleStr);
        savePlot2File(f,'png',[reportwpath,'/',dirs{i},'/'],['Mi_AllSz','_win',num2str(miWindowSize)]);
        savePlot2File(f,'fig',[reportwpath,'/',dirs{i},'/'],['Mi_AllSz','_win',num2str(miWindowSize)]);
        
        % Tests
        f=statTests(miAv,shiftLabels);
        savePlot2File(f,'png',[reportwpath,'/',dirs{i},'/'],['Mi_Tests_Sz',num2str(sIdx),'_win', ...
          num2str(miWindowSize)]);
        savePlot2File(f,'fig',[reportwpath,'/',dirs{i},'/'],['Mi_Tests_Sz',num2str(sIdx),'_win', ...
          num2str(miWindowSize)]);  
        
        % Plot number of averagings for all time stamps
        f=figure('Visible','Off');
        set(f,'PaperPositionMode','auto');
        set(f,'Position', [0 100 1350 400]);
        bar(cntBuf);
        set(gca,'XTickLabel',shiftLabels,'XTick',1:numel(shiftLabels));
        XTickLabel = get(gca,'XTickLabel');
        set(gca,'XTickLabel',' ');
        hxLabel = get(gca,'XLabel');
        set(hxLabel,'Units','data');
        xLabelPosition=get(hxLabel,'Position');
        y=xLabelPosition(2)-0.5;
        XTick=get(gca,'XTick');
        y=repmat(y,length(XTick),1);
        fs=get(gca,'fontsize');
        hText=text(XTick, y, XTickLabel,'fontsize',fs);
        set(hText,'Rotation',90,'HorizontalAlignment','right');
        title('Number of probes in averaging in av.MI for patient');
        grid on;
        savePlot2File(f,'png',[reportwpath,'/',dirs{i},'/'], ...
          ['Mi_Cnt_AllSz_win',num2str(miWindowSize)]);
        savePlot2File(f,'fig',[reportwpath,'/',dirs{i},'/'], ...
          ['Mi_Cnt_AllSz_win',num2str(miWindowSize)]);
        
        % Store calculated data
        save([reportwpath,'/',dirs{i},'/MI_Total_win', ...
        num2str(miWindowSize),'.mat'],'miAv');
        
        patTime=toc;
        totalTime=totalTime+patTime;
        disp(['Elapsed time: ',num2str(patTime),' s']);
      end
      
      close all;
    end
  end
  eTimeStr=datestr(totalTime/86400, 'HH:MM:SS');
  disp(['Total elapsed time: ',eTimeStr]);
  if (parallelFlag>0)
    delete(gcp);
  end
end

function [mi,miVar,miSur,miVarSur,miLabels,s,idxPrev]=calcShiftedMi(ia,s,p,startTime,sDuration, ...
  miWindowSize,idxPrev,wpath,pdir,subjectInfoFileName)
  % Calculate number of interconnected channels 
  miChNum=sum(1:(p.minChNum-1));
  
  mi=zeros(miChNum,1);
  miVar=zeros(miChNum,1);
  miSur=zeros(miChNum,1);
  miVarSur=zeros(miChNum,1);
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
  if (idx~=idxPrev)
    disp(['Processing ',pdir,'/',p.signalsAll{idx,1}]);
    s=loadRecord(wpath,[pdir,'/',p.signalsAll{idx,1}],subjectInfoFileName,...
      1,1,1);
  end
  startTime=startTime-p.signalsAll{idx,2};
  if (startTime+sDuration-s.records<11)
    if (startTime+sDuration>=s.records)
      startTime=s.records-sDuration-miWindowSize-1;
    end
    sigIdxBuf=p.signalsAll{idx,5}(1:p.minChNum);
    [mi,miVar,miSur,miVarSur,miLabels]=ia.windowedShortTimeMi(s,sigIdxBuf,startTime,sDuration,miWindowSize);
  end
  idxPrev=idx;
end
