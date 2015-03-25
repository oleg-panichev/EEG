function [features,fNames,fTimes,fLabels]=prepareFeatures(propertiesFunction,s)
  propertiesFunction();
  
  % Transpose data if needed
  data=s.data;
  if (size(data,1)>size(data,2))
    data=data';
  end
  fs=s.sampling_frequency;
  fIdx=1;

  %% Filter data  
  disp('Filtering data with HP filter...');
  % HP filter
  N=round(fs*2); % Order
  Fc=0.5; % Cutoff Frequency
  flag='scale';  % Sampling Flag
  % Create the window vector for the design algorithm.
  win=hamming(N+1);
  % Calculate the coefficients using the FIR1 function.
  b=fir1(N,Fc/(fs/2),'high',win,flag);
  for chIdx=1:size(data,1)
    data(chIdx,:)=filtfilt(b,1,data(chIdx,:));
  end
  
  % LP filter
  disp('Filtering data with LP filter...');
  N=round(fs*2); % Order
  Fc=40; % Cutoff Frequency
  flag='scale'; % Sampling Flag
  % Create the window vector for the design algorithm.
  win=hamming(N+1);
  % Calculate the coefficients using the FIR1 function.
  b=fir1(N,Fc/(fs/2),'low',win,flag);
  for chIdx=1:size(data,1)
    data(chIdx,:)=filtfilt(b,1,data(chIdx,:));
  end
  
  % Calculating features:
  
  %% Cross-correlation between channels
%   disp('Cross-correlation between channels...');
%   winSize=corrcWinSize; % Seconds
%   stepSize=corrcStepSize; % Seconds
%   [corrc,corrc_mean,corrc_std,corrc_fLabels,corrc_mean_fLabels,...
%     corrc_std_fLabels,tBuf]=f_corrBetweenChannels(data,fs,...
%     winSize*fs,stepSize*fs,s.channels);
%   features{fIdx}=corrc; fNames{fIdx}=['corrc_w',num2str(winSize),'_s',num2str(stepSize)]; 
%   fTimes{fIdx}=tBuf; fLabels{fIdx}=corrc_fLabels; fIdx=fIdx+1;
%   features{fIdx}=corrc_mean; fNames{fIdx}=['corrc_mean_w',num2str(winSize),'_s',num2str(stepSize)]; 
%   fTimes{fIdx}=tBuf; fLabels{fIdx}=corrc_mean_fLabels; fIdx=fIdx+1;
%   features{fIdx}=corrc_std; fNames{fIdx}=['corrc_std_w',num2str(winSize),'_s',num2str(stepSize)]; 
%   fTimes{fIdx}=tBuf; fLabels{fIdx}=corrc_std_fLabels; fIdx=fIdx+1;
  
  %% Cross-correlation between rhythms in channels
%   disp('Cross-correlation between rhythms in channels...');
%   winSize=corrcWinSize; % Seconds
%   stepSize=corrcStepSize; % Seconds
%   [corrc_a,corrc_a_mean,corrc_a_std,corrc_a_fLabels,corrc_a_mean_fLabels,...
%   corrc_a_std_fLabels,corrc_b,corrc_b_mean,corrc_b_std,corrc_b_fLabels,corrc_b_mean_fLabels,...
%   corrc_b_std_fLabels,corrc_d,corrc_d_mean,corrc_d_std,corrc_d_fLabels,corrc_d_mean_fLabels,...
%   corrc_d_std_fLabels,corrc_t,corrc_t_mean,corrc_t_std,corrc_t_fLabels,corrc_t_mean_fLabels,...
%   corrc_t_std_fLabels,tBuf]=f_corrcBetweenRhythmChannels(data,fs,...
%     winSize*fs,stepSize*fs,s.channels);
%   features{fIdx}=corrc_a; fNames{fIdx}=['corrc_A_w',num2str(winSize),'_s',num2str(stepSize)]; 
%   fTimes{fIdx}=tBuf; fLabels{fIdx}=corrc_a_fLabels; fIdx=fIdx+1;
%   features{fIdx}=corrc_a_mean; fNames{fIdx}=['corrc_A_mean_w',num2str(winSize),'_s',num2str(stepSize)]; 
%   fTimes{fIdx}=tBuf; fLabels{fIdx}=corrc_a_mean_fLabels; fIdx=fIdx+1;
%   features{fIdx}=corrc_a_std; fNames{fIdx}=['corrc_A_std_w',num2str(winSize),'_s',num2str(stepSize)]; 
%   fTimes{fIdx}=tBuf; fLabels{fIdx}=corrc_a_std_fLabels; fIdx=fIdx+1;
%   
%   features{fIdx}=corrc_b; fNames{fIdx}=['corrc_B_w',num2str(winSize),'_s',num2str(stepSize)]; 
%   fTimes{fIdx}=tBuf; fLabels{fIdx}=corrc_b_fLabels; fIdx=fIdx+1;
%   features{fIdx}=corrc_b_mean; fNames{fIdx}=['corrc_B_mean_w',num2str(winSize),'_s',num2str(stepSize)]; 
%   fTimes{fIdx}=tBuf; fLabels{fIdx}=corrc_b_mean_fLabels; fIdx=fIdx+1;
%   features{fIdx}=corrc_b_std; fNames{fIdx}=['corrc_B_std_w',num2str(winSize),'_s',num2str(stepSize)]; 
%   fTimes{fIdx}=tBuf; fLabels{fIdx}=corrc_b_std_fLabels; fIdx=fIdx+1;
%   
%   features{fIdx}=corrc_d; fNames{fIdx}=['corrc_D_w',num2str(winSize),'_s',num2str(stepSize)]; 
%   fTimes{fIdx}=tBuf; fLabels{fIdx}=corrc_d_fLabels; fIdx=fIdx+1;
%   features{fIdx}=corrc_d_mean; fNames{fIdx}=['corrc_D_mean_w',num2str(winSize),'_s',num2str(stepSize)]; 
%   fTimes{fIdx}=tBuf; fLabels{fIdx}=corrc_d_mean_fLabels; fIdx=fIdx+1;
%   features{fIdx}=corrc_d_std; fNames{fIdx}=['corrc_D_std_w',num2str(winSize),'_s',num2str(stepSize)]; 
%   fTimes{fIdx}=tBuf; fLabels{fIdx}=corrc_d_std_fLabels; fIdx=fIdx+1;
%   
%   features{fIdx}=corrc_t; fNames{fIdx}=['corrc_T_w',num2str(winSize),'_s',num2str(stepSize)]; 
%   fTimes{fIdx}=tBuf; fLabels{fIdx}=corrc_t_fLabels; fIdx=fIdx+1;
%   features{fIdx}=corrc_t_mean; fNames{fIdx}=['corrc_T_mean_w',num2str(winSize),'_s',num2str(stepSize)]; 
%   fTimes{fIdx}=tBuf; fLabels{fIdx}=corrc_t_mean_fLabels; fIdx=fIdx+1;
%   features{fIdx}=corrc_t_std; fNames{fIdx}=['corrc_T_std_w',num2str(winSize),'_s',num2str(stepSize)]; 
%   fTimes{fIdx}=tBuf; fLabels{fIdx}=corrc_t_std_fLabels; fIdx=fIdx+1;
  
  %% Spectral features
  disp('Spectral features...');
  winSize=corrcWinSize; % Seconds
  stepSize=corrcStepSize; % Seconds
  [d_mean,t_mean,a_mean,b_mean,dt_mean,da_mean,db_mean,...
  td_mean,ta_mean,tb_mean,ad_mean,at_mean,ab_mean,bd_mean,bt_mean,ba_mean,...
  d_mean_fLabels,t_mean_fLabels,a_mean_fLabels,b_mean_fLabels,...
  dt_mean_fLabels,da_mean_fLabels,db_mean_fLabels,...
  td_mean_fLabels,ta_mean_fLabels,tb_mean_fLabels,...
  ad_mean_fLabels,at_mean_fLabels,ab_mean_fLabels,...
  bd_mean_fLabels,bt_mean_fLabels,ba_mean_fLabels,...
  tBuf]=f_spectralFeatures(data,fs,...
    winSize*fs,stepSize*fs,s.channels);
  
  features{fIdx}=d_mean; fNames{fIdx}=['Delta_mean_w',num2str(winSize),'_s',num2str(stepSize)]; 
  fTimes{fIdx}=tBuf; fLabels{fIdx}=d_mean_fLabels; fIdx=fIdx+1;
  features{fIdx}=t_mean; fNames{fIdx}=['Theta_mean_w',num2str(winSize),'_s',num2str(stepSize)]; 
  fTimes{fIdx}=tBuf; fLabels{fIdx}=t_mean_fLabels; fIdx=fIdx+1;
  features{fIdx}=a_mean; fNames{fIdx}=['Alpha_mean_w',num2str(winSize),'_s',num2str(stepSize)]; 
  fTimes{fIdx}=tBuf; fLabels{fIdx}=a_mean_fLabels; fIdx=fIdx+1;
  features{fIdx}=b_mean; fNames{fIdx}=['Beta_mean_w',num2str(winSize),'_s',num2str(stepSize)]; 
  fTimes{fIdx}=tBuf; fLabels{fIdx}=b_mean_fLabels; fIdx=fIdx+1;
  
  features{fIdx}=dt_mean; fNames{fIdx}=['DeltaToTheta_mean_w',num2str(winSize),'_s',num2str(stepSize)]; 
  fTimes{fIdx}=tBuf; fLabels{fIdx}=dt_mean_fLabels; fIdx=fIdx+1;
  features{fIdx}=da_mean; fNames{fIdx}=['DeltaToAlpha_mean_w',num2str(winSize),'_s',num2str(stepSize)]; 
  fTimes{fIdx}=tBuf; fLabels{fIdx}=da_mean_fLabels; fIdx=fIdx+1;
  features{fIdx}=db_mean; fNames{fIdx}=['DeltaToBeta_mean_w',num2str(winSize),'_s',num2str(stepSize)]; 
  fTimes{fIdx}=tBuf; fLabels{fIdx}=db_mean_fLabels; fIdx=fIdx+1;
  
  features{fIdx}=td_mean; fNames{fIdx}=['ThetaToDelta_mean_w',num2str(winSize),'_s',num2str(stepSize)]; 
  fTimes{fIdx}=tBuf; fLabels{fIdx}=td_mean_fLabels; fIdx=fIdx+1;
  features{fIdx}=ta_mean; fNames{fIdx}=['ThetaToAlpha_mean_w',num2str(winSize),'_s',num2str(stepSize)]; 
  fTimes{fIdx}=tBuf; fLabels{fIdx}=ta_mean_fLabels; fIdx=fIdx+1;
  features{fIdx}=tb_mean; fNames{fIdx}=['ThetaToBeta_mean_w',num2str(winSize),'_s',num2str(stepSize)]; 
  fTimes{fIdx}=tBuf; fLabels{fIdx}=tb_mean_fLabels; fIdx=fIdx+1;
  
  features{fIdx}=ad_mean; fNames{fIdx}=['AlphaToDelta_mean_w',num2str(winSize),'_s',num2str(stepSize)]; 
  fTimes{fIdx}=tBuf; fLabels{fIdx}=ad_mean_fLabels; fIdx=fIdx+1;
  features{fIdx}=at_mean; fNames{fIdx}=['AlphaToTheta_mean_w',num2str(winSize),'_s',num2str(stepSize)]; 
  fTimes{fIdx}=tBuf; fLabels{fIdx}=at_mean_fLabels; fIdx=fIdx+1;
  features{fIdx}=ab_mean; fNames{fIdx}=['AlphaToBeta_mean_w',num2str(winSize),'_s',num2str(stepSize)]; 
  fTimes{fIdx}=tBuf; fLabels{fIdx}=ab_mean_fLabels; fIdx=fIdx+1;
  
  features{fIdx}=bd_mean; fNames{fIdx}=['BetaToDelta_mean_w',num2str(winSize),'_s',num2str(stepSize)]; 
  fTimes{fIdx}=tBuf; fLabels{fIdx}=bd_mean_fLabels; fIdx=fIdx+1;
  features{fIdx}=bt_mean; fNames{fIdx}=['BetaToTheta_mean_w',num2str(winSize),'_s',num2str(stepSize)]; 
  fTimes{fIdx}=tBuf; fLabels{fIdx}=bt_mean_fLabels; fIdx=fIdx+1;
  features{fIdx}=ba_mean; fNames{fIdx}=['BetaToAlpha_mean_w',num2str(winSize),'_s',num2str(stepSize)]; 
  fTimes{fIdx}=tBuf; fLabels{fIdx}=ba_mean_fLabels; fIdx=fIdx+1;
  
  %% Eigen values of cross-correlation between channels
%   disp('Eigen values of cross-correlation between channels...');
%   winSize=corrcWinSize; % Seconds
%   stepSize=corrcStepSize; % Seconds
%   [corrcEig,corrcEig_mean,corrcEig_std,corrcEig_fLabels,corrcEig_mean_fLabels,...
%     corrcEig_std_fLabels,tBuf]=f_corrEigBetweenChannels(data,fs,...
%     winSize*fs,stepSize*fs,s.channels);
%   features{fIdx}=corrcEig; fNames{fIdx}=['corrcEig_w',num2str(winSize),'_s',num2str(stepSize)]; 
%   fTimes{fIdx}=tBuf; fLabels{fIdx}=corrcEig_fLabels; fIdx=fIdx+1;
%   features{fIdx}=corrcEig_mean; fNames{fIdx}=['corrcEig_mean_w',num2str(winSize),'_s',num2str(stepSize)]; 
%   fTimes{fIdx}=tBuf; fLabels{fIdx}=corrcEig_mean_fLabels; fIdx=fIdx+1;
%   features{fIdx}=corrcEig_std; fNames{fIdx}=['corrcEig_std_w',num2str(winSize),'_s',num2str(stepSize)]; 
%   fTimes{fIdx}=tBuf; fLabels{fIdx}=corrcEig_std_fLabels; fIdx=fIdx+1;
  
%   []=f_MIBetweee...
    
%   x=corrc;
%   save([fLocation,'/',sName,'.mat'],'x');
  
    %% Mutual information
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