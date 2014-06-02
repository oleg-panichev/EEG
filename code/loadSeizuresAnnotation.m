function ann=loadSeizuresAnnotation(s,fileName)  
  file=fopen([fileName,'.seizures']);
  ann=zeros(1,round(s.eegLen));
  if (file>0)    
    data=uint32(fread(file));
    data=data(38:end-1);
    numberOfSeizures=numel(data)/16;
    disp(['Number of seizures in data: ',num2str(numberOfSeizures)]);
    shiftBytes=0;
    shift=0;
    for i=1:numberOfSeizures
      shift=shift+bitshift(data(shiftBytes+2),8)+data(shiftBytes+5);
      seizureStart=shift+1;
      shift=shift+bitshift(data(shiftBytes+12),8)+data(shiftBytes+13);
      seizureEnd=shift+1;
      disp(['<> Seizure ',num2str(i),': ',num2str(shift),' - ',num2str(shift),' s;']);
      ann(seizureStart*s.eegFs:seizureEnd*s.eegFs)=1;
      shiftBytes=shiftBytes+16;
    end   
  end
  s.annSeizure=ann;
end