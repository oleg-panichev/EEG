function [snr,sumSnr,snrT] = snrEstWinSzVar(S,fs,minWinSz,maxWinSz,winSzStep,...
  step,modelM,nOfPresum,updateModelFl,avMdlMethod,minF,maxF,sName,plotFlag)
  
  len = length(S);
  
  winSz=minWinSz:winSzStep:maxWinSz; % half of window size
  winSzLen=length(winSz);
  snrIdx=1+max(winSz):step:len-max(winSz);
%   nOfPresum=15; % Number of iterations of model estim. before SNR calculation
  snrT=snrIdx(nOfPresum:end)./fs;
  snr=zeros(winSzLen,length(snrT));
  
  for k=1:winSzLen
    win=hamming(2*winSz(k)+1); % Using Hamming window before calculation of spectra
    freqStep=fs/(winSz(k)*2+1);
    freqLowLimit=ceil(minF/freqStep+1);
    freqHighLimit=ceil(maxF/freqStep);
    
    idx=1;
    j=snrIdx(1);
    instSpectr=abs(fft(S(j-winSz(k):j+winSz(k)).*win'))./len;
    mdl=instSpectr(freqLowLimit:freqHighLimit);
    mdlBuf=zeros(nOfPresum,numel(mdl));
    mdlBuf(1,:)=mdl;

    for j=snrIdx(2:nOfPresum)
%        disp('in2d');
      instSpectr=abs(fft(S(j-winSz(k):j+winSz(k)).*win'))./len;
      switch (avMdlMethod)
          case 'movAvM'
            mdl=modelM*mdl+(1-modelM)*instSpectr(freqLowLimit:freqHighLimit);
          case 'movAvBuf'
            mdlBuf(j,:)=instSpectr(freqLowLimit:freqHighLimit);
            if (j==nOfPresum)
              mdl=sum(mdlBuf)/nOfPresum;  
            end
        otherwise
            mdl=instSpectr(freqLowLimit:freqHighLimit);
      end     
    end
    circMdlIdx=1;
    
    for j=snrIdx(nOfPresum:end)
      % Calculating instant spectra of part of signal
      instSpectr=abs(fft(S(j-winSz(k):j+winSz(k)).*win'))./len;
      instSpectr=instSpectr(freqLowLimit:freqHighLimit);

      % Calculating noise speactra for current position
      noiseSpectr=abs(instSpectr-mdl);

      s=sum(mdl);
      n=sum(noiseSpectr);
      % Calculating SNR
      snr(k,idx)=20*log10(s/n);

      % Updating model
      if (updateModelFl>0)
        switch (avMdlMethod)
          case 'movAvM'
            mdl=modelM*mdl+(1-modelM)*instSpectr;
          case 'movAvBuf'
            if(circMdlIdx>nOfPresum)
              circMdlIdx=1;
            end
            mdlBuf(circMdlIdx,:)=instSpectr;
            circMdlIdx=circMdlIdx+1;
            mdl=sum(mdlBuf)/nOfPresum;
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
    imagesc(snrT,2*winSz./fs,snr); 
    xlim([snrT(1) snrT(end)]);
    title(['EEG signal ', sName,', minF = ',num2str(minF),', maxF = ',num2str(maxF)]); 
    xlabel('t, s'); ylabel('WIndow size, s');
    grid on;
    
    subplot(212);
    sumSnr=sum(snr);    
    plot(snrT,sumSnr); xlabel('t, s'); 
    xlim([snrT(1) snrT(end)]); ylabel('Sum(SNR)'); grid on;
  end
end