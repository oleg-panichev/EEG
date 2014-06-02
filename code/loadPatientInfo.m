function loadPatientInfo(s,path,fileName,subjectInfoFileName)
  file=fopen([path,subjectInfoFileName]);
  if (file>0)
    formatSpec='%s%s%f';
    data=textscan(file,formatSpec,'delimiter','\t',...
      'headerLines',2,'EndOfLine','\r\n');
    idx=0;
    for i=1:length(data{1})
      if (strcmp(data{1}(i),fileName{1}(1:5)))
        idx=i;
        break;
      end
    end
    if (idx>0)
      s.patientName=data{1}(idx);
      s.patientName=[s.patientName{1}];
      s.patientGender=data{2}(idx);
      s.patientGender=[s.patientGender{1}];
      s.patientAge=data{3}(idx);
    end
    disp(['Patient info: Name - ',s.patientName,', gender - ', ...
      s.patientGender,', age - ',num2str(s.patientAge),'.']);
  end
  fclose(file);
end