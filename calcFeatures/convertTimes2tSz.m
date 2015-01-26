function [tBeforeSz,tAfterSz]=convertTimes2tSz(fTimes,szTimes,dataLen,fs)
  tBeforeSz=cell(size(fTimes));
  tAfterSz=cell(size(fTimes));
  szTimes=[0;szTimes*fs;dataLen+1];
  for i=1:numel(fTimes)
    tBeforeSz{i}=fTimes{i};
    tAfterSz{i}=fTimes{i};
    idx=1;
    
%     figure
%     subplot(numel(szTimes),1,1);
%     plot(tBeforeSz{i});
%     grid on;
    for k=2:numel(szTimes)
      szIdxPrev=szTimes(k-1);
      idxPrev=idx;
      tBeforeSz{i}(idx:end)=abs(tBeforeSz{i}(idx:end)-szTimes(k)+szIdxPrev);  
      
%       subplot(numel(szTimes),1,k);
%       plot(tBeforeSz{i});
%       grid on;
      
      [~,idx]=min(tBeforeSz{i}(idx:end));
      idx=idx+idxPrev;
      if (k<numel(szTimes))
        tAfterSz{i}(idx:end)=tAfterSz{i}(idx:end)-szTimes(k)+szIdxPrev;     
      end
    end
    tBeforeSz{i}=tBeforeSz{i}./fs;
    tAfterSz{i}=tAfterSz{i}./fs;
    
%     figure
%     subplot(211);
%     plot(fTimes{i}(:)./fs,tBeforeSz{i}(:)); hold on;
%     y1=get(gca,'ylim');
%     for j=1:numel(szTimes)
%       line([szTimes(j)/fs szTimes(j)/fs],y1,'Color',[1 0 0]);
%     end
%     title('tBeforeSz');
%     grid on;
%     subplot(212);
%     plot(fTimes{i}(:)./fs,tAfterSz{i}(:)); hold on;
%     y1=get(gca,'ylim');
%     for j=1:numel(szTimes)
%       line([szTimes(j)/fs szTimes(j)/fs],y1,'Color',[1 0 0]);
%     end
%     title('tAfterSz');
%     grid on;
%     pause;
  end
end