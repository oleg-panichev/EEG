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
    minWinSz;
    winSzStep;
    maxWinSz;
  end
  
  methods  (Access='public')
    function obj=snrEst(winSz,step,modelM,nOfPresum, ...
        updateModelFl,minF,maxF,minWinSz,winSzStep,maxWinSz)
      obj.config(winSz,step,modelM,nOfPresum, ...
        updateModelFl,minF,maxF,minWinSz,winSzStep,maxWinSz);
    end
    
    function config(obj,winSz,step,modelM,nOfPresum, ...
        updateModelFl,minF,maxF,minWinSz,winSzStep,maxWinSz)
      obj.winSz=winSz;
      obj.step=step;
      obj.modelM=modelM;
      obj.nOfPresum=nOfPresum;
      obj.updateModelFl=updateModelFl;
      obj.minF=minF;
      obj.maxF=maxF;
      obj.minWinSz=minWinSz;
      obj.winSzStep=winSzStep;
      obj.maxWinSz=maxWinSz;
    end
    
    function [snr,snrF,snrT]=snrEst1d(obj,s,chIdx,plotFlag)
      if (chIdx>s.chNum)
        error(['Wrong chIdx=',num2str(chIdx),' while chNum = ',...
          num2str(s.chNum)]);
      end
      [S,fs]=s.getSingleChannel(chIdx);
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
        title([s.recordID]);
        ylabel([s.label(chIdx),', ',s.units(chIdx)]); xlabel('t, s'); 
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
        plot(snrT,snr,'Linewidth',2); ylabel('SNR, dB'); xlabel('t, s');  
        grid on;

        subplot(514);
        imagesc(snrT,f,snrF); 
        xlim([snrT(1) snrT(end)]); ylim([f(1) f(end)]);
        xlabel('t, s'); ylabel('f, Hz');

        subplot(515);
        plot(snrT,sum(snrF),'Linewidth',2); 
        xlabel('t, s'); xlim([t(1) t(end)]); ylabel('sum(A), Hz'); grid on;
      end
    end 
    
    function [snr,sumSnr,snrT] = snrEstWinSzVar(obj,s,chIdx,plotFlag)
      if (chIdx>s.chNum)
        error(['Wrong chIdx=',num2str(chIdx),' while chNum = ',...
          num2str(s.chNum)]);
      end
      [S,fs]=s.getSingleChannel(chIdx);
      len = length(S);

      obj.minWinSz
      obj.winSzStep
      obj.maxWinSz
      winSzBuf=obj.minWinSz*fs:obj.winSzStep*fs:obj.maxWinSz*fs % half of window size
      winSzLen=length(winSzBuf);
      snrIdx=1+max(winSzBuf):obj.step:len-max(winSzBuf);
      snrT=snrIdx(obj.nOfPresum:end)./fs; 
      numel(winSzBuf)
      obj.nOfPresum
      snr=zeros(winSzLen,length(snrT));

      for k=1:winSzLen
        win=hamming(2*winSzBuf(k)+1); % Using Hamming window before calculation of spectra
        freqStep=fs/(winSzBuf(k)*2+1);
        freqLowLimit=ceil(obj.minF/freqStep+1);
        freqHighLimit=ceil(obj.maxF/freqStep);

        idx=1;
        j=snrIdx(1);
        instSpectr=abs(fft(S(j-winSzBuf(k):j+winSzBuf(k)).*win'))./len;
        mdl=instSpectr(freqLowLimit:freqHighLimit);
        mdlBuf=zeros(obj.nOfPresum,numel(mdl));
        mdlBuf(1,:)=mdl;

        for j=snrIdx(2:obj.nOfPresum)
    %        disp('in2d');
          instSpectr=abs(fft(S(j-winSzBuf(k):j+winSzBuf(k)).*win'))./len;
          switch (avMdlMethod)
              case 'movAvM'
                mdl=obj.modelM*mdl+(1-obj.modelM)*instSpectr(freqLowLimit:freqHighLimit);
              case 'movAvBuf'
                mdlBuf(j,:)=instSpectr(freqLowLimit:freqHighLimit);
                if (j==obj.nOfPresum)
                  mdl=sum(mdlBuf)/obj.nOfPresum;  
                end
            otherwise
                mdl=instSpectr(freqLowLimit:freqHighLimit);
          end     
        end
        circMdlIdx=1;

        for j=snrIdx(obj.nOfPresum:end)
          % Calculating instant spectra of part of signal
          instSpectr=abs(fft(S(j-winSzBuf(k):j+winSzBuf(k)).*win'))./len;
          instSpectr=instSpectr(freqLowLimit:freqHighLimit);

          % Calculating noise speactra for current position
          noiseSpectr=abs(instSpectr-mdl);

          s=sum(mdl);
          n=sum(noiseSpectr);
          % Calculating SNR
          snr(k,idx)=20*log10(s/n);

          % Updating model
          if (obj.updateModelFl>0)
            switch (avMdlMethod)
              case 'movAvM'
                mdl=obj.modelM*mdl+(1-obj.modelM)*instSpectr;
              case 'movAvBuf'
                if(circMdlIdx>obj.nOfPresum)
                  circMdlIdx=1;
                end
                mdlBuf(circMdlIdx,:)=instSpectr;
                circMdlIdx=circMdlIdx+1;
                mdl=sum(mdlBuf)/obj.nOfPresum;
              otherwise
                mdl=instSpectr;
            end
          end
          idx=idx+1;
        end
      end

      if (plotFlag)
    %     figure
    %     surf(snrT,2*winSz./fs, snr,'FaceColor','interp'); 
    %     title(['EEG signal ', sName,', minF = ',num2str(minF),', maxF = ',num2str(maxF)]); 
    % %     colorbar;
    %     xlabel('t, s'); ylabel('WIndow size, s'); zlabel('SNR, dB'); grid on;

        figure
        subplot(211);
        imagesc(snrT,2*winSzBuf./fs,snr); 
        xlim([snrT(1) snrT(end)]);
        title(['EEG signal ', sName,', minF = ',num2str(obj.minF),', maxF = ',num2str(obj.maxF)]); 
        xlabel('t, s'); ylabel('WIndow size, s');
        grid on;

        subplot(212);
        sumSnr=sum(snr);    
        plot(snrT,sumSnr); xlabel('t, s'); 
        xlim([snrT(1) snrT(end)]); ylabel('Sum(SNR)'); grid on;
      end
    end
    
  end
end


