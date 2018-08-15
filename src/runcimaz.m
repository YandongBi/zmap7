function runcimaz() 
    % turned into function by Celso G Reyes 2017
    
    ZG=ZmapGlobal.Data; % used by get_zmap_globals
    report_this_filefun();
    
    j = 0;
    it = 20
    minval = minval/days(ZG.bin_dur);
    maxval = maxval/days(ZG.bin_dur);
    [len, ncu] = size(cumuall);
    len = len -2;
    step = nustep;
    
    
    %set up movie axes
    %
    cin_lta
    axes(h1)
    fs_m = get(gcf,'pos');
    
    m = moviein(length(1:step:len-winlen_days));
    
    ma = [];
    mi = [];
    
    
    wai = waitbar(0,'Please wait...')
    set(wai,'Color',[0.8 0.8 0.8],'NumberTitle','off','Name','Movie -Percent done');
    pause(0.1)
    
    for it = minval:step:maxval
        j = j+1;
        cin_maxz
        axes(h1)
        m(:,j) = getframe(h1);
        figure(wai);
        waitbar(it/len)
    end   % for i
    
    close(wai)
    
    % save movie
    %
    clear newmatfile
    
    [newmatfile, newpath] = uiputfile('*.mat', 'Save As');
    
    if length(newpath > 1)
        save([newpath newmatfile])
        showmovi
    else
        showmovi
    end
    
    
end
