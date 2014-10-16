% Function for MI calculation
%
function [miBuf,miSurBuf,miLabels]=muinfoMultiChannel(signal,sStartIdx, ...
  miWindowSize,channelNames)   
%       disp(['Start time: ',num2str(sStartTime),'s, Duration: ',num2str(sDuration),'s']);

  % Calculate number of interconnected channels 
  chNum=min(size(signal));
  miChNum=sum(1:(chNum-1));

  % Calculate MI for all channels
  ddisp(['Calculating MI at ',num2str(sStartIdx),' sample'],0);
  miBuf=zeros(miChNum,1);
  miSurBuf=zeros(miChNum,1);
  miLabels=cell(miChNum,1);
  chIdx=1;
  
  for k=1:chNum
%     disp(['Channel #',num2str(k),'...']);
    for j=(k+1):chNum
%       disp([num2str(k),'-',num2str(j)]);    
      x=signal(k,sStartIdx:sStartIdx+miWindowSize)-mean(signal(k,sStartIdx:sStartIdx+miWindowSize));
      y=signal(j,sStartIdx:sStartIdx+miWindowSize)-mean(signal(j,sStartIdx:sStartIdx+miWindowSize));
      miBuf(chIdx)=muinfo(x,y);  

      % Permutate second signal for surrogate obtaining
      permData=y;
      permData=permData(randperm(length(permData)));
      miSurBuf(chIdx)=muinfo(signal(k,sStartIdx:sStartIdx+miWindowSize),permData);   

      miLabels{chIdx}=([channelNames{k},'-',channelNames{j}]);
      chIdx=chIdx+1;
    end
  end
end