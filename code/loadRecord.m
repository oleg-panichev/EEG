% Load record from file
%
function [s]=loadRecord(path,fileName,subjectInfoFileName)
  fullFileName=strcat(path,fileName);
  fullFileName=[fullFileName{1}];
  dataType=lower(fullFileName(end-2:end));
  if (strcmp(dataType,'edf'))
    [s]=loadFromEdf(fullFileName);
      
    loadPatientInfo(s,path,fileName,subjectInfoFileName);
    loadSeizuresAnnotation(s,fullFileName);
    disp('Data loading is done.');
  elseif (strcmp(dataType,'mat'))
    
  else
    error([dataType,' - data type is not supported!']);
  end
end