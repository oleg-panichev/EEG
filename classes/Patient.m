% Class for storing patient information.
%
classdef Patient < handle
  properties (SetAccess='public') 
    id; % Patient ID
    name; % Patient name
    age; % Patient's age
    gender; % Patient's gender
    signalsAll; % Cell(numOfSignals,5)-sname,timeStart,duration,
    % numOfSeizures,good channels
    minChNum; % Minimum number of channels from all patients streams
  end
  
  properties (SetAccess='private')   
    subjectInfoFileName='SUBJECT-INFO';
  end
  
  methods
    function obj=Patient()
    end
    
    function []=updateFields(obj,id,patientDir)
      obj.id=id;
      % Loading list of signals for current patient:
      items=dir(patientDir);
      signals=java.util.ArrayList;
      for i=1:numel(items)
        if (numel(items(i).name)>5)
          if (strcmp(items(i).name(1:5),patientDir(end-4:end)) && ...
              strcmp(items(i).name(end-2:end),'mat') && items(i).isdir==0)
            signals.add(items(i).name);
          end
        end
      end      
      % Loading data from signals:
      numOfSignals=signals.size();
      obj.signalsAll=cell(numOfSignals,4);
      shift=[];     
      obj.minChNum=Inf;
      for i=1:numOfSignals
        disp(['Reading data from ',[patientDir(end-4:end),'/',signals.get(i-1)],'...']);
        goodChannelIdxBuf=[];
        s=loadRecord(patientDir(1:end-5),[patientDir(end-4:end),'/', ...
          signals.get(i-1)],obj.subjectInfoFileName,1,1,1);
        % Loading patient data from first signal:
        if (i==1)
          obj.name=s.patientName;
          obj.age=s.patientAge;
          obj.gender=s.patientGender;
        end
        % Loading signal timings:
        obj.signalsAll{i,1}=signals.get(i-1);
        obj.signalsAll{i,2}=s.starttime;
        if (~isempty(s.starttime))
          [Y,M,D,H,MN,S]=datevec([s.startdate,'.',s.starttime],'dd.mm.yy.HH.MM.SS');
          dateVector=DateVector(Y,M,D,H,MN,S);
          % Shifting all the data (First signal starts at 0-th second):
          if(isempty(shift))
            shift=dateVector;
          end
          obj.signalsAll{i,2}=dateVector.date2sec(shift);
        else
          if (i>1)
            obj.signalsAll{i,2}=obj.signalsAll{i-1,2}+obj.signalsAll{i-1,3};
          end
        end
        if (~isempty(s.records))
          obj.signalsAll{i,3}=s.records;
        else
          obj.signalsAll{i,3}=s.eegLen/s.eegFs;
        end
        [obj.signalsAll{i,4},~]=size(s.seizureTimings);       
        % Check signal for good channels:
        for k=1:s.chNum
          if (~strcmp(s.label{k},'') && ~strcmp(s.label{k},'ECG') && ...
              s.digitalMax(k)>0 && s.digitalMin(k)<0)
            goodChannelIdxBuf=[goodChannelIdxBuf,k];
          end
        end
        obj.signalsAll{i,5}=goodChannelIdxBuf;
        % Calculating minimum channels number
        chNum=numel(goodChannelIdxBuf);
        if (chNum<obj.minChNum && chNum>0)
          obj.minChNum=chNum;
        end
      end   
    end
    
    function []=save(obj,location)
      save([location,'/PatientData.mat'],'obj');
    end
  end
end