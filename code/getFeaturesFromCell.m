% Function to get features in a vector from cell of features.
%
function features = getFeaturesFromCell(c,fIdx)
  N = numel(c);
  M = numel(c{1,1});
  
  if (N == 0)
    error('The cell with features is empty.');
  end
  if (~iscell(c))
    error('First input wariable must be cell.');
  end
  if (fIdx>M || fIdx<1)
    error(['Wrong feature index! fIdx = ',num2str(fIdx),...
      ', when number of features = ',num2str(M),'.']);
  end
  
  [n,m] = size(c{1,1}{1,fIdx});
  features = zeros(N,n*m);
  for i=1:N
    features(i,:) = c{i,1}{1,fIdx}(:);
  end
end