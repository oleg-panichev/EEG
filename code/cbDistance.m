% City blocks or L1 distance between vectors X and Y
%
function d=cbDistance(x,y)
  d=0;
  if (length(x)==length(y))
    d=sum(abs(x-y));
  else
    warning('Vectors x and y have different length');
  end
end