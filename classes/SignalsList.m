classdef SignalsList < handle
  properties (SetAccess='private')  
    signalsTable;
  end
  
  methods
    function obj=SignalsList(varargin)
      if (nargin==1)
        if (ischar(varargin{1}))
          obj.signalsTable=readtable(varargin{1});
        elseif (istable(varargin{1}))
          obj.signalsTable=varargin{1};
        else
          error(['Unsupported type of input! Input should be string with ',...
            'address of table or table.']);
        end
        obj.checkIds();
      else
        error('Constructor should be called with one input parameter!');
      end
    end
    
    function [h,w]=size(obj)
      [h,w]=size(obj.signalsTable);
    end
    
    function checkIds(obj)
      if (numel(unique(obj.signalsTable.id))~=size(obj.signalsTable,1))
        warning('Table contains rows with same ID!');
      end
    end
    
    function ids=getIDs(obj)
      ids=obj.signalsTable.id;
    end
    
    function subList=getSubListById(obj,ids)
      [~,Locb]=ismember(ids,obj.signalsTable.id);
      Locb=unique(sort(Locb));
      Locb=Locb(Locb>0);
      subList=SignalsList(obj.signalsTable(Locb,:));
    end
    
    function t=getTable(obj)
      t=obj.signalsTable;
    end
  end
end