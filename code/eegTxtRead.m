function [data, header]=eegTxtRead(fname)
  fid = fopen(fname, 'r', 'n', 'windows-1251');

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
  fclose(fid);
end