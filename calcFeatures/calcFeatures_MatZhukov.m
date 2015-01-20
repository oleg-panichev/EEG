function calcFeatures_MatZhukov(propertiesFunction,fname,dir2save)
  propertiesFunction();
  
  % Load data from file
  sdata=load(fname);
  
  % Store needed values in struct
  s=struct('data',sdata.data,'channels',sdata.labels,...
    'sampling_frequency',sdata.Fs,'data_length_sec',sdata.N/sdata.Fs,...
    'sequence',0);
  
  % prepareFeatures();
  
  % saveFeatures();
end