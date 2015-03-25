function [corrcEig,corrcEig_mean,corrcEig_std,corrcEig_fLabels,...
  corrcEig_mean_fLabels,corrcEig_std_fLabels,tBuf]=...
  f_corrEigBetweenChannels(data,fs,winSize,stepSize,chLabel)

  % Parameters of data
  dataSize=size(data);
  dataLen=max(dataSize);
  chNum=min(dataSize);
  if (dataSize(1)>dataSize(2))
    data=data';
  end 
  
  tBuf=ceil(1+winSize/2):stepSize:floor(dataLen-winSize/2);
  corrcEig=zeros(numel(tBuf),chNum);
  corrcEig_fLabels=cell(chNum,1);
  corrc=zeros(chNum,chNum);
  isNotNanIdx=ones(numel(tBuf),1);
  
  % Calculate correlations
  rowIdx=1;   
  for i=tBuf  
    for m=1:chNum
      x=data(m,i-round(winSize/2):i+round(winSize/2));
      for n=1:chNum        
        y=data(n,i-round(winSize/2):i+round(winSize/2));
        temp=corrcoef(x,y);
        corrc(m,n)=temp(1,2);     
      end
      if (i==tBuf(1))
        corrcEig_fLabels{m}=['corrcEig w',num2str(winSize/fs),' s',...
          num2str(stepSize/fs),' ',chLabel{m}];
      end
    end
    if (sum(sum(isnan(corrc)))==0)
      corrcEig(rowIdx,:)=eig(corrc);  
    else
      isNotNanIdx(rowIdx)=0;
    end
    rowIdx=rowIdx+1;
  end
  
  corrcEig=corrcEig(logical(isNotNanIdx),:);
  tBuf=tBuf(logical(isNotNanIdx));
  
  corrcEig_mean=mean(corrcEig,2);
  corrcEig_mean_fLabels=['corrcEig mean w',num2str(winSize/fs),' s',num2str(stepSize/fs)];
  corrcEig_std=std(corrcEig,[],2);
  corrcEig_std_fLabels=['corrcEig std w',num2str(winSize/fs),' s',num2str(stepSize/fs)];
end