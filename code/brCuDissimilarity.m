function d=brCuDissimilarity(x,y)
  d=0;
  if (length(x)==length(y))
    d=sum(abs(x-y))/(sum(x)+sum(y));
  else
    warning('Vectors x and y have different length');
  end
end