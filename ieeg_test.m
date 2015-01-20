sname = 'I001_P034_D01';
% I002_P025_D02
% I002_P024_D04 - коротенький
session = IEEGSession(sname,'Oleg Panichev',...
  'D:\Google\PhD\key\Ole_ieeglogin.bin')
session.data

session.data.viewer([1 50000],[1:10])

sz = [579016087 47];
fs = 5000;
path = 'D:\eeg_db\ieeg_mat_db\';
mkdir([path,sname]);

fr_len = fs*60*1;

part_idx = 1;

fr_start_idx = 1;
fr_end_idx = fr_len;
if fr_end_idx > sz(1)
  fr_end_idx = sz(1);
end
while fr_end_idx <= sz(1) && fr_start_idx < sz(1)
  disp(num2str(part_idx));
  data = session.data.getvalues(fr_start_idx:fr_end_idx, 1:sz(2));
  fr_start_idx = fr_end_idx+1;
  fr_end_idx = fr_end_idx+fr_len;
  if fr_end_idx > sz(1)
    fr_end_idx = sz(1);
  end
  
  save([path,sname,'\ieeg_',num2str(part_idx),'.mat'],'data');
  part_idx = part_idx+1;
end
  
anns = session.data.annLayer.getEvents(0);
save([path,sname,'ieeg_anns.mat'],anns);

% openDataSet(session,'I001_P002_D01');
