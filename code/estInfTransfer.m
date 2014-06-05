% Function for mutual information estimation
%
function estInfTransfer(s,path)
  skipSecondsStart=2900; % Number of seconds to skip from the begining
  skipSecondsEnd=200; % Number of seconds to use after skipSecondsStart
  miFs=1; % Sample rate of mutual information
  chNum=3; % Number of first N channels to analize, 0 - to use all channels
  winSize=2*s.eegFs; % Size of window to analyze signal
  
  % Check parameters
  if (chNum==0)
    chNum=s.chNum;
  end  
  if (skipSecondsEnd>0)
    idxEnd=(skipSecondsStart+skipSecondsEnd)*s.eegFs;
  else
    idxEnd=s.eegLen-winSize;
  end
  if (idxEnd>s.eegLen-winSize)
    idxEnd=s.eegLen-winSize;
  end
  
  % Calculate number of interconnected channels
  i=chNum-1;
  miChNum=0;
  while i>0
    miChNum=miChNum+i;
    i=i-1;
  end
  disp(['Number of channel pairs: ',num2str(miChNum)]);
  
  % Prepare buffers for data
  tMiBuf=skipSecondsStart+winSize/s.eegFs+1:1/miFs:idxEnd/s.eegFs;
  miLen=length(tMiBuf);
  miBuf=zeros(miChNum,miLen);
  tMiBuf=skipSecondsStart+winSize/s.eegFs+1:1/miFs:idxEnd/s.eegFs;
  miLabels=cell(miChNum,1);
  chIdx=1;  
  
  % Calculate MI for all channels
  disp('Calculating mutual information...');
  for k=1:chNum
    disp(['Channel #',num2str(k)]);
    for j=k+1:chNum
      idx=1;
      for i=skipSecondsStart*s.eegFs+winSize+1:s.eegFs/miFs:idxEnd  
        miBuf(chIdx,idx)=calculateMutualInformation(s.record(k,i-winSize:i+winSize),s.record(j,i-winSize:i+winSize));   
        idx=idx+1;
      end
      miLabels{chIdx}=([s.label{k},'-',s.label{j}]);
      chIdx=chIdx+1;
    end
  end
  
  % Plot MI results
  colors=[1,0,1;0.1,0.7,0.1;0,0,1;0,0.2,0.8]';
  f=figure;
  hs(1)=subplot(8,1,1:6);
  shift=0;
  t=tMiBuf(1):1/s.eegFs:tMiBuf(end);
  for i=1:miChNum
    miTemp=miBuf(i,:)/max(abs(miBuf(i,:)))-shift;
    shiftBuf(1:miLen)=-shift;
    plot(tMiBuf,miTemp,'Color',colors(:,mod(i,3)+1),'LineWidth',2); hold on;
    text(tMiBuf(10),miTemp(10),miLabels(i),...
      'VerticalAlignment','Bottom','FontSize',7);
    plot(tMiBuf,shiftBuf,'Color',[0,0,0]);
    shift=shift+1;
  end
  xlim([t(1) t(end)]);
  ylim([-shift+1 1]);
  ylabel('Mutual information'); 
  grid on;
  
  hs(2)=subplot(8,1,7);
  plot(tMiBuf,sum(miBuf,1)/miChNum,'Color',[0.2,0.4,0.3],...
    'Linewidth',3);
  xlim([t(1) t(end)]);
  ylabel('Sum(MI)');
  grid on;
  
  hs(3)=subplot(8,1,8); 
  ann=s.annSeizure(skipSecondsStart*s.eegFs+winSize+1:idxEnd-s.eegFs+1);
  plot(t,ann,'r','Linewidth',3);
  xlabel('Time, s');
  xlim([t(1) t(end)]);
  ylabel('Seizure status');
  xlabel('Time, s');
  grid on;
  linkaxes(hs, 'x');

  savePlot2File(f,'png',path,'miAllChannels');
  savePlot2File(f,'fig',path,'miAllChannels');
  disp('Done.');
  
  % Box plot
  annMiFs=s.annSeizure(skipSecondsStart*s.eegFs+winSize+1:s.eegFs/miFs:idxEnd);
  nonSeizureIdx=find(annMiFs==0);
  seizureIdx=find(annMiFs==1);
  figure
  boxplot(miBuf(1,nonSeizureIdx),'NonSZ'); hold on;
  boxplot(miBuf(1,seizureIdx),'SZ');
end