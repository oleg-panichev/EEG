% STURGES Sturges'Rule
% [numOfBins] = sturges(x) returns the number of bins for
% histogram calculation given vector of data x using 
% Sturges'Rule
%
function [nbins] = sturges(x)
  nbins = ceil(log2(length(x)) + 1);
end