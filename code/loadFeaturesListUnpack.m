function [x,fNamesStr,fNamesStrl,seq,y]=loadFeaturesListUnpack(fNamesList,path,...
  loadYflag)
  x=[];
  y=[];
  seq=[];
  fNamesStrl=[];
  cnt=0;
  
  % temp 
  s=load([path,'/',fNamesList{1},'.mat']);
  chNum=size(s.x,2);
  
  if (loadYflag>0 && numel(y)==0)
    sy=load([path,'/','y.mat']);
  end 
  
  for i=2:numel(fNamesList)
    s=load([path,'/',fNamesList{i},'.mat']);   
    x_temp=[];
    y_temp=[];
    obsNum=size(s.x,2)/chNum;
    for k=1:size(s.x,1)
      tBuf=reshape(real(s.x(k,:)),chNum,obsNum)';
%       x_aver=[mean(tBuf(1:obsNum/2,:));mean(tBuf(obsNum/2+1:end,:))];
%       x_aver=[mean(tBuf(:,:))];
      x_aver=tBuf;
      x_temp=[x_temp;x_aver];
      if (loadYflag>0 && numel(y)==0)        
        y_temp=[y_temp;ones(size(x_aver,1),1)*sy.y(k)];
      end
    end
    x=[x,x_temp];
    
    if (loadYflag>0 && numel(y)==0)
      y=y_temp;
    end
    
    if cnt>=4
      fNamesStrl=[fNamesStrl,fNamesList{i},',';''];
      cnt=0;
    else
      fNamesStrl=[fNamesStrl,fNamesList{i},','];
    end
    cnt=cnt+1;
  end
  seq=zeros(numel(y),1);  
  
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