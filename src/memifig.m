function memifig() 
    % turned into function by Celso G Reyes 2017
    
    ZG=ZmapGlobal.Data; % used by get_zmap_globals
    report_this_filefun();
    
    
    %input window
    %
    %default parameters
    
    %make a color map
    % Find out if figure already exists
    %
    mifmap=findobj('Type','Figure','-and','Name','Misfit-Map 2');
    
    % Set up the Seismicity Map window Enviroment
    %
    if isempty(mifmap)
        mifmap = figure_w_normalized_uicontrolunits( ...
            'Name','Misfit-Map 2',...
            'NumberTitle','off', ...
            'NextPlot','replace', ...
            'backingstore','on',...
            'Visible','off', ...
            'Position',[ 600 400 500 350]);
        % make menu bar
        
        
        
        set(gca,'NextPlot','add')
    end
    figure(mifmap);
    delete(findobj(mifmap,'Type','axes'));
    
    set(gca,'visible','off','FontSize',ZmapGlobal.Data.fontsz.s,'FontWeight','bold',...
        'FontWeight','bold','LineWidth',1.5,...
        'Box','on','SortMethod','childorder')
    
    %minimum and maximum of normlap2 for automatic scaling
    ZG.maxc = max(normlap2);
    ZG.minc = min(normlap2);
    
    %construct a matrix for the color plot
    normlap1=ones(length(tmpgri(:,1)),1);
    normlap2=nan(length(tmpgri(:,1)),1)
    normlap3=nan(length(tmpgri(:,1)),1)
    normlap1(ll)=me1;
    normlap2(ll)=normlap1(ll);
    normlap1(ll)=va1;
    normlap3(ll)=normlap1(ll);
    
    normlap2=reshape(normlap2,length(yvect),length(xvect));
    normlap3=reshape(normlap3,length(yvect),length(xvect));
    
    %plot color image
    orient tall
    gx = xvect; gy = yvect;
    
    set(gca,'NextPlot','add')
    pco1 = pcolor(xvect,yvect,normlap2);
    shading interp
    j = jet(64);
    j = j(64:-1:1,:);
    colormap(j);
    axis([ min(gx) max(gx) min(gy) max(gy)])
    axis image
    
    set(gca,'NextPlot','add')
    h5 = colorbar('vert');
    set(h5,'Pos',[0.82 0.46 0.03 0.10],...
        'FontSize',2)
    
    
    
    if exist('maex', 'var')
        set(gca,'NextPlot','add')
        pl = plot(maex,-maey,'*w');
        set(pl,'MarkerSize',6,'LineWidth',1)
    end
    
    %overlay
    title('Mean of the Misfit','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.s)
    xlabel('Distance in [km]','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.s)
    ylabel('Depth in [km]','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.s)
    
    set(gca,'visible','on','FontSize',ZmapGlobal.Data.fontsz.s,'FontWeight','bold',...
        'FontWeight','bold','LineWidth',1.5,...
        'Box','on','TickDir','out')
end
