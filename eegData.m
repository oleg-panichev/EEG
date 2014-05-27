% Inner EEG data class (similar to EDF)
%
classdef eegData < handle 
  properties (SetAccess='public') 
    ver;
    patientID;                       
    recordID;                                        
    startdate;
    starttime;
    bytes;
    records; % duration of stored signals, s
    duration; % 
    ns;
    label;
    transducer;
    units;
    physicalMin;
    physicalMax;
    digitalMin;
    digitalMax;
    prefilter;
    samples; % sample rate for every channel, Hz
    record; % signals (channel,sample)
    chNum; % number of channels
    eegLen; % number of samples in EEG data
    eegFs; % sample rate of eeg data
    ann; % seizure annotation
  end
  
  methods  (Access='public')
    function obj=eegData()
    end
    
    function [sig,fs]=getSingleChannel(obj,chIdx)
      sig=obj.record(chIdx,:);
      fs=obj.samples(chIdx);
    end
  end
end