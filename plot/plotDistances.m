function f=plotDistances(R,shiftLabels,titleStr)
  f=figure;
  set(f,'PaperPositionMode','auto');
  set(f,'Position',[0 100 600 600]);
  set(f,'DefaultAxesLooseInset',[0,0.1,0,0]);
  imagesc(R);
  set(gca,'YTick',1:numel(shiftLabels),'XTick',1:numel(shiftLabels), ...
    'XTickLabel',shiftLabels,'YTickLabel',shiftLabels);
  title(titleStr);     
  XTickLabel = get(gca,'XTickLabel');
  set(gca,'XTickLabel',' ');
  hxLabel = get(gca,'XLabel');
  set(hxLabel,'Units','data');
  xLabelPosition = get(hxLabel,'Position');
  y = xLabelPosition(2)-0.5;
  XTick = get(gca,'XTick');
  y=repmat(y,length(XTick),1);
  fs = get(gca,'fontsize');
  hText = text(XTick, y, XTickLabel,'fontsize',fs);
  set(hText,'Rotation',90,'HorizontalAlignment','right');
  colorbar;
end