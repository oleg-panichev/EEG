%%  SNR calculation function for EEG
%   Date:   2013.11.11
%   Author:	Oleg Panichev
%
close all; 
clear all;
clc;

%% Signal parameters:
addpath('code');
data=loadConf('data.csv');

% chNum=min(size(S));
% len=max(size(S));

%% Processing parameters:
idBuf=[1,3,4,5,8,11]; % [1:chNum] % Select signals to process
stype='mat';
channel=1;

winSz=1; % half of window size, s
step=0.1; % step of snr calculation, s
modelM=0.9; % Coefficient for model averaging
nOfPresum=30; % Number of iterations of model estim. before SNR calculation
updateModelFl=0; % Flag indicating updating of the modek status (0-off,else-on)
minF=0; % Min freqency in model, Hz
maxF=30; % Max freqency in model, Hz
avMdlMethod='movAvBuf'; % {'movAvM', 'movAvBuf'};
plotFlag=1; % 0 - disable all plot, 1 - enable all plots

snrEstimator=snrEst(winSz,step,modelM,nOfPresum, ...
        updateModelFl,minF,maxF);

idx=1;
for i=1:length(idBuf)
  s=loadData(data,idBuf(i),stype);
  
  snrIdx=1+winSz:step:s.len-winSz;
  snrT=snrIdx(nOfPresum:end)./s.fs;
  snr=zeros(length(idBuf),length(snrT));
  
  [snr(idx,:),~,~]=snrEstimator.snrEst1d(s,1);
  idx=idx+1;
end

figure
for i=1:numel(sBufIdx)
  plot(snrT,snr(i,:)); hold on;
end
plot(snrT,sum(snr,1)/numel(sBufIdx),'r','Linewidth',3);
title(['Average SNR(t) for ', num2str(chNum), ' test streams']);
xlabel('t, s'); ylabel('SNR, dB'); grid on;


%% Processing:


%% 2D SNR
minF=0; % Min freqency in model, Hz
maxF=20; % Max freqency in model, Hz
minWinSz=round(0.5*fs);
maxWinSz=round(2*fs);
winSzStep=round(0.125*fs);

winSz=minWinSz:winSzStep:maxWinSz; % half of window size
winSzLen=length(winSz);
snrIdx=1+max(winSz):step:len-max(winSz);
snrT=snrIdx(nOfPresum:end)./fs;
sumSnr=zeros(length(sBufIdx),length(snrT));

idx=1;
for i=sBufIdx  
  [snr,sumSnr(idx,:),snrT] = snrEstWinSzVar(S(i,:),fs,minWinSz,maxWinSz,winSzStep,step,modelM,...
    nOfPresum,updateModelFl,avMdlMethod,minF,maxF, ['EEG_"',num2str(i)],plotFlag);
  idx=idx+1;
end

figure
for i=1:numel(sBufIdx)
  plot(snrT,sumSnr(i,:)); hold on;
end
plot(snrT,sum(sumSnr,1)/numel(sBufIdx),'r','Linewidth',3);
title(['Average SNR(t) for ', num2str(chNum), ' test streams']);
xlabel('t, s'); ylabel('SNR, dB'); grid on;

%% Delta band snr
minF = 0;
maxF = 4;
minWinSz=round(0.5*fs);
maxWinSz=round(4*fs);
winSzStep=round(0.125*fs);

for i=sBufIdx  
  [snr,snrT] = snrEstWinSzVar(S(i,:),fs,minWinSz,maxWinSz,winSzStep,step,modelM,...
    nOfPresum,updateModelFl,avMdlMethod,minF,maxF, ['EEG_"',num2str(i)],plotFlag);
end

%% Theta band snr
minF = 4;
maxF = 8;
minWinSz=round(0.5*fs);
maxWinSz=round(4*fs);
winSzStep=round(0.125*fs);

for i=sBufIdx  
  [snr,snrT] = snrEstWinSzVar(S(i,:),fs,minWinSz,maxWinSz,winSzStep,step,modelM,...
    nOfPresum,updateModelFl,avMdlMethod,minF,maxF, ['EEG_"',num2str(i)],plotFlag);
end

%% Alpha band snr
minF = 8;
maxF = 14;
minWinSz=round(0.5*fs);
maxWinSz=round(4*fs);
winSzStep=round(0.125*fs);

for i=sBufIdx  
  [snr,snrT] = snrEstWinSzVar(S(i,:),fs,minWinSz,maxWinSz,winSzStep,step,modelM,...
    nOfPresum,updateModelFl,avMdlMethod,minF,maxF, ['EEG_"',num2str(i)],plotFlag);
end

%% Beta band snr
minF = 14;
maxF = 30;
minWinSz=round(0.5*fs);
maxWinSz=round(4*fs);
winSzStep=round(0.125*fs);

for i=sBufIdx  
  [snr,snrT] = snrEstWinSzVar(S(i,:),fs,minWinSz,maxWinSz,winSzStep,step,modelM,...
    nOfPresum,updateModelFl,avMdlMethod,minF,maxF, ['EEG_"',num2str(i)],plotFlag);
end

%% Relation bands snr
minF1 = 0;
maxF1 = 14;
minF2 = 14;
maxF2 = 30;
minWinSz=round(0.5*fs);
maxWinSz=round(4*fs);
winSzStep=round(0.125*fs);

for i=sBufIdx  
  [snr,snrT] = snrEstWinSzVarRel(S(i,:),fs,minWinSz,maxWinSz,winSzStep,...
    step,modelM,nOfPresum,updateModelFl,avMdlMethod,minF1,maxF1,minF2,maxF2,...
    ['EEG_"',num2str(i)], plotFlag);
end


% %% My EEG
% minF = 0;
% maxF = 30;
% 
% fs=1000; %Hz
% minWinSz=round(0.5*fs);
% maxWinSz=round(2*fs);
% winSzStep=round(0.125*fs);
% fname='panichevEEG/POYU6067f_20131206_red.txt';
% % [data,header]=eegTxtRead(fname);
% % save POYU6067f_20131206_red.mat data header fs
% load POYU6067f_20131206_red.mat
% len=length(data);
% t=0:1/fs:(len-1)/fs;
% channel=4;
% snrEst(data(channel,:), fs, winSz, step, modelM, updateModelFl, minF, maxF, [fname], plotFlag);
% [snr,snrT]=snrEstWinSzVar(data(channel,:),fs,minWinSz,maxWinSz,winSzStep,step,modelM,...
%     updateModelFl,avMdlMethod,minF,maxF,[fname],1);
%   
% winSz=minWinSz:winSzStep:maxWinSz;
% figure
% subplot(211);
% imagesc(snrT,winSz./fs,snr); 
% xlim([snrT(1) snrT(end)]);
% title(['EEG signal ', fname,', minF = ',num2str(minF),', maxF = ',num2str(maxF)]); 
% xlabel('t, s'); ylabel('WIndow size, s');
% grid on;
% 
% subplot(212);  
% plot(t,data(24,:),'r','LineWIdth',3); xlabel('t, s'); 
% xlim([snrT(1) snrT(end)]); ylabel('Marks'); grid on;



