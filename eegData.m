% Inner EEG data class
%
classdef eegData < handle 
  properties (SetAccess='public') 
    ver;
    patientID;                       
    recordID;                                        
    startdate;
    starttime;
    bytes;
    records;
    duration;
    ns;
    label;
    transducer;
    units;
    physicalMin;
    physicalMax;
    digitalMin;
    digitalMax;
    prefilter;
    samples;
    record;
    chNum;
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