% Function to calculate distance between two points in N-dimentional space.
%
function d=distance(x,y)
  d=0;
  if (length(x)==length(y))
    d=sqrt(sum((x-y).^2));
  else
    warning('Vectors x and y have different length');
  end
end