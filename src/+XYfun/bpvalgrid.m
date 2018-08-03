classdef bpvalgrid < ZmapHGridFunction
    % calculate P values on X-Y grid
    properties
        CO         = 0     % omori c parameter with sign dictating whether it is constant or not
        valeg2      = 2     % omori c parameter
        minpe       = nan   % min goodness percentage
        mc_choice    McMethods              = McMethods.MaxCurvature % magnitude of completion method
        wt_auto    LSWeightingAutoEstimate  = true
        mc_auto    McAutoEstimate           = true
    end
    properties(Constant)
        PlotTag = 'bpvalgrid';
        
        ReturnDetails = cell2table({ ... VariableNames, VariableDescriptions, VariableUnits
            'b_value_wls',  'b-value map (WLS)',    '';...      1 bv
            'Mc_value',     'Mag of completeness',  '';...    2 magco
            'b_value_maxlikelihood',        'b(max likelihood) map',    '';...  6: bv2
            'b_value_std_maxlikelihood',    'Error in b',               '';...             7 {pro} stan2
            'a_value',      'a-value',          '';...                8 av
            'stan',         'est. std predicting future based on A and B','';... stanm9: stan estimate of the std deviation of the error in predicting a future observation at X by A and B
            'power_fit',    'Goodness of fit to power-law', '';... prf
            'p_value',      'p-value',          '';...                11: pv
            'pstd',         'p-val std',        '';...              12: pstd
            'c_value',      'c in days',        '';...              14 cv
            'mmav',         'mmav',             '';...                   mmav
            'k_value',      'kv',               '';...                     kv
            'mbv',          'mbv',              '';...                    mbv
            'deltaB',       'difference in b',  '';...
            'dM',           'Magnitude range map (Mmax - Mcomp)',   ''...
            }, 'VariableNames', {'Names','Descriptions','Units'})
        
        CalcFields = {'b_value_wls',    'Mc_value', 'b_value_maxlikelihood',...
            'b_value_std_maxlikelihood','a_value', ...
            'stan',     'power_fit',    'p_value',  'pstd',...
            'c_value',  'mmav',         'k_value',  'mbv'};
        ParameterableProperties = ["CO" "valeg2" "minpe" "mc_choice"];
    end
    methods
        function obj=bpvalgrid(zap, varargin)
            % CGR_BVALGRID
            % obj = CGR_BVALGRID() takes catalog, grid, and eventselection from ZmapGlobal.Data
            %
            % obj = CGR_BVALGRID(ZAP) where ZAP is a ZmapAnalysisPkg
            
            
            obj@ZmapHGridFunction(zap, 'p_value'); %set default column here
            report_this_filefun();
            
            obj.parseParameters(varargin);
            obj.StartProcess();
        end
        
        function InteractiveSetup(obj)
            % create a dialog that allows user to select parameters neccessary for the calculation
            zdlg = ZmapDialog();
            Mc_Methods={'Automatic Mcomp (max curvature)',...
            'Fixed Mc (Mc = Mmin)',...
            'Automatic Mcomp (90% probability)',...
            'Automatic Mcomp (95% probability)',...
            'Best (?) combination (Mc95 - Mc90 - max curvature)',...
            'Constant Mc'};

            zdlg.AddBasicPopup('mc_choice', 'Magnitude of Completeness (Mc) method:',Mc_Methods,5,...
                'Choose the calculation method for Mc');
            zdlg.AddBasicEdit('c_val','omori c parameter', obj.valeg2,' input parameter (varying)');
            zdlg.AddBasicCheckbox('use_const_c','fixed c', obj.CO<0, {'const_c'},'keep the Omori C parameter fixed');
            zdlg.AddBasicEdit('const_c','omori c parameter', obj.valeg2, 'C-parameter parameter (fixed)');
            zdlg.AddBasicEdit('minpe','min goodness %', obj.minpe, 'Minimum goodness of fit (percentage)');
            
            zdlg.AddEventSelectionParameters('evsel', obj.EventSelector);
            % zdlg.AddBasicEdit('Mmin','minMag', nan, 'Minimum magnitude');
            % FIXME min number of events should be the number > Mc
            
            [res, okpressed]=zdlg.Create('B P val grid');
            if ~okpressed
                return
            end
            
            obj.SetValuesFromDialog(res);
            obj.doIt();
        end
        
        function SetValuesFromDialog(obj, res)
            obj.mc_choice = res.mc_choice;
            %ZG.inb1=res.mc_choice;
            obj.valeg2=res.c_val;
            obj.minpe=res.minpe;
            obj.EventSelector=res.evsel;
            if res.use_const_c
                obj.CO=res.const_c;
                obj.valeg2 = -obj.valeg2; %duplicating original inputs
            else
                obj.CO=0;
            end
        end
        
        function results=Calculate(obj)
            %In the following line, the program selgp.m is called, which creates a rectangular grid from which then selects,
            %on the basis of the vector ll, the points within the selected poligon.
            
            ZG=ZmapGlobal.Data;
            Nmin = obj.EventSelector.requiredNumEvents;
            minThreshMag = min(obj.RawCatalog.Magnitude);
            
            % get the grid parameter
            % initial values
            mainshock_idx = find(obj.RawCatalog.Magnitude==max(obj.RawCatalog.Magnitude),1,'first');
            mainshock = obj.RawCatalog.subset(mainshock_idx);
            
            ZG.maepi = mainshock;  % TODO remove maepi dependencies from called functions (mypval2m, z.B.)
            
            if ~ensure_mainshock()
                return
            end
            
            % cut catalog at mainshock time:
            l = obj.RawCatalog.Date > mainshock.Date;
            obj.RawCatalog = obj.RawCatalog.subset(l);
            
            % cut cat at selected magnitude threshold
            l = obj.RawCatalog.Magnitude >= minThreshMag;
            obj.RawCatalog = obj.RawCatalog.subset(obj.RawCatalog.Magnitude >= minThreshMag);
            
            %%%%%%%
            
            % overall b-value
            [bv, magco, stan, av] =  bvalca3(obj.RawCatalog.Magnitude,obj.mc_choice);
            ZG.bo1 = bv;
            
            
            mycalcmethods= {@calcguts_opt1,...
                @calcguts_opt2,...
                @calcguts_opt3,...
                @calcguts_opt4,...
                @calcguts_opt5};
            calculation_function = mycalcmethods{obj.mc_choice};
            % calculate at all points
            obj.gridCalculations(calculation_function);
            
            % prepare output to dektop
            obj.Result.minpe = obj.minpe; %min goodness of fit (%)
            
            % ADDITIONAL VALUES
            obj.Result.values.dM = obj.Result.values.max_mag - obj.Result.values.Mc_value;
            obj.Result.values.deltaB = obj.Result.values.b_value_wls - obj.Result.values.b_value_maxlikelihood;
            
            if nargout
                results = obj.Result.values;
            end
            
            
            % plot the results
            % old and valueMap (initially ) is the b-value matrix
            %
            % gridstats = array2gridstats(bpvg, ll);
            % gridstats.valueMap = gridstats.pvalg;
            
            % View the b-value and p-value map
            % view_bpva(sel, 11) % where sel was the original results
            % one menu option "histogram" called zhist()
            
            
            function bpvg = calcguts_opt1(b)
                [bv, magco, stan, av] =  bvalca3(b.Magnitude,McAutoEstimate.auto);
                maxcat = b.subset(b.Magnitude >= magco-0.05);
                if maxcat.Count  >= Nmin
                    [bv2, stan2] = calc_bmemag(maxcat.Magnitude, 0.1);
                    [pv, pstd, cv, ~, kv, ~, mmav,  mbv] = mypval2m(maxcat.Date,maxcat.Magnitude,'days',obj.valeg2,obj.CO,minThreshMag);
                    
                    bpvg = [bv magco bv2 stan2 av stan nan pv pstd cv mmav kv mbv];
                else
                    bpvg = nan(1,numel(obj.CalcFields));
                end
            end
            
            function bpvg = calcguts_opt2(b)
                [bv, magco, stan, av] =  bvalca3(b.Magnitude, McAutoEstimate.manual);
                [bv2, stan2] = calc_bmemag(b.Magnitude, 0.1);
                [pv, pstd, cv, ~, kv, ~, mmav,  mbv] = mypval2m(b.Date,b.Magnitude,'days',obj.valeg2,obj.CO,minThreshMag);
                %[pv, pstd, cv, ~, kv, ~, mmav,  mbv] = mypval2m(b.Date(l),b.Magnitude(l),'days',obj.valeg2,obj.CO,minThreshMag);
                
                bpvg = [bv magco bv2 stan2 av stan nan pv pstd cv mmav kv mbv];
            end
            
            function bpvg = calcguts_opt3(b)
                [~, Mc90, ~, magco, prf]=bvalca3(b.Magnitude);
                maxcat = b.subset(b.Magnitude >= Mc90-0.05);
                magco = Mc90;
                if maxcat.Count  >= Nmin
                    [bv, ~, stan, av] =  bvalca3(maxcat.Magnitude, McAutoEstimate.manual);
                    [bv2, stan2] = calc_bmemag(maxcat.Magnitude,0.1);
                    [pv, pstd, cv, ~, kv, ~, mmav,  mbv] = mypval2m(maxcat.Date,maxcat.Magnitude,'days',obj.valeg2,obj.CO,minThreshMag);
                    bpvg = [bv magco bv2 stan2 av stan prf pv pstd cv mmav kv mbv];
                else
                    bpvg = nan(1,numel(obj.CalcFields));
                end
            end
            
            function bpvg = calcguts_opt4(b)
                [~, ~, Mc95, magco, prf]=mcperc_ca3(b.Magnitude);
                maxcat= b.subset(b.Magnitude >= Mc95-0.05);
                magco = Mc95;
                if maxcat.Count >= Nmin
                    [bv, ~, stan, av] =  bvalca3(maxcat.Magnitude, McAutoEstimate.manual);
                    [bv2, stan2] = calc_bmemag(maxcat.Magnitude,0.1);
                    [pv, pstd, cv, ~, kv, ~, mmav,  mbv] = mypval2m(maxcat.Date,maxcat.Magnitude,'days',obj.valeg2,obj.CO,minThreshMag);
                    
                    bpvg = [bv magco bv2 stan2 av stan prf pv pstd cv mmav kv mbv];
                else
                    bpvg = nan(1,numel(obj.CalcFields));
                end
            end
            
            function bpvg = calcguts_opt5(b)
                [~, Mc90, Mc95, magco, prf]=mcperc_ca3(b.Magnitude);
                if ~isnan(Mc95)
                    magco = Mc95;
                elseif ~isnan(Mc90)
                    magco = Mc90;
                else
                    [bv, magco, stan, av] =  bvalca3(b.Magnitude,McAutoEstimate.auto);
                end
                maxcat= b.subset(b.Magnitude >= magco-0.05);
                if maxcat.Count  >= Nmin
                    [bv, ~, stan, av] =  bvalca3(maxcat.Magnitude, McAutoEstimate.manual);
                    [bv2, stan2] = calc_bmemag(maxcat.Magnitude,0.1);
                    [pv, pstd, cv, ~, kv, ~, mmav,  mbv] = mypval2m(maxcat.Date, maxcat.Magnitude, 'days' ,obj.valeg2,obj.CO,minThreshMag);
                    bpvg = [bv magco bv2 stan2 av stan prf pv pstd cv mmav kv mbv];
                else
                    bpvg = nan(1,numel(obj.CalcFields));
                end
            end
        end
        
        function ModifyGlobals(obj)
            obj.ZG.bvg=obj.Result.values;
        end
    end
    methods(Static)
        function h=AddMenuItem(parent,zapFcn)
            % create a menu item
            label='p- and b-value map';
            h=uimenu(parent,'Label',label,MenuSelectedField(), @(~,~)XYfun.bpvalgrid(zapFcn()));
        end
    end
end

%{
function my_load()
        % Load exist b-grid
        [file1,path1] = uigetfile('*.mat','b-value gridfile');
        if length(path1) > 1
            
            gridstats=load_existing_bgrid(fullfile(path1, file1));
            view_bpva(lab1,gridstats.valueMap)
        else
            return
        end
    end
%}