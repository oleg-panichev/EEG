% DEBUG DISP
% Wrapper for disp.
% Inputs:
%   str - input string
%   dflag - print flag (0 - do not print, otherwise - print)
%
function []=ddisp(str,dflag)
  if (dflag~=0)
    disp(str);
  end
end