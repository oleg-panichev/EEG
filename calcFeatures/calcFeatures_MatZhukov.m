function calcFeatures_MatZhukov(propertiesFunction,fname,dir2save)

  propertiesFunction();
  
  % Load data from file
  sdata=load(fname);
  
  % Store needed values in struct
  dataSize=size(sdata.data);
  if (dataSize(1)>dataSize(2))
    sdata.data=sdata.data';
  end
  [eegData,labels]=selectDataChannels(sdata.data,sdata.labels);

  s=struct('data',eegData,'channels',{labels},...
    'sampling_frequency',sdata.Fs,'data_length_sec',(sdata.N/sdata.Fs),...
    'sequence',0,'szTimes',sdata.seizureStart);
  
  % Calculate all features for signal
  [features,labels,fTimes,fLabels]=prepareFeatures(propertiesFunction,s);
  
  % Calculate tBeforeSz and tAfterSz
  [tBeforeSz,tAfterSz]=convertTimes2tSz(fTimes,s.szTimes,...
    length(eegData),s.sampling_frequency);
  
  % Save all features
  saveFeatures(dir2save,features,labels,tBeforeSz,tAfterSz,fLabels);
end