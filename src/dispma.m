function dispma() 
    % dispma calculates Magnitude Signatures, operates on catalogue ZG.newcat
    %
    % turned into function by Celso G Reyes 2017
    
    ZG=ZmapGlobal.Data; % used by get_zmap_globals
    
    report_this_filefun();
    
    myfig=figure();
    set(myfig,'Units','normalized','NumberTitle','off','Name','b-value curves');
    set(myfig,'pos',[ 0.2  0.8 0.5 0.8])
    if isempty(ZG.newcat)
        ZG.newcat = ZG.primeCatalog ;
    end
    maxmag = max(ZG.newcat.Magnitude);
    [t0b, teb] = ZG.newcat.DateRange() ;
    n = ZG.newcat.Count;
    tdiff = round(teb - t0b);
    
    
    % number of mag units
    nmagu = (maxmag*10)+1;
    
    
    l = ZG.newcat.Date > t1p(1) & ZG.newcat.Date < t2p(1) ;
    bval =  ZG.newcat.subset(l);
    [bval,xt2] = hist(bval(:,6),(0:0.1:maxmag));
    bvalsum = cumsum(bval);
    bvalsum3 = cumsum(bval(end:-1:1));
    magsteps_desc = (maxmag:-0.1:0);
    
    
    l = ZG.newcat.Date > t2p(1) & ZG.newcat.Date < t3p(1) ;
    bval2 = ZG.newcat.subset(l);
    bval2 = histogram(bval2(:,6),(0:0.1:maxmag));
    bvalsum2 = cumsum(bval2);
    bvalsum4 = cumsum(bval2(end:-1:1));
    
    
    % normalisation
    td12 = t2p(1) - t1p(1);
    td23 = t3p(1) - t2p(1);
    bvalsum = bvalsum *  td23/td12;
    bvalsum3 = bvalsum3 *  td23/td12;
    bval = bval *  td23/td12;
    
    
    orient tall
    rect = [0.2,  0.7, 0.60, 0.25];
    axes('position',rect)
    semilogy(xt2,bvalsum,'om')
    set(gca,'NextPlot','add')
    semilogy(xt2,bvalsum2,'xb')
    semilogy(xt2,bvalsum,'-.m')
    semilogy(xt2,bvalsum2,'b')
    semilogy(magsteps_desc,bvalsum4,'xb')
    semilogy(magsteps_desc,bvalsum4,'b')
    semilogy(magsteps_desc,bvalsum3,'-.m')
    semilogy(magsteps_desc,bvalsum3,'om')
    te1 = max([bvalsum  bvalsum2 bvalsum4 bvalsum3]);
    te1 = te1 - 0.2*te1;
    title(['o: ' num2str(t1p(1)) ' - ' num2str(t2p(1)) '     x: ' num2str(t2p(1)) ' - '  num2str(t3p(1)) ])
    
    xlabel('Magnitude ')
    ylabel('Cumulative Number -normalized')
    
    rect = [0.2,  0.38 0.60, 0.25];
    axes('position',rect)
    plot(xt2,bval,'om')
    set(gca,'NextPlot','add')
    plot(xt2,bval2,'xb')
    plot(xt2,bval,'-.m')
    plot(xt2,bval2,'b')
    
    xlabel('Magnitude ')
    ylabel('Number')
    
    pause(0.1)
    
    tm1 = round((t1p(1) - t0b)/days(ZG.bin_dur));
    tm2 = round((t3p(1) - t0b)/days(ZG.bin_dur));
    tmid = round((t2p(1) - t1p(1))/days(ZG.bin_dur));
    
    %FIXME these UICONTROLs don't have a type. maybe this whole thing should go away?
    uicontrol('Units','normal','Position',[.90 .61 .10 .05],'String',' MagSig ', 'callback',@(~,~)calcmags())
    
end
