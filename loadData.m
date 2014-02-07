function [s]=loadData(data,id,stype)

  idx=find(data{1,1}==id);
  if idx<1
    error(['There are no stream with id=',num2str(id),'!']);
  end
  
  dir=data{1,2}(idx);
  switch (stype)
    case 'mat'
      filename=strcat(dir,data{1,3}(idx));
      filename=[filename{1}];
      dataFormat=data{1,6}(idx);
      dataFormat=[dataFormat{1}];
      disp(['Loading data from ',filename]);
      [s]=loadFromMat(filename,dataFormat);
      s.name=data{1,3}(idx);
      disp('Done.');

    case 'edf'
      filename=strcat(dir,data{1,4}(idx));
      filename=[filename{1}];
      disp(['Loading data from ',filename]);
      [s]=loadFromEdf(filename);
      disp('Done.');

    case 'txt'
      filename=[dir,data{1,5}(idx)];
      disp(['Loading data from ',filename]);
      [s]=loadFromTxt(filename);
      s.name=data{1,5}(idx);
      disp('Done.');

    otherwise
      error([stype,' - wrong signal type!']);
  end  
end

function [s]=loadFromMat(filename,dataFormat)
  s=eegData();
  
  switch (dataFormat)
    case '45s'
      load(filename);
      s.eeg=A;
      s.fs=fs;
      s.len=length(A);
      s.chNum=1;
      s.markers=zeros(1,length(A));
      s.ymarks='uc';
      
    case 'IoN'
      
      
    otherwise
      error('Unknown data format');      
  end

end

function [s]=loadFromEdf(filename)
  s=eegData();
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
end
    





