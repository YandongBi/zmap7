function synsig3() 
    % Calculates magnitude signatures, yet another version, this time
    % Computes a synthetic signature, using corrections found by BVALFIT
    %
    %                                  R. Zuniga IGF-UNAM/GI-UAF  7/94
    %uicontrol('Units','normal','Position',[.90 .10 .10 %.10],'String','Wait... ')
    % turned into function by Celso G Reyes 2017
    
    ZG=ZmapGlobal.Data; % used by get_zmap_globals
    
    report_this_filefun();
    
    xt_backg = t1p(1):days(ZG.bin_dur):t2p(1);
    xt_foreg = t3p(1):days(ZG.bin_dur):t4p(1);
    tbckg = length(t1p(1):days(ZG.bin_dur):t2p(1));
    tforg = length(t3p(1):days(ZG.bin_dur):t4p(1));
    magsis = min(ZG.newcat.Magnitude)
    magis = min(ZG.newcat.Magnitude)
    
    pause(0.1)
    mmin = min(ZG.newcat.Magnitude);
    mmin = mmin*10 ;
    mmin = floor(mmin);
    mmin = mmin/10 ;       %  round towards zero to 0.1
    mmax = maxmag;
    mmax = maxmag*10 ;
    mmax = ceil(mmax);
    mmax = mmax/10 ;       %  round towards inf to 0.1
    masi = zeros(size(mmin:0.1:mmax));
    masi2 = masi;
    %
    %                     loop over all magnitude bands
    %
    wai = waitbar(0,'Please wait...');
    set(wai,'Color',[0.8 0.8 0.8],'NumberTitle','off','Name','Percent completed');
    nmag = length(mmin:0.1:mmax);
    ind = 0;
    
    for i = mmin:0.1:mmax
        waitbar(ind/length(masi));
        ind = ind+1;
        % disp(i)
        % and below
        l = backg(:,6) <= i;
        junk = backg(l,:);
        if ~isempty(junk),  % junk1
            [cum_mag, xt_backg] = hist(junk(:,3),xt_backg);      %    background
            l = foreg(:,6) <= i;
            junk = foreg(l,:);
            if ~isempty(junk), % junk2
                [cum_mag2, xt_foreg] = hist(junk(:,3),xt_foreg);     %    foreground
                %  l =  backg_new(:,6) <= i;
                %junk = backg_new(l,:);
                if ~isempty(junk), % junk3
                    l =  junk(:,6) <= magis;    % find out events below cut off for rate factor
                    if length(junk(l,:)) > 0   % junk4
                        [cum_junk, xt_backg] = hist(junk(l,3),xt_backg);
                    end  % if junk4
                    mean1 = mean(cum_mag(1:tbckg));
                    mean2 = mean(cum_mag2(1:tforg));
                    var1 = cov(cum_mag(1:tbckg));
                    var2 = cov(cum_mag2(1:tforg));
                    if sqrt(var1/tbckg+var2/tforg) > 0
                        masi(ind) = (mean1 - mean2)/(sqrt(var1/tbckg+var2/tforg));  end
                end   % if junk1
            end   % if junk2
        end   % if junk3
        
        % and above
        %
        l = backg(:,6) >= i;
        junk = backg(l,:);
        if ~isempty(junk)
            [cum_mag, xtbackg] = hist(junk(:,3),xt_backg);       %    background
            l = foreg(:,6) >= i;                                 %    foreground
            junk = foreg(l,:);
            if ~isempty(junk)
                [cum_mag2, xt_foreg] = hist(junk(:,3),xt_foreg);
                %l =  backg_new(:,6) >= i;
                % junk = backg_new(l,:);
                if ~isempty(junk)
                    if i <= magis
                        l =  junk(:,6) <= magis;    % find out events below cut off for rate factor
                        if length(junk(l,:)) > 0
                            [cum_junk, xt_backg] = hist(junk(l,3),xt_backg);
                        end  %  if junk4
                    end  % if i < magis
                    
                    mean1 = mean(cum_mag(1:tbckg));
                    mean2 = mean(cum_mag2(1:tforg));
                    if mean1 | mean2 > 0
                        var1 = cov(cum_mag(1:tbckg));
                        var2 = cov(cum_mag2(1:tforg));
                        %  masi2 = [masi2  (mean1 - mean2)/(sqrt(var1/tbckg+var2/tforg))];
                        masi2(ind) = (mean1 - mean2)/(sqrt(var1/tbckg+var2/tforg));
                    end   % if mean1
                    
                end   % if junk
            end   % if junk2
        end   % if junk3
        %mag(i) = i;
        cum_mag = []; cum_mag2 = [];  cum_syn = []; cum_junk = [];
        
    end  %    for i
    close(wai)
    if length(masi) > length(masi2), masi2(length(masi)) = 0; end
    
    % plot Magnitude Signature
    %
    figure(bvfig);
    rect = [0.20, 0.07, 0.35, 0.25];
    axes('position',rect)
    min1 = min([masi masi2 ]);
    max1 = max([masi masi2 ] );
    axis([mmin mmax min1 max1 ]);
    ploma1 = plot(mmin:0.1:mmax,masi,'om');
    set(gca,'NextPlot','add');
    set(ploma1,'MarkerSize',6)
    ploma1 = plot(mmin:0.1:mmax,masi,'-m');
    set(gca,'NextPlot','add')
    mag1 = gca;
    %set(mag1,'TickLength',[0 0])
    nu = [0.5 0 ; 3.0 0 ];
    plot(nu(:,1),nu(:,2),'-.g')
    xlabel('Mag and below','FontSize',ZmapGlobal.Data.fontsz.s,'FontWeight','bold')
    ylabel('z-value','FontSize',ZmapGlobal.Data.fontsz.s,'FontWeight','bold')
    
    set(gca,'box','on',...
        'SortMethod','childorder','TickDir','out','FontWeight',...
        'bold','FontSize',ZmapGlobal.Data.fontsz.s,'Linewidth',1.2)
    %set(gca,'Color',color_bg)
    
    
    axis([mmin mmax min1 max1 ]);
    rect = [0.20+0.35   0.07 0.35 0.25];
    axes('position',rect)
    axis([0.5 mmax  min1 max1 ])
    ploma2 = plot(mmin:0.1:mmax,masi2,'om');
    set(gca,'NextPlot','add');
    ploma2 = plot(mmin:0.1:mmax,masi2,'-m');
    set(ploma2,'MarkerSize',6)
    set(gca,'NextPlot','add')
    axis([mmin mmax min1 max1 ]);
    %ploma3 = plot(mag(5:mmax*10)/10,masi2(5:mmax*10),'y')
    %set(ploma3,'LineWidth',3)
    axis([mmin mmax min1 max1 ]);
    h = gca;
    set(h,'YTick',[-10 10])
    xlabel('Mag and above','FontSize',ZmapGlobal.Data.fontsz.s,'FontWeight','bold')
    nu = [0.5 0 ; 3.0 0 ];
    plot(nu(:,1),nu(:,2),'-.g')
    
    uicontrol('Units','normal',...
        'Position',[.0 .55 .08 0.08],...
        'String','Save  ', 'callback',@callbackfun_001)
    
    set(gca,'box','on',...
        'SortMethod','childorder','TickDir','out','FontWeight',...
        'bold','FontSize',ZmapGlobal.Data.fontsz.s,'Linewidth',1.2)
    %set(gca,'Color',color_bg)
    
    watchoff
    watchoff(mess)
    %clear junk cum_junk cum_syn cum_mag  cum_mag2 masi masi2 masi_syn masi_syn2 %xt_backg xt_foreg l ind i mean1 mean2 means var1 var2 vars ploma2 ploams2 %ploma1 plomas1 min1 max1 nu
    
    function callbackfun_001(mysrc,myevt)

        callback_tracker(mysrc,myevt,mfilename('fullpath'));
        save_ma;
    end
    
end
