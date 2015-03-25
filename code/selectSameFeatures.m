% Function for selection the same set of features for all signals.
function fIdxMatrices=selectSameFeatures(fNamesList)

  % Prepare buffers
  nOfSignals=size(fNamesList,1);
  nOfFeatureFiles=size(fNamesList,2);
  containMatrices=cell(1,nOfFeatureFiles);
  containMatricesLog=cell(size(fNamesList));
  fIdxMatrices=cell(1,nOfFeatureFiles);
  
  for m=1:nOfFeatureFiles
    fNames=fNamesList{1,m};
    if (~iscell(fNames))
      fNames={fNames};
    end
    nOfFeatures1buf=size(fNames,1);
    containMatrix=zeros(nOfSignals,nOfFeatures1buf);
    for n=1:nOfSignals
      for i=1:nOfFeatures1buf
        nOfFeatures2buf=size(fNamesList{n,m},1);
        for j=1:nOfFeatures2buf
%           fNamesList
%           fNamesList{n,m}{j}
          if (strcmp(fNames{i},fNamesList{n,m}{j}))
            containMatrix(n,i)=j;
          end
        end
      end
    end
    containMatrices{m}=containMatrix;
    containMatricesLog{m}=containMatrix>0;
    
    fIdx=[];
    for i=1:size(containMatrix,2)
      if (sum(containMatrix(:,i)==0)==0)
        fIdx=[fIdx,containMatrix(:,i)];
      end
    end
    fIdxMatrices{m}=fIdx;
  end
end