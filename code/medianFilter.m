% Median filter with kernel
% Input:
% x - input vector
% k - kernel size in percents (0:1)
% Output:
% y - output vector
function [y]=medianFilter(x,k)
  if (k<=0 || k>1)
    warning('Variable k should be 0<k<=1. Default value was used k=0.5.');
    k=0.5;
  end
  n=numel(x);
  m=round((n-k*n)/2);
  y=sort(x);  
  y=mean(y(m:end-m));
end