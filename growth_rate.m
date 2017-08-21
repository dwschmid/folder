function growth_rate(Action)

% Original author:    Marta Adamuszek
% Last committed:     $Revision: 86 $
% Last changed by:    $Author: fgt_marta $
% Last changed date:  $Date: 2016-04-26 10:15:58 +0200 (Wt, 26 kwi 2016) $
%--------------------------------------------------------------------------

%% input check
if nargin==0
    Action = 'initialize';
end

%% find gui
growth_gui_handle = findobj(0, 'tag', 'growth_gui_handle', 'type', 'figure');

switch lower(Action)
    case 'initialize'
        %% INITIALIZE
        
        %  Delete figure if it already exists
        if ~isempty(growth_gui_handle)
            delete(growth_gui_handle);
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
        fig_height      = 0.7*y_res;
        
        growth_gui_handle = figure('Units', 'pixels','pos', round([(x_res-fig_width)/2 (y_res-fig_height)/2, fig_width, fig_height]), ...
            'Name' ,'Growth Rates for Single Layer Perturbed with Sinusoidal Waveform', 'Units','pixels', 'tag','growth_gui_handle','Resize','on',...
            'NumberTitle', 'off', 'DockControls', 'off', 'MenuBar', 'none', 'ToolBar', 'none',...
            'Color',get(0, 'DefaultUipanelBackgroundColor'));
        
        % Default character size
        test_button     = uicontrol('Parent',growth_gui_handle,'style', 'text', 'String', 'Finite Strain');
        test_text       = text(0,0,'Finite Strain');
        set(test_text,'FontName',get(test_button,'FontName'),'FontSize',get(test_button,'FontSize'),'Units','Pixels');
        TextSize   = get(test_text,'Extent');
        delete(test_button);
        set(test_text,'visible','off');
               
        
        if Screensize(4)<768
            uiwait(warndlg('The screen resolution of your device can be too low to correctly display the GUI.', 'Error!', 'modal'));
        end
        if Screensize(4) < 800
            gap        = 5;
            b_height   = 17;
        else
            gap        = 5;
            b_height   = 20;
        end
        
        b_width         = 2*round((TextSize(3)+4*gap)/2);
        text_width      = 2*(b_width)+gap;
        field_width  	= 2*(b_width)+gap;
        
        %  Save default sizes in figure
        setappdata(growth_gui_handle, 'b_height', b_height);
        setappdata(growth_gui_handle, 'b_width',  b_width);
        setappdata(growth_gui_handle, 'gap',      gap);
        
        %% - Menu Entries
        % Project
        h1 = uimenu('Parent',growth_gui_handle, 'Label','File');
        %  Export to workspace
        uimenu('Parent',h1, 'Label', 'Export to Workspace', 'tag', 'growth_rate_export', ...
            'Callback', @(a,b) growth_rate('export_workspace'), 'Separator','off', 'enable', 'on');
        % Save figure
        uimenu('Parent',h1, 'Label', 'Save Figure', ...
            'Callback', @(a,b) growth_rate('save_figure'), 'Separator','off', 'enable', 'on');
            %'Callback', @(a,b) filemenufcn(gcbf,'FileSaveAs'), 'Separator','off', 'enable', 'on');
        %  Exit
        uimenu('Parent',h1, 'Label', 'Exit', ...
            'Callback', @(a,b) close(gcf), 'Separator','on', 'enable', 'on');
        
        %% - Main Layout
        % Panels dimensions
        panel_width     = text_width+field_width+4*gap;
        mod_height      = 1*(b_height+gap)+3*gap;
        rheol_height    = 3*(b_height+gap)+4*gap;
        geom_height     = 2*(b_height+gap)+4*gap;
        numerics_height = 2*(b_height+gap)+4*gap;
        plotting_height = 9*(b_height+gap)+4*gap;
        legend_height   = 4*(b_height+gap)+4*gap;
        
        fig_height      = mod_height+rheol_height+geom_height+numerics_height+plotting_height+legend_height+(b_height+gap);
        set(growth_gui_handle,'pos', round([(x_res-fig_width)/2 (y_res-fig_height)/2, fig_width, fig_height]))
        
        % Division into plot and controls panels
        b1                      = uiextras.HBox('Parent', growth_gui_handle,'Spacing', gap);
        b2                      = uiextras.VBox('Parent', b1, 'Spacing', gap);
        growth_upanel_mod      	= uibuttongroup( 'Parent', b2, 'Title', 'Mode','Tag', 'growth_upanel_mod','SelectionChangeFcn', @(a,b)  growth_rate('uicontrol_callback'));
        growth_upanel_vis      	= uipanel( 'Parent', b2, 'Title', 'Rheology','Tag','growth_upanel_vis');
        growth_upanel_geom      = uipanel( 'Parent', b2, 'Title', 'Geometry','Tag','growth_upanel_geom');
        growth_upanel_numerics 	= uipanel( 'Parent', b2, 'Title', 'Numerical Growth Rate','Tag','growth_upanel_numerics');
        growth_upanel_plotting 	= uipanel( 'Parent', b2, 'Title', 'Plotting Options','Tag','growth_upanel_plotting');
        growth_upanel_legend 	= uipanel( 'Parent', b2, 'Title', 'Legend','Tag','growth_upanel_legend');
        set( b2, 'Sizes', [mod_height rheol_height geom_height numerics_height plotting_height legend_height]); 
        growth_upanel_plot      = uipanel( 'Parent', b1,'Title','GROWTH RATE','tag','growth_upanel_plot');
        set( b1, 'Sizes', [panel_width -1]);
        
       
        %% Toolbar
        toolbar = uitoolbar('parent', growth_gui_handle, 'handleVisibility', 'off');
        uitoolfactory(toolbar, 'Exploration.ZoomIn');
        uitoolfactory(toolbar, 'Exploration.ZoomOut');
        uitoolfactory(toolbar, 'Exploration.Pan');
        
        %hSave = findall(gcf, 'tooltipstring', 'Save Figure');
        %set(hSave, 'ClickedCallback', 'filemenufcn(gcbf,''FileSave''),set(gcf, ''FileName'', '''')')
        %set(hSave, 'ClickedCallback', @(a,b) growth_rate('save_figure'));
        
        ToolbarButtons = load('ToolbarButtons.mat');
        
        % Add the additional icons
        obj.image       = uipushtool(toolbar,'cdata',ToolbarButtons.image, 'tooltip','Save Image',...
            'Separator','on','ClickedCallback',@(a,b) growth_rate('save_figure'));
        obj.export   = uipushtool(toolbar,'cdata',ToolbarButtons.export,   'tooltip','Export to Workspace',...
            'Separator','on','ClickedCallback',@(a,b) growth_rate('export_workspace'));
        
        
        
        %% Mode panel
        obj.growth_folding = uicontrol('Parent', growth_upanel_mod, 'style', 'radiobutton', 'String', 'Folding',...
            'tag','growth_folding',...
            'position', [gap, gap, text_width, b_height]);
        obj.growth_boudinage = uicontrol('Parent', growth_upanel_mod, 'style', 'radiobutton', 'String', 'Necking', ...
            'tag','growth_boudinage',...
            'position', [gap+2*b_width+gap, gap, text_width, b_height]);
        
        
        %% Rheology panel
        % VISCOSITY
        % Text
        uicontrol('Parent', growth_upanel_vis, 'style', 'text', 'String', 'Viscosity Ratio', 'HorizontalAlignment', 'left',...
            'position', [gap, gap+2*(b_height+gap), text_width, b_height], ...
            'tooltipstring','Viscosity ratio between layer and matrix.');
        % Field
        obj.growth_vis = uicontrol('Parent', growth_upanel_vis, 'style', 'edit', 'String', '', 'BackgroundColor','w',...
            'callback',  @(a,b)  growth_rate('uicontrol_callback'),...
            'tag', 'growth_vis', ...
            'position', [gap+text_width+gap, gap+2*(b_height+gap), field_width, b_height]);
        
        % STRESS EXPONENT
        % Text
        uicontrol('Parent', growth_upanel_vis, 'style', 'text', 'String', 'Layer Stress Exponent', 'HorizontalAlignment', 'left',...
            'position', [gap, gap+(b_height+gap), text_width, b_height]);
        % Field
        obj.growth_nl = uicontrol('Parent', growth_upanel_vis, 'style', 'edit', 'String', '', 'BackgroundColor','w',...
            'callback',  @(a,b)  growth_rate('uicontrol_callback'),...
            'tag', 'growth_nl', ...
            'position', [gap+text_width+gap, gap+(b_height+gap), field_width, b_height]);
        % Text
        uicontrol('Parent', growth_upanel_vis, 'style', 'text', 'String', 'Matrix Stress Exponent','HorizontalAlignment', 'left', ...
            'position', [gap, gap, text_width, b_height]);
        % Field
        obj.growth_nm = uicontrol('Parent', growth_upanel_vis, 'style', 'edit', 'String', '', 'BackgroundColor','w',...
            'callback',  @(a,b)  growth_rate('uicontrol_callback'),...
            'tag', 'growth_nm', ...
            'position', [gap+text_width+gap, gap, field_width, b_height]);
        
        %% Geometry panel
        % Box size
        % Text
        uicontrol('Parent', growth_upanel_geom, 'style', 'text', 'String', 'Box/Layer Thickness', 'HorizontalAlignment', 'left',...
            'tooltipstring','Box height to layer thickness ratio.',...
            'position', [gap, gap+(b_height+gap), text_width, b_height]);
        % Field
        obj.growth_boxH = uicontrol('Parent', growth_upanel_geom, 'style', 'edit', 'String', '', 'BackgroundColor','w',...
            'callback',  @(a,b)  growth_rate('uicontrol_callback'),...
            'tag', 'growth_boxH', ...
            'position', [gap+text_width+gap, gap+(b_height+gap), field_width, b_height]);
        
        % Perturbation amplitude
        % Text
        uicontrol('Parent', growth_upanel_geom, 'style', 'text', 'String', 'Perturbation Amplitude','HorizontalAlignment', 'left', ...
            'tooltipstring','Amplitude of the sinusoidal perturbation normalized by the layer thickness.',...
            'position', [gap, gap, text_width, b_height]);
        % Field
        obj.growth_ampl = uicontrol('Parent', growth_upanel_geom, 'style', 'edit', 'String', '', 'BackgroundColor','w',...
            'callback',  @(a,b)  growth_rate('uicontrol_callback'),...
            'tag', 'growth_ampl', ...
            'position', [gap+text_width+gap, gap, field_width, b_height]);
        
        
        %% Numerical Growth Rate
        % Check box
        obj.growth_num_switch = uicontrol('Parent', growth_upanel_numerics, 'style', 'checkbox', 'String', 'Calculate', 'Value', 0, ...
            'tag', 'growth_num_switch', 'enable', 'on', ...
            'callback', @(a,b) growth_rate('uicontrol_callback'), ...
            'position', [gap, gap+1*(b_height+gap), text_width, b_height]);
        
        % L2H
        % Text
        uicontrol('Parent', growth_upanel_numerics, 'style', 'text', 'String', 'Wavelength/Thickness', 'HorizontalAlignment', 'left',...
            'position', [gap, gap+0*(b_height+gap), text_width, b_height]);
        % Field
        obj.growth_L2H = uicontrol('Parent', growth_upanel_numerics, 'style', 'edit', 'String', '', 'BackgroundColor','w',...
            'callback',  @(a,b)  growth_rate('uicontrol_callback'),...
            'tag', 'growth_L2H', ...
            'enable', 'off', ...
            'position', [gap+text_width+gap, gap+0*(b_height+gap), field_width-(gap+b_height), b_height]);
        % Icon
        obj.growth_numerics_settings = ...
            uicontrol('Parent', growth_upanel_numerics, 'style', 'pushbutton',...
            'cdata', ToolbarButtons.settings, 'units', 'pixels',...
            'tag', 'growth_numerics_settings',...
            'enable', 'off', ...
            'callback',  @(a,b) growth_num_setting, ...
            'position', [2*gap+2*text_width-b_height, gap+0*(b_height+gap), b_height, b_height]);
        
        %% Plotting
        % XMIN
        % Text
        uicontrol('Parent', growth_upanel_plotting, 'style', 'text', 'String', 'x-min', 'HorizontalAlignment', 'left',...
            'position', [gap, gap+8*(b_height+gap), text_width, b_height]);
        % Field
        obj.growth_xmin = uicontrol('Parent', growth_upanel_plotting, 'style', 'edit', 'String', '', 'BackgroundColor','w',...
            'callback',  @(a,b)  growth_rate('uicontrol_callback'),...
            'tag', 'growth_xmin', ...
            'position', [gap+text_width+gap, gap+8*(b_height+gap), field_width, b_height]);
        
        % XMAX
        % Text
        uicontrol('Parent', growth_upanel_plotting, 'style', 'text', 'String', 'x-max','HorizontalAlignment', 'left', ...
            'position', [gap, gap+7*(b_height+gap), text_width, b_height]);
        % Field
        obj.growth_xmax = uicontrol('Parent', growth_upanel_plotting, 'style', 'edit', 'String', '', 'BackgroundColor','w',...
            'callback',  @(a,b)  growth_rate('uicontrol_callback'),...
            'tag', 'growth_xmax', ...
            'position', [gap+text_width+gap, gap+7*(b_height+gap), field_width, b_height]);
        
        % YSPAN
        %  ZOOM
        obj.growth_yspan = uicontrol('Parent', growth_upanel_plotting, 'style', 'checkbox', 'String', 'auto y-span', 'Value', 1, ...
            'tag', 'growth_yspan', 'enable', 'on', ...
            'callback', @(a,b) growth_rate('uicontrol_callback'), ...
            'position', [gap, gap+6*(b_height+gap), 2*b_width, b_height]);
        
        % YMIN
        % Text
        uicontrol('Parent', growth_upanel_plotting, 'style', 'text', 'String', 'y-min', 'HorizontalAlignment', 'left',...
            'position', [gap, gap+5*(b_height+gap), text_width, b_height]);
        % Field
        obj.growth_ymin = uicontrol('Parent', growth_upanel_plotting, 'style', 'edit', 'String', '', 'BackgroundColor','w',...
            'callback',  @(a,b)  growth_rate('uicontrol_callback'),...
            'tag', 'growth_ymin', 'enable','off',...
            'position', [gap+text_width+gap, gap+5*(b_height+gap), field_width, b_height]);
        
        % YMAX
        % Text
        uicontrol('Parent', growth_upanel_plotting, 'style', 'text', 'String', 'y-max','HorizontalAlignment', 'left', ...
            'position', [gap, gap+4*(b_height+gap), text_width, b_height]);
        % Field
        obj.growth_ymax = uicontrol('Parent', growth_upanel_plotting, 'style', 'edit', 'String', '', 'BackgroundColor','w',...
            'callback',  @(a,b)  growth_rate('uicontrol_callback'),...
            'tag', 'growth_ymax', 'enable','off',...
            'position', [gap+text_width+gap, gap+4*(b_height+gap), field_width, b_height]);
        
        % XSCALE
        % Text
        uicontrol('Parent', growth_upanel_plotting, 'style', 'text', 'String', 'x-scale','HorizontalAlignment', 'left', ...
            'position', [gap, gap+3*(b_height+gap), text_width, b_height]);
        % Field
        obj.growth_xscale = uicontrol('Parent', growth_upanel_plotting, 'style', 'popupmenu', 'String', {'Linear';'Logarithmic'}, 'BackgroundColor','w',...
            'callback',  @(a,b)  growth_rate('uicontrol_callback'),...
            'tag', 'growth_xscale', ...
            'position', [gap+text_width+gap, gap+3*(b_height+gap), field_width, b_height]);
        
        % YSCALE
        % Text
        uicontrol('Parent', growth_upanel_plotting, 'style', 'text', 'String', 'y-scale','HorizontalAlignment', 'left', ...
            'position', [gap, gap+2*(b_height+gap), text_width, b_height]);
        % Field
        obj.growth_yscale = uicontrol('Parent', growth_upanel_plotting, 'style', 'popupmenu', 'String', {'Linear';'Logarithmic'}, 'BackgroundColor','w',...
            'callback',  @(a,b)  growth_rate('uicontrol_callback'),...
            'tag', 'growth_yscale', ...
            'position', [gap+text_width+gap, gap+2*(b_height+gap), field_width, b_height]);
        
        % NX
        % Text
        uicontrol('Parent', growth_upanel_plotting, 'style', 'text', 'String', 'Number of Points','HorizontalAlignment', 'left', ...
            'position', [gap, gap+1*(b_height+gap), text_width, b_height]);
        % Field
        obj.growth_nx = uicontrol('Parent', growth_upanel_plotting, 'style', 'edit', 'String', '', 'BackgroundColor','w',...
            'callback',  @(a,b)  growth_rate('uicontrol_callback'),...
            'tag', 'growth_nx', ...
            'position', [gap+text_width+gap, gap+1*(b_height+gap), field_width, b_height]);
        
        
        % GRID
        %  ZOOM
        obj.growth_grid = uicontrol('Parent', growth_upanel_plotting, 'style', 'checkbox', 'String', 'Grid', 'Value', 1, ...
            'tag', 'growth_grid', 'enable', 'on', ...
            'callback', @(a,b) growth_rate('plot_update'), ...
            'position', [gap+text_width+gap, gap, 2*b_width, b_height]);
        
        %% Legend panel
        %  Thin plate
        obj.growth_legend_thin = uicontrol('Parent', growth_upanel_legend, 'style', 'checkbox', 'String', 'Thin plate', 'Value', 1, ...
            'tag', 'growth_legend_thin', 'enable', 'on', ...
            'callback', @(a,b) growth_rate('uicontrol_callback'), ...
            'position', [gap, gap+3*(b_height+gap), 2*b_width, b_height]);
        
        %  Thick plate
        obj.growth_legend_thick = uicontrol('Parent', growth_upanel_legend, 'style', 'checkbox', 'String', 'Thick plate', 'Value', 1, ...
            'tag', 'growth_legend_thick', 'enable', 'on', ...
            'callback', @(a,b) growth_rate('uicontrol_callback'), ...
            'position', [gap, gap+2*(b_height+gap), 2*b_width, b_height]);
        
       %  LAF
        obj.growth_legend_LAF = uicontrol('Parent', growth_upanel_legend, 'style', 'checkbox', 'String', 'LAF', 'Value', 1, ...
            'tag', 'growth_legend_LAF', 'enable', 'on', ...
            'callback', @(a,b) growth_rate('uicontrol_callback'), ...
            'position', [gap, gap+1*(b_height+gap), 2*b_width, b_height]); 
        
        %  Thick plate FMT
        obj.growth_legend_thick_FMT = uicontrol('Parent', growth_upanel_legend, 'style', 'checkbox', 'String', 'Thick plate FMT', 'Value', 1, ...
            'tag', 'growth_legend_thick_FMT', 'enable', 'on', ...
            'callback', @(a,b) growth_rate('uicontrol_callback'), ...
            'position', [gap+text_width+gap, gap+3*(b_height+gap), 2*b_width, b_height]);
        
        %  LAF FMT
        obj.growth_legend_LAF_FMT = uicontrol('Parent', growth_upanel_legend, 'style', 'checkbox', 'String', 'LAF FMT', 'Value', 1, ...
            'tag', 'growth_legend_LAF_FMT', 'enable', 'on', ...
            'callback', @(a,b) growth_rate('uicontrol_callback'), ...
            'position', [gap+text_width+gap, gap+2*(b_height+gap), 2*b_width, b_height]);
        
        %  Numerical
        obj.growth_legend_numerical = uicontrol('Parent', growth_upanel_legend, 'style', 'checkbox', 'String', 'Numerical', 'Value', 1, ...
            'tag', 'growth_legend_numerical', 'enable', 'on', ...
            'callback', @(a,b) growth_rate('uicontrol_callback'), ...
            'position', [gap+text_width+gap, gap+1*(b_height+gap), 2*b_width, b_height]);
        
        % Legend
        % Text
        uicontrol('Parent', growth_upanel_legend, 'style', 'text', 'String', 'Legend Position','HorizontalAlignment', 'left', ...
            'position', [gap, gap+0*(b_height+gap), text_width, b_height]);
        % Field
        obj.growth_legend = uicontrol('Parent', growth_upanel_legend, 'style', 'popupmenu', 'String', {'Top-Right outside','Top-right inside','Top-left inside','Bottom-right outside','Bottom-righ inside','Bottom-left inside','none'}, 'BackgroundColor','w',...
            'callback',  @(a,b)  growth_rate('uicontrol_callback'),...
            'tag', 'growth_legend', ...
            'position', [gap+text_width+gap, 2*gap+0*(b_height+gap), field_width, b_height]);
        
       
        % - Plot Axes
        h_cont  = uicontainer('parent', growth_upanel_plot,'tag','growth_uicontainer');
        h_axes  = axes('parent', h_cont,'ActivePositionProperty', 'outerposition');
        box(h_axes, 'on');
        
        % Tags on axes get removed by reset etc. actions. Store in appdata
        % of parent
        setappdata(growth_upanel_plot, 'h_cont', h_cont);
        setappdata(growth_upanel_plot, 'h_axes', h_axes);
        
        % Store in Figure Appdata
        setappdata(growth_gui_handle, 'obj', obj);
        
        % - Default Values
        growth_rate('default_values');
        
        % - Calculate growth rates
        growth_rate('calculate_growth_rate')
        
        % - Update Uicontrols
        growth_rate('uicontrol_update');
        
        % Update plot
        growth_rate('plot_update')
        
          
    case 'default_values'
        %% DEFAULT_VALUES
        
        growth.vis    = 20;
        growth.nl     = 1;
        growth.nm     = 1;
        growth.boxH   = 20;
        growth.ampl   = 0.1;
        growth.L2H    = [];
        
        growth.xmin   = 1;
        growth.xmax   = 50;
        growth.yspan  = 1;
        growth.ymin   = [];
        growth.ymax   = [];
        growth.xscale = 1;
        growth.yscale = 1;
        growth.nx     = 100;
        growth.legend = 2;
        
        growth.legend_thin          = 1;
        growth.legend_thick         = 1;
        growth.legend_thick_FMT     = 1;
        growth.legend_LAF           = 1;
        growth.legend_LAF_FMT       = 1;
        growth.legend_numerical     = 1;
        
        growth.num_switch       = 0;
        growth.mode   = 1;
        growth.num_vis0         = 1e6;
        growth.num_visInf       = 0;
        growth.num_dx           = 0.5;
        growth.num_area         = (growth.num_dx)^2/2;
        growth.num_pic_iter     = 5;
        growth.num_nr_iter      = 20;
        growth.num_rel_res      = 1e-12;
        
        setappdata(growth_gui_handle, 'growth', growth);
    
    case 'uicontrol_callback'
        %% UICONTROL_CALLBACK
        
        % Who is calling
        wcbo            = gcbo;
        Whoiscalling    = get(wcbo, 'tag');
        
        % Get data
        growth = getappdata(growth_gui_handle, 'growth');
        obj    = getappdata(growth_gui_handle, 'obj');
        
        % Check if input values have appropriate format
        if ~strcmpi(Whoiscalling,'growth_upanel_mod') && ~strcmpi(Whoiscalling,'growth_folding') && ~strcmpi(Whoiscalling,'growth_boudinage') && ...
                ~strcmpi(Whoiscalling,'growth_num_switch') && ~strcmpi(Whoiscalling,'growth_L2H') && ...
                ~strcmpi(Whoiscalling,'growth_yspan') && ~strcmpi(Whoiscalling,'growth_xscale') && ~strcmpi(Whoiscalling,'growth_yscale') && ...
                ~strcmpi(Whoiscalling,'growth_legend') && ~strcmpi(Whoiscalling,'growth_legend_thin') && ~strcmpi(Whoiscalling,'growth_legend_thick') && ...
                ~strcmpi(Whoiscalling,'growth_legend_thick_FMT') && ~strcmpi(Whoiscalling,'growth_legend_LAF') && ~strcmpi(Whoiscalling,'growth_legend_LAF_FMT') && ...
                ~strcmpi(Whoiscalling,'growth_legend_numerical') && ~strcmpi(Whoiscalling,'growth_num_apply') && ~strcmpi(Whoiscalling,'growth_num_done') 
           
            if isnan(str2double(get(gcbo,  'string')))
                warndlg('Wrong input argument.', 'Error!', 'modal');
                return;
            end
        end
        
        switch Whoiscalling
            case {'growth_folding','growth_boudinage','growth_upanel_mod'}
                if get(obj.growth_folding,'value')
                    growth.mode = 1; % Folding
                else
                    growth.mode = 0; % Boudinage
                end
                
                % Activate all the legend options
                growth.legend_thin      = 1;
                growth.legend_thick     = 1;
                growth.legend_thick_FMT = 1;
                growth.legend_LAF       = 1;
                growth.legend_LAF_FMT   = 1;
                growth.legend_numerical = 1;
            
            case 'growth_vis'
                if str2double(get(gcbo,  'string')) >= 1
                    growth.vis   	= str2double(get(gcbo,  'string'));
                else
                    warndlg('Viscosity ratio must be greater than 1.', 'Error!', 'modal');
                    growth_rate('uicontrol_update');
                    return;
                end
                
            case 'growth_nl'
                if str2double(get(gcbo,  'string')) > 0
                    growth.nl       = str2double(get(gcbo,  'string'));
                else
                    warndlg('Stress exponent must be a positive value.', 'Error!', 'modal');
                    growth_rate('uicontrol_update');
                    return;
                end
                
            case 'growth_nm'
                if str2double(get(gcbo,  'string')) > 0
                    growth.nm       = str2double(get(gcbo,  'string'));
                else
                    warndlg('Stress exponent must be a positive value.', 'Error!', 'modal');
                    growth_rate('uicontrol_update');
                    return;
                end
            
            case 'growth_boxH'
                if str2double(get(gcbo,  'string')) > 1
                    growth.boxH       = str2double(get(gcbo,  'string'));
                else
                    warndlg('The ratio must be greater than 1.', 'Error!', 'modal');
                    growth_rate('uicontrol_update');
                    return;
                end
             
            case 'growth_ampl'
                growth.ampl       = str2double(get(gcbo,  'string'));
                
            case 'growth_num_switch'
                growth.num_switch = get(wcbo,  'value');
                
                if growth.num_switch == 1
                    growth.L2H = 10;
                else
                    growth.L2H = [];
                end
                
            case 'growth_L2H'
                
                wavelengths   = regexp(get(wcbo,  'string'),['\d+\.?\d?'],'match');
                growth.L2H    = cellfun(@str2num,wavelengths(:))';
                
                %if str2double(get(gcbo,  'string'))> 0
                 %   growth.L2H   = wavelengths;
                %else
                %    warndlg('The value must be larger than 0.', 'Error!', 'modal');
                 %   growth_rate('uicontrol_update');
                 %   return;
                %end
                
            case 'growth_xmax'
                if str2double(get(gcbo,  'string'))> growth.xmin
                    growth.xmax   = str2double(get(gcbo,  'string'));
                else
                    warndlg('x-max must be larger than x-min.', 'Error!', 'modal');
                    growth_rate('uicontrol_update');
                    return;
                end
            
            case 'growth_xmin'
                if str2double(get(gcbo,  'string'))< growth.xmax
                    growth.xmin   = str2double(get(gcbo,  'string'));
                else
                    warndlg('x-min must be smaller than x-max.', 'Error!', 'modal');
                    growth_rate('uicontrol_update');
                    return;
                end
                
            case 'growth_yspan'
                growth.yspan   = get(wcbo,  'value');
                
                if growth.yspan == 0
                    set(obj.growth_ymin,'enable','on')
                    set(obj.growth_ymax,'enable','on')
                    
                    growth_upanel_plot	= findobj(growth_gui_handle, 'tag', 'growth_upanel_plot');
                    h_axes              = getappdata(growth_upanel_plot, 'h_axes');
                    temp                = get(h_axes,'YLim');
                    growth.ymin         = temp(1);
                    growth.ymax         = temp(2);
                    
                else
                    set(obj.growth_ymin,'enable','off')
                    set(obj.growth_ymax,'enable','off')
                    
                    growth.ymin         = [];
                    growth.ymax         = [];
                    
                end
                
            case 'growth_ymax'
                if str2double(get(gcbo,  'string'))> growth.ymin
                    growth.ymax   = str2double(get(gcbo,  'string'));
                else
                    warndlg('y-max must be larger than y-min.', 'Error!', 'modal');
                    growth_rate('uicontrol_update');
                    return;
                end
            
            case 'growth_ymin'
                if str2double(get(gcbo,  'string'))< growth.ymax
                    growth.ymin   = str2double(get(gcbo,  'string'));
                else
                    warndlg('y-min must be smaller than y-max.', 'Error!', 'modal');
                    growth_rate('uicontrol_update');
                    return;
                end
                
            case 'growth_xscale'
                growth.xscale   = get(wcbo,  'value');
                
            case 'growth_yscale'
                growth.yscale   = get(wcbo,  'value');
                
            case 'growth_nx'
                if str2double(get(gcbo,  'string')) > 3
                    growth.nx       = str2double(get(gcbo,  'string'));
                else
                    warndlg('Number of points must be larger than 3.', 'Error!', 'modal');
                    growth_rate('uicontrol_update');
                    return;
                end
                
            case 'growth_legend'
                growth.legend   = get(wcbo,  'value');
                
            case 'growth_legend_thin'
                growth.legend_thin      = get(wcbo,  'value');
                
            case 'growth_legend_thick'
                growth.legend_thick     = get(wcbo,  'value');
                
            case 'growth_legend_thick_FMT'
                growth.legend_thick_FMT = get(wcbo,  'value');
                
            case 'growth_legend_LAF'
                growth.legend_LAF       = get(wcbo,  'value');
                
            case 'growth_legend_LAF_FMT'
                growth.legend_LAF_FMT   = get(wcbo,  'value');
                
            case 'growth_legend_numerical'
                growth.legend_numerical = get(wcbo,  'value');
       
        end
                
        % Save data
        setappdata(growth_gui_handle, 'growth', growth);
        
        % Recalculate growth rates if necessary
        if ~strcmpi(Whoiscalling,'growth_yspan') && ~strcmpi(Whoiscalling,'growth_ymin') && ~strcmpi(Whoiscalling,'growth_ymax') && ...
                ~strcmpi(Whoiscalling,'growth_legend') && ~strcmpi(Whoiscalling,'growth_legend_thin') && ~strcmpi(Whoiscalling,'growth_legend_thick') && ...
                ~strcmpi(Whoiscalling,'growth_legend_thick_FMT') && ~strcmpi(Whoiscalling,'growth_legend_LAF') && ~strcmpi(Whoiscalling,'growth_legend_LAF_FMT') && ...
                ~strcmpi(Whoiscalling,'growth_legend_numerical')
            
            growth_rate('calculate_growth_rate')
        end
        
        % Update Uicontrols
        growth_rate('uicontrol_update');
        
        % - Buttons Enable
        growth_rate('buttons_enable')
        
        % Update plot
        growth_rate('plot_update')
        
        
    case 'uicontrol_update'
        %% UPDATE UICONTROLS
        
        growth = getappdata(growth_gui_handle, 'growth');
        obj    = getappdata(growth_gui_handle, 'obj');
        
        set(obj.growth_vis,     'string', num2str(growth.vis));
        set(obj.growth_nl,    	'string', num2str(growth.nl));
        set(obj.growth_nm,     	'string', num2str(growth.nm));
        set(obj.growth_ampl,   	'string', num2str(growth.ampl));
        set(obj.growth_boxH,  	'string', num2str(growth.boxH));
        set(obj.growth_L2H,  	'string', num2str(growth.L2H));
        set(obj.growth_xmin,   	'string', num2str(growth.xmin));
        set(obj.growth_xmax,   	'string', num2str(growth.xmax));
        set(obj.growth_yspan,  	'value',  growth.yspan);
        set(obj.growth_ymin,   	'string', num2str(growth.ymin));
        set(obj.growth_ymax,   	'string', num2str(growth.ymax));
        set(obj.growth_xscale, 	'value',  growth.xscale);
        set(obj.growth_yscale,	'value',  growth.yscale);
        set(obj.growth_nx,    	'string', num2str(growth.nx));
        set(obj.growth_legend, 	'value',  growth.legend);
        
        set(obj.growth_legend_thin,         'value', growth.legend_thin);
        set(obj.growth_legend_thick,        'value', growth.legend_thick);
        set(obj.growth_legend_thick_FMT,    'value', growth.legend_thick_FMT);
        set(obj.growth_legend_LAF,          'value', growth.legend_LAF);
        set(obj.growth_legend_LAF_FMT,      'value', growth.legend_LAF_FMT);
        set(obj.growth_legend_numerical,    'value', growth.legend_numerical);
        
    case 'buttons_enable'
        %% BUTTONS ENABLE
        
        % Get data
        growth = getappdata(growth_gui_handle, 'growth');
        obj    = getappdata(growth_gui_handle, 'obj');
        
        if growth.mode == 1 % Folding
            
            % Linear
            if growth.nl == 1 && growth.nm == 1
                set(obj.growth_legend_thin,         'enable', 'on');
                set(obj.growth_legend_thick,        'enable', 'on');
                set(obj.growth_legend_thick_FMT,    'enable', 'on');
                set(obj.growth_legend_LAF,          'enable', 'on');
                set(obj.growth_legend_LAF_FMT,      'enable', 'on');
            else
                set(obj.growth_legend_thin,         'enable', 'on');
                set(obj.growth_legend_thick,        'enable', 'on');
                set(obj.growth_legend_thick_FMT,    'enable', 'on');
                set(obj.growth_legend_LAF,          'enable', 'off');
                set(obj.growth_legend_LAF_FMT,      'enable', 'off');
            end
        
        else % Boudinage
            % Linear
            if growth.nl == 1 && growth.nm == 1
                set(obj.growth_legend_thin,         'enable', 'off');
                set(obj.growth_legend_thick,        'enable', 'on');
                set(obj.growth_legend_thick_FMT,    'enable', 'on');
                set(obj.growth_legend_LAF,          'enable', 'off');
                set(obj.growth_legend_LAF_FMT,      'enable', 'off');
            else
                set(obj.growth_legend_thin,         'enable', 'off');
                set(obj.growth_legend_thick,        'enable', 'on');
                set(obj.growth_legend_thick_FMT,    'enable', 'on');
                set(obj.growth_legend_LAF,          'enable', 'off');
                set(obj.growth_legend_LAF_FMT,      'enable', 'off');
            end
        end
        
        if get(obj.growth_num_switch,'value')
            set(obj.growth_L2H,'enable', 'on');
            set(obj.growth_numerics_settings,'enable', 'on');
        else
            set(obj.growth_L2H,'enable', 'off');
            set(obj.growth_numerics_settings,'enable', 'off');
        end
            
        
        set(obj.growth_legend_numerical,            'enable', 'on');
        
    case 'calculate_growth_rate'
        %% CALCLULATE GROWTH RATE
        
        % Get data
        growth = getappdata(growth_gui_handle, 'growth'); 
        obj    = getappdata(growth_gui_handle, 'obj');
        
        [Lam2h, Q] 	= growth_rate_calculate(growth.mode, growth.xscale, growth.vis, growth.nl, growth.nm, growth.nx, growth.boxH/2, growth.ampl, growth.xmin, growth.xmax);
        
        if get(obj.growth_num_switch,'value')
            Q_num    	= numerical_growth_rates(growth.L2H,growth.ampl,growth.boxH/2,growth.vis,growth.num_vis0,growth.num_visInf,growth.nl,growth.nm,growth.mode,...
                growth.num_dx,growth.num_area,growth.num_pic_iter,growth.num_nr_iter,growth.num_rel_res);
            growth.L2H_num 	= growth.L2H;
            Q{6}            = Q_num;
        else
            growth.L2H_num  = [];
            Q{6}            = [];
        end
        
        
        growth.Lam2h    = Lam2h;
        growth.Q        = Q;
        
        % Save data
        setappdata(growth_gui_handle, 'growth', growth);
        
    case 'plot_update'
        %% PLOT_UPDATE
        
        % Get data
        growth = getappdata(growth_gui_handle, 'growth');
        obj    = getappdata(growth_gui_handle, 'obj');
        
        growth_upanel_plot	= findobj(growth_gui_handle, 'tag', 'growth_upanel_plot');
        h_axes              = getappdata(growth_upanel_plot, 'h_axes');
        
        % Clear
        cla(h_axes,'reset');
        
        % Plot 
        hold(h_axes, 'on');
        
        legendlist         = {'Thin plate','Thick plate','Thick plate FMT','LAF','LAF FMT','Numerical model'};
        legendchoice       = [];
        legend_location    = {'northeastoutside','northeast','northwest','southeastoutside','southeast','southwest','none'};
        
        colorlist  = [0         0.4470    0.7410;... % blue
                      0.8500    0.3250    0.0980;    % red
                      0.9290    0.6940    0.1250;    % yellow
                      0.4940    0.1840    0.5560;    % violet
                      0.4660    0.6740    0.1880;    % green
                      0.3010    0.7450    0.9330;    % light blue
                      0.6350    0.0780    0.1840];   % claret (dark red)
        
        % Plot growth rates
        if ~isempty(growth.Q{1}) && growth.legend_thin == 1
            plot(h_axes,growth.Lam2h,growth.Q{1},'Color',colorlist(1,:),'LineWidth',2)
            legendchoice = [legendchoice 1];
        end
        if ~isempty(growth.Q{2}) && growth.legend_thick == 1
            plot(h_axes,growth.Lam2h,growth.Q{2},'Color',colorlist(7,:),'LineWidth',2)
            legendchoice = [legendchoice 2];
        end
        if ~isempty(growth.Q{3}) && growth.legend_thick_FMT
            plot(h_axes,growth.Lam2h,growth.Q{3},'Color',colorlist(3,:),'LineWidth',2)
            legendchoice = [legendchoice 3];
        end
        if ~isempty(growth.Q{4}) && growth.legend_LAF
            plot(h_axes,growth.Lam2h,growth.Q{4},'Color',colorlist(5,:),'LineWidth',2)
            legendchoice = [legendchoice 4];
        end
        if ~isempty(growth.Q{5}) && growth.legend_LAF_FMT
            plot(h_axes,growth.Lam2h,growth.Q{5},'Color',colorlist(2,:),'LineWidth',2)
            legendchoice = [legendchoice 5];
        end
        if ~isempty(growth.Q{6}) && growth.legend_numerical
            plot(h_axes,growth.L2H_num,growth.Q{6},'d','Color','k','MarkerFaceColor','r','MarkerSize',6)
            legendchoice = [legendchoice 6];
        elseif isempty(growth.Q{6})
            % Disable legend
            set(obj.growth_legend_numerical,    'enable', 'off');
        end
                
        if (~isempty(legendchoice)) && (growth.legend ~= 7)
            legend(h_axes,legendlist{legendchoice},'Location',legend_location{growth.legend})
        end
        
        xlabel(h_axes,'\lambda/h')
        ylabel(h_axes,'Growth Rate')
        xlim(h_axes,[growth.xmin growth.xmax])
               
        if growth.yspan == 0
            ylim(h_axes,[growth.ymin growth.ymax])
        end
        
        % Axes
        box(h_axes, 'on');
        if growth.xscale == 1
            set(h_axes,'xscale','linear')
        else
            set(h_axes,'xscale','log')
        end
        if growth.yscale == 1
            set(h_axes,'yscale','linear')
        else
            set(h_axes,'yscale','log')
        end   
        
        % Grid
        grid_val = {'off','on'};
        set(h_axes,'Xgrid',grid_val{get(findobj(growth_gui_handle, 'tag', 'growth_grid'),'value')+1},...
                   'Ygrid',grid_val{get(findobj(growth_gui_handle, 'tag', 'growth_grid'),'value')+1})
             
        
    case 'export_workspace'
        %% EXPORT TO WORKSPACE
        
        %  Get data
        growth              = getappdata(growth_gui_handle, 'growth');
        
        if ~isempty(growth.Q{1})
            GR.Thin_plate.x        = growth.Lam2h;
            GR.Thin_plate.y        = growth.Q{1};
        end
        if ~isempty(growth.Q{2})
            GR.Thick_plate.x       = growth.Lam2h;
            GR.Thick_plate.y       = growth.Q{2};
        end
        if ~isempty(growth.Q{3})
            GR.Thick_plate_FMT.x   = growth.Lam2h;
            GR.Thick_plate_FMT.y   = growth.Q{3};
        end
        if ~isempty(growth.Q{4})
            GR.LAF.x               = growth.Lam2h;
            GR.LAF.y               = growth.Q{4};
        end
        if ~isempty(growth.Q{5})
            GR.LAF_FMT.x           = growth.Lam2h;
            GR.LAF_FMT.y           = growth.Q{5};
        end
        if ~isempty(growth.Q{6})
            GR.Numerics.x          = growth.L2H_num;
            GR.Numerics.y          = growth.Q{6};
        end
        %Growth_Rate.legend  = {'Thin plate','Thick plate','Thick plate FMT','LAF','LAF FMT'};
        
        % Export into workspace
        checkLabels = {'Save data named:'};
        varNames    = {'GR'};
        items       = {GR};
        export2wsdlg(checkLabels,varNames,items,...
            'Save Growth Rate Data to Workspace');
        
    case 'save_figure'
        %% SAVE FIGURE
        
        %  Open dialogbox
        [filename, pathname] = uiputfile(...
            {'*.png';'*.jpg';'*.bmp';'*.tif';'*.eps'},...
            'Save as');
        
        % If any folder is selected
        if length(filename)>1
            
            %  Find plotting axes
            growth_upanel_plot	= findobj(growth_gui_handle, 'tag', 'growth_upanel_plot');
            h_axes              = getappdata(growth_upanel_plot, 'h_axes');
            h_cont              = getappdata(growth_upanel_plot, 'h_cont');
            
            % Get size of the container
            Position    = getpixelposition(h_cont);
            
            % Get current colormap
            Map         = colormap(h_axes);
            
            % Make hidden figure of the same size
            % Switch to visible to see what is going on.
            hidden_plot = figure('units','pixels', 'pos', Position,...
                'NumberTitle','off', 'Name','Hidden Plot','tag','folder_hidden_plot',...
                'MenuBar','none',...
                'visible', 'off', ...
                'Color', [1 1 1]);
            
            set(hidden_plot, 'PaperPositionMode','auto');
            
            % Copy the container to the figure
            new_handle  = copyobj(h_cont, hidden_plot);
            
            % Activate colormap
            colormap(Map);
            
            % White background
            set(new_handle, 'BackgroundColor', [1 1 1]);
            
            % Print
            print(hidden_plot, '-dpng', '-r300', [pathname,filename]);
            
            % Delete figure
            delete(hidden_plot);
        end
        
end
end

%% fun growth_rate_calculate
function [Lam2h, q] = growth_rate_calculate(mode, scale, R, nl, nm, nx, H, amp, xmin,xmax)
%  Close previous waitbars if exist
h = helpdlg('Calculating growth rates - please be patient.', 'Growth Rate');

% Arclength to thickness ratio
if scale == 1
    Lam2h = linspace(xmin,xmax,nx);
else
    Lam2h = logspace(log10(xmin),log10(xmax),nx);
end

% Wavenumber
k = 2*pi./Lam2h;

if mode == 1
    %% -Folding
    
    if nl==1 && nm==1
        %% --Linear
        
        %% --- Thin plate (Biot 1961)
        q{1} = 12*k*R./(R*k.^3+12);
        
        %% --- Thick plate (Fletcher 1977)
        q{2} = 4*k*(1-R)*R./(2*k*(R^2-1)-(R+1)^2*exp(k)+(R-1)^2*exp(-k));
        
        %% --- Thick plate bounded
        AA   = exp(k);
        BB   = exp(k*H);
        q{3} =  -4*k.*(R - 1).*( R*(1-AA.^2./BB.^4) - 2*AA./BB.^2.*(2*H - 1).*( k.*(R-1)- sinh(k) ) )./ ...
            (+ (R-1)^2*(1+AA.^4./BB.^4).*AA.^-1 + ...
            - (R+1)^2*AA.*(1+1./BB.^4 ) + ...
            + 2*k.*(R^2 - 1).*(1-AA.^2./BB.^4) +...
            - 4*AA./BB.^2.*( k.^2.*(2*H-1)*(R-1)^2+2*R - k.*(2*H-1).*sinh(k).*(R^2-1) ) );
        
        %% --- LAF
        dt      = 0.001;
        tspan   = dt*[0:10];
        temp    = zeros(size(Lam2h));
        for iq = 1:length(temp)
            [~,~,Q] = LAF_sine(tspan,R,Lam2h(iq),1,amp);
            temp(iq)= Q(1);
        end
        q{4}    = temp;
        
        %% --- LAF bounded
        dt      = 0.001;
        tspan   = dt*[0:10];
        temp    = zeros(size(Lam2h));
        for iq = 1:length(temp)
            [~,~,Q] = LAF_sine_bounded(tspan,R,Lam2h(iq),1,amp,H);
            temp(iq)= Q(1);
        end
        q{5}    = temp;
        
        
    else
        %% --Non-linear
        
        if nl == 1
            nl = 1.000001;
        end
        if nm == 1
            nm = 1.000001;
        end
        
        %% --- Thin plate (Fletcher 1974)
        q{1}    = nl./(k.^2/12 + sqrt(nl^2/nm)/R./k);
        
        %% --- Thick plate (Fletcher 1974)
        % Introduce coefficients
        alpha   = sqrt(1./nl);
        beta    = sqrt(1-1./nl);
        Q       = sqrt(nl/nm)/R;
        temp1	= -2*nl.*(1-1/R);
        temp2   = (1-Q^2);
        temp3   = sqrt(nl-1)./(2*sin(beta*k));
        temp4   = (1+Q^2)*(exp(alpha*k)-exp(-alpha*k));
        temp5   =     2*Q*(exp(alpha*k)+exp(-alpha*k));
        
        % Amplification factor
        q{2}    = temp1 ./ ( temp2 - temp3.*(temp4 + temp5) );
        
        %% --- Thick plate bounded
        temp     = zeros(size(Lam2h));
        for iq = 1:length(temp)
            temp(iq) = growth_rate_SAS_boundary(2*pi/k(iq),R,nl,nm,1,H);
        end
        q{3}  	= temp;
        q{4}    = [];
        q{5}    = [];
        
    end
    
else
    %% - Boudinage
    if nl==1 && nm==1
        %% --Linear
        
        %% --- Thin plate
        q{1}  = [];
        
        %% --- Thick plate (Johnson & Fletcher 1994 p.220)
        q{2} = 4*k*(1-R)*R./(2*k*(R^2-1)+(R+1)^2*exp(k)-(R-1)^2*exp(-k));
        
        %% --- Thick plate bounded
        AA   = exp(k);
        BB   = exp(k*H);
        
        q{3} = 4*k.*(R - 1).*( R*(1-AA.^2./BB.^4) - 2*AA./BB.^2.*(2*H - 1).*( k.*(R-1)+ sinh(k) ) )./ ...
            (+ (R-1)^2*(1+AA.^4./BB.^4).*AA.^-1 +...
            - (R+1)^2*AA.*(1+1./BB.^4 ) + ...
            - 2*k.*(R^2 - 1).*(1-AA.^2./BB.^4) +...
            + 4*AA./BB.^2.*( k.^2.*( 2*H-1 )*(R-1)^2+ 2*R + k.*( 2*H-1 ).*sinh(k).*(R^2-1)  ) );
        
        q{4}    = [];
        q{5}    = [];
    else
        %% --Non-linear
        if nl == 1
            nl = 1.0001;
        end
        if nm == 1
            nm = 1.0001;
        end
        
        %% --- Thin plate
        q{1} = [];
        
        
        %% --- Thick plate (Pollard & Fletcher 1994 p.430)
        % Introduce coefficients
        alpha   = sqrt(1./nl);
        beta    = sqrt(1-1./nl);
        Q       = sqrt(nl/nm)/R;
        temp1	= -2*nl.*(1-1/R);
        temp2   = (1-Q^2);
        temp3   = sqrt(nl-1)./(2*sin(beta*k));
        temp4   = (1+Q^2)*(exp(alpha*k)-exp(-alpha*k));
        temp5   =     2*Q*(exp(alpha*k)+exp(-alpha*k));
        
        % Amplification factor
        q{2}    = temp1 ./ ( temp2 + temp3.*(temp4 + temp5) );
        
        %% --- Thick plate bounded
        temp     = zeros(size(Lam2h));
        for iq = 1:length(temp)
            temp(iq) = growth_rate_SAS_necking_boundary(2*pi/k(iq),R,nl,nm,1,H);
        end
        q{3}    = temp;
        
        q{4}    = [];
        q{5}    = [];
        
    end
end
delete(h);
end

function Q = numerical_growth_rates(L2H,A,H,Mu,Mu0,MuInf,Nl,Nm,strain_mode,dx,max_area,max_it_pic,max_it_nr,relres)
%% fun_numerical_growth_rates

Q = zeros(1,length(L2H));

for ii = 1:length(L2H)
    
    L           = L2H(ii);
    nx          = round(L/dx);
    Mus         = [1;Mu;1];
    Ns          = [Nm;Nl;Nm];
    
    Mus0        = zeros(3,1);
    MusInf      = zeros(3,1);
    for in = 1:3
        if Ns(in) == 1
            % Linear materials
            Mus0(in)    = Mus(in);
            MusInf(in)  = Mus(in);
        else
            % Non-lienar materials
            Mus0(in)    = Mu0*Mus(in);
            MusInf(in)  = MuInf*Mus(in);
        end
    end
    try
        Vel   = growth_rate_vel_solver(L,H,A,nx,max_area,Mus,Mus0,MusInf,Ns,strain_mode,max_it_pic,max_it_nr,relres);
        vel   = reshape(Vel,2,size(Vel,1)/2);
        vel   = vel(:,3:end-2);
        vy    = vel(2,:);
        
        vy_dn   = vy(1:nx);
        %vy_up   = vy(nx+1:end);
        
        if strain_mode == 1
            % Folding
            Q(ii)    = (max(vy_dn)-min(vy_dn))/2/abs(A)-1;
        else
            % Boudinage
            Q(ii)    = (vy_dn(1)-vy_dn(end))/2/abs(A)-1;
        end
    catch err
        uiwait(warndlg(err.message, 'modal'));
        Q = [];
    end
end

end