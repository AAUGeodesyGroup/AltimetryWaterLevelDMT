function MyFigure = PlotMyFigure(WindowName,PlotData,PlotTitle,PlotXlabel,PlotYlabel,DataStyle)
    
    if ~isempty(fieldnames(PlotData))
        MyFigure = figure('Name',WindowName);
        for i=1:length(PlotData)
            plot(PlotData(i).Time,PlotData(i).Id,DataStyle{:}); hold on;
        end
        title(PlotTitle)
        xlabel(PlotXlabel)
        ylabel(PlotYlabel)
    else
        disp([WindowName 'is not plotted, because struct is empty.']);
        MyFigure = [];
    end
end

