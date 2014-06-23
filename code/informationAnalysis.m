% Class for information flow analysis in EEG signals.
%
classdef informationAnalysis < handle
  properties (SetAccess='private') 
    skipSecondsStart=0; % Number of seconds to skip from the begining
    skipSecondsEnd=0; % Number of seconds to use after skipSecondsStart
    miFs=1; % Sample rate of mutual information
    chNum=22; % Number of first N channels to analize, 0 - to use all channels
    winSize; % Size of window to analyze signal
    
    idxEnd;
    miChNum;
    tMiBuf;
    miLen;
%     miBuf;
%     miSurBuf;
    miLabels;
    
    miChBuf; % miChBuf - pre-seizure,pre-seizure surrogate,seizure,seizure surrogate.
  end
  
  methods  (Access='public')
    % Constructor
    function obj=informationAnalysis(s)
      obj.winSize=2*s.eegFs; % Size of window to analyze signal
      % Check parameters
      if (obj.chNum==0 || obj.chNum>s.chNum)
        obj.chNum=s.chNum;
      end  
      if (obj.skipSecondsEnd>0)
        obj.idxEnd=(obj.skipSecondsStart+obj.skipSecondsEnd)*s.eegFs;
      else
        obj.idxEnd=s.eegLen-obj.winSize;
      end
      if (obj.idxEnd>s.eegLen-obj.winSize)
        obj.idxEnd=s.eegLen-obj.winSize;
      end
      
      % Calculate number of interconnected channels
      i=obj.chNum-1;
      obj.miChNum=0;
      while i>0
        obj.miChNum=obj.miChNum+i;
        i=i-1;
      end
%       disp(['Number of channel pairs: ',num2str(obj.miChNum)]);

      
      % Prepare buffers for data
      obj.tMiBuf=obj.skipSecondsStart+obj.winSize/s.eegFs+1:1/obj.miFs:obj.idxEnd/s.eegFs;
      obj.miLen=length(obj.tMiBuf);
%       obj.miBuf=zeros(obj.miChNum,obj.miLen);
%       obj.miSurBuf=zeros(obj.miChNum,obj.miLen);
      obj.miLabels=cell(obj.miChNum,1);
      
      obj.miChBuf=zeros(obj.miChNum,4);
    end
    
    % Function for estimation MI(t) in predefined window for all channels
    % combinations.
    function [miChBuf,miCellBuf]=estMutualInfTimeDomain(obj,s,path,verbose)    
      chIdx=1;  
      [nOfSeizures,~]=size(s.seizureTimings);
      miCellBuf=cell(obj.miChNum,2);

      % Calculate MI for all channels
      disp('Calculating mutual information...');
      for k=1:obj.chNum
        disp(['Channel #',num2str(k),'...']);
        for j=(k+1):obj.chNum
          idx=1;   
          for i=obj.skipSecondsStart*s.eegFs+obj.winSize+1:s.eegFs/obj.miFs:obj.idxEnd  
            obj.miBuf(chIdx,idx)=muinfo(s.record(k,i-obj.winSize: ...
              i+obj.winSize),s.record(j,i-obj.winSize:i+obj.winSize));  
            
            % Permutate second signal for surrogate obtaining
            permData=s.record(j,i-obj.winSize:i+obj.winSize);
            permData=permData(randperm(length(permData)));
            obj.miSurBuf(chIdx,idx)=muinfo(s.record(k,i-obj.winSize: ...
              i+obj.winSize),permData);  
            
            idx=idx+1;
          end
          obj.miLabels{chIdx}=([s.label{k},'-',s.label{j}]);
          
          % Store averaged MI and other info 
          seizureIdx=false(size(obj.tMiBuf));
          for i=1:nOfSeizures
            seizureIdx=seizureIdx+obj.tMiBuf>=s.seizureTimings(i,1) & ...
              obj.tMiBuf<=s.seizureTimings(i,2);
          end
          nonSeizureIdx=~seizureIdx;
          obj.miChBuf(chIdx,1)=mean(obj.miBuf(nonSeizureIdx)); %%% ÈÑÏÐÀÂÈÒÜ ÈÍÄÅÊÑÈÐÎÂÀÍÈÅ 
          obj.miChBuf(chIdx,2)=mean(obj.miSurBuf(nonSeizureIdx)); %%% ÈÑÏÐÀÂÈÒÜ 
          if (nOfSeizures>0)
            obj.miChBuf(chIdx,3)=mean(obj.miBuf(seizureIdx)); %%% ÈÑÏÐÀÂÈÒÜ 
            obj.miChBuf(chIdx,4)=mean(obj.miSurBuf(seizureIdx)); %%% ÈÑÏÐÀÂÈÒÜ 
          else
            obj.miChBuf(chIdx,3)=NaN;
            obj.miChBuf(chIdx,4)=NaN;
          end
          miCellBuf{chIdx,1}=obj.miLabels{chIdx};
          miCellBuf{chIdx,2}=s.patientName;
          
          chIdx=chIdx+1;
        end
      end
      miChBuf=obj.miChBuf;
      
      if (verbose>0)
        obj.plotMiData(s,path,'miAllChannels',obj.miBuf);
        obj.plotMiData(s,path,'miAllSurrChannels',obj.miSurBuf);
      end
           
      % Box plot
      [~,pairIdx]=max(obj.miChBuf(:,1)); % The channels pair with the highest MI will be analysed next
      [nOfSeizures,~]=size(s.seizureTimings);
      if (nOfSeizures>0)
        for i=1:nOfSeizures
          seizureIdx=find(obj.tMiBuf>=s.seizureTimings(i,1) & obj.tMiBuf<=s.seizureTimings(i,2));
          nonSeizureIdx=seizureIdx-length(seizureIdx);
          f=figure;
          boxplot([obj.miBuf(pairIdx,nonSeizureIdx)',obj.miSurBuf(pairIdx,nonSeizureIdx)', ...
            obj.miBuf(pairIdx,seizureIdx)',obj.miSurBuf(pairIdx,seizureIdx)'], ...
            {'Pre-seizure','Pre-seizure surrogate','Seizure','Seizure surrogate'}); hold on;
          title({'MI box plot',['Channels: ',obj.miLabels{pairIdx},', Seizure length = ', ...
            num2str(obj.tMiBuf(seizureIdx(end))-obj.tMiBuf(seizureIdx(1))), ...
            ', MI window length: ',num2str(obj.winSize/s.eegFs),' s']});
          grid on;
          savePlot2File(f,'png',path,['boxPlot',num2str(i),'_w',num2str(obj.winSize/s.eegFs),'s']);
          savePlot2File(f,'fig',path,['boxPlot',num2str(i),'_w',num2str(obj.winSize/s.eegFs),'s']);
        end
      else
        f=figure;
        boxplot([obj.miBuf(pairIdx,:)',obj.miSurBuf(pairIdx,:)'], ...
          {'Non-seizure','Non-seizure surrogate'}); hold on;
        title({'MI box plot',['Channels: ',obj.miLabels{pairIdx}, ...
          ', MI window length: ',num2str(obj.winSize/s.eegFs),' s']});
        grid on;
        savePlot2File(f,'png',path,['boxPlot',num2str(i),'_w',num2str(obj.winSize/s.eegFs),'s']);
        savePlot2File(f,'fig',path,['boxPlot',num2str(i),'_w',num2str(obj.winSize/s.eegFs),'s']);
      end
      
      disp('Done.');
    end

    % Function for plotting results from estMutualInfTimeDomain(~)
    function plotMiData(obj,s,path,fname,miBuf)
      colors=[1,0,1;0.1,0.7,0.1;0,0,1;0,0.2,0.8]';
      f=figure;
      hs(1)=subplot(8,1,1:6);
      shift=0;
      t=obj.tMiBuf(1):1/s.eegFs:obj.tMiBuf(end);

      for i=1:obj.miChNum
%         miTemp=miBuf(i,:)/max(abs(miBuf(i,:)))-shift;
%         if (i>1)
%           shift=shift+max(miBuf(i,:));
%         end
        miTemp=miBuf(i,:)-shift;
        shiftBuf(1:obj.miLen)=-shift;
        plot(obj.tMiBuf,miTemp,'Color',colors(:,mod(i,3)+1),'LineWidth',2); hold on;
        text(obj.tMiBuf(10),miTemp(10),obj.miLabels(i),...
          'VerticalAlignment','Bottom','FontSize',7);
        plot(obj.tMiBuf,shiftBuf,'Color',[0,0,0]); 
        shift=shift+1;
      end
      xlim([t(1) t(end)]);
      ylim([-shift+1 1]);
      ylabel('Mutual information'); 
      grid on;

      hs(2)=subplot(8,1,7);
      plot(obj.tMiBuf,sum(obj.miBuf,1)/obj.miChNum,'Color',[0.2,0.4,0.3],...
        'Linewidth',3);
      xlim([t(1) t(end)]);
      ylabel('Sum(MI)');
      grid on;

      hs(3)=subplot(8,1,8); 
      ann=s.annSeizure(obj.skipSecondsStart*s.eegFs+obj.winSize+1:obj.idxEnd-s.eegFs+1);
      plot(t,ann,'r','Linewidth',3);
      xlabel('Time, s');
      xlim([t(1) t(end)]);
      ylabel('Seizure status');
      xlabel('Time, s');
      grid on;
      linkaxes(hs, 'x');

      savePlot2File(f,'png',path,fname);
      savePlot2File(f,'fig',path,fname);
    end
    
    % Function for MI estimation for all epileptic seizures set. MI window
    % size equals length of the seizure for each pair pre-seizure/seizure
    % MI.
    function [miSzChBuf,nOfSeizures]=estMiAllPairs(obj,s,path)
      [nOfSeizures,~]=size(s.seizureTimings);
      disp('Calculating mutual information...');
      miSzChBuf=zeros(obj.miChNum*nOfSeizures,4);
      t=0:1/s.eegFs:(s.eegLen-1)/s.eegFs;
      for i=1:nOfSeizures
        chIdx=1;
        for k=1:obj.chNum
          disp(['Channel #',num2str(k),'...']);
          for j=k+1:obj.chNum
            seizureIdx=find(t>=s.seizureTimings(i,1) & t<=s.seizureTimings(i,2));
            preSeizureIdx=seizureIdx-length(seizureIdx);

            obj.miChBuf(chIdx,3)=muinfo(s.record(k,seizureIdx),s.record(j,seizureIdx));
            permData=s.record(j,seizureIdx);
            permData=permData(randperm(length(permData)));
            obj.miChBuf(chIdx,4)=muinfo(s.record(k,seizureIdx),permData);
            
            obj.miChBuf(chIdx,1)=muinfo(s.record(k,preSeizureIdx),s.record(j,preSeizureIdx));
            permData=s.record(j,preSeizureIdx);
            permData=permData(randperm(length(permData)));
            obj.miChBuf(chIdx,2)=muinfo(s.record(k,seizureIdx),permData);
            
            obj.miLabels{chIdx}=([s.label{k},'-',s.label{j}]);
            chIdx=chIdx+1;
          end
        end 
        f=figure;
        boxplot(obj.miChBuf,{'Pre-seizure','Pre-seizure surrogate','Seizure','Seizure surrogate'}); 
        title({'MI box plot',['Seizure length = ',num2str(s.seizureTimings(i,2)-s.seizureTimings(i,1))]});
        grid on;
        savePlot2File(f,'png',path,['AllChPairs_BoxPlot',num2str(i)]);
        savePlot2File(f,'fig',path,['AllChPairs_BoxPlot',num2str(i)]);

        miSzChBuf((i-1)*obj.miChNum+1:i*obj.miChNum,:)=obj.miChBuf;
      end 
    end
    
    % Function for estimation MI(t) in predefined window for all channels
    % combinations.
    function [miAvBuf,miLabels]=windowedShortTimeMi(obj,s,sStartTime, ...
        sDuration,miWindowSize)    
      chIdx=1;  
      obj.miFs=round(miWindowSize/2);
      miAvBuf=zeros(obj.miChNum,2);

      % Calculate MI for all channels
      disp('Calculating mutual information...');
      halfWinSz=round(miWindowSize*s.eegFs/2);
      samplesBuf=(sStartTime*s.eegFs+halfWinSz+1):(s.eegFs/obj.miFs) ...
              :((sStartTime+sDuration)*s.eegFs-halfWinSz);
      miBuf=zeros(obj.miChNum,numel(samplesBuf)); 
      miSurBuf=zeros(obj.miChNum,numel(samplesBuf)); 
      for k=1:obj.chNum
%         disp(['Channel #',num2str(k),'...']);
        for j=(k+1):obj.chNum
          idx=1;     
          for i=samplesBuf;
            miBuf(chIdx,idx)=muinfo(s.record(k,i-halfWinSz:i+halfWinSz),...
              s.record(j,i-halfWinSz:i+halfWinSz));  
            
            % Permutate second signal for surrogate obtaining
            permData=s.record(j,(i-halfWinSz):(i+halfWinSz));
            permData=permData(randperm(length(permData)));
            miSurBuf(chIdx,idx)=muinfo(s.record(k,i-halfWinSz:i+halfWinSz),permData);  
            
            idx=idx+1;
          end
          obj.miLabels{chIdx}=([s.label{k},'-',s.label{j}]);
          
          % Store averaged MI and other info 
          miAvBuf(chIdx,1)=mean(miBuf(chIdx,:));
          miAvBuf(chIdx,2)=mean(miSurBuf(chIdx,:));
          
          chIdx=chIdx+1;
        end
      end
      miLabels=obj.miLabels;
      disp('Done.');
    end
  end % methods
end % classdef