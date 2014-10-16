% Function to calculate distance metrices of feature vectores
% euDist - Euclidian distance
% brcudiss - Bray-Curtis dissimilarity
function [euDist,brcuDiss,brcuSim,chsqDist,cbDist]=distances(featuresBuf)
  nOfFeatureVectors=size(featuresBuf,2);
  euDist=zeros(nOfFeatureVectors,nOfFeatureVectors);
  brcuDiss=zeros(nOfFeatureVectors,nOfFeatureVectors);
  brcuSim=zeros(nOfFeatureVectors,nOfFeatureVectors);
  chsqDist=zeros(nOfFeatureVectors,nOfFeatureVectors);
  cbDist=zeros(nOfFeatureVectors,nOfFeatureVectors);
  for m=1:nOfFeatureVectors
    for n=m+1:nOfFeatureVectors
      if (featuresBuf(1,m)~=0 && featuresBuf(1,n)~=0)
        euDist(n,m)=euDistance(featuresBuf(:,m),featuresBuf(:,n));
        brcuDiss(n,m)=brCuDissimilarity(featuresBuf(:,m),featuresBuf(:,n))*100;
        brcuSim(n,m)=100-brcuDiss(n,m);
        chsqDist(n,m)=chSqDistance(featuresBuf(:,m),featuresBuf(:,n),10);
        cbDist(n,m)=cbDistance(featuresBuf(:,m),featuresBuf(:,n));
      end
    end
  end  
end