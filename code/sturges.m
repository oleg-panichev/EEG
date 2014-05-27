% STURGES Sturges'Rule
% [numOfBins] = sturges(x) returns the number of bins for
% histogram calculation given vector of data x using 
% Sturges'Rule

function [numOfBins] = sturges(x)
    rangeX = range(x);
    binWidth = rangeX / ( 1+log2(length(x)) );
    numOfBins = floor( rangeX / binWidth );
end