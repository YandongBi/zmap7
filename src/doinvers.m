function doinvers() 
    %  doinvers calculates orientation of the stress tensor based on Gephard's algorithm.
    % stress tensor orientation. The actual calculation is done using a call to a fortran program.
    %
    % Stefan Wiemer 03/96
    % turned into function by Celso G Reyes 2017
    
    ZG=ZmapGlobal.Data; % used by get_zmap_globals
    
    
    global mif1 mif2 a newcat2
    global tmpi cumu2
    report_this_filefun();
    
    
    if isunix ~= 1
        errordlg('Misfit calculation only implemented for UNIX version! ');
        return
    end
    
    prepfocal2
    hodis = [hodi '/stinvers'];
    tmpi = tmpout2;
    try
        save(ZmapGlobal.Data.Directories.output, 'data.inp','tmpi','-ascii');
    catch
        errordlg(['Error - could not save file ' ZmapGlobal.Data.Directories.output '/tmpin.dat - permission?']);
        return
    end
    
    infi = [ZmapGlobal.Data.Directories.output 'data.inp'];
    outfi = [ZmapGlobal.Data.Directories.output 'tmpout.dat'];
    
    
    comm = [ '! '   hodis '/invshell1 ',...
        num2str(length(tmpi(:,1))) ' ' num2str(10) ' ' hodis ' ' infi  ' & ']
    eval(comm)
    
end
