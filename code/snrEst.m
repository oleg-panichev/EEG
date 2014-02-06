% snrEst    This class provides a set of methods for SNR estimation in EEG
%           signal.
%
% Syntax:
%   snrEstimator = snrEst(winSz,step,modelM,nOfPresum, ...
%        updateModelFl,minF,maxF,sName,plotFlag);
%   [snr,snrF,snrT]=snrEstimator.snrEst1d(s,channelIdx);
%   etc.
%
% Description:
%   This class provides a set of methods for SNR estimation in EEG
%   signal.
%
% Oleg Panichev, 2013-07-23
%
classdef snrEst < handle
  properties (SetAccess='private')
    winSz;
    step;
    modelM;
    nOfPresum;
    updateModelFl;
    minF;
    maxF;   
  end
  
  methods  (Access='public')
    function obj=snrEst(winSz,step,modelM,nOfPresum, ...
        updateModelFl,minF,maxF)
      obj.winSz=winSz;
      obj.step=step;
      obj.modelM=modelM;
      obj.nOfPresum=nOfPresum;
      obj.updateModelFl=updateModelFl;
      obj.minF=minF;
      obj.maxF=maxF;
    end
    
    function [snr,snrF,snrT]=snrEst1d(obj,s,channelIdx,plotFlag)
      [S,fs]=snrEst.structToSeparateData(s);
      
      if (channelIdx>s.chNum)
        error(['Wrong channelIdx=',num2str(channelIdx),' while chNum = ',...
          num2str(s.chNum)]);
      end
      S=S(channelIdx,:);
      len = length(S);
      winSzIn=round(obj.winSz*fs);
      stepIn=round(obj.step*fs);
      
      t=0:1/fs:(len-1)/fs;
      freqStep=fs/(winSzIn*2+1);
      freqLowLimit=ceil(obj.minF/freqStep+1);
      freqHighLimit=ceil(obj.maxF/freqStep);
      f=freqStep*(freqLowLimit-1):freqStep:freqStep*(freqHighLimit-1);

      win=hamming(2*winSzIn+1); % Using Hamming window before calculation of spectra
      snrIdx=1+winSzIn:stepIn:len-winSzIn;
      snrT=snrIdx(obj.nOfPresum:end)./fs;
      snr=zeros(1,length(snrT));
      snrF=zeros(length(f),length(snrT));

      if(plotFlag~=0)
        figure
        subplot(511);
        plot(t, S); 
%         title(['EEG signal ', s.name,', minF = ',num2str(obj.minF), ...
%           ', maxF = ',num2str(obj.maxF)]); 
        ylabel('A, uV'); xlabel('t, s'); 
        xlim([t(1) t(end)]); grid on;
        subplot(512);
      end

      idx=1;
      j=snrIdx(1);
      instSpectr=abs(fft(S(j-winSzIn:j+winSzIn).*win'))./len;
      mdl=instSpectr(freqLowLimit:freqHighLimit);
      for j=snrIdx(2:obj.nOfPresum)
        instSpectr=abs(fft(S(j-winSzIn:j+winSzIn).*win'))./len;
        mdl=obj.modelM*mdl+(1-obj.modelM)*instSpectr(freqLowLimit:freqHighLimit);
      end

      for j=snrIdx(obj.nOfPresum:end)
        % Calculating instant spectra of part of signal
        instSpectr=abs(fft(S(j-winSzIn:j+winSzIn).*win'))./len;
        instSpectr=instSpectr(freqLowLimit:freqHighLimit);

        % Calculating noise speactra for current position
        noiseSpeactr=abs(instSpectr-mdl);

        s=sum(mdl);
        n=sum(noiseSpeactr);
        % Calculating SNR
        snr(idx)=20*log10(s/n);
        snrF(:,idx)=20*log10(mdl./noiseSpeactr);

        % Updating model
        if (obj.updateModelFl>0)
          mdl=obj.modelM*mdl+(1-obj.modelM)*instSpectr;
        end

        idx=idx+1;

        if (plotFlag~=0)
          plot(f,instSpectr); hold on;
        end
      end

      if (plotFlag~=0)
        plot(f,mdl,'r','Linewidth',2); xlabel('f, Hz'); ylabel('V^2'); grid on;

        subplot(513);
        plot(snrT,snr,'Linewidth',2); ylabel('SNR, dB'); xlabel('t, s'); xlim([t(1) t(end)]); 
        grid on;

        subplot(514);
        imagesc(snrT,f,snrF); 
        xlim([snrT(1) snrT(end)]); ylim([f(1) f(end)]);
        xlabel('t, s'); ylabel('f, Hz');

        subplot(515);
        plot(snrT,sum(snrF),'Linewidth',2); grid on;
      end
    end 
  end
  
  methods (Static)
    function [eeg,fs]=structToSeparateData(s)
      eeg=s.eeg;
      fs=s.fs;
    end
  end
end


