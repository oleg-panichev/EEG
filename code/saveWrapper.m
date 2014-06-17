% Wrapper of standard matlab SAVE function for using in parfor.
%
function saveWrapper(fname,varargin)
  if (length(varargin)==1)
    var1=varargin{1};
    save(fname,'var1');
  elseif (length(varargin)==2) 
    var1=varargin{1};
    var2=varargin{2};
    save(fname,'var1','var2');
  elseif (length(varargin)==3) 
    var1=varargin{1};
    var2=varargin{2};
    var3=varargin{3};
    save(fname,'var1','var2','var3');
  elseif (length(varargin)==4) 
    var1=varargin{1};
    var2=varargin{2};
    var3=varargin{3};
    var4=varargin{4};
    save(fname,'var1','var2','var3','var4');
  elseif (length(varargin)==5) 
    var1=varargin{1};
    var2=varargin{2};
    var3=varargin{3};
    var4=varargin{4};
    var5=varargin{5};
    save(fname,'var1','var2','var3','var4','var5');
  elseif (length(varargin)==6) 
    var1=varargin{1};
    var2=varargin{2};
    var3=varargin{3};
    var4=varargin{4};
    var5=varargin{5};
    var6=varargin{6};
    save(fname,'var1','var2','var3','var4','var5','var6');
  end  
end