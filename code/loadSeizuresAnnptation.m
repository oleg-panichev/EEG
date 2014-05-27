function ann=loadSeizuresAnnptation(s,fileName)  
  file=fopen([fileName,'.seizures']);
  if (file>0)
    ann=zeros(1,round(s.eegLen));
    data=uint32(fread(file));
    data=data(38:end-1);
    numberOfSeizures=numel(data)/16;
    disp(['Number of seizures in data: ',num2str(numberOfSeizures)]);
    shiftBytes=0;
    shift=0;
    for i=1:numberOfSeizures
      shift=shift+bitshift(data(shiftBytes+2),8)+data(shiftBytes+5);
      seizureStart=shift+1;
      disp(['<> Seizure ',num2str(i),':']);
      disp(['Starts: ',num2str(shift),' s;']);
      shift=shift+bitshift(data(shiftBytes+12),8)+data(shiftBytes+13);
      seizureEnd=shift+1;
      disp(['Ends: ',num2str(shift),' s;']);
      ann(seizureStart*s.eegFs:seizureEnd*s.eegFs)=1;
      shiftBytes=shiftBytes+16;
    end
    s.ann=ann;
    disp('.seizures file has been successfully loaded.');
  end
end