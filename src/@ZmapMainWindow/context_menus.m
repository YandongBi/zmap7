function c=context_menus(obj, tag, createmode, varargin)
    % c=context_menus(obj, tag, createmode, varargin)
    % handles context menus, which avoids creating context menus
    % over and over. Contexts are attached to the figure, so deleting
    % objects that they are attached to will not delete the context menus.
    %
    % context menus can be reused.
    existing_contexts = findobj(gcf,'Type','uicontextmenu');
    c = findobj(existing_contests, 'Tag',tag);
    
    switch method
        case 'overwrite'
            % delete existing context first, then recreate it and return handle
        case 'reuse'
            % if a context exists, just return a handle to it
    end
    switch tag
        
        
    end
end


%% callbacks
function cb_chwidth(obj, xsec)
    % change width of a cross-section
    prompt={'Enter the New Width:'};
    name='Cross Section Width';
    numlines=1;
    defaultanswer={num2str(xsec.width_km)};
    answer=inputdlg(prompt,name,numlines,defaultanswer);
    if ~isempty(answer)
        xsec=xsec.change_width(str2double(answer),axm);
        obj.xsec_add(mytitle, xsec);
    end
    xsec.plot_events_along_strike(ax,obj.xscats(mytitle),true);
    ax.Title=[];
    obj.replot_all('CatalogUnchanged');
end

function cb_chcolorb(obj, xsec)
    color=uisetcolor(xsec.color,['Color for ' xsec.startlabel '-' xsec.endlabel]);
    xsec=xsec.change_color(color,axm);
    mytab.ForegroundColor = xsec.color;
    obj.xsections(mytitle)=xsec;
    obj.replot_all('CatalogUnchanged');
end

function cb_cropToXS(obj, xsec)
    oldshape=copy(obj.shape)
    obj.shape=ShapePolygon('polygon',[xsec.polylons(:), xsec.polylats(:)]);
    obj.shapeChangedFcn(oldshape, obj.shape);
    obj.replot_all();
end

function deltab(s,v,obj, xsec)
    % cross section "knows" how to delete itself from the main map. 
    xsec.DeleteFcn();
    xsec.DeleteFcn='';
    
    delete(mytab);
    obj.xsec_remove(mytitle);
    obj.replot_all('CatalogUnchanged');
end