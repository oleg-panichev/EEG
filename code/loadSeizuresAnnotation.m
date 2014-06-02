function ann=loadSeizuresAnnotation(s,fileName)  
  file=fopen([fileName,'.seizures']);
  ann=zeros(1,round(s.eegLen));
  seizureTimings=[];
  if (file>0)    
    data=uint32(fread(file));
    data=data(38:end-1);
    numberOfSeizures=numel(data)/16;
    disp(['Number of seizures in data: ',num2str(numberOfSeizures)]);
    seizureTimings=zeros(numberOfSeizures,2);
    shiftBytes=0;
    shift=0;
    for i=1:numberOfSeizures
      shift=shift+bitshift(data(shiftBytes+2),8)+data(shiftBytes+5);
      seizureStart=shift;
      shift=shift+bitshift(data(shiftBytes+10),8)+data(shiftBytes+13);
      seizureEnd=shift;
      disp(['<> Seizure ',num2str(i),': ',num2str(seizureStart),' - ',...
        num2str(seizureEnd),' s;']);
      if (~isempty(s.eegFs))
        ann(seizureStart*s.eegFs:seizureEnd*s.eegFs)=1;
      end
      seizureTimings(i,1)=seizureStart;
      seizureTimings(i,2)=seizureEnd;
      shiftBytes=shiftBytes+16;
    end   
  end
  s.annSeizure=ann;
  s.seizureTimings=seizureTimings;
end