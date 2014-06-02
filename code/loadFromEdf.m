% Function to load data from edf file and save it to inner data format
%
function loadFromEdf(s,filename)
  [hdr, record]=edfread(filename);
  s.ver=hdr.ver;
  s.patientID=hdr.patientID;                       
  s.recordID=hdr.recordID;                                        
  s.startdate=hdr.startdate;
  s.starttime=hdr.starttime;
  s.bytes=hdr.bytes;
  s.records=hdr.records;
  s.duration=hdr.duration;
  s.ns=hdr.ns;
  s.label=hdr.label;
  s.transducer=hdr.transducer;
  s.units=hdr.units;
  s.physicalMin=hdr.physicalMin;
  s.physicalMax=hdr.physicalMax;
  s.digitalMin=hdr.digitalMin;
  s.digitalMax=hdr.digitalMax;
  s.prefilter=hdr.prefilter;
  s.samples=hdr.samples;
  s.record=record;
  s.chNum=min(size(s.record));
  s.eegLen=length(record);
  s.eegFs=s.samples(1);
end