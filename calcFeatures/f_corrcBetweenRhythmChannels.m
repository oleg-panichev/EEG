function [corrc_a,corrc_a_mean,corrc_a_std,corrc_a_fLabels,corrc_a_mean_fLabels,...
  corrc_a_std_fLabels,corrc_b,corrc_b_mean,corrc_b_std,corrc_b_fLabels,corrc_b_mean_fLabels,...
  corrc_b_std_fLabels,corrc_d,corrc_d_mean,corrc_d_std,corrc_d_fLabels,corrc_d_mean_fLabels,...
  corrc_d_std_fLabels,corrc_t,corrc_t_mean,corrc_t_std,corrc_t_fLabels,corrc_t_mean_fLabels,...
  corrc_t_std_fLabels,tBuf]=f_corrcBetweenRhythmChannels(data,fs,...
  winSize,stepSize,chLabel)

  % Parameters of data
  dataSize=size(data);
  dataLen=max(dataSize);
  chNum=min(dataSize);
  if (dataSize(1)>dataSize(2))
    data=data';
  end
  intChNum=sum(1:(chNum-1)); 
  
  tBuf=ceil(1+winSize/2):stepSize:floor(dataLen-winSize/2);
  % Buffers to store results
  corrc_a=zeros(numel(tBuf),intChNum); % Alpha (8-13 Hz)
  corrc_a_fLabels=cell(intChNum,1);
  corrc_b=zeros(numel(tBuf),intChNum); % Beta (14-40 Hz)
  corrc_b_fLabels=cell(intChNum,1);
  corrc_d=zeros(numel(tBuf),intChNum); % Delta (0.5-3 Hz)
  corrc_d_fLabels=cell(intChNum,1);
  corrc_t=zeros(numel(tBuf),intChNum); % Theta (4-7 Hz)
  corrc_t_fLabels=cell(intChNum,1);
  
  % Filters
  % Buffers to store filtered signals
  data_a=zeros(size(data));
  data_b=zeros(size(data));
  data_d=zeros(size(data));
  data_t=zeros(size(data));
  
  % Alpha
  N=round(fs*2); % Order
  Fc1=8; % First Cutoff Frequency
  Fc2=13; % Second Cutoff Frequency
  flag='scale';  % Sampling Flag
  win=hamming(N+1);
  num_a=fir1(N, [Fc1 Fc2]/(fs/2), 'bandpass', win, flag);
  for chIdx=1:size(data,1)
    data_a(chIdx,:)=filtfilt(num_a,1,data(chIdx,:));
  end
  
  % Beta
  N=round(fs*2); % Order
  Fc1=0.5; % First Cutoff Frequency
  Fc2=3; % Second Cutoff Frequency
  flag='scale';  % Sampling Flag
  win=hamming(N+1);
  num_d=fir1(N, [Fc1 Fc2]/(fs/2), 'bandpass', win, flag);
  for chIdx=1:size(data,1)
    data_d(chIdx,:)=filtfilt(num_d,1,data(chIdx,:));
  end
  
  % Delta
  N=round(fs*2); % Order
  Fc1=0.5; % First Cutoff Frequency
  Fc2=3; % Second Cutoff Frequency
  flag='scale';  % Sampling Flag
  win=hamming(N+1);
  num_d=fir1(N, [Fc1 Fc2]/(fs/2), 'bandpass', win, flag);
  for chIdx=1:size(data,1)
    data_d(chIdx,:)=filtfilt(num_d,1,data(chIdx,:));
  end
  
  % Theta
  N=round(fs*2); % Order
  Fc1=4; % First Cutoff Frequency
  Fc2=7; % Second Cutoff Frequency
  flag='scale';  % Sampling Flag
  win=hamming(N+1);
  num_t=fir1(N, [Fc1 Fc2]/(fs/2), 'bandpass', win, flag);
  for chIdx=1:size(data,1)
    data_t(chIdx,:)=filtfilt(num_t,1,data(chIdx,:));
  end
  
  % Calculate correlations
  rowIdx=1;   
  for i=tBuf  
%     disp([num2str(rowIdx),'/',num2str(numel(tBuf))]);
    % Alpha
    colIdx=1;
    for m=1:chNum
      x=data_a(m,i-round(winSize/2):i+round(winSize/2));
      for n=(m+1):chNum    
%         disp([num2str(m),'-',num2str(n)]);
        y=data_a(n,i-round(winSize/2):i+round(winSize/2));
        temp=corrcoef(x,y);
        corrc_a(rowIdx,colIdx)=temp(1,2);     
        if (i==tBuf(1))
          corrc_a_fLabels{colIdx}=['corrc A w',num2str(winSize/fs),' s',...
            num2str(stepSize/fs),' ',chLabel{m},' ',chLabel{n}];
        end
        colIdx=colIdx+1; 
      end
    end
    
    % Beta
    colIdx=1;
    for m=1:chNum
      x=data_b(m,i-round(winSize/2):i+round(winSize/2));
      for n=(m+1):chNum    
%         disp([num2str(m),'-',num2str(n)]);
        y=data_b(n,i-round(winSize/2):i+round(winSize/2));
        temp=corrcoef(x,y);
        corrc_b(rowIdx,colIdx)=temp(1,2);     
        if (i==tBuf(1))
          corrc_b_fLabels{colIdx}=['corrc B w',num2str(winSize/fs),' s',...
            num2str(stepSize/fs),' ',chLabel{m},' ',chLabel{n}];
        end
        colIdx=colIdx+1; 
      end
    end
    
    % Delta
    colIdx=1;
    for m=1:chNum
      x=data_d(m,i-round(winSize/2):i+round(winSize/2));
      for n=(m+1):chNum    
%         disp([num2str(m),'-',num2str(n)]);
        y=data_d(n,i-round(winSize/2):i+round(winSize/2));
        temp=corrcoef(x,y);
        corrc_d(rowIdx,colIdx)=temp(1,2);     
        if (i==tBuf(1))
          corrc_d_fLabels{colIdx}=['corrc D w',num2str(winSize/fs),' s',...
            num2str(stepSize/fs),' ',chLabel{m},' ',chLabel{n}];
        end
        colIdx=colIdx+1; 
      end
    end
    
    % Theta
    colIdx=1;
    for m=1:chNum
      x=data_t(m,i-round(winSize/2):i+round(winSize/2));
      for n=(m+1):chNum    
%         disp([num2str(m),'-',num2str(n)]);
        y=data_t(n,i-round(winSize/2):i+round(winSize/2));
        temp=corrcoef(x,y);
        corrc_t(rowIdx,colIdx)=temp(1,2);     
        if (i==tBuf(1))
          corrc_t_fLabels{colIdx}=['corrc T w',num2str(winSize/fs),' s',...
            num2str(stepSize/fs),' ',chLabel{m},' ',chLabel{n}];
        end
        colIdx=colIdx+1; 
      end
    end
    
    rowIdx=rowIdx+1;  
  end
  
  corrc_a_mean=mean(corrc_a,2);
  corrc_a_mean_fLabels=['corrc A mean w',num2str(winSize/fs),' s',num2str(stepSize/fs)];
  corrc_a_std=std(corrc_a,[],2);
  corrc_a_std_fLabels=['corrc A std w',num2str(winSize/fs),' s',num2str(stepSize/fs)];
  
  corrc_b_mean=mean(corrc_b,2);
  corrc_b_mean_fLabels=['corrc B mean w',num2str(winSize/fs),' s',num2str(stepSize/fs)];
  corrc_b_std=std(corrc_b,[],2);
  corrc_b_std_fLabels=['corrc B std w',num2str(winSize/fs),' s',num2str(stepSize/fs)];
  
  corrc_d_mean=mean(corrc_d,2);
  corrc_d_mean_fLabels=['corrc D mean w',num2str(winSize/fs),' s',num2str(stepSize/fs)];
  corrc_d_std=std(corrc_d,[],2);
  corrc_d_std_fLabels=['corrc D std w',num2str(winSize/fs),' s',num2str(stepSize/fs)];
  
  corrc_t_mean=mean(corrc_t,2);
  corrc_t_mean_fLabels=['corrc T mean w',num2str(winSize/fs),' s',num2str(stepSize/fs)];
  corrc_t_std=std(corrc_t,[],2);
  corrc_t_std_fLabels=['corrc T std w',num2str(winSize/fs),' s',num2str(stepSize/fs)];
end