addpath('code');
addpath('classes');
addpath('classifiers');
addpath('plot');
prepareWorkspace();

run('processingProperties.m');
items=dir(wpath);
dirs={items([items.isdir]).name};
patBuf=dirs(3:end);

XTrain=[];
XTest=[];
featuresList={};

% Load all data
patData=cell(numel(patBuf),1);
% fNamesList={'euDist av','euDist var','euDistSort av','euDistSort var',...
%   'corrc av','corrc var','MI av','MI var','iAmpl av','iAmpl var',...
%   'iPhase av','iPhase var','iPhaseDiff av','iPhaseDiff var',...
%   'iPhaseDiff avt'};
fNamesList={'corrc_30_avt'};

sNamesBuf_Test=[];
for patIdx=1:numel(patBuf)
  [X,fNamesStr,fNamesStrl]=loadFeaturesList(fNamesList,[reportPath,patBuf{patIdx},'/',trainPath]);
  if (runOnTestDataFlag>0)
    [X_test,~,~]=loadFeaturesList(fNamesList,[reportPath,patBuf{patIdx},'/',testPath]);
    s=load([reportPath,patBuf{patIdx},'/',testPath,'sNamesBuf.mat']);
    sNamesBuf_Test=[sNamesBuf_Test,s.testBuf];
  else
    X_test=[];
  end
  
  s=load([reportPath,patBuf{patIdx},'/',trainPath,'y.mat']);
  Y=s.y;
  s=load([reportPath,patBuf{patIdx},'/',trainPath,'s.mat']);
  S=s.sequence;

%   [X,fNamesStr,fNamesStrl,S,Y]=loadFeaturesListUnpack(fNamesList,[reportPath,patBuf{patIdx},'/',trainPath],1);
  
  data=struct('X',X,'Y',Y,'S',S,'X_test',X_test);
  patData{patIdx}=data;
end

allClassNames={'threshold','nbayes','logit','svm','tree','treebagger',...
  'knn','discr'};
% classifierNames={'nbayes','logit','svm','tree',...
%   'knn','discr'};
classifierNames={'nbayes','logit','svm','tree',...
  'knn','discr'};

clNum=numel(classifierNames);
T=cell(clNum,1);
TWght=cell(clNum,1);
ROCs=cell(clNum,1);
ROCsWght=cell(clNum,1);
RSLT=cell(clNum,1);

for i=1:clNum
  [T{i},TWght{i},ROCs{i},ROCsWght{i},RSLT{i}]=runIndClassification(patData,...
    classifierNames{i},patBuf);
  
  t=cell(1,2);
  t{1,1}=[classifierNames{i},', number of iterations: ',num2str(nOfIterations)];
  t{2,1}=fNamesStrl;
  t=cell2table(t);
  for k=1:numel(allClassNames)
    if strcmp(classifierNames{i},allClassNames{k});
      break;
    end
  end
  writetable(t,'classification_results.xlsx','Sheet',k,...
    'WriteRowNames',false,'WriteVariableNames',false,'Range','A1');
  writetable(T{i},'classification_results.xlsx','Sheet',k,...
    'WriteRowNames',true,'Range','A3');
  writetable(TWght{i},'classification_results.xlsx','Sheet',k,...
    'WriteRowNames',false,'Range','K3'); 
end

plotROCs(classifierNames,patBuf,ROCs,ROCsWght,T,TWght,fNamesStr);

if (runOnTestDataFlag>0)
  disp('Writing results to submition file...');
  t=clock;
  fileID=fopen(['submit_',num2str(t(1)),num2str(t(2)),num2str(t(3)),...
    '_',num2str(t(4)),num2str(t(5)),'.csv'],'w');
  fprintf(fileID,'clip,preictal\n');
  nOfPi=0;
  for i=1:size(RSLT{clResultNumber,1},1)
    fprintf(fileID,[sNamesBuf_Test{i},',%d\n'],RSLT{clResultNumber,1}(i));
  end
  fclose(fileID);
  disp('Done!');
end

