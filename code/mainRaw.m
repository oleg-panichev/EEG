clc, clear all, close all;
% edfFile = 'C:\Users\misha\Documents\MATLAB\signals\raw_absance\3.edf';
txtFile = '/home/misha/Documents/MATLAB/1.txt';
%% �����, �:�:�� Fp1 Fp2 F7 F3 Fz F4 F8 T3 C3 Cz C4 T4 T5 P3 Pz P4 T6 O1 O2 ECG ������� 22

% %% read edf
% [hdr, record] = edfread(edfFile);
% fprintf('Loaded 3.edf');
% Fs = 1e3; 
% 
% 
% N = size(record,2);
% nChannels = size(record,1);
% t = 0 :1/Fs: (N-1)/Fs;        
% f = 0 :Fs/N: Fs-Fs/N; 
% 
% fprintf(', Fs=%dHz\n',Fs);

%% read txt
fid = fopen(txtFile, 'r', 'n', 'windows-1251');

format = '%d:%d:%d';
for i=1:21
   format = strcat(format,' %f'); 
end


header = textscan(fid,'%s',1,'delimiter','\n'); 
i=1;
tic
while (~feof(fid)) 
    text = textscan(fid,'%s',1,'delimiter','\n'); 
    if(~isempty(text{1}))
        text = strrep(text{1}{1}, ',', '.');
        data(:,i) = sscanf(text,format);
        i=i+1;
    end
end
toc

% ecg = data(23,:);
marks = data(24,:);
% record = [record; marks];
