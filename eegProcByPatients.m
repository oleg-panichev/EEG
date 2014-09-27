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
  sDuration=0.5; % Large window size, seconds
  shiftBuf=[7200:-300:3600,3300:-300:30]; % Backshift values from seizure, seconds
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
  
  disp(['Averaging window size = ',num2str(sDuration),' s']);
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
      miVarAllSz=cell(nOfSeizures,1);
      miDiffAllSz=cell(nOfSeizures,1);
      
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
          [mi(:,end),miVar(:,end),miSur(:,end),miVarSur(:,end),miLabels]= ...
            ia.windowedShortTimeMi(s,sigIdxBuf,(sStartTime+8+2*sDuration),sDuration,miWindowSize);
          [mi(:,end-1),miVar(:,end-1),miSur(:,end-1),miVarSur(:,end-1),~]= ...
            ia.windowedShortTimeMi(s,sigIdxBuf,(sStartTime+8+sDuration),sDuration,miWindowSize);
          [mi(:,end-2),miVar(:,end-2),miSur(:,end-2),miVarSur(:,end-2),~]= ...
            ia.windowedShortTimeMi(s,sigIdxBuf,(sStartTime+8),sDuration,miWindowSize);
          [mi(:,end-3),miVar(:,end-3),miSur(:,end-3),miVarSur(:,end-3),~]= ...
            ia.windowedShortTimeMi(s,sigIdxBuf,(sStartTime-5),sDuration, ...
            miWindowSize);

          % Calculating MI with shifts back before seizure and
          % abs(diff(MI))
          tmp=numel(shiftBuf);
          idxPrev=k;
          absStartTime=sStartTime+p.signalsAll{k,2};
          while tmp>0
            startTime=absStartTime-shiftBuf(tmp);
            if (startTime > prevSeizureStartTime)
              [mi(:,tmp),miVar(:,tmp),miSur(:,tmp),miVarSur(:,tmp),~,s,idxPrev]=...
                calcShiftedMi(ia,s,p,startTime,sDuration,miWindowSize,...
                idxPrev,wpath,dirs{i},subjectInfoFileName);         
            else
              break;
            end
            tmp=tmp-1;
          end   
          prevSeizureStartTime=absStartTime;
          miDiff=zeros(size(mi));
          miDiff(:,2:end)=abs(diff(mi,1,2));
          
          % Distance between MI-points in N-dim. space
          Rfull=zeros(size(mi,2),size(mi,2));
          for tmp1=1:size(mi,2)
            for tmp2=1:size(mi,2)
              Rfull(tmp1,tmp2)=distance(mi(:,tmp1),mi(:,tmp2));
            end
          end
          titleStr=({'Distance between MI-points',['Seizure ',num2str(sIdx),' from ',...
            sSigName,' at ',num2str(absStartTime),'s, Averaging win. size: ',...
            num2str(sDuration),'s, MI Win. size: ',num2str(miWindowSize),'s. ' ...
            ]});
          f=plotDistances(Rfull,shiftLabels,titleStr);
          savePlot2File(f,'png',[reportwpath,'/',dirs{i},'/'],['MiDistance_Sz',num2str(sIdx),'_win', ...
            num2str(miWindowSize)]);

          % Using only median kernel elements for boxplot
          if (medianCoef<1 && medianCoef>0)
            elNum=round(size(mi,1)*medianCoef);
            skipNum=round((size(mi,1)-elNum)/2);
            miBox=zeros(elNum,size(mi,2));
            miVarBox=zeros(elNum,size(mi,2));
            miDiffBox=zeros(elNum,size(mi,2));
            for tmp=1:size(mi,2)
              medMi=sort(mi(:,tmp));
              miBox(:,tmp)=medMi((1+skipNum):(1+skipNum+elNum-1));
              medMi=sort(miVar(:,tmp));
              miVarBox(:,tmp)=medMi((1+skipNum):(1+skipNum+elNum-1));
              medMi=sort(miDiff(:,tmp));
              miDiffBox(:,tmp)=medMi((1+skipNum):(1+skipNum+elNum-1));
            end
          else
            miBox=mi;
            miVarBox=miVar;
            miDiffBox=miDiff;
          end
          
          % Plot results for current SEIZURE
          f=figure('Visible','Off');
          set(f,'PaperPositionMode','auto');
          set(f,'Position',[0 100 1350 400]);
          set(f,'DefaultAxesLooseInset',[0,0.1,0,0]);
          boxplot(miBox,shiftLabels);
          set(gca,'XTick',1:numel(shiftLabels),'XTickLabel',shiftLabels);
          XTickLabel = get(gca,'XTickLabel');
          set(gca,'XTickLabel',' ');
          hxLabel = get(gca,'XLabel');
          set(hxLabel,'Units','data');
          xLabelPosition = get(hxLabel,'Position');
          y = xLabelPosition(2);
          XTick = get(gca,'XTick');
          y=repmat(y,length(XTick),1);
          fs = get(gca,'fontsize');
          hText = text(XTick, y, XTickLabel,'fontsize',fs);
          set(hText,'Rotation',90,'HorizontalAlignment','right')
          
          ylabel('MI');
          title({'Mutual information',['Seizure ',num2str(sIdx),' from ',...
            sSigName,' at ',num2str(absStartTime),'s, Averaging win. size: ',...
            num2str(sDuration),'s, MI Win. size: ',num2str(miWindowSize),'s']});
          grid on;
          savePlot2File(f,'png',[reportwpath,'/',dirs{i},'/'],['Mi_Sz',num2str(sIdx),'_win', ...
            num2str(miWindowSize)]);
          savePlot2File(f,'fig',[reportwpath,'/',dirs{i},'/'],['Mi_Sz',num2str(sIdx),'_win', ...
            num2str(miWindowSize)]);

          f=figure('Visible','Off');
          set(f,'PaperPositionMode','auto');
          set(f, 'Position', [0 100 1350 400]);
          set(f,'DefaultAxesLooseInset',[0,0.1,0,0]);
          boxplot(miVarBox,shiftLabels);
          set(gca,'XTick',1:numel(shiftLabels),'XTickLabel',shiftLabels);
          XTickLabel = get(gca,'XTickLabel');
          set(gca,'XTickLabel',' ');
          hxLabel = get(gca,'XLabel');
          set(hxLabel,'Units','data');
          xLabelPosition = get(hxLabel,'Position');
          y = xLabelPosition(2);
          XTick = get(gca,'XTick');
          y=repmat(y,length(XTick),1);
          fs = get(gca,'fontsize');
          hText = text(XTick, y, XTickLabel,'fontsize',fs);
          set(hText,'Rotation',90,'HorizontalAlignment','right')
          
          ylabel('var(MI)');
          title({'Mutual information variance',['Seizure ',num2str(sIdx),' from ',...
            sSigName,' at ',num2str(absStartTime),'s, Averaging win. size: ',...
            num2str(sDuration),'s, MI Win. size: ',num2str(miWindowSize),'s']});
          grid on;
          savePlot2File(f,'png',[reportwpath,'/',dirs{i},'/'],['MiVar_Sz',num2str(sIdx),'_win', ...
            num2str(miWindowSize)]);
          savePlot2File(f,'fig',[reportwpath,'/',dirs{i},'/'],['MiVar_Sz',num2str(sIdx),'_win', ...
            num2str(miWindowSize)]);

          f=figure('Visible','Off');
          set(f,'PaperPositionMode','auto');
          set(f, 'Position', [0 100 1350 400]);
          set(f,'DefaultAxesLooseInset',[0,0.1,0,0]);
          boxplot(miDiffBox,shiftLabels);
          set(gca,'XTick',1:numel(shiftLabels),'XTickLabel',shiftLabels);
          XTickLabel = get(gca,'XTickLabel');
          set(gca,'XTickLabel',' ');
          hxLabel = get(gca,'XLabel');
          set(hxLabel,'Units','data');
          xLabelPosition = get(hxLabel,'Position');
          y = xLabelPosition(2);
          XTick = get(gca,'XTick');
          y=repmat(y,length(XTick),1);
          fs = get(gca,'fontsize');
          hText = text(XTick, y, XTickLabel,'fontsize',fs);
          set(hText,'Rotation',90,'HorizontalAlignment','right');
          
          ylabel('diff(MI)');
          title({'Mutual information diff',['Seizure ',num2str(sIdx),' from ',...
            sSigName,' at ',num2str(absStartTime),'s, Averaging win. size: ',...
            num2str(sDuration),'s, MI Win. size: ',num2str(miWindowSize),'s']});
          grid on;
          savePlot2File(f,'png',[reportwpath,'/',dirs{i},'/'],['MiDiff_Sz',num2str(sIdx),'_win', ...
            num2str(miWindowSize)]);
          savePlot2File(f,'fig',[reportwpath,'/',dirs{i},'/'],['MiDiff_Sz',num2str(sIdx),'_win', ...
            num2str(miWindowSize)]);
          
          % Tests
          testLabels={'kstest','kstest2','ttest2','ranksum'};
          testMi=zeros(4,length(shiftLabels),3)+0.5;
          testMiVar=zeros(4,length(shiftLabels),3)+0.5;
          testDiff=zeros(4,length(shiftLabels),3)+0.5;
          redColor=[1,0,0];
          for tmp=1:length(shiftLabels)
            if (mi(1,tmp)~=0)
              testMi(1,tmp,1:3)=kstest(mi(:,tmp));
              testMi(2,tmp,1:3)=kstest2(mi(:,tmp),mi(:,end));
              testMi(3,tmp,1:3)=ttest2(mi(:,tmp),mi(:,end));
              [~,testMi(4,tmp,1:3)]=ranksum(mi(:,tmp),mi(:,end));

              testMiVar(1,tmp,1:3)=kstest(miVar(:,tmp));
              testMiVar(2,tmp,1:3)=kstest2(miVar(:,tmp),miVar(:,end));
              testMiVar(3,tmp,1:3)=ttest2(miVar(:,tmp),miVar(:,end));
              [~,testMiVar(4,tmp,1:3)]=ranksum(miVar(:,tmp),miVar(:,end));

              testDiff(1,tmp,1:3)=kstest(miDiff(:,tmp));
              testDiff(2,tmp,1:3)=kstest2(miDiff(:,tmp),miDiff(:,end));
              testDiff(3,tmp,1:3)=ttest2(miDiff(:,tmp),miDiff(:,end));
              [~,testDiff(4,tmp,1:3)]=ranksum(miDiff(:,tmp),miDiff(:,end));
            end
          end
          [idxM,idxN]=find(isnan(testMi(:,:,1)));
          for tmp=1:numel(idxN)
            nanIdx=find(isnan(mi(:,idxN)));
            if numel(nanIdx>0)
              disp(['MI contain NaNs.']);
            end
            testMi(idxM(tmp),idxN(tmp),:)=redColor;
          end
          
          testMiFull=zeros(length(shiftLabels),length(shiftLabels),3)+0.5;
          for rowIdx=1:length(shiftLabels)
            for colIdx=1:length(shiftLabels)
              if (mi(1,rowIdx)~=0 && mi(1,colIdx)~=0)
                testMiFull(rowIdx,colIdx,1:3)=kstest2(mi(:,rowIdx),mi(:,colIdx));
              end
            end
          end
          figure
          imagesc(testMiFull);
          set(gca,'YTick',1:numel(shiftLabels),'XTick',1:numel(shiftLabels), ...
            'XTickLabel',shiftLabels,'YTickLabel',shiftLabels);
          title({'Tests for MI',['Seizure ',num2str(sIdx),' from ',...
            sSigName,' at ',num2str(absStartTime),'s, Averaging win. size: ',...
            num2str(sDuration),'s, MI Win. size: ',num2str(miWindowSize),'s. ', ...
            '1 - white, 0 - black, NaN - red.']});     
          XTickLabel = get(gca,'XTickLabel');
          set(gca,'XTickLabel',' ');
          hxLabel = get(gca,'XLabel');
          set(hxLabel,'Units','data');
          xLabelPosition = get(hxLabel,'Position');
          y = xLabelPosition(2)-0.7;
          XTick = get(gca,'XTick');
          y=repmat(y,length(XTick),1);
          fs = get(gca,'fontsize');
          hText = text(XTick, y, XTickLabel,'fontsize',fs);
          set(hText,'Rotation',90,'HorizontalAlignment','right');
            
          %% Plot tests results
          f=figure('Visible','On');
          set(f,'PaperPositionMode','auto');
          set(f,'Position',[0 60 1350 650]);
          set(f,'DefaultAxesLooseInset',[0,0.1,0,0]);
          subplot(3,1,1);
          imagesc(testMi);
          colormap(gray);
          set(gca,'YTick',1:4,'YTickLabel',testLabels,'XTick',1:numel(shiftLabels), ...
            'XTickLabel',shiftLabels);
          XTickLabel = get(gca,'XTickLabel');
          set(gca,'XTickLabel',' ');
          hxLabel = get(gca,'XLabel');
          set(hxLabel,'Units','data');
          xLabelPosition = get(hxLabel,'Position');
          y = xLabelPosition(2)-0.7;
          XTick = get(gca,'XTick');
          y=repmat(y,length(XTick),1);
          fs = get(gca,'fontsize');
          hText = text(XTick, y, XTickLabel,'fontsize',fs);
          set(hText,'Rotation',90,'HorizontalAlignment','right');
          
          title({'Tests for MI',['Seizure ',num2str(sIdx),' from ',...
            sSigName,' at ',num2str(absStartTime),'s, Averaging win. size: ',...
            num2str(sDuration),'s, MI Win. size: ',num2str(miWindowSize),'s. ', ...
            '1 - white, 0 - black, NaN - red.']});      
          grid minor;
          subplot(3,1,2);
          imagesc(testMiVar);
          colormap(gray);
          set(gca,'YTick',1:4,'YTickLabel',testLabels,'XTick',1:numel(shiftLabels), ...
            'XTickLabel',shiftLabels);
          XTickLabel = get(gca,'XTickLabel');
          set(gca,'XTickLabel',' ');
          hxLabel = get(gca,'XLabel');
          set(hxLabel,'Units','data');
          xLabelPosition = get(hxLabel,'Position');
          y = xLabelPosition(2)-0.6;
          XTick = get(gca,'XTick');
          y=repmat(y,length(XTick),1);
          fs = get(gca,'fontsize');
          hText = text(XTick, y, XTickLabel,'fontsize',fs);
          set(hText,'Rotation',90,'HorizontalAlignment','right');
          
          title('Tests for MI var');
          grid minor;
          subplot(3,1,3);
          imagesc(testDiff);
          colormap(gray);
          set(gca,'YTick',1:4,'YTickLabel',testLabels,'XTick',1:numel(shiftLabels), ...
            'XTickLabel',shiftLabels);
          XTickLabel = get(gca,'XTickLabel');
          set(gca,'XTickLabel',' ');
          hxLabel = get(gca,'XLabel');
          set(hxLabel,'Units','data');
          xLabelPosition = get(hxLabel,'Position');
          y = xLabelPosition(2)-0.6;
          XTick = get(gca,'XTick');
          y=repmat(y,length(XTick),1);
          fs = get(gca,'fontsize');
          hText = text(XTick, y, XTickLabel,'fontsize',fs);
          set(hText,'Rotation',90,'HorizontalAlignment','right');
          
          title('Tests for MI diff');
          grid minor;
          savePlot2File(f,'png',[reportwpath,'/',dirs{i},'/'],['Tests_Sz',num2str(sIdx),'_win', ...
            num2str(miWindowSize)]);
          savePlot2File(f,'fig',[reportwpath,'/',dirs{i},'/'],['Tests_Sz',num2str(sIdx),'_win', ...
            num2str(miWindowSize)]);

          %% Store calculated data
          saveWrapper([reportwpath,'/',dirs{i},'/','Mi_Sz',num2str(sIdx),'_win', ...
            num2str(miWindowSize),'.mat'],mi,miVar,miSur,miVarSur,miDiff);
          if (numel(mi)>0)
            miAllSz{sIdx}=mi;
            miVarAllSz{sIdx}=miVar;
            miDiffAllSz{sIdx}=miDiff;
            sIdx=sIdx+1;
          end
          close all;
        end
      end
      cntBuf=zeros(size(seizuresSigIdx));
      disp(['Number of processed good seizures: ',num2str(sIdx-1)]);
      if (size(miAllSz,1)>0 && size(miAllSz,2)>0)
        miAv=zeros(size(mi));
        miVarAv=zeros(size(mi));
        miDiffAv=zeros(size(mi));
        for j=1:size(miAv,2)
          cnt=0;
          for n=1:sIdx-1
%             n,j,size(miAv,2),sIdx
%             size(miAllSz)
            if (numel(miAllSz{n}) > 0)
              if (miAllSz{n}(1,j) ~= 0)
                miAv(:,j)=miAv(:,j)+miAllSz{n}(:,j);
                miVarAv(:,j)=miVarAv(:,j)+miVarAllSz{n}(:,j);
                miDiffAv(:,j)=miDiffAv(:,j)+miDiffAllSz{n}(:,j);
                cnt=cnt+1;
              end
            end
          end
          miAv(:,j)=miAv(:,j)/cnt;
          miVarAv(:,j)=miVarAv(:,j)/cnt;
          miDiffAv(:,j)=miDiffAv(:,j)/cnt;
          cntBuf(j)=cnt;
        end
        
        %% Using only median kernel elements for boxplot
        if (medianCoef<1 && medianCoef>0)
          elNum=round(size(miAv,1)*medianCoef);
          skipNum=round((size(miAv,1)-elNum)/2);
          miAvBox=zeros(elNum,size(miAv,2));
          miVarAvBox=zeros(elNum,size(miAv,2));
          miDiffAvBox=zeros(elNum,size(miAv,2));
          for tmp=1:size(mi,2)
            medMi=sort(miAv(:,tmp));
            miAvBox(:,tmp)=medMi((1+skipNum):(1+skipNum+elNum-1));
            medMi=sort(miVarAv(:,tmp));
            miVarAvBox(:,tmp)=medMi((1+skipNum):(1+skipNum+elNum-1));
            medMi=sort(miDiffAv(:,tmp));
            miDiffAvBox(:,tmp)=medMi((1+skipNum):(1+skipNum+elNum-1));
          end
        else
          miAvBox=mi;
          miVarAvBox=miVar;
          miDiffAvBox=miDiff;
        end
          
        %% Plot results for current PATIENT
        f=figure('Visible','Off');
        set(f,'PaperPositionMode','auto');
        set(f, 'Position', [0 100 1350 400]);
        set(f,'DefaultAxesLooseInset',[0,0,0,0]);
        boxplot(miAvBox,shiftLabels);
        set(gca,'XTick',1:numel(shiftLabels),'XTickLabel',shiftLabels);
        XTickLabel = get(gca,'XTickLabel');
        set(gca,'XTickLabel',' ');
        hxLabel = get(gca,'XLabel');
        set(hxLabel,'Units','data');
        xLabelPosition = get(hxLabel,'Position');
        y = xLabelPosition(2);
        XTick = get(gca,'XTick');
        y=repmat(y,length(XTick),1);
        fs = get(gca,'fontsize');
        hText = text(XTick, y, XTickLabel,'fontsize',fs);
        set(hText,'Rotation',90,'HorizontalAlignment','right');
        ylabel('MI');
        title({'Mutual information',['All seizures, MI Win. size: ', ...
          num2str(miWindowSize),'s']});
        grid on;
        savePlot2File(f,'png',[reportwpath,'/',dirs{i},'/'],['Mi_AllSz','_win',num2str(miWindowSize)]);
        savePlot2File(f,'fig',[reportwpath,'/',dirs{i},'/'],['Mi_AllSz','_win',num2str(miWindowSize)]);
        
        f=figure('Visible','Off');
        set(f,'PaperPositionMode','auto');
        set(f, 'Position', [0 100 1350 400]);
        set(f,'DefaultAxesLooseInset',[0,0,0,0]);
        boxplot(miVarAvBox,shiftLabels);
        set(gca,'XTick',1:numel(shiftLabels),'XTickLabel',shiftLabels);
        XTickLabel = get(gca,'XTickLabel');
        set(gca,'XTickLabel',' ');
        hxLabel = get(gca,'XLabel');
        set(hxLabel,'Units','data');
        xLabelPosition = get(hxLabel,'Position');
        y = xLabelPosition(2);
        XTick = get(gca,'XTick');
        y=repmat(y,length(XTick),1);
        fs = get(gca,'fontsize');
        hText = text(XTick, y, XTickLabel,'fontsize',fs);
        set(hText,'Rotation',90,'HorizontalAlignment','right');
        ylabel('MI');
        title({'Mutual information variance',['All seizures, MI Win. size: ', ...
          num2str(miWindowSize),'s']});
        grid on;
        savePlot2File(f,'png',[reportwpath,'/',dirs{i},'/'],['MiVar_AllSz','_win',num2str(miWindowSize)]);
        savePlot2File(f,'fig',[reportwpath,'/',dirs{i},'/'],['MiVar_AllSz','_win',num2str(miWindowSize)]);
        
        f=figure('Visible','Off');
        set(f,'PaperPositionMode','auto');
        set(f, 'Position', [0 100 1350 400]);
        set(f,'DefaultAxesLooseInset',[0,0,0,0]);
        boxplot(miDiffAvBox,shiftLabels);
        set(gca,'XTick',1:numel(shiftLabels),'XTickLabel',shiftLabels);
        XTickLabel = get(gca,'XTickLabel');
        set(gca,'XTickLabel',' ');
        hxLabel = get(gca,'XLabel');
        set(hxLabel,'Units','data');
        xLabelPosition = get(hxLabel,'Position');
        y = xLabelPosition(2);
        XTick = get(gca,'XTick');
        y=repmat(y,length(XTick),1);
        fs = get(gca,'fontsize');
        hText = text(XTick, y, XTickLabel,'fontsize',fs);
        set(hText,'Rotation',90,'HorizontalAlignment','right');
        ylabel('MI');
        title({'Mutual information diff',['All seizures, MI Win. size: ', ...
          num2str(miWindowSize),'s']});
        grid on;
        savePlot2File(f,'png',[reportwpath,'/',dirs{i},'/'], ...
          ['MiDiff_AllSz','_win',num2str(miWindowSize)]);
        savePlot2File(f,'fig',[reportwpath,'/',dirs{i},'/'], ...
          ['MiDiff_AllSz','_win',num2str(miWindowSize)]);
        
        saveWrapper([reportwpath,'/',dirs{i},'/MI_Total_win', ...
          num2str(miWindowSize),'.mat'],miAv,miVarAv,miDiffAv);
        
        %% Tests
        testLabels={'kstest','kstest2','ttest2','ranksum'};
        testMi=zeros(4,length(shiftLabels))+0.5;
        testMiVar=zeros(4,length(shiftLabels))+0.5;
        testDiff=zeros(4,length(shiftLabels))+0.5;       
        redColor=[1,0,0];
        for tmp=1:length(shiftLabels)
          if (numel(miAv)>0)
            if (miAv(1,tmp)~=0 && ~isnan(miAv(1,tmp)))
              testMi(1,tmp)=kstest(miAv(:,tmp));
              testMi(2,tmp)=kstest2(miAv(:,tmp),miAv(:,end));
              testMi(3,tmp)=ttest2(miAv(:,tmp),miAv(:,end));
              [~,testMi(4,tmp)]=ranksum(miAv(:,tmp),miAv(:,end));

              testMiVar(1,tmp)=kstest(miVarAv(:,tmp));
              testMiVar(2,tmp)=kstest2(miVarAv(:,tmp),miVarAv(:,end));
              testMiVar(3,tmp)=ttest2(miVarAv(:,tmp),miVarAv(:,end));
              [~,testMiVar(4,tmp)]=ranksum(miVarAv(:,tmp),miVarAv(:,end));

              testDiff(1,tmp)=kstest(miDiffAv(:,tmp));
              testDiff(2,tmp)=kstest2(miDiffAv(:,tmp),miDiffAv(:,end));
              testDiff(3,tmp)=ttest2(miDiffAv(:,tmp),miDiffAv(:,end));
              [~,testDiff(4,tmp)]=ranksum(miDiffAv(:,tmp),miDiffAv(:,end));
            end
          end
        end
        [idxM,idxN]=find(isnan(testMi(:,:,1)));
        for tmp=1:numel(idxN)
          nanIdx=find(isnan(mi(:,idxN)));
          if numel(nanIdx>0)
            disp(['MI contain NaNs.']);
          end
          testMi(idxM(tmp),idxN(tmp),:)=redColor;
        end

        f=figure('Visible','On');
        set(f,'PaperPositionMode','auto');
        set(f,'Position',[0 100 1350 600]);
        set(f,'DefaultAxesLooseInset',[0,0,0,0]);
        subplot(3,1,1);
        imagesc(testMi);
        colormap(gray);
        set(gca,'YTick',1:4,'YTickLabel',testLabels,'XTick',1:numel(shiftLabels), ...
          'XTickLabel',shiftLabels);
        XTickLabel = get(gca,'XTickLabel');
        set(gca,'XTickLabel',' ');
        hxLabel = get(gca,'XLabel');
        set(hxLabel,'Units','data');
        xLabelPosition = get(hxLabel,'Position');
        y = xLabelPosition(2)-0.7;
        XTick = get(gca,'XTick');
        y=repmat(y,length(XTick),1);
        fs = get(gca,'fontsize');
        hText = text(XTick, y, XTickLabel,'fontsize',fs);
        set(hText,'Rotation',90,'HorizontalAlignment','right');
        title({'Tests for MI',['All seizures, MI Win. size: ', ...
          num2str(miWindowSize),'s. 1 - white, 0 - black, NaN - red.']});
        grid minor;
        subplot(3,1,2);
        imagesc(testMiVar);
        colormap(gray);
        set(gca,'YTick',1:4,'YTickLabel',testLabels,'XTick',1:numel(shiftLabels), ...
          'XTickLabel',shiftLabels);
        XTickLabel = get(gca,'XTickLabel');
        set(gca,'XTickLabel',' ');
        hxLabel = get(gca,'XLabel');
        set(hxLabel,'Units','data');
        xLabelPosition = get(hxLabel,'Position');
        y = xLabelPosition(2)-0.6;
        XTick = get(gca,'XTick');
        y=repmat(y,length(XTick),1);
        fs = get(gca,'fontsize');
        hText = text(XTick, y, XTickLabel,'fontsize',fs);
        set(hText,'Rotation',90,'HorizontalAlignment','right');
        title('Tests for MI var');
        grid minor;
        subplot(3,1,3);
        imagesc(testDiff);
        colormap(gray);
        set(gca,'YTick',1:4,'YTickLabel',testLabels,'XTick',1:numel(shiftLabels), ...
          'XTickLabel',shiftLabels);
        XTickLabel = get(gca,'XTickLabel');
        set(gca,'XTickLabel',' ');
        hxLabel = get(gca,'XLabel');
        set(hxLabel,'Units','data');
        xLabelPosition = get(hxLabel,'Position');
        y = xLabelPosition(2)-0.6;
        XTick = get(gca,'XTick');
        y=repmat(y,length(XTick),1);
        fs = get(gca,'fontsize');
        hText = text(XTick, y, XTickLabel,'fontsize',fs);
        set(hText,'Rotation',90,'HorizontalAlignment','right');
        title('Tests for MI diff');
        grid minor;
        savePlot2File(f,'png',[reportwpath,'/',dirs{i},'/'],['TestsAll_win', ...
          num2str(miWindowSize)]);
        savePlot2File(f,'fig',[reportwpath,'/',dirs{i},'/'],['TestsAll_win', ...
          num2str(miWindowSize)]);
        
        f=figure('Visible','Off');
        set(f,'PaperPositionMode','auto');
        set(f,'Position', [0 100 1350 400]);
        set(f,'DefaultAxesLooseInset',[0,0,0,0]);
        bar(cntBuf);
        set(gca,'XTickLabel',shiftLabels,'XTick',1:numel(shiftLabels));
        XTickLabel = get(gca,'XTickLabel');
        set(gca,'XTickLabel',' ');
        hxLabel = get(gca,'XLabel');
        set(hxLabel,'Units','data');
        xLabelPosition = get(hxLabel,'Position');
        y = xLabelPosition(2)-0.1;
        XTick = get(gca,'XTick');
        y=repmat(y,length(XTick),1);
        fs = get(gca,'fontsize');
        hText = text(XTick, y, XTickLabel,'fontsize',fs);
        set(hText,'Rotation',90,'HorizontalAlignment','right');
        title('Number of probes in averaging in av.MI for patient');
        grid on;
        savePlot2File(f,'png',[reportwpath,'/',dirs{i},'/'], ...
          ['Mi_AllSzCnt','_win',num2str(miWindowSize)]);
        savePlot2File(f,'fig',[reportwpath,'/',dirs{i},'/'], ...
          ['Mi_AllSzCnt','_win',num2str(miWindowSize)]);
        
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
