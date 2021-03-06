function [x, y, mouse_points_overlay] = select_polygon(ax)
    % select_polygon plots a polygon interactively using the mouse on selected axis
    % usage [ x, y, mask, mouse_overlay] = select_polygon(ax)
    %
    % returns [x, y, lineobject]
    %
    % lineobject has tag 'mouse_points_overlay'
    report_this_filefun();
    axes(ax);
    holdstate=ishold(ax);
    set(gca,'NextPlot','add')
    mouse_points_overlay = plot(ax,0,0,'o-k',...
        'MarkerSize',5,'LineWidth',2.0,...
        'Tag','mouse_points_overlay',...
        'DisplayName','polygon outline');
    
    hold(ax,tf2onoff(holdstate));
    
    %msg.infodisp( (other key/button) last point', 'Define Polygon for Grid: (LEFT button): add point);
    
    but=1;
    x=[]; 
    y=[];
    
    while but == 1 || but == 112
        [xi,yi,but] = ginput(1);
        x = [x; xi];
        y = [y; yi];
        mouse_points_overlay.XData=x;
        mouse_points_overlay.YData=y;
    end
    
    x = [x ; x(1)];
    y = [y ; y(1)];      %  closes polygon
    mouse_points_overlay.XData=x;
    mouse_points_overlay.YData=y;
    mouse_points_overlay.LineStyle='-';
    mouse_points_overlay.Color='k';
    mouse_points_overlay.MarkerEdgeColor='k';
end
