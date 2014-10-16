function d=chSqDistance(x,y,nbins)  
  d=0;
  if (length(x)==length(y))
    hx=hist(x,nbins);
    hy=hist(y,nbins);
    d=1/2*sum((hx-hy).*(hx-hy)./(hx+hy+eps));
  else
    warning('Vectors x and y have different length');
  end
end