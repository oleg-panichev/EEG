% Information transfer estimation
%
function estInformationTransfer(s)  
  disp('Information transfer estimation...');

  % Parameter list:
  windowSize = 10*s.eegFs; % Signal length should be not less then windowSize+max_delta
  max_delta = 2*s.eegFs; % Maximum value of delta
  step = 8; % Step of delta increase
  nbins = 20; % Number of bins in histogram

  mutualInformation_XY = zeros(floor(max_delta/step)+1,1);
  mutualInformation_YX = zeros(floor(max_delta/step)+1,1);
  MI_XY = zeros(s.chNum, s.chNum);
  MI_YX = zeros(s.chNum, s.chNum);
  CMI_XY = zeros(s.chNum, s.chNum);
  CMI_YX = zeros(s.chNum, s.chNum);
  D_XY = zeros(s.chNum, s.chNum);
  D_YX = zeros(s.chNum, s.chNum);
  for m = 1:s.chNum
      disp(['Channel #', num2str(m), '...']);
      for n = 1:s.chNum
          idx = 1;
          for delta_i = 0:step:max_delta            
              X = s.record(m, 1:windowSize);
              if delta_i>0
                  Y = s.record(n, 1+delta_i:windowSize+delta_i) - s.record(n, 1:windowSize);
              else
                  Y = s.record(n, 1+delta_i:windowSize+delta_i);
              end
              temp(:,1) = X(:); temp(:,2) = Y(:);
              p_XY = hist3(temp, [nbins nbins])/s.eegLen; 
              mutualInformation_XY(idx) = calcMI(p_XY);

              if delta_i>0
                  X = s.record(m, 1+delta_i:windowSize+delta_i) - s.record(m, 1:windowSize);
              else
                  X = s.record(m, 1+delta_i:windowSize+delta_i);
              end            
              Y = s.record(n, 1:windowSize);
              temp(:,1) = X; temp(:,2) = Y;
              p_YX = hist3(temp, [nbins nbins])/s.eegLen; 
              mutualInformation_YX(idx) = calcMI(p_YX);

              idx = idx + 1;
          end
          MI_XY(m,n) = mutualInformation_XY(1);
          MI_YX(m,n) = mutualInformation_YX(1);
          CMI_XY(m,n) = mean(mutualInformation_XY);
          CMI_YX(m,n) = mean(mutualInformation_YX);

          if m == 12 && n == 2
              mi_delta = mutualInformation_XY;

              figure
              plot([0:step:max_delta]./s.eegFs, mi_delta);
              xlim([0 max_delta/s.eegFs]);
              xlabel('\delta, s'); ylabel('MI');
              grid on;
  %             break;           
          end

          D_XY(m,n) = (CMI_XY(m,n) - CMI_YX(m,n))/(CMI_XY(m,n) + CMI_YX(m,n));
          D_YX(m,n) = (CMI_YX(m,n) - CMI_XY(m,n))/(CMI_YX(m,n) + CMI_XY(m,n));
      end
  end

  cMap_WR = makeColorMap([1 1 1],[1 0 0],80);
  cMap_BWR = makeColorMap([0 0 1],[1 1 1],[1 0 0],80);



  figure; % subplot(2,2,1); 
  temp = zeros(s.chNum+1,s.chNum+1); temp(1:end-1,1:end-1) = MI_XY; pcolor(temp);
  set(gca,'XTick',1.5:s.chNum+0.5,'YTick',1.5:s.chNum+0.5, 'XTickLabel', s.label,'YTickLabel', s.label, 'FontSize', 8);
  xlabel('Y'); title('MI X->Y', 'FontSize', 10);  ylabel('X'); colorbar; colormap(cMap_BWR); grid off;
  
  figure; % subplot(2,2,2); 
  temp = zeros(s.chNum+1,s.chNum+1); temp(1:end-1,1:end-1) = MI_YX; pcolor(temp);
  set(gca,'XTick',1.5:s.chNum+0.5,'YTick',1.5:s.chNum+0.5, 'XTickLabel', s.label,'YTickLabel', s.label, 'FontSize', 8);
  xlabel('Y'); title('MI Y->X', 'FontSize', 10);  ylabel('X'); colorbar; colormap(cMap_BWR); grid off;
  
  figure; % subplot(2,2,3); 
  temp = zeros(s.chNum+1,s.chNum+1); temp(1:end-1,1:end-1) = CMI_XY; pcolor(temp);
  set(gca,'XTick',1.5:s.chNum+0.5,'YTick',1.5:s.chNum+0.5, 'XTickLabel', s.label,'YTickLabel', s.label, 'FontSize', 8);
  xlabel('Y'); title('CMI X->Y', 'FontSize', 10);  ylabel('X'); colorbar; colormap(cMap_BWR); grid off;
  
  figure; % subplot(2,2,4); 
  temp = zeros(s.chNum+1,s.chNum+1); temp(1:end-1,1:end-1) = CMI_YX; pcolor(temp);
  set(gca,'XTick',1.5:s.chNum+0.5,'YTick',1.5:s.chNum+0.5, 'XTickLabel', s.label,'YTickLabel', s.label, 'FontSize', 8);
  xlabel('Y'); title('CMI Y->X', 'FontSize', 10);  ylabel('X'); colorbar; colormap(cMap_BWR); grid off;

  figure
  temp = zeros(s.chNum+1,s.chNum+1); temp(1:end-1,1:end-1) = D_XY; pcolor(temp);
  set(gca,'XTick',1.5:s.chNum+0.5,'YTick',1.5:s.chNum+0.5, 'XTickLabel', s.label,'YTickLabel', s.label, 'FontSize', 8);
  xlabel('Y'); title('Directionality index X->Y', 'FontSize', 10); ylabel('X'); colorbar; colormap(cMap_BWR); grid off;
  disp('Done.');
end