% Function to calculate distance metrices of feature vectores
% euDist - Euclidian distance
% brcudiss - Bray-Curtis dissimilarity
function [euDist,brcudiss,brcusim]=distances(featuresBuf)
  nOfFeatureVectors=size(featuresBuf,2);
  euDist=zeros(nOfFeatureVectors,nOfFeatureVectors);
  brcudiss=zeros(nOfFeatureVectors,nOfFeatureVectors);
  brcusim=zeros(nOfFeatureVectors,nOfFeatureVectors);
  for m=1:nOfFeatureVectors
    for n=m+1:nOfFeatureVectors
      if (featuresBuf(1,m)~=0 && featuresBuf(1,n)~=0)
        euDist(n,m)=euDistance(featuresBuf(:,m),featuresBuf(:,n));
        brcudiss(n,m)=brCuDissimilarity(featuresBuf(:,m),featuresBuf(:,n))*100;
        brcusim(n,m)=100-brcudiss(n,m);
      end
    end
  end  
end