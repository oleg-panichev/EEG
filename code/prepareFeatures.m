function [features,labels]=prepareFeatures(s)
  run('processingProperties.m');
  fs=s.sampling_frequency;
  % Mutual information
  mi=[];
  for i=1:round(60*fs):floor(s.data_length_sec*fs-miWindowSize*fs)
    [temp,~,miLabels]=muinfoMultiChannel(s.data,i, ...
      round(miWindowSize*fs),s.channels);
    mi=[mi,temp];
  end
  temp=mean(mi,2);
  features=[mean(temp);var(temp)];
  labels=miLabels;
  
  % Instant amplitude and phase
  winSize=10; 
  tBuf=1:round(60*fs):floor(s.data_length_sec*fs-winSize*fs);
  iAmpl=zeros(numel(s.channels),1);
  iPhase=zeros(numel(s.channels),1);
  hData=zeros(size(s.data));
  for i=1:numel(s.channels)
    hData(i,:)=hilbert(s.data(i,:));
  end
  for m=1:numel(s.channels)
    for i=tBuf 
      iAmpl(m)=iAmpl(m)+mean(abs(hData(m,i:i+round(winSize*fs))));
      iPhase(m)=iPhase(m)+mean(phase(hData(m,i:i+round(winSize*fs))));
    end
    iAmpl(m)=iAmpl(m)/numel(tBuf);
    iPhase(m)=iPhase(m)/numel(tBuf);
  end
  features=[mean(iAmpl);var(iAmpl);mean(iPhase);var(iPhase);];

%   % Distance
%   winSize=60; 
%   colIdx=1;
%   tBuf=1:round(60*fs):floor(s.data_length_sec*fs-winSize*fs);
%   temp=zeros(sum(1:(numel(s.channels)-1)),numel(tBuf));
%   for i=tBuf 
%     rowIdx=1;   
%     for m=1:numel(s.channels)
%       for n=(m+1):numel(s.channels)
%         x=sort(s.data(m,i:i+round(winSize*fs)));
%         y=sort(s.data(n,i:i+round(winSize*fs)));
%         temp(rowIdx,colIdx)=chSqDistance(x,y,20);%euDistance(x,y);
%         rowIdx=rowIdx+1;
%       end
%     end
%     colIdx=colIdx+1;
%   end
%   labels=cell(sum(1:(numel(s.channels)-1)),1);
%   idx=1;
%   for m=1:numel(s.channels)
%     for n=(m+1):numel(s.channels)
%       labels{idx}=([num2str(m),'-',num2str(n)]);
%       idx=idx+1;
%     end
%   end
% %   k=0.8;
% %   t=medianVector(temp(1,:),k);
% %   nt=zeros(size(temp,1),numel(t));
% %   for i=1:size(temp,1)
% %     nt(i,:)=medianVector(temp(1,:),k);
% %   end
%   temp=mean(temp,2);
% %   features=[mean(temp);var(temp)];
% %   [B,I]=sort(temp);
% %   temp=temp(I(25:end-24));
%   features=[mean(temp);var(temp);var(temp.^2)];
% %   i=1;
% %   winSize=20;
% %   for m=1:numel(s.channels)
% %     for n=(m+1):numel(s.channels)
% %       x=sort(s.data(m,1:round(winSize*fs)));
% %       y=sort(s.data(n,1:round(winSize*fs)));
% %       temp(i)=chSqDistance(x,y,12);
% %       i=i+1;
% %     end
% %   end
% %   features=[features;temp];
end