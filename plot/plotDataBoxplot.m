function f=plotDataBoxplot(data,xLabels,titleStr)
  f=figure('Visible','Off');
  set(f,'PaperPositionMode','auto');
  set(f,'Position',[0 100 1350 400]);
  set(f,'DefaultAxesLooseInset',[0,0.1,0,0]);
  boxplot(data,xLabels);
  set(gca,'XTick',1:numel(xLabels),'XTickLabel',xLabels);
  XTickLabel = get(gca,'XTickLabel');
  set(gca,'XTickLabel',' ');
  hxLabel = get(gca,'XLabel');
  set(hxLabel,'Units','data');
  xLabelPosition=get(hxLabel,'Position');
  y=xLabelPosition(2);
  XTick=get(gca,'XTick');
  y=repmat(y,length(XTick),1);
  fs=get(gca,'fontsize');
  hText=text(XTick, y, XTickLabel,'fontsize',fs);
  set(hText,'Rotation',90,'HorizontalAlignment','right')
  ylabel('MI');
  title(titleStr);
  grid on;
end