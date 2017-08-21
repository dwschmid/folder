function run_info(Action)

% Original author:    Marta Adamuszek
% Last committed:     $Revision: 71 $
% Last changed by:    $Author: fgt_marta $
% Last changed date:  $Date: 2015-09-07 15:26:14 +0200 (Pn, 07 wrz 2015) $
%--------------------------------------------------------------------------

%% input check
if nargin==0
    Action = 'initialize';
end

%% find gui
info_gui_handle = findobj(0, 'tag', 'info_gui_handle', 'type', 'figure');

switch lower(Action)
    case 'initialize'
        %% INITIALIZE
        
        %  Delete figure if it already exists
        if ~isempty(info_gui_handle)
            delete(info_gui_handle);
        end
        
        %  Add current path and subfolders
        addpath(genpath(pwd));
        
        rmpath(genpath([pwd, filesep, 'ext', filesep, 'GUILayout-v1p17']));
        rmpath(genpath([pwd, filesep, 'ext', filesep, 'GUILayout']));
        try
            %Check if toolbox is installed and of right version
            if ( verLessThan('layout', '2.1') && ~verLessThan('matlab', '8.4.0') ) || ( ~verLessThan('layout', '2.1') && verLessThan('matlab', '8.4.0') )
                uiwait(warndlg('Wrong GUI Layout Toolbox installed - manually remove from permanent path!', 'modal'));
            end
        catch
            %Not installed yet - install
            if verLessThan('matlab', '8.4.0')
                run([pwd, filesep, 'ext',filesep,'GUILayout-v1p17',filesep,'install.m']);
            else
                addpath([pwd, filesep, 'ext', filesep, 'GUILayout', filesep, 'layout']);
            end
        end
        
        
        %% - Figure Setup
        Screensize      = get(0, 'ScreenSize');
        x_res           = Screensize(3);
        y_res           = Screensize(4);
        
        fig_width       = 0.7*x_res;
        fig_height      = 0.5*y_res;
        
        info_gui_handle = figure('Units', 'pixels','pos', round([(x_res-fig_width)/2 (y_res-fig_height)/2, fig_width, fig_height]), ...
            'Name' ,'Numerical Run Summary', 'Units','pixels', 'tag','info_gui_handle','Resize','on',...
            'NumberTitle', 'off', 'DockControls', 'off', 'MenuBar', 'none', 'ToolBar', 'none',...
            'Color',get(0, 'DefaultUipanelBackgroundColor'));
        
        % Default character size
        try
            folder_gui_handle = findobj(0, 'tag', 'folder_gui_handle', 'type', 'figure');
            
            %  Get fold data
            fold      = getappdata(folder_gui_handle, 'fold');
            
            b_width  = getappdata(folder_gui_handle, 'b_width');
            b_height = getappdata(folder_gui_handle, 'b_height');
            gap      = getappdata(folder_gui_handle, 'gap');
        catch
            warndlg('You should start to run the main Folder function first.', 'Error');
            return;
        end
        
        text_width      = 2*(b_width)+gap;
        field_width  	= 2*(b_width)+gap;
        
        
        %% - Main Layout
        % Panels dimensions
        panel_width     = text_width+field_width+4*gap;
        general_height  = 6*(b_height+gap)+4*gap;
        field_height    = 1*(b_height+gap)+4*gap;
        
        % Division into plot and controls panels
        b1                      = uiextras.HBox('Parent', info_gui_handle,'Spacing', gap);
        b2                      = uiextras.VBox('Parent', b1, 'Spacing', gap);
        info_upanel_general     = uipanel( 'Parent', b2, 'Title', 'General','Tag','info_upanel_general');
        info_upanel_field       = uipanel( 'Parent', b2, 'Title', 'Plotting','Tag','info_upanel_field');
        set( b2, 'Sizes', [general_height field_height]); 
        info_upanel_plot        = uipanel( 'Parent', b1,'Title','Detailed','tag','info_upanel_plot');
        set( b1, 'Sizes', [panel_width -1]);
        
       
        %% Toolbar
        toolbar = uitoolbar('parent', info_gui_handle, 'handleVisibility', 'off');
        uitoolfactory(toolbar, 'Standard.SaveFigure');
        uitoolfactory(toolbar, 'Standard.PrintFigure');
        uitoolfactory(toolbar, 'Exploration.ZoomIn');
        uitoolfactory(toolbar, 'Exploration.ZoomOut');
        uitoolfactory(toolbar, 'Exploration.Pan');
        
        hSave = findall(gcf, 'tooltipstring', 'Save Figure');
        set(hSave, 'ClickedCallback', 'filemenufcn(gcbf,''FileSave''),set(gcf, ''FileName'', '''')')
        
        ToolbarButtons = load('ToolbarButtons.mat');
        
        % Get data
        try
            temp = load([fold.run_output,'run_output',filesep,'numerics.mat'],'data');
            data = temp.data;
            data(1).solver  = fold.num.solver;
            data(1).nt      = fold.num.nt;
            data(1).picards = fold.num.picards;
            data(1).newtons = fold.num.newtons;
            data(1).max_rel_res = fold.num.relres;
        catch
            return;
        end
        setappdata(info_gui_handle, 'data', data);
        
        %% General Panel
        % SOLVER
        % Text
        uicontrol('Parent', info_upanel_general, 'style', 'text', 'String', 'Solver', 'HorizontalAlignment', 'left',...
            'position', [gap, gap+5*(b_height+gap), text_width, b_height]);
        % Field
        solvers = {'Euler';'Improved Euler';'Runge-Kutta 2';'Runge-Kutta 3';'Runge-Kutta 4';...
            'Adams-Bashforth 2';'Adams-Bashforth 3';'Adams-Bashforth 4'};
        obj.info_solver = uicontrol('Parent', info_upanel_general, 'style', 'text', 'String', solvers{fold.num.solver}, 'BackgroundColor','w',...
            'tag', 'info_solver', ...
            'position', [gap+text_width+gap, gap+5*(b_height+gap), field_width, b_height]);
        
        % NUMBER OF TIME STEPS
        % Text
        uicontrol('Parent', info_upanel_general, 'style', 'text', 'String', '# Time Steps', 'HorizontalAlignment', 'left',...
            'position', [gap, gap+4*(b_height+gap), text_width, b_height]);
        % Field
        obj.info_nsteps = uicontrol('Parent', info_upanel_general, 'style', 'text', 'String', num2str(fold.num.nt), 'BackgroundColor','w',...
            'tag', 'info_nsteps', ...
            'position', [gap+text_width+gap, gap+4*(b_height+gap), field_width, b_height]);

        % MAX RELATIVE RESIDUAL
        % Text
        uicontrol('Parent', info_upanel_general, 'style', 'text', 'String', 'Max. Relative Residual', 'HorizontalAlignment', 'left',...
            'position', [gap, gap+3*(b_height+gap), text_width, b_height]);
        % Field
        obj.info_nsteps = uicontrol('Parent', info_upanel_general, 'style', 'text', 'String', num2str(fold.num.relres), 'BackgroundColor','w',...
            'tag', 'info_rel_res', ...
            'position', [gap+text_width+gap, gap+3*(b_height+gap), field_width, b_height]);
        
        % PICARD ITERATIONS 
        % Text
        uicontrol('Parent', info_upanel_general, 'style', 'text', 'String', 'Max. # Picard Iter.', 'HorizontalAlignment', 'left',...
            'position', [gap, gap+2*(b_height+gap), text_width, b_height]);
        % Field
        obj.info_picard = uicontrol('Parent', info_upanel_general, 'style', 'text', 'String', num2str(fold.num.picards), 'BackgroundColor','w',...
            'tag', 'info_picard', ...
            'position', [gap+text_width+gap, gap+2*(b_height+gap), field_width, b_height]);
        
        % NEWTON-RAPHSON ITERATIONS
        % Text
        uicontrol('Parent', info_upanel_general, 'style', 'text', 'String', 'Max. # Newton-Raphson Iter.', 'HorizontalAlignment', 'left',...
            'position', [gap, gap+1*(b_height+gap), text_width, b_height]);
        % Field
        obj.info_nr = uicontrol('Parent', info_upanel_general, 'style', 'text', 'String', num2str(fold.num.newtons), 'BackgroundColor','w',...
            'tag', 'info_nr', ...
            'position', [gap+text_width+gap, gap+1*(b_height+gap), field_width, b_height]);
        
        % TOTAL TIME
        % Text
        uicontrol('Parent', info_upanel_general, 'style', 'text', 'String', 'Total Time', 'HorizontalAlignment', 'left',...
            'position', [gap, gap+0*(b_height+gap), text_width, b_height]);
        % Field
        if ~isfield(data(1),'total_time')
            data(1).total_time = [];
        end
        obj.info_time = uicontrol('Parent', info_upanel_general, 'style', 'text', 'String', [num2str(data(1).total_time,'%.3f'),' s'], 'BackgroundColor','w',...
            'tag', 'info_time', ...
            'position', [gap+text_width+gap, gap+0*(b_height+gap), field_width, b_height]);
        
        %% Field Panel
        % Text
        uicontrol('Parent', info_upanel_field, 'style', 'text', 'String', 'Parameter', 'HorizontalAlignment', 'left',...
            'position', [gap, gap+0*(b_height+gap), text_width, b_height]);
        % Field
        obj.info_field = uicontrol('Parent', info_upanel_field, 'style', 'popupmenu', 'String', {'Number of Nodes'},'value',1,'BackgroundColor','w',...
            'callback',  @(a,b)  run_info('uicontrol_callback'),...
            'tag','info_field',...
            'position', [gap+text_width+gap, 2*gap+0*(b_height+gap), field_width, b_height]);
        
        N          = zeros(1,length(fold.region))';
        for ii = 1:length(fold.region)
            N(ii)   = str2double(fold.material_data{fold.region(ii).material,6});
        end
        
        if any(N>1)
            % case 1: non-linear viscous materials
            set(obj.info_field,'String', {'Number of Nodes';'Number of Elements';'Time of Each Step';...
                'Number of Iterations';'Mean Iteration Time in Each (Sub)Step';'Relative Residual'});
        else
            % case 2: non-linear viscous materials
            set(obj.info_field,'String', {'Number of Nodes';'Number of Elements';'Time of Each Step'});
        end
       
        % - Plot Axes
        h_axes  = axes('parent', info_upanel_plot);
        box(h_axes, 'on');
        
        % Tags on axes get removed by reset etc. actions. Store in appdata
        % of parent
        setappdata(info_upanel_plot, 'h_axes', h_axes);
        
        % Store in Figure Appdata
        setappdata(info_gui_handle, 'obj', obj);
        
        % - Update plot
        run_info('plot_update');
    
    case 'uicontrol_callback'
        %% UICONTROL_CALLBACK
        
        % Who is calling
        wcbo            = gcbo;
        Whoiscalling    = get(wcbo, 'tag');
        
        % Get data
        obj     = getappdata(info_gui_handle, 'obj');
        
        switch Whoiscalling
            
            case 'info_field'
                set(obj.info_field, 'value', get(wcbo,  'value'));
                
            case 'info_legend'
                set(obj.info_legend, 'value', get(wcbo,  'value'));
        end
        
        % Update plot
        run_info('plot_update')
    
        
    case 'plot_update'
        %% PLOT_UPDATE
        
        % Get data
        obj 	= getappdata(info_gui_handle, 'obj');
        data	= getappdata(info_gui_handle, 'data');
        
        info_upanel_plot    = findobj(info_gui_handle, 'tag', 'info_upanel_plot');
        h_axes            	= getappdata(info_upanel_plot, 'h_axes');
        
        % Clear
        cla(h_axes,'reset');
        
        % Plot 
        hold(h_axes, 'on');
               
        
        % Set X-coordinace
        if data(1).solver == 1
            nts = data(1).nt;
            X = 1:nts;
        elseif data(1).solver == 2 || data(1).solver == 3
            nts = data(1).nt;
            X = repmat(1:nts,2,1);
            X = X(:)';
        elseif data(1).solver == 4
            nts = data(1).nt;
            X = repmat(1:nts,3,1);
            X = X(:)';
        elseif data(1).solver == 5
            nts = data(1).nt;
            X = repmat(1:nts,4,1);
            X = X(:)';
        elseif data(1).solver == 6
            nts = (data(1).nt-1) + 1*2;
            X = [1 1 2 2 3:data(1).nt];
        elseif data(1).solver == 7
            nts = (data(1).nt-2) + 2*3;
            X = [ones(1,3) 2*ones(1,3) 3*ones(1,3) 4:data(1).nt];
        elseif data(1).solver == 8
            nts = (data(1).nt-3) + 3*4;
            X = [ones(1,4) 2*ones(1,4) 3*ones(1,4) 4:data(1).nt];
        end
        
        
        switch get(obj.info_field,'value')
            
            case 1
                % Number of nodes
                nnodes  = horzcat(data.nnodes);
                c1      = nnodes(1:length(X));
                xlabel('Time Step')
                ylabel('# Nodes')
                
            case 2
                % Number of elements
                nels    = horzcat(data.nel);
                c1      = nels(1:length(X));
                xlabel('Time Step')
                ylabel('# Elements')
                
            case 3
                % Time of each time step
                X  = 1:data(1).nt;
                c1 = data(1).step_time(1:end-1);
                xlabel('Time step')
                ylabel('Time (s)')
                
            case 4
                % Number of iterations
                c1 = zeros(1,length(X));
                c2 = zeros(1,length(X));
                for it = 1:length(X)
                    c1(it) = length(data(it).picard_time_part);
                    if length(data(it).newton_time_part) == 0
                        c2(it) = 0;
                    else
                        c2(it) = length(data(it).newton_time_part)-c1(it);
                    end
                end
                xlabel('Time step')
                ylabel('# Iterations')
                
            case 5
                % Mean Iteration Time
                c1 = zeros(1,length(X));
                c2 = zeros(1,length(X));
                for it = 1:length(X)
                    c1(it) = mean(data(it).picard_time_part);
                    c2(it) = mean(data(it).newton_time_part(length(data(it).picard_time_part)+1:end));
                end
                xlabel('Time step')
                ylabel('Mean Time (s)')
                
            case 6
                % Relative Residual - plot below
                
        end
        
        col1 = [0         0.4470    0.7410];
        col2 = [0.8500    0.3250    0.0980];
        col3 = [0.4660    0.6740    0.1880];
        
        if get(obj.info_field,'value') < 4
            
            h(1) = plot(h_axes,X,c1,'o','MarkerSize',6,'MarkerEdgeColor','k','MarkerFaceColor',col3);
           
        elseif get(obj.info_field,'value') > 3 && get(obj.info_field,'value') < 6
            
            h(1) = plot(h_axes,X,c1,'o','MarkerSize',6,'MarkerEdgeColor','k','MarkerFaceColor',col1);
            h(2) = plot(h_axes,X,c2,'o','MarkerSize', 6,'MarkerEdgeColor','k','MarkerFaceColor',col2);
            legend(h,'Picard','Newton-Raphson',-1)
            
        else
            max_x = zeros(1,length(X));
            for it  = 1:length(X)
                h(2) = plot(h_axes,0:(data(1).picards+data(1).newtons)-1,data(it).rel_res(1:end-1),'o-','Color',col2,...
                    'MarkerSize', 4,'MarkerEdgeColor','k','MarkerFaceColor',col2);
                h(1) = plot(h_axes,0:data(1).picards,data(it).rel_res(1:data(1).picards+1),'o-','Color',col1,...
                    'MarkerSize', 4,'MarkerEdgeColor','k','MarkerFaceColor',col1);
                max_x(it) = sum(~isnan(data(it).rel_res))-1;
                set(h_axes,'yscale','log')
                xlabel('Iteration')
                ylabel('Relative Residual')
                legend(h,'Picard','Newton-Raphson',-1)
            end
            xlim([0 max(max_x)])
            plot(h_axes,[0 max(max_x)],[1 1]*data(1).max_rel_res,'k--','LineWidth',2)
        end
        
        % Axes
        box(h_axes, 'on');
        set(h_axes,'xscale','linear')
 
        % Grid
        set(h_axes,'Xgrid','on','Ygrid','on')
             
        
    case 'export_workspace'
        %% EXPORT TO WORKSPACE
        
        %  Get data
        info        = getappdata(info_gui_handle, 'info');
        
        Run_Info = []
        
        % Export into workspace
        checkLabels = {'Save data named:'};
        varNames    = {'Run_Info'};
        items       = {Run_Info};
        export2wsdlg(checkLabels,varNames,items,...
            'Save Numerical Run Info to Workspace');
        
end
end
