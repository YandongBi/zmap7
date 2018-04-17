function cumplot(obj, tabgrouptag)
    % Cumulative Event Plot
    
    Tags.xs = 'CumPlot xs contextmenu';
    Tags.bg = 'CumPlot bg contextmenu';
    Tags.line = 'CumPlot line contextmenu';
    
    
    myTab = findOrCreateTab(obj.fig, tabgrouptag, 'cumplot');
    
    delete(myTab.Children);
    
    ax=axes(myTab);
    ax.TickDir='out';
    
    cln=findobj(gcf,'Tag',Tags.line);
    if isempty(cln)
        cln=uicontextmenu('tag',Tags.line);
        uimenu(cln,'Label','start here',Futures.MenuSelectedFcn,@(~,~)obj.cb_starthere(ax));
        uimenu(cln,'Label','end here',Futures.MenuSelectedFcn,@(~,~)obj.cb_endhere(ax));
        uimenu(cln, 'Label', 'trim to largest event',Futures.MenuSelectedFcn,@obj.cb_trim_to_largest);
        uimenu(cln,'Label','Open in new window',Futures.MenuSelectedFcn,@(~,~)obj.cb_timeplot());
    end
    
    % plot the main catalog
    p=line(ax,obj.catalog.Date,1:obj.catalog.Count,'linewidth',2.5,'DisplayName','catalog',...
        'Tag','catalog','color','k');
    p.UIContextMenu=cln;
    grid(ax,'on');
    
    
    % plot cross sections, too
    cxs=findobj(gcf,'Tag',Tags.xs);
    if isempty(cxs)
        cxs=uicontextmenu('tag',Tags.xs);
        uimenu(cxs,'Label','Open in new window',Futures.MenuSelectedFcn,@cb_xstimeplot);
    end
    
    % remove any cross-sections that are no longer exist
    k = obj.xsections.keys;
    m=findobj(ax,'Type','line','-and','-not','Tag','catalog'); % plotted cross sections
    if ~isempty(m)
        notrep = ~ismember({m.DisplayName},k);
        if any(notrep)
            delete(m(notrep));
        end
    end
        
    obj.plot_xsections(@xsplotter, 'Xsection cumplot');
    
    yl=ylabel(ax,'Cummulative Number of events');
    yl.UIContextMenu=obj.sharedContextMenus.LogLinearYScale;
    
    xl=xlabel(ax,'Time');
    %xl.UIContextMenu=obj.sharedContextMenus.LogLinearXScale;
    
    
    cbg=findobj(gcf,'Tag',Tags.bg);
    
    if isempty(cbg)
        cbg=uicontextmenu('Tag',Tags.bg);
        addLegendToggleContextMenuItem(cbg,'bottom','above');
        uimenu(cbg,'Label','Open in new window',Futures.MenuSelectedFcn,@(~,~)obj.cb_timeplot());
        ax.UIContextMenu=cbg;
    end
    
    
    function h = xsplotter(xs, xscat)
        h=findobj(ax,'DisplayName',xs.name,'-and','Type','line');
        if isempty(h)
            h=line(ax,xscat.Date, 1:xscat.Count,...
                'linewidth',1.5,'DisplayName',xs.name,'Color',xs.color,...
                'Tag',['Xsection cumplot ' xs.name]);
            h.UIContextMenu = cxs;
        else
            if ~isequal(xscat.Date, h.XData)
                set(h,'XData',xscat.Date, 'YData', 1:xscat.Count,'linewidth',1.5,'Color',xs.color);
            else
                set(h,'Color',xs.color);
            end
        end
    end
    
    function cb_xstimeplot(~,~)
        % CB_XSTIMEPLOT shows the TIMEPLOT for the currently selected cross-section
        myName = get(gco,'DisplayName');
        xs = obj.xsections(myName);
        ZG=ZmapGlobal.Data;
        ZG.newt2=obj.catalog.subset(xs.inside(obj.catalog));
        ZG.newt2.Name=sprintf('Events within %g km of %s',xs.name);
        timeplot();
    end
end
