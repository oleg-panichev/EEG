% Function for MI calculation
%
function [miBuf,miSurBuf,miLabels]=muinfoMultiChannel(signal,sStartIdx, ...
  miWindowSize,channelNames,surStatus)   
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
  
  signalMod=zeros(chNum,numel(sStartIdx:sStartIdx+miWindowSize));
  for k=1:chNum
    signalMod(k,:)=signal(k,sStartIdx:sStartIdx+miWindowSize)-mean(signal(k,sStartIdx:sStartIdx+miWindowSize));
  end
  
  for k=1:chNum
%     disp(['Channel #',num2str(k),'...']);
    for j=(k+1):chNum
%       disp([num2str(k),'-',num2str(j)]);          
      miBuf(chIdx)=muinfo(signalMod(k,:),signalMod(j,:));  

      if (surStatus>0)
        % Permutate second signal for surrogate obtaining
        permData=signalMod(j,:);
        permData=permData(randperm(length(permData)));
        miSurBuf(chIdx)=muinfo(signal(k,sStartIdx:sStartIdx+miWindowSize),permData);   
      end

      miLabels{chIdx}=([num2str(k),'-',num2str(j)]);
      chIdx=chIdx+1;
    end
  end
end