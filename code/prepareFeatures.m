function [features,labels]=prepareFeatures(s)
  run('properties.m');
  fs=s.sampling_frequency;
  [mi,miSur,miLabels]=muinfoMultiChannel(s.data,round(s.data_length_sec/2*fs), ...
  	round(miWindowSize*fs),s.channels);
  features=mi;
  labels=miLabels;
end