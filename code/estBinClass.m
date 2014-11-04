function [TP,TN,FP,FN,PPV,TPR,F1]=estBinClass(Y,result)
  TP=0;
  TN=0;
  FP=0;
  FN=0;
  for i=1:numel(Y)
    if (Y(i)==1 && result(i)==1)
      TP=TP+1;
    elseif (Y(i)==0 && result(i)==1)
      FP=FP+1;
    elseif (Y(i)==1 && result(i)==0)
      FN=FN+1;
    elseif (Y(i)==0 && result(i)==0)
      TN=TN+1;
    end
  end
  PPV=TP/(TP+FP);
  TPR=TP/(TP+FN);
  F1=2*PPV*TPR/(PPV+TPR);
end