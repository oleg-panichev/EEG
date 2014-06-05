function estInfTransfer(s)
  skipSeconds=2500;
  winSize=2*s.eegFs;
  miFs=1;
  
  i=s.chNum-1;
  miChNum=0;
  while i>0
    miChNum=miChNum+i;
    i=i-1;
  end
  miBuf=zeros(miChNum,s.records);
%   label=
  chIdx=1;
  idx=1;
  
  disp('Calculating mutual information...');
  for k=1:s.chNum
    disp(['Channel #',num2str(k)]);
    for j=k+1:s.chNum
      for i=skipSeconds*s.eegFs+winSize+1:miFs*s.eegFs:s.eegLen-winSize
%         label=
        miBuf(chIdx,idx)=calculateMutualInformation(s.record(k,i-winSize:i+winSize),s.record(j,i-winSize:i+winSize));   
      end
      chIdx=chIdx+1;
    end
  end
end