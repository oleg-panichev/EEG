function [features,labels]=prepareFeatures(s)
  run('processingProperties.m');
  fs=s.sampling_frequency;
  stepSec=30; 
  tBuf = 1:round(stepSec*fs):floor(s.data_length_sec*fs-miWindowSize*fs);
  chNum=numel(s.channels);
  intChNum=sum(1:(chNum-1));

%   % Mutual information
%   mi=zeros(intChNum,numel(tBuf));
%   idx=1;
%   for i=tBuf
%     [mi(:,idx),~,~]=muinfoMultiChannel(s.data,i, ...
%       round(miWindowSize*fs),s.channels,0);
%     idx=idx+1;
%   end
%   mi_avt=mean(mi,2);
%   mi_av=mean(mi_avt);
%   
%   % Distance
%   winSize=60;
%   stepSec=30; 
%   colIdx=1;
%   tBuf=1:round(stepSec*fs):floor(s.data_length_sec*fs-winSize*fs);
%   euDist=zeros(intChNum,numel(tBuf));
%   euDistSort=zeros(intChNum,numel(tBuf));
%   for i=tBuf 
%     rowIdx=1;  
%     sortBuf=zeros(chNum,numel(i:i+round(winSize*fs)));
%     for m=1:chNum
%       sortBuf(m,:)=sort(s.data(m,i:i+round(winSize*fs)));
%     end
%     
%     for m=1:chNum
%       x=s.data(m,i:i+round(winSize*fs));
%       xSort=sortBuf(m,:);
%       for n=(m+1):chNum        
%         y=s.data(n,i:i+round(winSize*fs));
%         euDist(rowIdx,colIdx)=euDistance(x,y);       
%         ySort=sortBuf(n,:);
%         euDistSort(rowIdx,colIdx)=euDistance(xSort,ySort);
%         rowIdx=rowIdx+1;
%       end
%     end
%     colIdx=colIdx+1;
%   end
%   
%   euDist_avt=mean(euDist,2);
%   euDist_av=mean(euDist_avt);
%   euDistSort_avt=mean(euDistSort,2);
%   euDistSort_av=mean(euDistSort_avt);

%   features={mi,mi_avt,mi_av,euDist,euDist_avt,euDist_av,euDistSort,...
%     euDistSort_avt,euDistSort_av};
%   labels=[];
  
  % Correlation
  winSize=60;
  stepSec=30; 
  colIdx=1;
  tBuf=1:round(stepSec*fs):floor(s.data_length_sec*fs-winSize*fs);
  corrc=zeros(intChNum,numel(tBuf));
  corrcSort=zeros(intChNum,numel(tBuf));
  for i=tBuf 
    rowIdx=1;  
    sortBuf=zeros(chNum,numel(i:i+round(winSize*fs)));
    for m=1:chNum
      sortBuf(m,:)=sort(s.data(m,i:i+round(winSize*fs)));
    end
    
    for m=1:chNum
      x=s.data(m,i:i+round(winSize*fs));
      xSort=sortBuf(m,:);
      for n=(m+1):chNum        
        y=s.data(n,i:i+round(winSize*fs));
        temp=corrcoef(x,y);
        corrc(rowIdx,colIdx)=temp(1,2);       
        ySort=sortBuf(n,:);
        temp=corrcoef(xSort,ySort);
        corrcSort(rowIdx,colIdx)=temp(1,2);
        rowIdx=rowIdx+1;
      end
    end
    colIdx=colIdx+1;
  end
  
  corrc_avt=mean(corrc,2);
  corrc_av=mean(corrc_avt);
  corrcSort_avt=mean(corrcSort,2);
  corrcSort_av=mean(corrcSort_avt);
  
  features={corrc,corrc_avt,corrc_av,...
    corrcSort,corrcSort_avt,corrcSort_av};
  labels=[];
  
%   % Instant amplitude and phase
%   winSize=10; 
%   tBuf=1:round(60*fs):floor(s.data_length_sec*fs-winSize*fs);
%   iAmpl=zeros(chNum,1);
%   iPhase=zeros(chNum,1);
%   iPhaseDiff=zeros(intChNum,1);
%   hData=zeros(size(s.data));
%   phData=zeros(size(s.data));
%   idx=1;
%   for i=1:chNum
%     hData(i,:)=hilbert(s.data(i,:));
%     phData=phase(hData(i,:));
%   end
%   for m=1:chNum
%     for i=tBuf 
%       iAmpl(m)=iAmpl(m)+mean(abs(hData(m,i:i+round(winSize*fs))));
%       iPhase(m)=iPhase(m)+mean(phase(hData(m,i:i+round(winSize*fs))));
%     end
%     iAmpl(m)=iAmpl(m)/numel(tBuf);
%     iPhase(m)=iPhase(m)/numel(tBuf);
%     
%     % Phase difference
%     for n=(m+1):chNum
%       iPhaseDiff(idx)=mean(phData(m,:)-phData(n,:));
%       idx=idx+1;
%     end
%   end
%   features=[features;iPhaseDiff];


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