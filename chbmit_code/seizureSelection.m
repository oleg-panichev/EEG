% seizure signal quality analysis

% 12.07.2014 

clc; 
close all;
clear all;
%%%%%%%


%%%%%%%%%%%%%%%%%%%%
%%%% data from Oleg
folder_path='D:\Studying\ÑÈÃÍÀËÛ_\chbmit_mat';
folder_path='F:\chbmit_mat';
folder_path='eeg_data/chbmit_mat/';


items = dir(folder_path);
dirs = {items([items.isdir]).name};
dirs=dirs(3:end); % names of all folders in the main folder
N=5;% number of channel to extract sampling rate from

% ---
recordsFileName='RECORDS-WITH-SEIZURES'; % File with list of signals
file=fopen([folder_path,'\',recordsFileName]);
recordsList=textscan(file,'%s');
recordsNum=numel(recordsList{1,1});
disp(['Records number in list ',recordsFileName,': ',num2str(recordsNum)]);
if (recordsNum>0)
  sigIdx=1:recordsNum;
end
disp(['Number of signals to proccess: ',num2str(numel(sigIdx))]);

tic
files=recordsList{1,1}(18:end)';
for fname=files
    disp(strcat('Looking inside the file f=',fname));
    load([folder_path,'\',char(fname)]);%%%%% open a particular file
    if ~isempty(seizureTimings)% if there is at least one seizure episode, rate it
        strcat('Number of seizures in the file, S=',num2str(size(seizureTimings,1)))
        good_seizures_numbers=[];
        average_seizures_numbers=[];
        % plotting the examples of signals with seizure to evaluate it visually
        for seiz_numb=1:size(seizureTimings,1) 
            range_seizure=seizureTimings(seiz_numb,1)*samples(N):...
                seizureTimings(seiz_numb,2)*samples(N);% samples for seizure marker
            markers=zeros(1,size(record,2));
            markers(range_seizure)=1;               
            channels_to_plot=[2 7 14 20];
            figure
            hs(1)=subplot(4,1,1);
            plot(record(channels_to_plot(1),:)); hold on;
            plot(markers*.2e3,'r','linewidth',2)
            hs(2)=subplot(4,1,2);
            plot(record(channels_to_plot(2),:)); hold on;
            plot(markers*.2e3,'r','linewidth',2)
            hs(3)=subplot(4,1,3);
            plot(record(channels_to_plot(3),:)); hold on;
            plot(markers*.2e3,'r','linewidth',2)
            hs(4)=subplot(4,1,4);
            plot(record(channels_to_plot(4),:)); hold on;
            plot(markers*.2e3,'r','linewidth',2)
            linkaxes(hs,'x');

            flag=1;% evaluation
            while flag==1
                d=input('Good(g) or bad(b) or average(a)? Answer=','s');
                if strcmp(d,'g')
                    disp('Found good one!' )
                    good_seizures_numbers=[good_seizures_numbers, seiz_numb];
                    flag=0;
                elseif strcmp(d,'b')
                    disp('Next time!')
                    flag=0;
                elseif strcmp(d,'a')
                    disp('Found average one!' )
                    average_seizures_numbers=[average_seizures_numbers, seiz_numb];
                    flag=0;
                else
                    disp('Try again!')
                    flag=1;
                end
            end% rate the seizure quality
        end
        average_seizures_numbers %#ok<NOPTS>
        good_seizures_numbers %#ok
        % saving arrays with rated seizures
            save([folder_path,'\',char(fname)],...
                'average_seizures_numbers','good_seizures_numbers',...
                '-append');
         close all;
    else
        % saving empty arrays
        average_seizures_numbers=[]
        good_seizures_numbers=[]
            save([folder_path,'\',char(fname)],...
                'average_seizures_numbers','good_seizures_numbers',...
                '-append');
        close all;
    end
end
t=toc


