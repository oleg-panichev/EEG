function [corrc,corrc_mean,corrc_std]=f_corrBetweenChannels(data,fs,...
  winSize,stepSize)

  % Parameters of data
  dataSize=size(data);
  dataLen=max(dataSize);
  chNum=min(dataSize);
  if (dataSize(1)>dataSize(2))
    data=data';
  end
  intChNum=sum(1:(chNum-1)); 
  
  tBuf=ceil(1+winSize/2*fs):stepSize:floor(dataLen-winSize/2*fs);
  corrc=zeros(numel(tBuf),intChNum);
  
  % Calculate correlations
  rowIdx=1;   
  for i=tBuf      
    for m=1:chNum
      x=data(m,i:i+round(winSize*fs));
      for n=(m+1):chNum        
        y=data(n,i:i+round(winSize*fs));
        temp=corrcoef(x,y);
        corrc(rowIdx,colIdx)=temp(1,2); 
        colIdx=colIdx+1;       
      end
    end
    rowIdx=rowIdx+1;
    colIdx=1;
  end
  
  corrc_mean=mean(corrc,2);
  corrc_std=std(corrc,[],2);
end