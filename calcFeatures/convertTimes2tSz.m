function [tBeforeSz,tAfterSz]=convertTimes2tSz(fTimes,szTimes,dataLen,fs)
  tBeforeSz=cell(size(fTimes));
  tAfterSz=cell(size(fTimes));
  szTimes=[0;szTimes*fs;dataLen+1];
  for i=1:numel(fTimes)
    tBeforeSz{i}=fTimes{i};
    tAfterSz{i}=fTimes{i};
    idx=1;
    szIdxPrev=0;
    for k=2:numel(szTimes)
      if (k>2)
        szIdxPrev=szTimes(k-1);
      end
      tBeforeSz{i}(idx:end)=abs(tBeforeSz{i}(idx:end)-szTimes(k)+szIdxPrev);          

      [~,idx]=min(tBeforeSz{i}(idx:end));
      idx=idx+szIdxPrev+1;
      if (k<numel(szTimes))
        tAfterSz{i}(idx-1:end)=tAfterSz{i}(idx-1:end)-szTimes(k)+szIdxPrev;     
      end
    end
    tBeforeSz{i}=tBeforeSz{i}./fs;
    tAfterSz{i}=tAfterSz{i}./fs;
  end
end