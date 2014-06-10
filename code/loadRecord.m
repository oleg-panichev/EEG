% Load record from file
%
function [s]=loadRecord(path,fileName,subjectInfoFileName,...
    loadRecordFl,loadPatientInfoFl,loadSeizuresAnnotationFl)
  fullFileName=strcat(path,fileName);
  fullFileName=[fullFileName{1}];
  dataType=lower(fullFileName(end-2:end));
  if (strcmp(dataType,'edf'))
    s=eegData();
    if (loadRecordFl>0) 
      loadFromEdf(s,fullFileName);
    end
    if (loadPatientInfoFl>0)  
      loadPatientInfo(s,path,fileName,subjectInfoFileName);
    end
    if (loadSeizuresAnnotationFl>0)
      loadSeizuresAnnotation(s,fullFileName);
    end
    disp('Data loading is done.');
    
  elseif (strcmp(dataType,'mat'))
    s=eegData();
    s_struct=load(fullFileName);
    s.ver=s_struct.ver;
    s.patientID=s_struct.patientID;   
    s.patientName=s_struct.patientName;
    s.patientGender=s_struct.patientGender;
    s.patientAge=s_struct.patientAge;
    s.recordID=s_struct.recordID;                                        
    s.startdate=s_struct.startdate;
    s.starttime=s_struct.starttime;
    s.bytes=s_struct.bytes;
    s.records=s_struct.records;
    s.duration=s_struct.duration;
    s.ns=s_struct.ns;
    s.label=s_struct.label; 
    s.transducer=s_struct.transducer;
    s.units=s_struct.units; 
    s.physicalMin=s_struct.physicalMin;
    s.physicalMax=s_struct.physicalMax;
    s.digitalMin=s_struct.digitalMin;
    s.digitalMax=s_struct.digitalMax;
    s.prefilter=s_struct.prefilter;
    s.samples=s_struct.samples; 
    s.record=s_struct.record; 
    s.chNum=s_struct.chNum; 
    s.eegLen=s_struct.eegLen; 
    s.eegFs=s_struct.eegFs; 
    s.annSeizure=s_struct.annSeizure; 
    s.seizureTimings=s_struct.seizureTimings; 
    disp('Data loading is done.');
  else
    error([dataType,' - data type is not supported!']);
  end
end