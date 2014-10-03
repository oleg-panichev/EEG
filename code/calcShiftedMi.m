function [mi,miVar,miSur,miVarSur,miLabels,s,idxPrev]=calcShiftedMi(ia,s,p,startTime,sDuration, ...
  miWindowSize,idxPrev,wpath,pdir,subjectInfoFileName)
  % Calculate number of interconnected channels 
  miChNum=sum(1:(p.minChNum-1));
  
  mi=zeros(miChNum,1);
  miSur=zeros(miChNum,1);
  miVar=[];
  miVarSur=[];
  miLabels=[];
  n=1;
  while (p.signalsAll{n,2}<startTime && n<size(p.signalsAll,1))
    n=n+1;
  end
  sigNum=size(p.signalsAll,1);
  if (n<=sigNum)
    idx=n-1;
  else
    idx=sigNum;
  end 
  if (idx~=idxPrev)
    disp(['Processing ',pdir,'/',p.signalsAll{idx,1}]);
    s=loadRecord(wpath,[pdir,'/',p.signalsAll{idx,1}],subjectInfoFileName,...
      1,1,1);
  end
  startTime=startTime-p.signalsAll{idx,2};
  if (startTime+sDuration-s.records<11)
    if (startTime+sDuration>=s.records)
      startTime=s.records-sDuration-miWindowSize-1;
    end
    sigIdxBuf=p.signalsAll{idx,5}(1:p.minChNum);
    [mi,~,miSur,~,miLabels]=ia.windowedShortTimeMi(s,sigIdxBuf,startTime,sDuration,miWindowSize);
  end
  idxPrev=idx;
end