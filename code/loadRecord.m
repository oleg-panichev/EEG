% Load record from file
%
function [s]=loadRecord(path,fileName,subjectInfoFileName,...
    loadRecordFl,loadPatientInfoFl,loadSeizuresAnnotationFl)
  fullFileName=strcat(path,fileName);
  fullFileName=[fullFileName{1}];
  dataType=lower(fullFileName(end-2:end));
  if (strcmp(dataType,'edf'))
    s=eegData();
    if (loadRecordFl>0) 
      loadFromEdf(s,fullFileName);
    end
    if (loadPatientInfoFl>0)  
      loadPatientInfo(s,path,fileName,subjectInfoFileName);
    end
    if (loadSeizuresAnnotationFl>0)
      loadSeizuresAnnotation(s,fullFileName);
    end
    disp('Data loading is done.');
  elseif (strcmp(dataType,'mat'))
    
  else
    error([dataType,' - data type is not supported!']);
  end
end