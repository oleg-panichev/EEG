% Function for mutual information estimation
%
classdef informationAnalysis < handle
  properties (SetAccess='private') 
    skipSecondsStart=2900; % Number of seconds to skip from the begining
    skipSecondsEnd=200; % Number of seconds to use after skipSecondsStart
    miFs=1; % Sample rate of mutual information
    chNum=0; % Number of first N channels to analize, 0 - to use all channels
    winSize; % Size of window to analyze signal
    
    idxEnd;
    miChNum;
    tMiBuf;
    miLen;
    miBuf;
    miSurBuf;
    miLabels;
    
    miChBuf; % miChBuf - pre-seizure,pre-seizure surrogate,seizure,seizure surrogate.
  end
  
  methods  (Access='public')
    function obj=informationAnalysis(s)
      obj.winSize=2*s.eegFs; % Size of window to analyze signal
      % Check parameters
      if (obj.chNum==0)
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
      disp(['Number of channel pairs: ',num2str(obj.miChNum)]);

      % Prepare buffers for data
      obj.tMiBuf=obj.skipSecondsStart+obj.winSize/s.eegFs+1:1/obj.miFs:obj.idxEnd/s.eegFs;
      obj.miLen=length(obj.tMiBuf);
      obj.miBuf=zeros(obj.miChNum,obj.miLen);
      obj.miSurBuf=zeros(obj.miChNum,obj.miLen);
      obj.miLabels=cell(obj.miChNum,1);
      
      obj.miChBuf=zeros(obj.miChNum,4);
    end
    
    function estMutualInfTimeDomain(obj,s,path)    
      chIdx=1;  

      % Calculate MI for all channels
      disp('Calculating mutual information...');
      for k=1:obj.chNum
        disp(['Channel #',num2str(k),'...']);
        for j=k+1:obj.chNum
          idx=1;   
          for i=obj.skipSecondsStart*s.eegFs+obj.winSize+1:s.eegFs/obj.miFs:obj.idxEnd  
            obj.miBuf(chIdx,idx)=calculateMutualInformation(s.record(k,i-obj.winSize: ...
              i+obj.winSize),s.record(j,i-obj.winSize:i+obj.winSize));  
            permData=s.record(j,i-obj.winSize:i+obj.winSize);
            permData=permData(randperm(length(permData)));
            obj.miSurBuf(chIdx,idx)=calculateMutualInformation(s.record(k,i-obj.winSize: ...
              i+obj.winSize),permData);  
            idx=idx+1;
          end
          obj.miLabels{chIdx}=([s.label{k},'-',s.label{j}]);
          chIdx=chIdx+1;
        end
      end

      obj.plotMiData(s,path,'miAllChannels',obj.miBuf);
      obj.plotMiData(s,path,'miAllSurrChannels',obj.miSurBuf);
      
      pairNum=1;
      % Box plot
      [nOfSeizures,~]=size(s.seizureTimings);
      for i=1:nOfSeizures
        annMiFs=s.annSeizure(obj.skipSecondsStart*s.eegFs+obj.winSize+1:s.eegFs/obj.miFs:obj.idxEnd);
        seizureIdx=find(obj.tMiBuf>=s.seizureTimings(i,1) & obj.tMiBuf<=s.seizureTimings(i,2));
        nonSeizureIdx=seizureIdx-length(seizureIdx);
        f=figure;
        boxplot([obj.miBuf(pairNum,nonSeizureIdx)',obj.miBuf(pairNum,seizureIdx)'],{'Pre-seizure','Seizure'}); hold on;
        title({'MI box plot',['Seizure length = ',num2str(obj.tMiBuf(seizureIdx(end))-obj.tMiBuf(seizureIdx(1)))]});
        grid on;
        savePlot2File(f,'png',path,['boxPlot',num2str(i)]);
        savePlot2File(f,'fig',path,['boxPlot',num2str(i)]);
      end
      
      disp('Done.');
    end

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
    
    function miSzChBuf=estMiAllPairs(obj,s,path)
      [nOfSeizures,~]=size(s.seizureTimings);
      disp('Calculating mutual information...');
      miSzChBuf=zeros(obj.miChNum8nOfSeizures,4);
      t=0:1/s.eegFs:(s.eegLen-1)/s.eegFs;
      for i=1:nOfSeizures
        chIdx=1;
        for k=1:obj.chNum
          disp(['Channel #',num2str(k),'...']);
          for j=k+1:obj.chNum
            idx=1;   
            seizureIdx=find(t>=s.seizureTimings(i,1) & t<=s.seizureTimings(i,2));
            preSeizureIdx=seizureIdx-length(seizureIdx);

            obj.miChBuf(chIdx,3)=calculateMutualInformation(s.record(k,seizureIdx),s.record(j,seizureIdx));
            permData=s.record(j,seizureIdx);
            permData=permData(randperm(length(permData)));
            obj.miChBuf(chIdx,4)=calculateMutualInformation(s.record(k,seizureIdx),permData);
            
            obj.miChBuf(chIdx,1)=calculateMutualInformation(s.record(k,preSeizureIdx),s.record(j,preSeizureIdx));
            permData=s.record(j,preSeizureIdx);
            permData=permData(randperm(length(permData)));
            obj.miChBuf(chIdx,2)=calculateMutualInformation(s.record(k,seizureIdx),permData);
            
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
      end 
    end
  end
end