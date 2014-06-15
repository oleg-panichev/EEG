% Date vector wrapper
%
classdef DateVector < handle
  properties
    Y; % Year
    M; % Month
    D; % Day
    H; % Hour
    MN; % Minute
    S; % Second
  end
  methods
    function obj=DateVector(Y,M,D,H,MN,S)
      obj.Y=Y;
      obj.M=M;
      obj.D=D;
      obj.H=H;
      obj.MN=MN;
      obj.S=S;
    end
    
    function sec=date2sec(obj,dateFrom)
      sec=etime([obj.Y,obj.M,obj.D,obj.H,obj.MN,obj.S], ...
        [dateFrom.Y,dateFrom.M,dateFrom.D,dateFrom.H,dateFrom.MN,dateFrom.S]);
    end
  end
end