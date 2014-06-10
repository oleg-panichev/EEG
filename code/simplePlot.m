% Example ploting one channel of EEG signal
%
function simplePlot(s,path)
  chNum=round(1+(s.chNum-1)*rand(1,1));
  [sig,fs]=s.getSingleChannel(chNum);
  sigLen=length(sig);
  sigTime=0:1/fs:(sigLen-1)/fs;
  
  f=figure;
  hs(1)=subplot(2,1,1);
  plot(sigTime,sig);  
  xlim([sigTime(1) sigTime(end)]);
  ylabel([s.label{chNum},', ',s.units{chNum}]);
  grid on;
  
  hs(2)=subplot(2,1,2);
  plot(sigTime,s.annSeizure,'r','Linewidth',3);
  xlabel('Time, s');
  xlim([sigTime(1) sigTime(end)]);
  ylabel('Seizure status');
  grid on;
  
  linkaxes(hs, 'x');
  savePlot2File(f,'png',path,'simplePlot');
  savePlot2File(f,'fig',path,'simplePlot');
end