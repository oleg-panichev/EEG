function [eegData,labels]=selectDataChannels(eegData,labels)
  eegChIdx=[];
  eogChIdx=[];
  emgChIdx=[];
  respChIdx=[];
  ecgChIdx=[];
  for i=1:numel(labels)
    if (strcmp(labels{i}(1:3),'EEG'))
      if (std(eegData(i,:))>0.001)
        eegChIdx=[eegChIdx,i];
      else
        disp([labels{i},' - no signal!']);
      end
    elseif (strcmp(labels{i}(1:3),'EOG'))
      eogChIdx=[eogChIdx,i];
    elseif (strcmp(labels{i}(1:3),'EMG'))
      emgChIdx=[emgChIdx,i];
    elseif (strcmp(labels{i}(1:3),'RESP'))
      respChIdx=[respChIdx,i];
    elseif (strcmp(labels{i}(1:3),'ECG'))
      ecgChIdx=[ecgChIdx,i];
    end
  end
  eegData=eegData(eegChIdx,:);
  labels=labels(eegChIdx);
end