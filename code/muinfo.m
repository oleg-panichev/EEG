% Function for calculation of mutual information between two signals s1 and 
% s2.
%
function mi=muinfo(s1,s2)
  n1=numel(s1);
  n2=numel(s2);
  if (n1~=n2)
    error(['Input vectors must be the same length! numel(s1)=', ...
      num2str(n1),', numel(s2)=',num2str(n2),'.']);
  else
    N=n1;
  end
  
  nbins=max(sturges(s1),sturges(2));
  p1=hist(s1,nbins)/N;
  p2=hist(s2,nbins)/N;
  temp(:,1)=s1; 
  temp(:,2)=s2;
  p12=hist3(temp,[nbins nbins])/N;
  
  mi=0;
  for i=1:nbins
    for j=1:nbins
      if (p12(i,j)~=0 && p1(i)>0 && p2(i)>0)
        mi=mi+p12(i,j)*log(p12(i,j)/(p1(i)*p2(j)));
      end
%       if (isnan(mi) || mi == Inf)
%         p1, p2, p12
%         pause;
%       end
    end
  end
  
end 