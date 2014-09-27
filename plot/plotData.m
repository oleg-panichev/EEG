function f=plotData(data,xLabels,yLabels,titleStr)
  f=figure;
  set(f,'PaperPositionMode','auto');
  set(f,'Position',[0 100 1350 600]);
  set(f,'DefaultAxesLooseInset',[0,0.1,0,0]);
  imagesc(data);
  set(gca,'YTick',1:numel(yLabels),'XTick',1:numel(xLabels), ...
    'XTickLabel',xLabels,'YTickLabel',yLabels);
  title(titleStr);     
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