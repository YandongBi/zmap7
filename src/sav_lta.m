function sav_lta() 
    % turned into function by Celso G Reyes 2017
    
    ZG=ZmapGlobal.Data; % used by get_zmap_globals
    report_this_filefun();
    
    str = [];
    [newmatfile, newpath] = uiputfile(ZmapGlobal.Data.Directories.output,'*.m', 'Save As'); %Syntax change Matlab Version 7, no window positioning on macs
    
    
    s = [xt  ; cumu2 ; lta   ];
    fid = fopen([newpath newmatfile],'w') ;
    fprintf(fid,'%6.2f  %6.2f %6.2f\n',s);
    return
    
end
