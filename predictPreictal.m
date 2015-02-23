function predictPreictal(propertiesFunction)
  addpath('calcFeatures');
  addpath('classes');
  addpath('classifiers');
  addpath('code');
  addpath('plot');
  prepareWorkspace();
  propertiesFunction();

  % Prepare dirs for features
  if (~exist(repLocation,'dir'))
    mkdir(repLocation);
  end
  
  % Load feature list and choose same features for all patients 
  disp('Selecting features...');
  tic;
  fNamesStr=[];
  for fListIdx=1:numel(fList)
    fNamesStr=[fNamesStr,fList{fListIdx},','];
  end
  fNamesStr=fNamesStr(1:end-1); % List of used features
  
  fNamesList=cell(numel(sigId),numel(fList));
  for sigIdx=1:numel(signalsWorkList.id)
    switch signalsWorkList.sigType{sigIdx}
      case 'aes_spc'

      case 'mat_zhukov'    
        dir2open=[ftLocation,signalsWorkList.mat_address{sigIdx}(1:end-4),'/'];
        for fIdx=1:numel(fList)
          s=load([dir2open,fList{fIdx}],'fLabels');
          fNamesList{sigIdx,fIdx}=s.fLabels;
        end
      otherwise
        warning(['There are np aproriate method to process signals of ',...
          'type ',signalsWorkList.sigType(sigIdx),'! Signal with ID = ',...
          num2str(signalsWorkList.id(sigIdx)),' has been skipped.']);
    end
  end
  fIdxMatrices=selectSameFeatures(fNamesList);
  
  % Load all features in one buffer
  X=[];
  tBeforeSz=[];
  tAfterSz=[];
  SID=[];
  sigList=[];
  for sigIdx=1:numel(signalsWorkList.id)
    disp(signalsWorkList.mat_address{sigIdx});
    switch signalsWorkList.sigType{sigIdx}
      case 'aes_spc'

      case 'mat_zhukov'    
        dir2open=[ftLocation,signalsWorkList.mat_address{sigIdx}(1:end-4),'/'];
        for fIdx=1:numel(fList)
          s=load([dir2open,fList{fIdx}]);
          X=[X;s.x(:,fIdxMatrices{fIdx}(sigIdx,:))];
          tBeforeSz=[tBeforeSz,s.tBeforeSz];
          tAfterSz=[tAfterSz,s.tAfterSz];
          SID=[SID,ones(size(tBeforeSz))*signalsWorkList.id(sigIdx)];
        end
      otherwise
        warning(['There are np aproriate method to process signals of ',...
          'type ',signalsWorkList.sigType(sigIdx),'! Signal with ID = ',...
          num2str(signalsWorkList.id(sigIdx)),' has been skipped.']);
    end
    sigList=[sigList,',',num2str(signalsWorkList.id(sigIdx))];
  end
  sigList=sigList(2:end);
  disp(['Number of features: ',num2str(size(X,2))]);
  t=toc;
  disp(['Elapsed time: ',num2str(t),'s']);
  
  % Form Y using tBeforeSz and tAfterSz
  yIdx=tBeforeSz>earlyDetection & tAfterSz>afterSzStart;
  tbsz=tBeforeSz(yIdx);
  tasz=tAfterSz(yIdx);
  X=X(yIdx,:);
  SID=SID(yIdx)';
  Y=tbsz<preictalTime;
  Y=Y';
  disp(['Number of observations: "',num2str(numel(Y))]);
  
  % Run classification
	disp('Classifying...');
  results=[];
  for classIdx=1:numel(classifierNames)
    tic;
    disp(classifierNames{classIdx});
    R=runNonPatSpecificClassification(propertiesFunction,X,Y,SID,classifierNames{classIdx});
    disp(['Mean CV AUC: ',num2str(R.AUC_cv_av)]);
    
    % Selecting sheet in XLS file
    for sheetIdx=1:numel(allClassifierNames)
      if strcmp(classifierNames{classIdx},allClassifierNames{sheetIdx});
        break;
      end
    end
  
    % Save results to XLS tables
    t=cell(1,2);
    t{1,1}=classifierNames{classIdx};
    t{2,1}=['Number of iterations: ',num2str(nOfIterations)];
    t{3,1}=['Signals IDs: ',sigList];
    t=cell2table(t);
    writetable(t,[repLocation,'classification_results.xlsx'],'Sheet',sheetIdx,...
      'WriteRowNames',false,'WriteVariableNames',false,'Range','A1');
    
    resultsTable=table(preictalTime,R.TH_tr_av,R.PPV_tr_av,R.TPR_tr_av,R.SPC_tr_av,R.FPR_tr_av,R.F1_tr_av,R.SS_tr_av,R.AUC_tr_av,...
      R.TH_cv_av,R.PPV_cv_av,R.TPR_cv_av,R.SPC_cv_av,R.FPR_cv_av,R.F1_cv_av,R.SS_cv_av,R.AUC_cv_av,... 
      R.TH_ts_av,R.PPV_ts_av,R.TPR_ts_av,R.SPC_ts_av,R.FPR_ts_av,R.F1_ts_av,R.SS_ts_av,R.AUC_ts_av,...
      'RowNames',{fNamesStr},'VariableNames',{'PI_sec','TH_tr','PPV_tr','TPR_tr','SPC_tr','FPR_tr','F1_tr','SS_tr','AUC_tr',...
      'TH_cv','PPV_cv','TPR_cv','SPC_cv','FPR_cv','F1_cv','SS_cv','AUC_cv',...
      'TH_ts','PPV_ts','TPR_ts','SPC_ts','FPR_ts','F1_ts','SS_ts','AUC_ts'});
    writetable(resultsTable,[repLocation,'classification_results.xlsx'],'Sheet',sheetIdx,...
      'WriteRowNames',true,'Range','A5');
    
    resultsStdTable=table(preictalTime,R.TH_tr_std,R.PPV_tr_std,R.TPR_tr_std,R.SPC_tr_std,R.FPR_tr_std,R.F1_tr_std,R.SS_tr_std,R.AUC_tr_std,...
      R.TH_cv_std,R.PPV_cv_std,R.TPR_cv_std,R.SPC_cv_std,R.FPR_cv_std,R.F1_cv_std,R.SS_cv_std,R.AUC_cv_std,... 
      R.TH_ts_std,R.PPV_ts_std,R.TPR_ts_std,R.SPC_ts_std,R.FPR_ts_std,R.F1_ts_std,R.SS_ts_std,R.AUC_ts_std,...
      'RowNames',{'std'});    
    writetable(resultsStdTable,[repLocation,'classification_results.xlsx'],'Sheet',sheetIdx,...
      'WriteRowNames',true,'WriteVariableNames',false,'Range','A7');

    results=[results,R];
    t=toc;
    disp(['Elapsed time: ',num2str(t),'s']);
  end
  
  % Plot ROC Curves
  fig=plotROCs(propertiesFunction,results);
  savePlot2File(fig,'png',repLocation,'Classification_results');
  savePlot2File(fig,'fig',repLocation,'Classification_results'); 
  
  % Save results
  save([repLocation,'/',fNamesStr,'.mat'],'results');
end
