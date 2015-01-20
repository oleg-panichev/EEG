function calcFeatures_ch_sleep_kharitonov(propertiesFile,wpath)
  run(propertiesFile);

  % Load list of patients
  items=dir(wpath);
  dirs={items([items.isdir]).name};
  patBuf=dirs(3:end);
  nOfPatients=numel(patBuf);  
  
  % Preparing buffers to store information about signals.
  SignalLength=zeros(nOfPatients,1);
  nOfSeizures=zeros(nOfPatients,1);
  nOfChannels=zeros(nOfPatients,1);
  isNoise=zeros(nOfPatients,1);
  avIntBetweenSeizures=zeros(nOfPatients,1);
  minIntBetweenSeizures=zeros(nOfPatients,1);
  maxIntBetweenSeizures=zeros(nOfPatients,1);
  sName=cell(nOfPatients,1);
  
  % Get list of patients to work with.
  patIdxBuf=1:nOfPatients;
  try 
    idx=0;
    for i=1:numel(db_list)
      if (strcmp(db_list{i},'ch_sleep_kharitonov'))
        idx=i;
        break;
      end
    end
    patIdxBuf=work_patients{idx};
  catch err
    patIdxBuf=1:nOfPatients;
  end
  
  % Processing patients
  for patIdx=patIdxBuf
    disp([patBuf{patIdx},'...']);
    
    % Load signals list
    items=dir([wpath,'/',patBuf{patIdx},'/*.mat']);
    sigBuf={items.name};
    nOfSignals=numel(sigBuf);
  
    for sigIdx=1:nOfSignals
      % Load data from file
      sdata=load([wpath,'/',patBuf{patIdx},'/',patBuf{patIdx}]);
    
      % Store needed values in struct
      s=struct('data',sdata.data,'channels',sdata.labels,...
        'sampling_frequency',sdata.Fs,'data_length_sec',sdata.N/sdata.Fs,...
        'sequence',0);
    
      % Features calculation
      prepareFeatures(propertiesFile,s); 

%       SignalLength(patIdx)=sdata.N/sdata.Fs;
%       nOfSeizures(patIdx)=numel(sdata.seizureStart);
%       nOfChannels(patIdx)=numel(sdata.labels);
%       isNoise(patIdx)=sum(sdata.markers)/sdata.N*100;
%       if nOfSeizures(patIdx)>1
%         avIntBetweenSeizures(patIdx)=mean(diff(sdata.seizureStart));
%         [minIntBetweenSeizures(patIdx),~]=min(diff(sdata.seizureStart));
%         maxIntBetweenSeizures(patIdx)=max(diff(sdata.seizureStart));
%       end
%       sName{patIdx}=patBuf{patIdx};
    end
  end
  
%   % Forming table with information about patients
%   T_kh = table(SignalLength,nOfSeizures,nOfChannels,...
%     avIntBetweenSeizures,minIntBetweenSeizures,maxIntBetweenSeizures,...
%     isNoise,'RowNames',sName);
%   writetable(T_kh,'db_info.xlsx',...
%     'WriteRowNames',true,'WriteVariableNames',true,'Range','A1');
end
