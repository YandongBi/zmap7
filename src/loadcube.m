function loadcube() 
    % turned into function by Celso G Reyes 2017
    
    ZG=ZmapGlobal.Data; % used by get_zmap_globals
    report_this_filefun();
    
    cupa = cd;
    
    
    [file1,path1] = uigetfile(['*.mat'],'Cube Data File');
    
    if length(path1) > 1
        
        load([path1 file1])
        abo2 = abo;
        plotala()
    else
        return
    end
    
end
