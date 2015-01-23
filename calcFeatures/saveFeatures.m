function saveFeatures(dir2save,features,labels,tBeforeSzCell,tAfterSzCell)
  for k=1:numel(labels)
    featureName=labels{k};
    x=features{k}; 
    tBeforeSz=tBeforeSzCell{k};
    tAfterSz=tAfterSzCell{k};
    save([dir2save,'/',featureName,'.mat'],...
      'x','tBeforeSz','tAfterSz');
  end
end