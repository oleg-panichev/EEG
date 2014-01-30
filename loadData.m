function [s]=loadData(data,id,stype)

  idx=find(data{1,1}==id);
  if idx<1
    error(['There are no stream with id=',num2str(id),'!']);
  end
  
  dir=data{1,2}(idx);
  disp(class(stype));
  disp(stype);
  switch (stype)
    case 'mat'
      filename=strcat(dir,data{1,3}(idx));
      filename=[filename{1}];
      dataFormat=data{1,6}(idx);
      dataFormat=[dataFormat{1}];
      [s]=loadFromMat(filename,dataFormat);
      s.name=data{1,3}(idx);

    case 'edf'
      filename=[dir,data{1,4}(idx)];
      [s]=loadFromEdf(filename);
      s.name=data{1,4}(idx);

    case 'txt'
      filename=[dir,data{1,5}(idx)];
      [s]=loadFromTxt(filename);
      s.name=data{1,5}(idx);

    otherwise
      error([stype,' - wrong signal type!']);
  end  
end

function [s]=loadFromMat(filename,dataFormat)
%   fieldEeg='eeg'; valueEeg=[]; 
%   fieldFs='fs'; valueFs=0;
%   fieldChNum='chNum'; valueChNum=0;
%   fieldMarkers='markers'; valueMarkers=[];
%   fieldMarks='ymarks'; valueMarks=[];
%   s=struct(fieldEeg,valueEeg,fieldFs,valueFs,fieldChNum,valueChNum,...
%     fieldMarkers,valueMarkers,fieldMarks,valueMarks);
  s=eegData();
  
  disp(class(dataFormat));
  disp(dataFormat);
  
  disp(class(filename));
  disp(filename);
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
    





