classdef CumMomentAnalysisWindow < AnalysisWindow
    properties
    end
    methods
        function obj=CumMomentAnalysisWindow(ax)
            obj@AnalysisWindow(ax);
        end
        
        function prepare_axes(obj)
            % moment release axes
            %momentax=axes(f,'units','pixels','Position',[1025 100 225 250]);
            obj.ax.Tag = 'dvMoment';
            obj.ax.Title.String='Cum Moment Release';
            obj.ax.XLabel.String='time';
            obj.ax.YLabel.String='Cumulative Moment [nm]'; %units as per calc_moment
        end
        
        function [x,y]=calculate(~,catalog)
            %maxstep=ceil(max(catalog.Depth)./obj.depthsteps) .* obj.depthsteps;
            %minstep=floor(min(catalog.Depth)./obj.depthsteps) .* obj.depthsteps;
            %bins=minstep : obj.depthsteps : maxstep;
            x=catalog.Date;
            [~, y, ~] = calc_moment(catalog);
        end
        
    end
end