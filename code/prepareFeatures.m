function [features,labels]=prepareFeatures(propertiesFile,s)
  run(propertiesFile);
  fs=s.sampling_frequency;
  chNum=numel(s.channels);
  intChNum=sum(1:(chNum-1));
  
  features=[];
  labels=[];

  % Mutual information
  mi=zeros(intChNum,1);
  idx=1;
  [mi(:),~,~]=muinfoMultiChannel(s.data,1, ...
    size(s.data,1),s.channels,0);
  mi_av=mean(mi_avt);
  mi_var=var(mi_avt);
  
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

  %% Correlation 0.5s
  winSize=0.5;
  stepSec=30; 
  colIdx=1;
  
  calcCorrFeatures();
  
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
  
  corrc_05=corrc;  
  corrc_05_avt=mean(corrc,2);
  corrc_05_av=mean(corrc_05_avt);
  corrc_05_var=var(corrc_05_avt);
  corrcSort_05=corrcSort;
  corrcSort_05_avt=mean(corrcSort,2);
  corrcSort_05_av=mean(corrcSort_05_avt);
  corrcSort_05_var=var(corrcSort_05_avt);
  
%   %% Correlation 1s
%   winSize=1;
%   stepSec=30; 
%   colIdx=1;
%   tBuf=1:round(stepSec*fs):floor(s.data_length_sec*fs-winSize*fs);
%   corrc=zeros(intChNum,numel(tBuf));
%   corrcSort=zeros(intChNum,numel(tBuf));
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
%         temp=corrcoef(x,y);
%         corrc(rowIdx,colIdx)=temp(1,2);       
%         ySort=sortBuf(n,:);
%         temp=corrcoef(xSort,ySort);
%         corrcSort(rowIdx,colIdx)=temp(1,2);
%         rowIdx=rowIdx+1;
%       end
%     end
%     colIdx=colIdx+1;
%   end
%   
%   corrc_1=corrc;  
%   corrc_1_avt=mean(corrc,2);
%   corrc_1_av=mean(corrc_1_avt);
%   corrc_1_var=var(corrc_1_avt);
%   corrcSort_1=corrcSort;
%   corrcSort_1_avt=mean(corrcSort,2);
%   corrcSort_1_av=mean(corrcSort_1_avt);
%   corrcSort_1_var=var(corrcSort_1_avt);
%   
%   %% Correlation 2s
%   winSize=2;
%   stepSec=30; 
%   colIdx=1;
%   tBuf=1:round(stepSec*fs):floor(s.data_length_sec*fs-winSize*fs);
%   corrc=zeros(intChNum,numel(tBuf));
%   corrcSort=zeros(intChNum,numel(tBuf));
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
%         temp=corrcoef(x,y);
%         corrc(rowIdx,colIdx)=temp(1,2);       
%         ySort=sortBuf(n,:);
%         temp=corrcoef(xSort,ySort);
%         corrcSort(rowIdx,colIdx)=temp(1,2);
%         rowIdx=rowIdx+1;
%       end
%     end
%     colIdx=colIdx+1;
%   end
%   
%   corrc_2=corrc;  
%   corrc_2_avt=mean(corrc,2);
%   corrc_2_av=mean(corrc_2_avt);
%   corrc_2_var=var(corrc_2_avt);
%   corrcSort_2=corrcSort;
%   corrcSort_2_avt=mean(corrcSort,2);
%   corrcSort_2_av=mean(corrcSort_2_avt);
%   corrcSort_2_var=var(corrcSort_2_avt);
%   
%   %% Correlation 5s
%   winSize=5;
%   stepSec=30; 
%   colIdx=1;
%   tBuf=1:round(stepSec*fs):floor(s.data_length_sec*fs-winSize*fs);
%   corrc=zeros(intChNum,numel(tBuf));
%   corrcSort=zeros(intChNum,numel(tBuf));
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
%         temp=corrcoef(x,y);
%         corrc(rowIdx,colIdx)=temp(1,2);       
%         ySort=sortBuf(n,:);
%         temp=corrcoef(xSort,ySort);
%         corrcSort(rowIdx,colIdx)=temp(1,2);
%         rowIdx=rowIdx+1;
%       end
%     end
%     colIdx=colIdx+1;
%   end
%   
%   corrc_5=corrc;  
%   corrc_5_avt=mean(corrc,2);
%   corrc_5_av=mean(corrc_5_avt);
%   corrc_5_var=var(corrc_5_avt);
%   corrcSort_5=corrcSort;
%   corrcSort_5_avt=mean(corrcSort,2);
%   corrcSort_5_av=mean(corrcSort_5_avt);
%   corrcSort_5_var=var(corrcSort_5_avt);
% 
%   %% Correlation 10s
%   winSize=10;
%   stepSec=30; 
%   colIdx=1;
%   tBuf=1:round(stepSec*fs):floor(s.data_length_sec*fs-winSize*fs);
%   corrc=zeros(intChNum,numel(tBuf));
%   corrcSort=zeros(intChNum,numel(tBuf));
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
%         temp=corrcoef(x,y);
%         corrc(rowIdx,colIdx)=temp(1,2);       
%         ySort=sortBuf(n,:);
%         temp=corrcoef(xSort,ySort);
%         corrcSort(rowIdx,colIdx)=temp(1,2);
%         rowIdx=rowIdx+1;
%       end
%     end
%     colIdx=colIdx+1;
%   end
%   
%   corrc_10=corrc;  
%   corrc_10_avt=mean(corrc,2);
%   corrc_10_av=mean(corrc_10_avt);
%   corrc_10_var=var(corrc_10_avt);
%   corrcSort_10=corrcSort;
%   corrcSort_10_avt=mean(corrcSort,2);
%   corrcSort_10_av=mean(corrcSort_10_avt);
%   corrcSort_10_var=var(corrcSort_10_avt);
%   
%   %% Correlation 20s
%   winSize=20;
%   stepSec=30; 
%   colIdx=1;
%   tBuf=1:round(stepSec*fs):floor(s.data_length_sec*fs-winSize*fs);
%   corrc=zeros(intChNum,numel(tBuf));
%   corrcSort=zeros(intChNum,numel(tBuf));
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
%         temp=corrcoef(x,y);
%         corrc(rowIdx,colIdx)=temp(1,2);       
%         ySort=sortBuf(n,:);
%         temp=corrcoef(xSort,ySort);
%         corrcSort(rowIdx,colIdx)=temp(1,2);
%         rowIdx=rowIdx+1;
%       end
%     end
%     colIdx=colIdx+1;
%   end
%   
%   corrc_20=corrc;  
%   corrc_20_avt=mean(corrc,2);
%   corrc_20_av=mean(corrc_20_avt);
%   corrc_20_var=var(corrc_20_avt);
%   corrcSort_20=corrcSort;
%   corrcSort_20_avt=mean(corrcSort,2);
%   corrcSort_20_av=mean(corrcSort_20_avt);
%   corrcSort_20_var=var(corrcSort_20_avt);
%   
%   %% Correlation 30s
%   winSize=30;
%   stepSec=30; 
%   colIdx=1;
%   tBuf=1:round(stepSec*fs):floor(s.data_length_sec*fs-winSize*fs);
%   corrc=zeros(intChNum,numel(tBuf));
%   corrcSort=zeros(intChNum,numel(tBuf));
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
%         temp=corrcoef(x,y);
%         corrc(rowIdx,colIdx)=temp(1,2);       
%         ySort=sortBuf(n,:);
%         temp=corrcoef(xSort,ySort);
%         corrcSort(rowIdx,colIdx)=temp(1,2);
%         rowIdx=rowIdx+1;
%       end
%     end
%     colIdx=colIdx+1;
%   end
%   
%   corrc_30=corrc;  
%   corrc_30_avt=mean(corrc,2);
%   corrc_30_av=mean(corrc_30_avt);
%   corrc_30_var=var(corrc_30_avt);
%   corrcSort_30=corrcSort;
%   corrcSort_30_avt=mean(corrcSort,2);
%   corrcSort_30_av=mean(corrcSort_30_avt);
%   corrcSort_30_var=var(corrcSort_30_avt);
%   
%   %% Correlation 45s
%   winSize=45;
%   stepSec=30; 
%   colIdx=1;
%   tBuf=1:round(stepSec*fs):floor(s.data_length_sec*fs-winSize*fs);
%   corrc=zeros(intChNum,numel(tBuf));
%   corrcSort=zeros(intChNum,numel(tBuf));
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
%         temp=corrcoef(x,y);
%         corrc(rowIdx,colIdx)=temp(1,2);       
%         ySort=sortBuf(n,:);
%         temp=corrcoef(xSort,ySort);
%         corrcSort(rowIdx,colIdx)=temp(1,2);
%         rowIdx=rowIdx+1;
%       end
%     end
%     colIdx=colIdx+1;
%   end
%   
%   corrc_45=corrc;  
%   corrc_45_avt=mean(corrc,2);
%   corrc_45_av=mean(corrc_45_avt);
%   corrc_45_var=var(corrc_45_avt);
%   corrcSort_45=corrcSort;
%   corrcSort_45_avt=mean(corrcSort,2);
%   corrcSort_45_av=mean(corrcSort_45_avt);
%   corrcSort_45_var=var(corrcSort_45_avt);
%   
%   %% Correlation 60s
%   winSize=60;
%   stepSec=30; 
%   colIdx=1;
%   tBuf=1:round(stepSec*fs):floor(s.data_length_sec*fs-winSize*fs);
%   corrc=zeros(intChNum,numel(tBuf));
%   corrcSort=zeros(intChNum,numel(tBuf));
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
%         temp=corrcoef(x,y);
%         corrc(rowIdx,colIdx)=temp(1,2);       
%         ySort=sortBuf(n,:);
%         temp=corrcoef(xSort,ySort);
%         corrcSort(rowIdx,colIdx)=temp(1,2);
%         rowIdx=rowIdx+1;
%       end
%     end
%     colIdx=colIdx+1;
%   end
%   
%   corrc_60=corrc;  
%   corrc_60_avt=mean(corrc,2);
%   corrc_60_av=mean(corrc_60_avt);
%   corrc_60_var=var(corrc_60_avt);
%   corrcSort_60=corrcSort;
%   corrcSort_60_avt=mean(corrcSort,2);
%   corrcSort_60_av=mean(corrcSort_60_avt);
%   corrcSort_60_var=var(corrcSort_60_avt);
%   
%   %% Correlation 75s
%   winSize=75;
%   stepSec=30; 
%   colIdx=1;
%   tBuf=1:round(stepSec*fs):floor(s.data_length_sec*fs-winSize*fs);
%   corrc=zeros(intChNum,numel(tBuf));
%   corrcSort=zeros(intChNum,numel(tBuf));
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
%         temp=corrcoef(x,y);
%         corrc(rowIdx,colIdx)=temp(1,2);       
%         ySort=sortBuf(n,:);
%         temp=corrcoef(xSort,ySort);
%         corrcSort(rowIdx,colIdx)=temp(1,2);
%         rowIdx=rowIdx+1;
%       end
%     end
%     colIdx=colIdx+1;
%   end
%   
%   corrc_75=corrc;  
%   corrc_75_avt=mean(corrc,2);
%   corrc_75_av=mean(corrc_75_avt);
%   corrc_75_var=var(corrc_75_avt);
%   corrcSort_75=corrcSort;
%   corrcSort_75_avt=mean(corrcSort,2);
%   corrcSort_75_av=mean(corrcSort_75_avt);
%   corrcSort_75_var=var(corrcSort_75_avt);
%   
%   %% Correlation 90s
%   winSize=90;
%   stepSec=30; 
%   colIdx=1;
%   tBuf=1:round(stepSec*fs):floor(s.data_length_sec*fs-winSize*fs);
%   corrc=zeros(intChNum,numel(tBuf));
%   corrcSort=zeros(intChNum,numel(tBuf));
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
%         temp=corrcoef(x,y);
%         corrc(rowIdx,colIdx)=temp(1,2);       
%         ySort=sortBuf(n,:);
%         temp=corrcoef(xSort,ySort);
%         corrcSort(rowIdx,colIdx)=temp(1,2);
%         rowIdx=rowIdx+1;
%       end
%     end
%     colIdx=colIdx+1;
%   end
%   
%   corrc_90=corrc;  
%   corrc_90_avt=mean(corrc,2);
%   corrc_90_av=mean(corrc_90_avt);
%   corrc_90_var=var(corrc_90_avt);
%   corrcSort_90=corrcSort;
%   corrcSort_90_avt=mean(corrcSort,2);
%   corrcSort_90_av=mean(corrcSort_90_avt);
%   corrcSort_90_var=var(corrcSort_90_avt);
%  
%   
%   %% Correlation 120s
%   winSize=120;
%   stepSec=30; 
%   colIdx=1;
%   tBuf=1:round(stepSec*fs):floor(s.data_length_sec*fs-winSize*fs);
%   corrc=zeros(intChNum,numel(tBuf));
%   corrcSort=zeros(intChNum,numel(tBuf));
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
%         temp=corrcoef(x,y);
%         corrc(rowIdx,colIdx)=temp(1,2);       
%         ySort=sortBuf(n,:);
%         temp=corrcoef(xSort,ySort);
%         corrcSort(rowIdx,colIdx)=temp(1,2);
%         rowIdx=rowIdx+1;
%       end
%     end
%     colIdx=colIdx+1;
%   end
%   
%   corrc_120=corrc;  
%   corrc_120_avt=mean(corrc,2);
%   corrc_120_av=mean(corrc_120_avt);
%   corrc_120_var=var(corrc_120_avt);
%   corrcSort_120=corrcSort;
%   corrcSort_120_avt=mean(corrcSort,2);
%   corrcSort_120_av=mean(corrcSort_120_avt);
%   corrcSort_120_var=var(corrcSort_120_avt);
% 
%   %% Correlation 150s
%   winSize=150;
%   stepSec=30; 
%   colIdx=1;
%   tBuf=1:round(stepSec*fs):floor(s.data_length_sec*fs-winSize*fs);
%   corrc=zeros(intChNum,numel(tBuf));
%   corrcSort=zeros(intChNum,numel(tBuf));
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
%         temp=corrcoef(x,y);
%         corrc(rowIdx,colIdx)=temp(1,2);       
%         ySort=sortBuf(n,:);
%         temp=corrcoef(xSort,ySort);
%         corrcSort(rowIdx,colIdx)=temp(1,2);
%         rowIdx=rowIdx+1;
%       end
%     end
%     colIdx=colIdx+1;
%   end
%   
%   corrc_150=corrc;  
%   corrc_150_avt=mean(corrc,2);
%   corrc_150_av=mean(corrc_150_avt);
%   corrc_150_var=var(corrc_150_avt);
%   corrcSort_150=corrcSort;
%   corrcSort_150_avt=mean(corrcSort,2);
%   corrcSort_150_av=mean(corrcSort_150_avt);
%   corrcSort_150_var=var(corrcSort_150_avt);
  
%   %% Correlation 180s
%   winSize=180;
%   stepSec=30; 
%   colIdx=1;
%   tBuf=1:round(stepSec*fs):floor(s.data_length_sec*fs-winSize*fs);
%   corrc=zeros(intChNum,numel(tBuf));
%   corrcSort=zeros(intChNum,numel(tBuf));
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
%         temp=corrcoef(x,y);
%         corrc(rowIdx,colIdx)=temp(1,2);       
%         ySort=sortBuf(n,:);
%         temp=corrcoef(xSort,ySort);
%         corrcSort(rowIdx,colIdx)=temp(1,2);
%         rowIdx=rowIdx+1;
%       end
%     end
%     colIdx=colIdx+1;
%   end
%   
%   corrc_180=corrc;  
%   corrc_180_avt=mean(corrc,2);
%   corrc_180_av=mean(corrc_180_avt);
%   corrc_180_var=var(corrc_180_avt);
%   corrcSort_180=corrcSort;
%   corrcSort_180_avt=mean(corrcSort,2);
%   corrcSort_180_av=mean(corrcSort_180_avt);
%   corrcSort_180_var=var(corrcSort_180_avt);
  
  %% Correlation 240s
  winSize=240;
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
  
  corrc_240=corrc;  
  corrc_240_avt=mean(corrc,2);
  corrc_240_av=mean(corrc_240_avt);
  corrc_240_var=var(corrc_240_avt);
  corrcSort_240=corrcSort;
  corrcSort_240_avt=mean(corrcSort,2);
  corrcSort_240_av=mean(corrcSort_240_avt);
  corrcSort_240_var=var(corrcSort_240_avt);
  
  %% Correlation 300s
  winSize=300;
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
  
  corrc_300=corrc;  
  corrc_300_avt=mean(corrc,2);
  corrc_300_av=mean(corrc_300_avt);
  corrc_300_var=var(corrc_300_avt);
  corrcSort_300=corrcSort;
  corrcSort_300_avt=mean(corrcSort,2);
  corrcSort_300_av=mean(corrcSort_300_avt);
  corrcSort_300_var=var(corrcSort_300_avt);
  

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
  
  %% Store features
  features={...
%     mi,mi_avt,mi_av,mi_var,...
%     euDist,euDist_avt,euDist_av,euDist_var,...
%     euDistSort,euDistSort_avt,euDistSort_av,euDistSort_var,...
%     chSqDist,chSqDist_avt,chSqDist_av,chSqDist_var,...
%     chSqDistSort,chSqDistSort_avt',chSqDistSort_av,chSqDistSort_var,...
%     brCuDiss,brCuDiss_avt,brCuDiss_av,brCuDiss_var,...
%     brCuDissSort,brCuDissSort_avt,brCuDissSort_av,brCuDissSort_var,...
%     corrc,corrc_avt,corrc_av,corrc_var,...
%     corrcSort,corrcSort_avt,corrcSort_av,corrcSort_var,...
%     iAmpl,iAmpl_avt,iAmpl_av,iAmpl_var,...
%     iPhase,iPhase_avt,iPhase_av,iPhase_var,...
%     iPhaseDiff,iPhaseDiff_avt,iPhaseDiff_av,iPhaseDiff_var...

%       corrc_05,corrc_05_avt,corrc_05_av,corrc_05_var,...
%       corrcSort_05,corrcSort_05_avt,corrcSort_05_av,corrcSort_05_var,...
%       corrc_1,corrc_1_avt,corrc_1_av,corrc_1_var,...
%       corrcSort_1,corrcSort_1_avt,corrcSort_1_av,corrcSort_1_var,...
%       corrc_2,corrc_2_avt,corrc_2_av,corrc_2_var,...
%       corrcSort_2,corrcSort_2_avt,corrcSort_2_av,corrcSort_2_var,...
%       corrc_5,corrc_5_avt,corrc_5_av,corrc_5_var,...
%       corrcSort_5,corrcSort_5_avt,corrcSort_5_av,corrcSort_5_var,...
%       corrc_10,corrc_10_avt,corrc_10_av,corrc_10_var,...
%       corrcSort_10,corrcSort_10_avt,corrcSort_10_av,corrcSort_10_var,...
%       corrc_20,corrc_20_avt,corrc_20_av,corrc_20_var,...
%       corrcSort_20,corrcSort_20_avt,corrcSort_20_av,corrcSort_20_var,...
%       corrc_30,corrc_30_avt,corrc_30_av,corrc_30_var,...
%       corrcSort_30,corrcSort_30_avt,corrcSort_30_av,corrcSort_30_var,...
%       corrc_45,corrc_45_avt,corrc_45_av,corrc_45_var,...
%       corrcSort_45,corrcSort_45_avt,corrcSort_45_av,corrcSort_45_var,...
%       corrc_60,corrc_60_avt,corrc_60_av,corrc_60_var,...
%       corrcSort_60,corrcSort_60_avt,corrcSort_60_av,corrcSort_60_var,...
%       corrc_75,corrc_75_avt,corrc_75_av,corrc_75_var,...
%       corrcSort_75,corrcSort_75_avt,corrcSort_75_av,corrcSort_75_var,...
%       corrc_90,corrc_90_avt,corrc_90_av,corrc_90_var,...
%       corrcSort_90,corrcSort_90_avt,corrcSort_90_av,corrcSort_90_var,...
%       corrc_120,corrc_120_avt,corrc_120_av,corrc_120_var,...
%       corrcSort_120,corrcSort_120_avt,corrcSort_120_av,corrcSort_120_var,...
%       corrc_150,corrc_150_avt,corrc_150_av,corrc_150_var,...
%       corrcSort_150,corrcSort_150_avt,corrcSort_150_av,corrcSort_150_var,...
%       corrc_180,corrc_180_avt,corrc_180_av,corrc_180_var,...
%       corrcSort_180,corrcSort_180_avt,corrcSort_180_av,corrcSort_180_var...

      corrc_240,corrc_240_avt,corrc_240_av,corrc_240_var,...
      corrcSort_240,corrcSort_240_avt,corrcSort_240_av,corrcSort_240_var,...
      corrc_300,corrc_300_avt,corrc_300_av,corrc_300_var,...
      corrcSort_300,corrcSort_300_avt,corrcSort_300_av,corrcSort_300_var...
    };
  labels={...
%     'mi','mi avt','mi av','mi var',...
%     'euDist','euDist avt','euDist av','euDist var',...
%     'euDistSort','euDistSort avt','euDistSort av','euDistSort var',...
%     'chSqDist','chSqDist avt','chSqDist av','chSqDist var',...
%     'chSqDistSort','chSqDistSort avt','chSqDistSort av','chSqDistSort var',...
%     'brCuDiss','brCuDiss avt','brCuDiss av','brCuDiss var',...
%     'brCuDissSort','brCuDissSort avt','brCuDissSort av','brCuDissSort var',...
%     'corrc','corrc avt','corrc av','corrc var',...
%     'corrcSort','corrcSort avt','corrcSort av','corrcSort var',...
%     'iAmpl','iAmpl avt','iAmpl av','iAmpl var',...
%     'iPhase','iPhase avt','iPhase av','iPhase var',...
%     'iPhaseDiff','iPhaseDiff avt','iPhaseDiff av','iPhaseDiff var'...

%       'corrc_05','corrc_05_avt','corrc_05_av','corrc_05_var',...
%       'corrcSort_05','corrcSort_05_avt','corrcSort_05_av','corrcSort_05_var',...
%       'corrc_1','corrc_1_avt','corrc_1_av','corrc_1_var',...
%       'corrcSort_1','corrcSort_1_avt','corrcSort_1_av','corrcSort_1_var',...
%       'corrc_2','corrc_2_avt','corrc_2_av','corrc_2_var',...
%       'corrcSort_2','corrcSort_2_avt','corrcSort_2_av','corrcSort_2_var',...
%       'corrc_5','corrc_5_avt','corrc_5_av','corrc_5_var',...
%       'corrcSort_5','corrcSort_5_avt','corrcSort_5_av','corrcSort_5_var',...
%       'corrc_10','corrc_10_avt','corrc_10_av','corrc_10_var',...
%       'corrcSort_10','corrcSort_10_avt','corrcSort_10_av','corrcSort_10_var',...
%       'corrc_20','corrc_20_avt','corrc_20_av','corrc_20_var',...
%       'corrcSort_20','corrcSort_20_avt','corrcSort_20_av','corrcSort_20_var',...
%       'corrc_30','corrc_30_avt','corrc_30_av','corrc_30_var',...
%       'corrcSort_30','corrcSort_30_avt','corrcSort_30_av','corrcSort_30_var',...
%       'corrc_45','corrc_45_avt','corrc_45_av','corrc_45_var',...
%       'corrcSort_45','corrcSort_45_avt','corrcSort_45_av','corrcSort_45_var',...
%       'corrc_60','corrc_60_avt','corrc_60_av','corrc_60_var',...
%       'corrcSort_60','corrcSort_60_avt','corrcSort_60_av','corrcSort_60_var',...
%       'corrc_75','corrc_75_avt','corrc_75_av','corrc_75_var',...
%       'corrcSort_75','corrcSort_75_avt','corrcSort_75_av','corrcSort_75_var',...
%       'corrc_90','corrc_90_avt','corrc_90_av','corrc_90_var',...
%       'corrcSort_90','corrcSort_90_avt','corrcSort_90_av','corrcSort_90_var',...
%       'corrc_120','corrc_120_avt','corrc_120_av','corrc_120_var',...
%       'corrcSort_120','corrcSort_120_avt','corrcSort_120_av','corrcSort_120_var',...
%       'corrc_150','corrc_150_avt','corrc_150_av','corrc_150_var',...
%       'corrcSort_150','corrcSort_150_avt','corrcSort_150_av','corrcSort_150_var',...
%       'corrc_180','corrc_180_avt','corrc_180_av','corrc_180_var',...
%       'corrcSort_180','corrcSort_180_avt','corrcSort_180_av','corrcSort_180_var'...
      
      'corrc_240','corrc_240_avt','corrc_240_av','corrc_240_var',...
      'corrcSort_240','corrcSort_240_avt','corrcSort_240_av','corrcSort_240_var',...
      'corrc_300','corrc_300_avt','corrc_300_av','corrc_300_var',...
      'corrcSort_300','corrcSort_300_avt','corrcSort_300_av','corrcSort_300_var'...
    };
end