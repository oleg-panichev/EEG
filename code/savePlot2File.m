%% This function saves plot to file
%
% Inputs:
%   fig - plot index to save;
%   fileFormat - file format;
%   filePath - file path;
%   fileName - file name;
%   
function savePlot2File(fig,fileFormat,filePath,fileName)
  set(fig,'Visible','On');
  saveas(fig,[filePath,fileName,'.',fileFormat],fileFormat);
end
