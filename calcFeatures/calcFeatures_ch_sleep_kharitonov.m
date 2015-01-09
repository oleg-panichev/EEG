function calcFeatures_ch_sleep_kharitonov(wpath)
  % Load list of patients
  items=dir([wpath,'/*.mat']);
  patBuf={items.name};
  nOfPatients=numel(patBuf);
  
  SignalLength=zeros(nOfPatients,1);
  nOfSeizures=zeros(nOfPatients,1);
  nOfChannels=zeros(nOfPatients,1);
  isNoise=zeros(nOfPatients,1);
  avIntBetweenSeizures=zeros(nOfPatients,1);
  minIntBetweenSeizures=zeros(nOfPatients,1);
  maxIntBetweenSeizures=zeros(nOfPatients,1);
  sName=cell(nOfPatients,1);
  for patIdx=1:nOfPatients
    disp([patBuf{patIdx},'...']);
    % Load data from file
    sdata=load([wpath,patBuf{patIdx}]);
    
    % Store needed values in struct
    s=struct('data',sdata.data,'channels',sdata.labels,...
      'sampling_frequency',sdata.Fs,'data_length_sec',sdata.N/sdata.Fs,...
      'sequence',0);
    
    % Features calculation
%     tBuf=
%     features=cell(nOfObservations,1);
%     featureIdx=1;
%     [features{featureIdx},labels]=prepareFeatures(s); 
    
    SignalLength(patIdx)=sdata.N/sdata.Fs;
    nOfSeizures(patIdx)=numel(sdata.seizureStart);
    nOfChannels(patIdx)=numel(sdata.labels);
    isNoise(patIdx)=sum(sdata.markers)/sdata.N*100;
    if nOfSeizures(patIdx)>1
      avIntBetweenSeizures(patIdx)=mean(diff(sdata.seizureStart));
      [minIntBetweenSeizures(patIdx),~]=min(diff(sdata.seizureStart));
      maxIntBetweenSeizures(patIdx)=max(diff(sdata.seizureStart));
    end
    sName{patIdx}=patBuf{patIdx};
  end
  T_kh = table(SignalLength,nOfSeizures,nOfChannels,...
    avIntBetweenSeizures,minIntBetweenSeizures,maxIntBetweenSeizures,...
    isNoise,'RowNames',sName);
  writetable(T_kh,'db_info.xlsx',...
    'WriteRowNames',true,'WriteVariableNames',true,'Range','A1');
end
