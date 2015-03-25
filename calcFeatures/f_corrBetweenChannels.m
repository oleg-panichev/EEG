function [corrc,corrc_mean,corrc_std,corrc_fLabels,corrc_mean_fLabels,...
  corrc_std_fLabels,tBuf]=f_corrBetweenChannels(data,fs,...
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
  corrc=zeros(numel(tBuf),intChNum);
  corrc_fLabels=cell(intChNum,1);
  
  % Calculate correlations
  rowIdx=1;   
  for i=tBuf  
%     disp([num2str(rowIdx),'/',num2str(numel(tBuf))]);
    colIdx=1;
    for m=1:chNum
      x=data(m,i-round(winSize/2):i+round(winSize/2));
      for n=(m+1):chNum    
%         disp([num2str(m),'-',num2str(n)]);
        y=data(n,i-round(winSize/2):i+round(winSize/2));
        temp=corrcoef(x,y);
        corrc(rowIdx,colIdx)=temp(1,2);     
        if (i==tBuf(1))
          corrc_fLabels{colIdx}=['corrc w',num2str(winSize/fs),' s',...
            num2str(stepSize/fs),' ',chLabel{m},' ',chLabel{n}];
        end
        colIdx=colIdx+1; 
      end
    end
    rowIdx=rowIdx+1;  
%     break;
  end
  
  corrc_mean=mean(corrc,2);
  corrc_mean_fLabels=['corrc mean w',num2str(winSize/fs),' s',num2str(stepSize/fs)];
  corrc_std=std(corrc,[],2);
  corrc_std_fLabels=['corrc std w',num2str(winSize/fs),' s',num2str(stepSize/fs)];
end