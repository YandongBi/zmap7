function prepfocal2() 
    % PREPFOCAL2
    % to prepare the events for inversion based
    % on Lu Zhongs code.
    % turned into function by Celso G Reyes 2017
    
    ZG=ZmapGlobal.Data; % used by get_zmap_globals
    
    report_this_filefun();
    
    
    tmp = [ZG.newt2(:,10:12)];
    try
        save(ZmapGlobal.Data.Directories.output ,'data.inp','tmp','-ascii');
    catch
        err =  ['Error - could not save file ' ZmapGlobal.Data.Directories.output 'data.inp - permission?'];
        errordlg(err);
        return;
    end
    
    infi = [ZmapGlobal.Data.Directories.output 'data.inp'];
    outfi = [ZmapGlobal.Data.Directories.output 'tmpout.dat'];
    outfi2 = [ZmapGlobal.Data.Directories.output 'tmpout2.dat'];
    
    
    fid = fopen([ZmapGlobal.Data.Directories.output 'inmifi.dat'],'w');
    
    fprintf(fid,'%s\n',infi);
    fprintf(fid,'%s\n',outfi);
    
    fclose(fid);
    comm = ['!/bin/rm ' outfi];
    eval(comm)
    
    comm = ['!  ' hodi '/stinvers/datasetupDD < ' ZmapGlobal.Data.Directories.output 'inmifi.dat ' ]
    eval(comm)
    
    comm = ['!grep  "1.0" ' outfi  '>'  outfi2];
    eval(comm)
    
    comm = ['load ' ZmapGlobal.Data.Directories.output 'tmpout2.dat'];
    eval(comm)
    
    
    
    
end
