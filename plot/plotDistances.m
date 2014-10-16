function f=plotDistances(euDist,brcudiss,chsqDist,cbDist,xLabels,titleStr)
  f=figure;
  subplot(2,2,1);
  set(f,'PaperPositionMode','auto');
  set(f,'Position',[0 100 700 600]);
  set(f,'DefaultAxesLooseInset',[0,0.1,0,0]);
  imagesc(euDist);
  set(gca,'YTick',1:numel(xLabels),'XTick',1:numel(xLabels), ...
    'XTickLabel',xLabels,'YTickLabel',xLabels);
  title({'Euclidian Distance',titleStr});     
  XTickLabel = get(gca,'XTickLabel');
  set(gca,'XTickLabel',' ');
  hxLabel = get(gca,'XLabel');
  set(hxLabel,'Units','data');
  xLabelPosition=get(hxLabel,'Position');
  y=xLabelPosition(2)-0.5;
  XTick=get(gca,'XTick');
  y=repmat(y,length(XTick),1);
  fs=get(gca,'fontsize');
  hText=text(XTick, y, XTickLabel,'fontsize',fs);
  set(hText,'Rotation',90,'HorizontalAlignment','right');
  colorbar;
  
  subplot(2,2,2);
  imagesc(brcudiss);
  set(gca,'YTick',1:numel(xLabels),'XTick',1:numel(xLabels), ...
    'XTickLabel',xLabels,'YTickLabel',xLabels);
  title({'Bray-Curtis dissimilarity, %',titleStr});       
  XTickLabel = get(gca,'XTickLabel');
  set(gca,'XTickLabel',' ');
  hxLabel = get(gca,'XLabel');
  set(hxLabel,'Units','data');
  xLabelPosition=get(hxLabel,'Position');
  y=xLabelPosition(2)-0.5;
  XTick=get(gca,'XTick');
  y=repmat(y,length(XTick),1);
  fs=get(gca,'fontsize');
  hText=text(XTick, y, XTickLabel,'fontsize',fs);
  set(hText,'Rotation',90,'HorizontalAlignment','right');
  colorbar;
  
  subplot(2,2,3);
  imagesc(chsqDist);
  set(gca,'YTick',1:numel(xLabels),'XTick',1:numel(xLabels), ...
    'XTickLabel',xLabels,'YTickLabel',xLabels);
  title({'Chi-square distance, %',titleStr});       
  XTickLabel = get(gca,'XTickLabel');
  set(gca,'XTickLabel',' ');
  hxLabel = get(gca,'XLabel');
  set(hxLabel,'Units','data');
  xLabelPosition=get(hxLabel,'Position');
  y=xLabelPosition(2)-0.5;
  XTick=get(gca,'XTick');
  y=repmat(y,length(XTick),1);
  fs=get(gca,'fontsize');
  hText=text(XTick, y, XTickLabel,'fontsize',fs);
  set(hText,'Rotation',90,'HorizontalAlignment','right');
  colorbar;
  
    
  subplot(2,2,4);
  imagesc(cbDist);
  set(gca,'YTick',1:numel(xLabels),'XTick',1:numel(xLabels), ...
    'XTickLabel',xLabels,'YTickLabel',xLabels);
  title({'City blocks (L1) distance',titleStr});       
  XTickLabel = get(gca,'XTickLabel');
  set(gca,'XTickLabel',' ');
  hxLabel = get(gca,'XLabel');
  set(hxLabel,'Units','data');
  xLabelPosition=get(hxLabel,'Position');
  y=xLabelPosition(2)-0.5;
  XTick=get(gca,'XTick');
  y=repmat(y,length(XTick),1);
  fs=get(gca,'fontsize');
  hText=text(XTick, y, XTickLabel,'fontsize',fs);
  set(hText,'Rotation',90,'HorizontalAlignment','right');
  colorbar;
end