function [d_mean,t_mean,a_mean,b_mean,dt_mean,da_mean,db_mean,...
  td_mean,ta_mean,tb_mean,ad_mean,at_mean,ab_mean,bd_mean,bt_mean,ba_mean,...
  d_mean_fLabels,t_mean_fLabels,a_mean_fLabels,b_mean_fLabels,...
  dt_mean_fLabels,da_mean_fLabels,db_mean_fLabels,...
  td_mean_fLabels,ta_mean_fLabels,tb_mean_fLabels,...
  ad_mean_fLabels,at_mean_fLabels,ab_mean_fLabels,...
  bd_mean_fLabels,bt_mean_fLabels,ba_mean_fLabels,...
  tBuf]=f_spectralFeatures(data,fs,...
  winSize,stepSize,chLabel)

  % Parameters of data
  dataSize=size(data);
  dataLen=max(dataSize);
  chNum=min(dataSize);
  if (dataSize(1)>dataSize(2))
    data=data';
  end
  
  tBuf=ceil(1+winSize/2):stepSize:floor(dataLen-winSize/2);
  
  % Buffers to store features and labels
  d_mean=zeros(numel(tBuf),chNum);
  d_mean_fLabels=cell(chNum,1);
  t_mean=zeros(numel(tBuf),chNum);
  t_mean_fLabels=cell(chNum,1);
  a_mean=zeros(numel(tBuf),chNum);
  a_mean_fLabels=cell(chNum,1);
  b_mean=zeros(numel(tBuf),chNum);
  b_mean_fLabels=cell(chNum,1);
  
  dt_mean=zeros(numel(tBuf),chNum);
  dt_mean_fLabels=cell(chNum,1);
  da_mean=zeros(numel(tBuf),chNum);
  da_mean_fLabels=cell(chNum,1);
  db_mean=zeros(numel(tBuf),chNum);
  db_mean_fLabels=cell(chNum,1);
  
  td_mean=zeros(numel(tBuf),chNum);
  td_mean_fLabels=cell(chNum,1);
  ta_mean=zeros(numel(tBuf),chNum);
  ta_mean_fLabels=cell(chNum,1);
  tb_mean=zeros(numel(tBuf),chNum);
  tb_mean_fLabels=cell(chNum,1);
  
  ad_mean=zeros(numel(tBuf),chNum);
  ad_mean_fLabels=cell(chNum,1);
  at_mean=zeros(numel(tBuf),chNum);
  at_mean_fLabels=cell(chNum,1);
  ab_mean=zeros(numel(tBuf),chNum);
  ab_mean_fLabels=cell(chNum,1);
  
  bd_mean=zeros(numel(tBuf),chNum);
  bd_mean_fLabels=cell(chNum,1);
  bt_mean=zeros(numel(tBuf),chNum);
  bt_mean_fLabels=cell(chNum,1);
  ba_mean=zeros(numel(tBuf),chNum);
  ba_mean_fLabels=cell(chNum,1);
  
  % Prepare constants before processing
  N=numel(tBuf(1)-round(winSize/2):tBuf(1)+round(winSize/2));
  f=0:fs/N:(fs-fs/N);
  d_idx=(f>=0.5) & (f<3);
  t_idx=(f>=3) & (f<8);
  a_idx=(f>=8) & (f<13);
  b_idx=(f>=13) & (f<40);
  
  % Calculate correlations
  rowIdx=1;   
  for i=tBuf  
%     disp([num2str(rowIdx),'/',num2str(numel(tBuf))]);
    for m=1:chNum
      x=data(m,i-round(winSize/2):i+round(winSize/2)); 
      afc=abs(fft(x))/N;
      
      % Mean energy in rhythms
      d_mean(rowIdx,m)=mean(afc(d_idx));
      t_mean(rowIdx,m)=mean(afc(t_idx));
      a_mean(rowIdx,m)=mean(afc(a_idx));
      b_mean(rowIdx,m)=mean(afc(b_idx));
      
      % Rhythms energy ratios
      dt_mean(rowIdx,m)=d_mean(rowIdx,m)/t_mean(rowIdx,m);
      da_mean(rowIdx,m)=d_mean(rowIdx,m)/a_mean(rowIdx,m);
      db_mean(rowIdx,m)=d_mean(rowIdx,m)/b_mean(rowIdx,m);
      
      td_mean(rowIdx,m)=t_mean(rowIdx,m)/d_mean(rowIdx,m);
      ta_mean(rowIdx,m)=t_mean(rowIdx,m)/a_mean(rowIdx,m);
      tb_mean(rowIdx,m)=t_mean(rowIdx,m)/b_mean(rowIdx,m);
      
      ad_mean(rowIdx,m)=a_mean(rowIdx,m)/d_mean(rowIdx,m);
      at_mean(rowIdx,m)=a_mean(rowIdx,m)/t_mean(rowIdx,m);
      ab_mean(rowIdx,m)=a_mean(rowIdx,m)/b_mean(rowIdx,m);
      
      bd_mean(rowIdx,m)=b_mean(rowIdx,m)/d_mean(rowIdx,m);
      bt_mean(rowIdx,m)=b_mean(rowIdx,m)/t_mean(rowIdx,m);
      ba_mean(rowIdx,m)=b_mean(rowIdx,m)/a_mean(rowIdx,m);
      
      % Create labels for features
      if (i==tBuf(1))
        d_mean_fLabels{m}=['Delta mean w',num2str(winSize/fs),' s',...
          num2str(stepSize/fs),' ',chLabel{m}];
        t_mean_fLabels{m}=['Theta mean w',num2str(winSize/fs),' s',...
          num2str(stepSize/fs),' ',chLabel{m}];
        a_mean_fLabels{m}=['Alpha mean w',num2str(winSize/fs),' s',...
          num2str(stepSize/fs),' ',chLabel{m}];
        b_mean_fLabels{m}=['Beta mean w',num2str(winSize/fs),' s',...
          num2str(stepSize/fs),' ',chLabel{m}];
        
        dt_mean_fLabels{m}=['DeltaToTheta mean w',num2str(winSize/fs),' s',...
          num2str(stepSize/fs),' ',chLabel{m}];
        da_mean_fLabels{m}=['DeltaToAlpha mean w',num2str(winSize/fs),' s',...
          num2str(stepSize/fs),' ',chLabel{m}];
        db_mean_fLabels{m}=['DeltaToBeta mean w',num2str(winSize/fs),' s',...
          num2str(stepSize/fs),' ',chLabel{m}];
        
        td_mean_fLabels{m}=['ThetaToDelta mean w',num2str(winSize/fs),' s',...
          num2str(stepSize/fs),' ',chLabel{m}];
        ta_mean_fLabels{m}=['ThetaToAlpha mean w',num2str(winSize/fs),' s',...
          num2str(stepSize/fs),' ',chLabel{m}];
        tb_mean_fLabels{m}=['ThetaToBeta mean w',num2str(winSize/fs),' s',...
          num2str(stepSize/fs),' ',chLabel{m}];
        
        ad_mean_fLabels{m}=['AlphaToDelta mean w',num2str(winSize/fs),' s',...
          num2str(stepSize/fs),' ',chLabel{m}];
        at_mean_fLabels{m}=['AlphaToTheta mean w',num2str(winSize/fs),' s',...
          num2str(stepSize/fs),' ',chLabel{m}];
        ab_mean_fLabels{m}=['AlphaToBeta mean w',num2str(winSize/fs),' s',...
          num2str(stepSize/fs),' ',chLabel{m}];
        
        bd_mean_fLabels{m}=['BetaToDelta mean w',num2str(winSize/fs),' s',...
          num2str(stepSize/fs),' ',chLabel{m}];
        bt_mean_fLabels{m}=['BetaToTheta mean w',num2str(winSize/fs),' s',...
          num2str(stepSize/fs),' ',chLabel{m}];
        ba_mean_fLabels{m}=['BetaToAlpha mean w',num2str(winSize/fs),' s',...
          num2str(stepSize/fs),' ',chLabel{m}];
      end
    end
    rowIdx=rowIdx+1;  
%     break;
  end
end