function [features,labels,fTimes]=prepareFeatures(propertiesFunction,s,sName,...
    fLocation)
  propertiesFunction();
  fs=s.sampling_frequency;
  chNum=numel(s.channels);
  intChNum=sum(1:(chNum-1));
  fIdx=1;

  % Calculating features
  winSize=30; % Seconds
  stepSize=15; % Seconds
  [corrc,corrc_mean,corrc_std,tBuf]=f_corrBetweenChannels(data,fs,...
    winSize*fs,stepSize*fs);  
  features{fIdx}=corrc; labels{fIdx}=['corrc_w',num2str(winSize),'_s',num2str(stepSize)]; fTimes{fIdx}=tBuf; fIdx=fIdx+1;
  features{fIdx}=corrc_mean; labels{fIdx}=['corrc_mean_w',num2str(winSize),'_s',num2str(stepSize)]; fTimes{fIdx}=tBuf; fIdx=fIdx+1;
  features{fIdx}=corrc_std; labels{fIdx}=['corrc_std_w',num2str(winSize),'_s',num2str(stepSize)]; fTimes{fIdx}=tBuf; fIdx=fIdx+1;
  
%   x=corrc;
%   save([fLocation,'/',sName,'.mat'],'x');
  
%   % Mutual information
%   mi=zeros(intChNum,1);
%   idx=1;
%   [mi(:),~,~]=muinfoMultiChannel(s.data,1, ...
%     size(s.data,1),s.channels,0);
%   mi_av=mean(mi_avt);
%   mi_var=var(mi_avt);
  
  %% Euclidian Distance, Chi Square Distance, Bray-Curtis Dissimilarity
%   winSize=60;
%   stepSec=30; 
%   colIdx=1;
%   tBuf=1:round(stepSec*fs):floor(s.data_length_sec*fs-winSize*fs);
%   euDist=zeros(intChNum,numel(tBuf));
%   euDistSort=zeros(intChNum,numel(tBuf));
%   chSqDist=zeros(intChNum,numel(tBuf));
%   chSqDistSort=zeros(intChNum,numel(tBuf));
%   brCuDiss=zeros(intChNum,numel(tBuf));
%   brCuDissSort=zeros(intChNum,numel(tBuf));
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
%         ySort=sortBuf(n,:);
%         
%         euDist(rowIdx,colIdx)=euDistance(x,y);              
%         euDistSort(rowIdx,colIdx)=euDistance(xSort,ySort);
%         
%         chSqDist(rowIdx,colIdx)=euDistance(x,y);       
%         chSqDistSort(rowIdx,colIdx)=chSqDistance(xSort,ySort,20);
%         
%         brCuDiss(rowIdx,colIdx)=brCuDissimilarity(x,y);       
%         brCuDissSort(rowIdx,colIdx)=brCuDissimilarity(xSort,ySort);
%         
%         rowIdx=rowIdx+1;
%       end
%     end
%     colIdx=colIdx+1;
%   end
%   
%   euDist_avt=mean(euDist,2);
%   euDist_av=mean(euDist_avt);
%   euDist_var=var(euDist_avt);
%   euDistSort_avt=mean(euDistSort,2);
%   euDistSort_av=mean(euDistSort_avt);
%   euDistSort_var=var(euDistSort_avt);
%   
%   chSqDist_avt=mean(chSqDist,2);
%   chSqDist_av=mean(chSqDist_avt);
%   chSqDist_var=var(chSqDist_avt);
%   chSqDistSort_avt=mean(chSqDistSort,2);
%   chSqDistSort_av=mean(chSqDistSort_avt);
%   chSqDistSort_var=var(chSqDistSort_avt);
%   
%   brCuDiss_avt=mean(brCuDiss,2);
%   brCuDiss_av=mean(brCuDiss_avt);
%   brCuDiss_var=var(brCuDiss_avt);
%   brCuDissSort_avt=mean(brCuDissSort,2);
%   brCuDissSort_av=mean(brCuDissSort_avt);
%   brCuDissSort_var=var(brCuDissSort_avt);

  %% Instant amplitude and phase
%   winSize=10; 
%   tBuf=1:round(60*fs):floor(s.data_length_sec*fs-winSize*fs);
%   iAmpl=zeros(chNum,numel(tBuf));
%   iPhase=zeros(chNum,numel(tBuf));
%   iPhaseDiff=zeros(intChNum,numel(tBuf));
% 
%   colIdx=1;
%   
%   iNum=numel(1:1+round(winSize*fs));
%   hData=zeros(chNum,iNum);
%   phData=zeros(chNum,iNum);
%   for i=tBuf 
%     rowIdx=1;  
%     for m=1:chNum
%       hData(m,:)=hilbert(s.data(m,i:i+round(winSize*fs)));
%       phData(m,:)=phase(hData(m,:));
%     end
%     
%     for m=1:chNum
%       iAmpl(m,colIdx)=mean(hData(m,:));
%       iPhase(m,colIdx)=mean(phData(m,:));
%       for n=(m+1):chNum
%         iPhaseDiff(rowIdx,colIdx)=mean(abs(phData(m,:)-phData(n,:)));
%         rowIdx=rowIdx+1;
%       end
%     end
%     colIdx=colIdx+1;
%   end
% 
%   iAmpl_avt=mean(iAmpl,2);
%   iAmpl_av=mean(iAmpl_avt);
%   iAmpl_var=var(iAmpl_avt);
%   
%   iPhase_avt=mean(iPhase,2);
%   iPhase_av=mean(iPhase_avt);
%   iPhase_var=var(iPhase_avt);
%   
%   iPhaseDiff_avt=mean(iPhaseDiff,2);
%   iPhaseDiff_av=mean(iPhaseDiff_avt);
%   iPhaseDiff_var=var(iPhaseDiff_avt);
end