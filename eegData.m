% Inner EEG data class (similar to EDF)
%
classdef eegData < handle 
  properties (SetAccess='public') 
    ver;
    patientID;   
    patientName; % Patient's name
    patientGender; % Gender
    patientAge; % Age in years
    recordID;                                        
    startdate;
    starttime;
    bytes;
    records; % duration of stored signals, s
    duration; % 
    ns;
    label; % Channel labels
    transducer;
    units; % Measurement units
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
    annSeizure; % seizure annotation, 0 - no seizure, 1 - seizure
  end
  
  methods  (Access='public')
    function obj=eegData()
    end
    
    function [sig,fs]=getSingleChannel(obj,chIdx)
      sig=obj.record(chIdx,:);
      fs=obj.samples(chIdx);
    end
    
    function [dataStruct]=exportToStruct(obj)
      dataStruct=struct('ver',obj.ver,'patientID',obj.patientID,...
        'patientName',obj.patientName,'patientGender',obj.patientGender,...
        'patientAge',obj.patientAge,'recordID',obj.recordID,...
        'startdate',obj.startdate,'starttime',obj.starttime,...
        'bytes',obj.bytes,'records',obj.records,...
        'duration',obj.duration,'ns',obj.ns,...
        'label',obj.label,'transducer',obj.transducer,'units',obj.units,...
        'physicalMin',obj.physicalMin,'physicalMax',obj.physicalMax,...
        'digitalMin',obj.digitalMin,'digitalMax',obj.digitalMax,...
        'prefilter',obj.prefilter,'samples',obj.samples,'record',obj.record,...
        'chNum',obj.chNum,'eegLen',obj.eegLen,'eegFs',obj.eegFs,...
        'annSeizure',obj.annSeizure);
    end
  end
end