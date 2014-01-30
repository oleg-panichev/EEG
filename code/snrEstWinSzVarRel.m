function [snr,snrT] = snrEstWinSzVarRel(S,fs,minWinSz,maxWinSz,winSzStep,...
  step,modelM,nOfPresum,updateModelFl,avMdlMethod,minF1,maxF1,minF2,...
  maxF2,sName,plotFlag)
  
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
    freqLowLimit1=ceil(minF1/freqStep+1);
    freqHighLimit1=ceil(maxF1/freqStep);
    freqLowLimit2=ceil(minF2/freqStep+1);
    freqHighLimit2=ceil(maxF2/freqStep);
    
    idx=1;
    j=snrIdx(1);
    instSpectr=abs(fft(S(j-winSz(k):j+winSz(k)).*win'))./len;
    mdl1=instSpectr(freqLowLimit1:freqHighLimit1);
    mdl2=instSpectr(freqLowLimit2:freqHighLimit2);
    mdlBuf1=zeros(nOfPresum,numel(mdl1));
    mdlBuf2=zeros(nOfPresum,numel(mdl2));
    mdlBuf1(1,:)=mdl1;
    mdlBuf2(1,:)=mdl2;

    for j=snrIdx(2:nOfPresum)
%        disp('in2d');
      instSpectr=abs(fft(S(j-winSz(k):j+winSz(k)).*win'))./len;
      switch (avMdlMethod)
          case 'movAvM'
            mdl1=modelM*mdl1+(1-modelM)*instSpectr(freqLowLimit1:freqHighLimit1);
            mdl2=modelM*mdl2+(1-modelM)*instSpectr(freqLowLimit2:freqHighLimit2);
          case 'movAvBuf'
            mdlBuf1(j,:)=instSpectr(freqLowLimit1:freqHighLimit1);
            mdlBuf2(j,:)=instSpectr(freqLowLimit2:freqHighLimit2);
            if (j==nOfPresum)
              mdl1=sum(mdlBuf1)/nOfPresum;  
              mdl2=sum(mdlBuf2)/nOfPresum;
            end
        otherwise
            mdl1=instSpectr(freqLowLimit1:freqHighLimit1);
            mdl2=instSpectr(freqLowLimit2:freqHighLimit2);
      end     
    end
    circMdlIdx=1;
    
    for j=snrIdx(nOfPresum:end)
      % Calculating instant spectra of part of signal
      instSpectr=abs(fft(S(j-winSz(k):j+winSz(k)).*win'))./len;
      instSpectr1=instSpectr(freqLowLimit1:freqHighLimit1);
      instSpectr2=instSpectr(freqLowLimit2:freqHighLimit2);

      % Calculating noise speactra for current position
      noiseSpectr1=abs(instSpectr1-mdl1);
      noiseSpectr2=abs(instSpectr2-mdl2);
      
      s=sum(mdl2)/sum(mdl1);
      n=sum(noiseSpectr2)/sum(noiseSpectr1);
      % Calculating SNR
      snr(k,idx)=20*log10(s/n);

      % Updating model
      if (updateModelFl>0)
        switch (avMdlMethod)
          case 'movAvM'
            mdl1=modelM*mdl1+(1-modelM)*instSpectr1;
            mdl2=modelM*mdl2+(1-modelM)*instSpectr2;
          case 'movAvBuf'
            if(circMdlIdx>nOfPresum)
              circMdlIdx=1;
            end
            mdlBuf1(circMdlIdx,:)=instSpectr1;
            mdlBuf2(circMdlIdx,:)=instSpectr2;
            circMdlIdx=circMdlIdx+1;
            mdl1=sum(mdlBuf1)/nOfPresum;
            mdl2=sum(mdlBuf2)/nOfPresum;
          otherwise
            mdl1=instSpectr1;
            mdl2=instSpectr2;
        end
      end
      idx=idx+1;
    end
  end
  
  if (plotFlag)
    figure
    surf(snrT,2*winSz./fs, snr,'FaceColor','interp'); 
    title(['EEG signal ', sName,', minF1 = ',num2str(minF1),', maxF1 = ',...
      num2str(maxF1),', minF2 = ',num2str(minF2),', maxF2 = ',...
      num2str(maxF2)]); 
%     colorbar;
    xlabel('t, s'); ylabel('WIndow size, s'); zlabel('SNR, dB'); grid on;

    figure
    subplot(211);
    imagesc(snrT,2*winSz./fs,snr); 
    xlim([snrT(1) snrT(end)]);
    title(['EEG signal ', sName,', minF1 = ',num2str(minF1),', maxF1 = ',...
      num2str(maxF1),', minF2 = ',num2str(minF2),', maxF2 = ',...
      num2str(maxF2)]); 
    xlabel('t, s'); ylabel('WIndow size, s');
    grid on;
    
    subplot(212);
    sumSnr=sum(snr);    
    plot(snrT,sumSnr); xlabel('t, s'); 
    xlim([snrT(1) snrT(end)]); ylabel('Sum(SNR)'); grid on;
  end
end