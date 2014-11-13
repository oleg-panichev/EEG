% Function for estimation thresholds vector for threshold classifier.
%
function [T]=getThresholds(X,n)
  minX=min(X);
  maxX=max(X);  
  T=minX:abs(maxX-minX)/(n-1):maxX;
end