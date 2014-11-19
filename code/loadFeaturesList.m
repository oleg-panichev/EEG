function [x,fNamesStr]=loadFeaturesList(fNamesList,path)
  x=[];
  fNamesStr=[];
  for i=1:numel(fNamesList)
    s=load([path,'/',fNamesList{i},'.mat']);
    x=[x,s.x];
    fNamesStr=[fNamesStr,fNamesList{i},','];
  end
  fNamesStr=fNamesStr(1:end-1);
end