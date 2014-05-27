% Load record from file
%
function [s]=loadRecord(fileName)
  dataType=lower(fileName(end-2:end));
  if (strcmp(dataType,'edf'))
    [s]=loadFromEdf(fileName);
    
    loadSeizuresAnnptation(s,fileName);
    disp('Data loading is done.');
  elseif (strcmp(dataType,'mat'))
    
  else
    error([dataType,' - data type is not supported!']);
  end
end