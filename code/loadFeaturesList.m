function [x,fNamesStr,fNamesStrl]=loadFeaturesList(fNamesList,path)
  x=[];
  fNamesStrl=[];
  cnt=0;
  for i=1:numel(fNamesList)
    s=load([path,'/',fNamesList{i},'.mat']);
    x=[x,real(s.x)];
    
    if cnt>=4
      fNamesStrl=[fNamesStrl,fNamesList{i},',';''];
      cnt=0;
    else
      fNamesStrl=[fNamesStrl,fNamesList{i},','];
    end
    cnt=cnt+1;
  end
    
  num=ceil(numel(fNamesList)/8);
  cnt=0;
  idx=1;
  fNamesStr=cell(num,1);
  for i=1:numel(fNamesList)
    fNamesStr{idx}=[fNamesStr{idx},fNamesList{i},','];    
    cnt=cnt+1;
    if cnt>=8
      fNamesStr{idx}=fNamesStr{idx}(1:end-1);
      cnt=0;
      idx=idx+1;
    end
  end
end