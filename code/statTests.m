function f=statTests(data,xLabels)
  testLabels={'kstest','kstest2','ttest2','ranksum'};
  testMi_kstest=zeros(length(xLabels),length(xLabels),3)+0.5;
  testMi_kstest2=zeros(length(xLabels),length(xLabels),3)+0.5;
  testMi_ttest2=zeros(length(xLabels),length(xLabels),3)+0.5;
  testMi_ranksum=zeros(length(xLabels),length(xLabels),3)+0.5;
  
  for rowIdx=1:length(xLabels)
    for colIdx=1:length(xLabels)
      if (data(1,rowIdx)~=0 && data(1,colIdx)~=0)
        if (rowIdx==colIdx)
          testMi_kstest(rowIdx,colIdx,1:3)=kstest(data(:,rowIdx));
        end
        testMi_kstest2(rowIdx,colIdx,1:3)=kstest2(data(:,rowIdx),data(:,colIdx));
        testMi_ttest2(rowIdx,colIdx,1:3)=ttest2(data(:,rowIdx),data(:,colIdx));
        [~,testMi_ranksum(rowIdx,colIdx,1:3)]=ranksum(data(:,rowIdx),data(:,colIdx));
      end
    end
  end

  testMi_kstest=replaceNans(testMi_kstest);
  testMi_kstest2=replaceNans(testMi_kstest2);
  testMi_ttest2=replaceNans(testMi_ttest2);
  testMi_ranksum=replaceNans(testMi_ranksum);
  
  f=figure;
  set(f,'PaperPositionMode','auto');
  set(f,'Position',[0 100 700 700]);
  set(f,'DefaultAxesLooseInset',[0,0.1,0,0]);
  
  subplot(2,2,1);
  imagesc(testMi_kstest);
  set(gca,'YTick',1:numel(xLabels),'XTick',1:numel(xLabels), ...
    'XTickLabel',xLabels,'YTickLabel',xLabels);
  title({testLabels{1},'1 - white, 0 - black, NaN - red.'});     
  XTickLabel = get(gca,'XTickLabel');
  set(gca,'XTickLabel',' ');
  hxLabel = get(gca,'XLabel');
  set(hxLabel,'Units','data');
  xLabelPosition = get(hxLabel,'Position');
  y = xLabelPosition(2)-0.7;
  XTick = get(gca,'XTick');
  y=repmat(y,length(XTick),1);
  fs = get(gca,'fontsize');
  hText = text(XTick, y, XTickLabel,'fontsize',fs);
  set(hText,'Rotation',90,'HorizontalAlignment','right');
  
  subplot(2,2,2);
  imagesc(testMi_kstest2);
  set(gca,'YTick',1:numel(xLabels),'XTick',1:numel(xLabels), ...
    'XTickLabel',xLabels,'YTickLabel',xLabels);
  title({testLabels{2},'1 - white, 0 - black, NaN - red.'});     
  XTickLabel = get(gca,'XTickLabel');
  set(gca,'XTickLabel',' ');
  hxLabel = get(gca,'XLabel');
  set(hxLabel,'Units','data');
  xLabelPosition = get(hxLabel,'Position');
  y = xLabelPosition(2)-0.7;
  XTick = get(gca,'XTick');
  y=repmat(y,length(XTick),1);
  fs = get(gca,'fontsize');
  hText = text(XTick, y, XTickLabel,'fontsize',fs);
  set(hText,'Rotation',90,'HorizontalAlignment','right');
  
  subplot(2,2,3);
  imagesc(testMi_ttest2);
  set(gca,'YTick',1:numel(xLabels),'XTick',1:numel(xLabels), ...
    'XTickLabel',xLabels,'YTickLabel',xLabels);
  title({testLabels{3},'1 - white, 0 - black, NaN - red.'});      
  XTickLabel = get(gca,'XTickLabel');
  set(gca,'XTickLabel',' ');
  hxLabel = get(gca,'XLabel');
  set(hxLabel,'Units','data');
  xLabelPosition = get(hxLabel,'Position');
  y = xLabelPosition(2)-0.7;
  XTick = get(gca,'XTick');
  y=repmat(y,length(XTick),1);
  fs = get(gca,'fontsize');
  hText = text(XTick, y, XTickLabel,'fontsize',fs);
  set(hText,'Rotation',90,'HorizontalAlignment','right');
  
  subplot(2,2,4);
  imagesc(testMi_ranksum);
  set(gca,'YTick',1:numel(xLabels),'XTick',1:numel(xLabels), ...
    'XTickLabel',xLabels,'YTickLabel',xLabels);
  title({testLabels{4},'1 - white, 0 - black, NaN - red.'});     
  XTickLabel = get(gca,'XTickLabel');
  set(gca,'XTickLabel',' ');
  hxLabel = get(gca,'XLabel');
  set(hxLabel,'Units','data');
  xLabelPosition = get(hxLabel,'Position');
  y = xLabelPosition(2)-0.7;
  XTick = get(gca,'XTick');
  y=repmat(y,length(XTick),1);
  fs = get(gca,'fontsize');
  hText = text(XTick, y, XTickLabel,'fontsize',fs);
  set(hText,'Rotation',90,'HorizontalAlignment','right');
end

function data=replaceNans(data)
  redColor=[1,0,0];
  [idxM,idxN]=find(isnan(data(:,:,1)));
  for tmp=1:numel(idxN)
    data(idxM(tmp),idxN(tmp),:)=redColor;
  end
end