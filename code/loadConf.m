function [data]=loadConf(fileConf)
  % Load CSV with data files list
  file=fopen(fileConf);
  if (file < 0)
    error('loadConf.m - error: can not open configuration file;');
  end
  
  % Parse parameters from input file
  data=textscan(file,'%d%s%s%s%s%s%d%d',...
    'delimiter',';','headerLines',1);
  fclose(file);
end