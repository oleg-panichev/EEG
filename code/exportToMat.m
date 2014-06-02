function exportToMat(fileName,s)
%   clear dataStruct;
%   dataStruct=s.exportToStruct;
%   size(dataStruct.record)
%   save(fileName,'dataStruct');
  ver=s.ver;
	patientID=s.patientID;   
  patientName=s.patientName; % Patient's name
  patientGender=s.patientGender; % Gender
  patientAge=s.patientAge; % Age in years
  recordID=s.recordID;                                        
  startdate=s.startdate;
  starttime=s.starttime;
  bytes=s.bytes;
  records=s.records; % duration of stored signals, s
  duration=s.duration; % 
  ns=s.ns;
  label=s.label; % Channel labels
  transducer=s.transducer;
  units=s.units; % Measurement units
  physicalMin=s.physicalMin;
  physicalMax=s.physicalMax;
  digitalMin=s.digitalMin;
  digitalMax=s.digitalMax;
  prefilter=s.prefilter;
  samples=s.samples; % sample rate for every channel, Hz
  record=s.record; % signals (channel,sample)
  chNum=s.chNum; % number of channels
  eegLen=s.eegLen; % number of samples in EEG data
  eegFs=s.eegFs; % sample rate of eeg data
  annSeizure=s.annSeizure;
  seizureTimings=s.seizureTimings;
  save(fileName,'ver','patientID',...
        'patientName','patientGender',...
        'patientAge','recordID',...
        'startdate','starttime',...
        'bytes','records',...
        'duration','ns',...
        'label','transducer','units',...
        'physicalMin','physicalMax',...
        'digitalMin','digitalMax',...
        'prefilter','samples','record',...
        'chNum','eegLen','eegFs',...
        'annSeizure','seizureTimings');
  disp(['Data has been successfully saved to ',fileName,'.']);
end
