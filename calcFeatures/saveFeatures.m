function saveFeatures(dir2save,features,labels,tBeforeSzCell,...
  tAfterSzCell,fLabelsCell)

  for k=1:numel(labels)
    featureName=labels{k};
    x=features{k}; 
    tBeforeSz=tBeforeSzCell{k};
    tAfterSz=tAfterSzCell{k};
    fLabels=fLabelsCell{k};
    save([dir2save,'/',featureName,'.mat'],...
      'x','tBeforeSz','tAfterSz','fLabels');
  end
end