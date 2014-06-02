function estInfTransfer(s)
  winSize=2*s.eegFs;
  miFs=1;
  
  while i>0
    
  end
  miBuf=zeros(factorial(s.chNum-1),s.records);
%   label=
  chIdx=1;
  idx=1;
  
  for k=1:s.chNum
    for j=k+1:chNum
      for i=winSize+1:miFs*s.eegFs:s.eegLen-winSize
%         label=
        miBuf(chIdx,idx)=calculateMutualInformation(s.record(k,i-winSize:i+winSize),s.record(j,i-winSize:i+winSize),2);   
      end
      chIdx=chIdx+1;
    end
  end
end