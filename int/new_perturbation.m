function new_perturbation(Action)

% Original author:    Marta Adamuszek
% Last committed:     $Revision: 91 $
% Last changed by:    $Author: schmid $
% Last changed date:  $Date: 2017-08-21 16:17:19 +0200 (Mon, 21 Aug 2017) $
%--------------------------------------------------------------------------

%% input check
if nargin==0
    Action = 'initialize';
end

%% find gui
pert_gui_handle = findobj(0, 'tag', 'pert_gui_handle', 'type', 'figure');

switch lower(Action)
    case 'initialize'
        %% INITIALIZE
        
        %  Delete figure if it already exists
        if ~isempty(pert_gui_handle)
            delete(pert_gui_handle);
        end
        
        %  Add current path and subfolders
        addpath(genpath(pwd));
       
        Screensize      = get(0, 'ScreenSize');
        
        x_res           = Screensize(3);
        y_res           = Screensize(4);
        fracx           = 10;
        gui_width       = x_res/fracx*(fracx-2);
        gui_height      = 0.7*y_res;
        
        % Create dialog window
        pert_gui_handle = figure( ...
            'Name' ,'New Perturbation', 'Units','pixels', 'tag','pert_gui_handle',...
            'NumberTitle', 'off', 'DockControls', 'off', 'MenuBar', 'none', 'ToolBar', 'none',...
            'pos', [x_res/fracx, (y_res-gui_height)/2, gui_width, gui_height], 'Color',get(0, 'DefaultUipanelBackgroundColor'));%,...
            %'WindowStyle', 'modal');
        
        %% Main Layout
        % Find default character size
        try
            folder_gui_handle = findobj(0, 'tag', 'folder_gui_handle', 'type', 'figure');
            b_width  = getappdata(folder_gui_handle, 'b_width');
            b_height = getappdata(folder_gui_handle, 'b_height');
            gap      = getappdata(folder_gui_handle, 'gap');
        catch
            warndlg('You should start to run the main Folder function first.', 'Error');
            return;
        end
        
        %  Save default sizes in figure
        setappdata(pert_gui_handle, 'b_height', b_height);
        setappdata(pert_gui_handle, 'b_width',  b_width);
        setappdata(pert_gui_handle, 'gap',      gap);
        
        % Arrange panels
        % Panels dimensions
        panel_width             = 3*b_width+4*gap;
        
        text_width              = 1.5*b_width+gap;
        box_width               = 1.5*b_width+gap;
        
        start_panel             = 2*(b_height+gap)+4*gap;
        interface_panel         = 6*(b_height+gap)+4*gap;
        plotting_panel          = 2*(b_height+gap)+4*gap;
        control_panel           = 3*(b_height+gap)+4*gap;
        
        % Division of the figure into panels
        b1                      = uiextras.HBox('Parent', pert_gui_handle);
        
        left_panel              = uiextras.VBox('Parent', b1, 'Spacing', gap);
        pert_upanel_start       = uipanel( 'Parent', left_panel,'title','Start','tag','pert_upanel_start');
        pert_upanel_interface   = uipanel( 'Parent', left_panel,'title','Interface','tag','pert_upanel_interface');
        pert_upanel_plot        = uipanel( 'Parent', left_panel,'title','Scale Y-axis','tag','pert_panel_uplot');
        pert_upanel_control     = uipanel( 'Parent', left_panel,'title','Controls','tag','pert_upanel_control');
        
        set( left_panel, 'Sizes', [start_panel interface_panel plotting_panel control_panel]);
        
        rght_panel              = uiextras.VBox('Parent', b1, 'Spacing', gap);
        pert_upanel_current     = uipanel( 'Parent', rght_panel,'title','Current','tag','pert_upanel_current');
        pert_upanel_final       = uipanel( 'Parent', rght_panel,'title','Final','tag','pert_upanel_final');
        
        set( rght_panel, 'Sizes', [-1 -1]);

        set( b1, 'Sizes', [panel_width -1]);
        
        
        %% - Start
        %  NX
        %  Text
        uicontrol('Parent', pert_upanel_start, 'style', 'text', 'String', 'nx', 'HorizontalAlignment', 'left', ...
            'position', [gap, 1*(b_height+gap)+gap, text_width, b_height],...
            'tooltipstring','Number of nodes on interface.');
         % Position field
        obj.pert_nx = uicontrol('Parent', pert_upanel_start, 'style', 'edit', 'String', '','BackgroundColor','w', ...
            'callback',  @(a,b)  new_perturbation('uicontrol_callback'),...
            'tag', 'pert_nx', ...
            'position', [gap+text_width, 1*(b_height+gap)+gap, box_width, b_height]); 
        
        % RESTART
        uicontrol('Parent', pert_upanel_start, 'style', 'pushbutton', 'String', 'Restart', ...
            'callback',  @(a,b)  new_perturbation('restart'),...
            'tooltipstring','Clear both figures.',...
            'position', [panel_width-(b_width+gap), 0*(b_height+gap)+gap, b_width, b_height]);
        
        
        %% - Interface
        %  PERTURBATION
        %  Text
        uicontrol('Parent', pert_upanel_interface, 'style', 'text', 'String', 'Perturbation', 'HorizontalAlignment', 'left', ...
            'position', [gap, 5*(b_height+gap)+gap, text_width, b_height],...
            'tooltipstring','Perturbation type.');
         % Position field
        obj.pert_pert = uicontrol('Parent', pert_upanel_interface, 'style', 'popupmenu', 'String', {'Sine';'Red Noise'; 'White Noise'; 'Gaussian Noise'; 'Step'; 'Triangle'; 'Bell'}, 'value', 1, ...
            'callback',  @(a,b)  new_perturbation('uicontrol_callback'),'BackgroundColor','w', ...
            'tag', 'pert_pert', ...
            'position', [gap+text_width, 5*(b_height+gap)+gap, box_width, b_height]);
        
        %  AMPLITUDE
        %  Text
        uicontrol('Parent', pert_upanel_interface, 'style', 'text', 'String', 'Amplitude', 'HorizontalAlignment', 'left', ...
            'position', [gap, 4*(b_height+gap)+gap, text_width, b_height],...
            'tooltipstring','Perturbation amplitude.');
         % Position field
        obj.pert_ampl = uicontrol('Parent', pert_upanel_interface, 'style', 'edit', 'String', '','BackgroundColor','w', ...
            'callback',  @(a,b)  new_perturbation('uicontrol_callback'),...
            'tag', 'pert_ampl', ...
            'position', [gap+text_width, 4*(b_height+gap)+gap, box_width, b_height]);
        
        %  WAVELENGTH
        %  Text
        uicontrol('Parent', pert_upanel_interface, 'style', 'text', 'String', 'Wavelenth', 'HorizontalAlignment', 'left', ...
            'position', [gap, 3*(b_height+gap)+gap, text_width, b_height],...
            'tooltipstring','Perturbation wavelegth.');
         % Position field
        obj.pert_wave = uicontrol('Parent', pert_upanel_interface, 'style', 'edit', 'String', '','BackgroundColor','w', ...
            'callback',  @(a,b)  new_perturbation('uicontrol_callback'),...
            'tag', 'pert_wave', ...
            'position', [gap+text_width, 3*(b_height+gap)+gap, box_width, b_height]);
          
        %  PHASE SHIFT
        %  Text
        uicontrol('Parent', pert_upanel_interface, 'style', 'text', 'String', 'Shift', 'HorizontalAlignment', 'left', ...
            'position', [gap, 2*(b_height+gap)+gap, text_width, b_height],...
            'tooltipstring','Shift of the perturbation. Domain width represents the full period.');
         % Position field
        obj.pert_phase_shift = uicontrol('Parent', pert_upanel_interface, 'style', 'edit', 'String', '','BackgroundColor','w', ...
            'callback',  @(a,b)  new_perturbation('uicontrol_callback'),...
            'tag', 'pert_phase_shift', ...
            'position', [gap+text_width, 2*(b_height+gap)+gap, box_width, b_height]);
        
        %  Bell width
        %  Text
        obj.pert_bell_width_text = uicontrol('Parent', pert_upanel_interface, 'style', 'text', 'String', 'Bell Width', 'HorizontalAlignment', 'left', ...
            'position', [gap, 1*(b_height+gap)+gap, text_width, b_height],...
            'tag','pert_bell_width_text',...
            'tooltipstring','Width of the bell-shape perturbation.');
         % Position field
        obj.pert_bell_width = uicontrol('Parent', pert_upanel_interface, 'style', 'edit', 'String', '','BackgroundColor','w', ...
            'callback',  @(a,b)  new_perturbation('uicontrol_callback'),...
            'tag', 'pert_bell_width', ...
            'position', [gap+text_width, 1*(b_height+gap)+gap, box_width, b_height]);
        
        % ADD
        obj.pert_add_pert = uicontrol('Parent', pert_upanel_interface, 'style', 'pushbutton', 'String', 'Add', ...
            'callback',  @(a,b)  new_perturbation('uicontrol_callback'),...
            'tag','pert_add_pert',...
            'position', [panel_width-2*(b_width+gap), 0*(b_height+gap)+gap, b_width, b_height]);
        
        %  Clear
        obj.pert_clear = uicontrol('Parent', pert_upanel_interface, 'style', 'pushbutton', 'String', 'Clear', ...
            'callback',  @(a,b)  new_perturbation('uicontrol_callback'),...
            'tag','pert_clear','tooltipstring','Clear final perturbation plot.',...
            'position', [panel_width-(b_width+gap), 0*(b_height+gap)+gap, b_width, b_height]);
        
        
        %% - Current Plotting Setting
        % Upper
        %  Text
        uicontrol('Parent', pert_upanel_plot, 'style', 'text', 'String', 'Upper Plot', 'HorizontalAlignment', 'left', ...
            'position', [gap, 1*(b_height+gap)+gap, text_width, b_height],...
            'tooltipstring','Scale y-axis in the current perturbation plot.');
         % Position field
        obj.pert_exaggeration_upper = uicontrol('Parent', pert_upanel_plot, 'style', 'edit', 'String', '','BackgroundColor','w', ...
            'callback',  @(a,b)  new_perturbation('uicontrol_callback'),...
            'tag', 'pert_exaggeration_upper', ...
            'position', [gap+text_width, 1*(b_height+gap)+gap, box_width, b_height]);
        
        % Lower
        %  Text
        uicontrol('Parent', pert_upanel_plot, 'style', 'text', 'String', 'Lower Plot', 'HorizontalAlignment', 'left', ...
            'position', [gap, 0*(b_height+gap)+gap, text_width, b_height],...
            'tooltipstring','Scale y-axis in the final perturbation plot.');
         % Position field
        obj.pert_exaggeration_lower = uicontrol('Parent', pert_upanel_plot, 'style', 'edit', 'String', '','BackgroundColor','w', ...
            'callback',  @(a,b)  new_perturbation('uicontrol_callback'),...
            'tag', 'pert_exaggeration_lower', ...
            'position', [gap+text_width, 0*(b_height+gap)+gap, box_width, b_height]);
        
        %% - Controls
        %  Load
        uicontrol('Parent', pert_upanel_control, 'style', 'pushbutton', 'String', 'Load', ...
            'callback',  @(a,b)  new_perturbation('load'),...
            'tooltipstring','Load perturbation or image.',...
            'position', [panel_width-(b_width+gap), 2*(b_height+gap)+gap, b_width, b_height]);
        
        %  Save
        obj.new_save = uicontrol('Parent', pert_upanel_control, 'style', 'pushbutton', 'String', 'Save', ...
            'callback',  @(a,b)  new_perturbation('save'),'enable','off',...
            'tag','new_save',...
            'tooltipstring','Save perturbation.',...
            'position', [panel_width-(b_width+gap), 1*(b_height+gap)+gap, b_width, b_height]);
        
        %  Close
        uicontrol('Parent', pert_upanel_control, 'style', 'pushbutton', 'String', 'Close', ...
            'callback',  @(a,b) close(gcf),...
            'position', [panel_width-(b_width+gap), 0*(b_height+gap)+gap, b_width, b_height]);
        
        
        %% - Curent plot
        h_axes_up  = axes('parent', pert_upanel_current);
        box(h_axes_up, 'on');
        
        % Allow for modification
        set(pert_gui_handle,'WindowButtonDownFcn',   @(a,b) start_draw_perturbation,...
                            'WindowButtonUpFcn',     @(a,b) stop_draw_perturbation);
                        
        hcmenu = uicontextmenu('Parent',pert_gui_handle);
        obj.pert_upper_grid = uimenu(hcmenu, 'Label','Grid','Checked','off',...
            'callback',@(a,b)  new_perturbation('uicontrol_callback'),...
            'tag','pert_upper_grid');
        set(h_axes_up,'uicontextmenu',hcmenu);
        
        %% - Final plot
        h_axes_dn  = axes('parent', pert_upanel_final);
        box(h_axes_dn, 'on');
        
        hcmenu = uicontextmenu('Parent',pert_gui_handle);
        obj.pert_lower_grid = uimenu(hcmenu, 'Label','Grid','Checked','off',...
            'callback',@(a,b)  new_perturbation('uicontrol_callback'),...
            'tag','pert_lower_grid');
        set(h_axes_dn,'uicontextmenu',hcmenu);
        
        % Store data
        setappdata(pert_upanel_current, 'h_axes_up', h_axes_up);
        setappdata(pert_upanel_final,   'h_axes_dn', h_axes_dn);
        
        % Store in Figure Appdata
        setappdata(pert_gui_handle, 'obj', obj);
        
        % - pert Default Values
        new_perturbation('default_values');
        
        % - Update Uicontrols
        new_perturbation('uicontrol_update');
        
        % - Buttons Enable
        new_perturbation('buttons_enable')
        
        % - Generate perturbation
        new_perturbation('perturbation_update')
        
        % - Update Plot
        new_perturbation('plot_update');
        
    case 'default_values'
        %% DEFAULT_VALUES
        
        % find default data saved in folder_gui_handle
        folder_gui_handle = findobj(0, 'tag', 'folder_gui_handle', 'type', 'figure');
        
        % Assign values from FOLDER if exist
        if ~isempty(folder_gui_handle)
            % Get data
            fold  = getappdata(folder_gui_handle, 'fold');
            
            npert.box_width             = fold.box.width;
            npert.line_color         	= fold.selection.line_color;
            npert.line_width          	= fold.selection.line_width;
            npert.marker_size         	= fold.selection.marker_size;
            npert.marker_color        	= fold.selection.marker_color;
            npert.marker_edge_color    	= fold.selection.marker_edge_color;
        end
        
        npert.marker    = 'o';
        npert.mode      = 1;
        npert.pert      = 1;
        npert.ampl      = 0.1;
        npert.wave      = npert.box_width;
        npert.shift     = 0;
        npert.width     = 1;
        npert.nx        = 50;
        npert.xx        = 0;
        npert.yy        = 0;
        npert.exag_upper= 1;
        npert.exag_lower= 1;
        npert.upper_grid= 0;
        npert.lower_grid= 0;
        npert.PICTURE   = [];
        
        % Store in Figure Appdata
        setappdata(pert_gui_handle, 'npert', npert);

    
    case 'uicontrol_update'
        %% UICONTROL_UPDATE
        
        % Get data
        obj     = getappdata(pert_gui_handle, 'obj'); 
        npert   = getappdata(pert_gui_handle, 'npert');
        
        % - Interface
        set(obj.pert_pert,               'value',  npert.pert);
        set(obj.pert_ampl,               'string', num2str(npert.ampl));
        set(obj.pert_wave,               'string', num2str(npert.wave));
        set(obj.pert_phase_shift,        'string', num2str(npert.shift));
        set(obj.pert_bell_width,         'string', num2str(npert.width));
        set(obj.pert_nx,                 'string', num2str(npert.nx));
        set(obj.pert_exaggeration_upper, 'string', num2str(npert.exag_upper));
        set(obj.pert_exaggeration_lower, 'string', num2str(npert.exag_lower));
        
        if npert.upper_grid==1;
            set(obj.pert_upper_grid,'Check','on')
        else
            set(obj.pert_upper_grid,'Check','off')
        end
        
        if npert.lower_grid==1;
            set(obj.pert_lower_grid,'Check','on')
        else
            set(obj.pert_lower_grid,'Check','off')
        end
        
        
    case 'perturbation_update'
        %% PERTURBATION UPDATE
        
        % Get data
        npert   = getappdata(pert_gui_handle, 'npert');
        
        % Generate 
        npert.x       = linspace(-npert.box_width/2,npert.box_width/2,npert.nx);
        npert.y       = perturbation(npert.pert, npert.wave, npert.box_width, npert.shift, npert.width,npert.nx, npert.ampl);
        
        % Update data
        setappdata(pert_gui_handle, 'npert', npert);
        
    case 'plot_update'
        %% PLOT UPDATE
        
        % Get data
        obj     = getappdata(pert_gui_handle, 'obj'); 
        npert   = getappdata(pert_gui_handle, 'npert');
        
        % UPPER PLOT
        %  Find plotting axes
        pert_upanel_current	= findobj(pert_gui_handle, 'tag', 'pert_upanel_current');
        h_axes_up           = getappdata(pert_upanel_current, 'h_axes_up');
        
        % Clear
        cla(h_axes_up, 'reset');
        hold(h_axes_up, 'on');
        
        % Plot image
        if ~isempty(npert.PICTURE)
            %I = image([1, size(npert.PICTURE,2)], [1, size(npert.PICTURE,1)], flipdim(npert.PICTURE, 1), 'Parent', h_axes_up);
            image(npert.PICTURE.X,npert.PICTURE.Y,npert.PICTURE.C, 'Parent', h_axes_up);
            %set(h_axes_up,  'YDir', 'normal');
        end
        
        % Plot 
        ph = plot(npert.x,npert.y,...
            'Color',0.7*[1 1 1],'LineWidth',1,'Marker',npert.marker,...
            'MarkerFaceColor',0.7*[1 1 1],'MarkerSize',3,'MarkerEdgeColor',0.7*[1 1 1],...
            'Parent', h_axes_up);
        
        % Save plot data
        setappdata(pert_gui_handle,'ph',ph);
        
        % Axis
        box(h_axes_up, 'on');
        axis(h_axes_up,'equal');
        set(h_axes_up,'DataAspectRatio',[1 1/npert.exag_upper 1]);
        
        % Grid
        if npert.upper_grid == 1
            grid(h_axes_up,'on')
        else
            grid(h_axes_up,'off')
        end
        
        
        % LOWER PLOT
        %  Find plotting axes
        pert_upanel_final 	= findobj(pert_gui_handle, 'tag', 'pert_upanel_final');
        h_axes_dn           = getappdata(pert_upanel_final, 'h_axes_dn');
        
        % Clear
        cla(h_axes_dn, 'reset');
        hold(h_axes_dn, 'on');
        
        % Plot 
        ph2 = plot(npert.x,npert.y,...
            'Color',0.7*[1 1 1],'LineWidth',1,'Marker',npert.marker,...
            'MarkerFaceColor',0.7*[1 1 1],'MarkerSize',3,'MarkerEdgeColor',0.7*[1 1 1],...
            'Parent', h_axes_dn);
        % Save plot data
        setappdata(pert_gui_handle,'ph2',ph2);
        
        if length(npert.xx)>1
        plot(npert.xx,npert.yy,...
            'Color',npert.line_color,'LineWidth',npert.line_width,'Marker',npert.marker,...
            'MarkerFaceColor',npert.marker_color,'MarkerSize',npert.marker_size,'MarkerEdgeColor',npert.marker_edge_color,...
            'Parent', h_axes_dn)
        end
        
        % Axis
        box(h_axes_dn, 'on');
        axis(h_axes_dn,'equal');
        set(h_axes_dn,'DataAspectRatio',[1 1/npert.exag_lower 1]);
        
        % Grid
        if npert.lower_grid == 1
            grid(h_axes_dn,'on')
        else
            grid(h_axes_dn,'off')
        end
        
        % Update Data
        setappdata(pert_gui_handle, 'npert', npert);
        
        
    case 'uicontrol_callback'
        %% UICONTROL_CALLBACK
        
        % Who is calling
        wcbo            = gcbo;
        Whoiscalling    = get(wcbo, 'tag');
        
        % Get data
        npert   = getappdata(pert_gui_handle, 'npert');
        
        switch Whoiscalling
            
            case 'pert_pert'
                
                npert.pert    	= get(wcbo,  'value');
                
                % Get data
                obj             = getappdata(pert_gui_handle, 'obj'); 
                % Modify name
                if npert.pert == 4
                    set(obj.pert_bell_width_text,'String','Hurst Exponent','tooltipstring',sprintf(''))
                    % Set default value
                    npert.width = 1;
                else
                    set(obj.pert_bell_width_text,'String','Bell Width','tooltipstring',sprintf('Width of the bell-shape perturbation.'))
                end
                
            case 'pert_ampl'
                npert.ampl          = str2double(get(wcbo,  'string'));
                
            case 'pert_wave'
                if str2double(get(wcbo,  'string')) > 0
                    npert.wave       = str2double(get(wcbo,  'string'));
                else
                    warndlg('The wavelength must be a positive value.', 'Error!', 'modal');
                end
                
            case 'pert_phase_shift'
                
                % Check if pert shift is not outside the domain
                if (str2double(get(wcbo,  'string')) <= -npert.box_width/2) || (str2double(get(wcbo,  'string')) >= npert.box_width/2)
                    warndlg('The value must be smaller than half of the domain width.', 'Error!', 'modal');
                else
                    npert.shift         = str2double(get(wcbo,  'string'));
                end
                
            case 'pert_bell_width'
                if npert.pert ~= 4
                    % Check if the bell width is a positive value
                    if str2double(get(wcbo,  'string')) <= 0
                        warndlg('The bell width must be a positive value.', 'Error!', 'modal');
                    else
                        npert.width         = str2double(get(wcbo,  'string'));
                    end
                else
                    % Check if the Hurst exponent is between 0-1
                    if str2double(get(wcbo,  'string')) < 0 || str2double(get(wcbo,  'string')) > 1
                        warndlg('The Hurst exponent value must be between 0 and 1.', 'Error!', 'modal');
                    else
                        npert.width         = str2double(get(wcbo,  'string'));
                    end
                end
                
            case 'pert_nx'
                if str2double(get(wcbo,  'string')) > 2
                    npert.nx        = str2double(get(wcbo,  'string'));
                else
                    warndlg('Number of points on the interface should be larger than 2.', 'Error!', 'modal');
                end
                
            case 'pert_clear'
                
                % Clear final perturbation
                npert.xx = 0;
                npert.yy = 0;
                
            case 'pert_add_pert'
                
                % Update perturbation
                npert.xx = npert.x;
                npert.yy = npert.yy + npert.y;
                
            case 'pert_upper_grid'
                
                npert.upper_grid = mod(npert.upper_grid+1,2);
                
            case 'pert_lower_grid'
                
                npert.lower_grid = mod(npert.lower_grid+1,2);
                
            case 'pert_exaggeration_upper'
                if str2double(get(wcbo,  'string')) > 0
                    npert.exag_upper   = str2double(get(wcbo,  'string'));
                else
                    warndlg('The number must be larger than 0.', 'Error!', 'modal');
                end
                
            case 'pert_exaggeration_lower'
                if str2double(get(wcbo,  'string')) > 0
                    npert.exag_lower    = str2double(get(wcbo,  'string'));
                else
                    warndlg('The number must be larger than 0.', 'Error!', 'modal');
                end
                
        end
        
        % Update Data
        setappdata(pert_gui_handle, 'npert', npert);
        
        % Change Run Data State
        new_perturbation('buttons_enable');
        
        % - Update perturbation if necessary
        if ~strcmpi(Whoiscalling, 'pert_upper_grid') && ~strcmpi(Whoiscalling, 'pert_lower_grid') && ...
           ~strcmpi(Whoiscalling, 'pert_exaggeration_upper') && ~strcmpi(Whoiscalling, 'pert_exaggeration_lower')
                
            new_perturbation('perturbation_update')
        end
        
        % - Uicontrolupdate
        new_perturbation('uicontrol_update')
        
        % Plot Update
        new_perturbation('plot_update');    
        
    case 'buttons_enable'
        %% BUTTONS ENABLE
        
        % Get data
        obj     = getappdata(pert_gui_handle, 'obj');
        npert   = getappdata(pert_gui_handle, 'npert');
        
        if npert.mode
            set(obj.pert_pert,         	 'enable', 'on');
            set(obj.pert_ampl,           'enable', 'on');
            set(obj.pert_wave,           'enable', 'on');
            set(obj.pert_phase_shift,    'enable', 'on');
            set(obj.pert_bell_width,     'enable', 'on');
            
            switch npert.pert
                case 1
                    set(obj.pert_bell_width,  'enable', 'off');
                case {2,3}
                    set(obj.pert_wave,        'enable', 'off');
                    set(obj.pert_phase_shift, 'enable', 'off');
                    set(obj.pert_bell_width,  'enable', 'off');
                case 4
                    set(obj.pert_phase_shift, 'enable', 'off');
                case 5
                    set(obj.pert_wave,        'enable', 'off');
                    set(obj.pert_bell_width,  'enable', 'off');
                case 6
                    set(obj.pert_bell_width,  'enable', 'off');
                case 7
                    set(obj.pert_wave,        'enable', 'off');
            end
            
        else
            set(obj.pert_pert,         	 'enable', 'off');
            set(obj.pert_ampl,           'enable', 'off');
            set(obj.pert_wave,           'enable', 'off');
            set(obj.pert_phase_shift,    'enable', 'off');
            set(obj.pert_bell_width,     'enable', 'off');
        end
        
        if length(npert.xx)==1
            set(obj.pert_nx,             'enable', 'on');
            set(obj.new_save,            'enable', 'off');
        else
            set(obj.pert_nx,             'enable', 'off');
            set(obj.new_save,            'enable', 'on');
        end
    
    case 'load'
        %% LOAD
        
        % Get data
        npert   = getappdata(pert_gui_handle, 'npert');
        
        %  Load in files
        [filename, pathname] = uigetfile({'*.mat;*.jpg;*.png', 'FOLDER Input Files'},'Pick a file');
        
         if length(filename)==1 && filename==0
            return;
        end
  
        try
            switch filename(end-2:end)
                case 'mat'
                    Input_data  = load([pathname,filename]);
                    
                    try 
                        npert       = Input_data.npert;
                    catch
                        warndlg('The file does not have a proper structure.', 'Error!', 'modal');
                        return;
                    end
                    
                otherwise
                    % Picture Format
                    I  = imread([pathname,filename]);
                    
                    scale = npert.box_width/size(I,2);
                    npert.PICTURE.X = [-1 1]*(size(I,2)-1)/2*scale;
                    npert.PICTURE.Y = [1 -1]*(size(I,1)-1)/2*scale;
                    npert.PICTURE.C = I;
            end
        catch err
            errordlg(err.message, 'Loading Error');
            return;
        end
        
        %  Write data into storage
        setappdata(pert_gui_handle, 'npert', npert);
        
        % Change Run Data State
        new_perturbation('buttons_enable');
        
        % Update Uicontrols
        new_perturbation('uicontrol_update');
        
        % Plot Update
        new_perturbation('plot_update');
        
        
    case 'save'
        %% SAVE
        
        % Get data
        npert   = getappdata(pert_gui_handle, 'npert');
        
        if isempty(npert)
            warndlg('No data to save!', 'FOLDER Toolbox');
            return;
        end
        
        % Scale perturbation to be between <-1,1>
        pert = npert.yy;
        pert = 2/(max(pert)-min(pert))*pert;
        pert = pert - (max(pert)-1);
        npert.yy = pert;
        
        [Filename, Pathname] = uiputfile(...
            {'*.mat'},'Save perturbation as',['perturbation',filesep,'new_perturbation.mat']);
        
        % Save perturbation
        if ~(length(Filename)==1 && Filename==0)
            save([Pathname, Filename], 'npert');
        end
        
        % Find mai gui
        folder_gui_handle = findobj(0, 'tag', 'folder_gui_handle', 'type', 'figure');
        
        % Update main gui if exists
        try
            %  Get data
            fold        = getappdata(folder_gui_handle, 'fold');
            
            % Identify index
            if isfield(fold,'pert')
                idx = length(fold.pert) + 1;
            else
                idx = 1;
            end
            
            fold.pert(idx).name = Filename(1:end-4);
            fold.pert(idx).x    = npert.xx;
            fold.pert(idx).y    = npert.yy;
            
            % Update perturbation list
            pert_name = {'Sine';'Red Noise'; 'White Noise'; 'Gaussian Noise'; 'Step'; 'Triangle'; 'Bell'};
            pert_name = [pert_name;cellstr(strvcat(fold.pert.name))];
            set(findobj(folder_gui_handle, 'tag', 'folder_pert'), 'String',pert_name);
            
            %  Write data into storage
            setappdata(folder_gui_handle, 'fold', fold);
            
        catch
        end
        
        
     case 'restart'
        %% RESTART
        
        % - pert Default Values
        new_perturbation('default_values');
        
        % - Update Uicontrols
        new_perturbation('uicontrol_update');
        
        % - Buttons Enable
        new_perturbation('buttons_enable')
        
        % - Generate perturbation
        new_perturbation('perturbation_update')
        
        % - Update Upper Plot
        new_perturbation('plot_update');
        
end

%% fun start draw perturbation
    function start_draw_perturbation()
        
        % Activate button motion function
        set(pert_gui_handle,'WindowButtonMotionFcn',   @(a,b) draw_perturbation);
        
    end

%% fun stop draw perturbation
    function stop_draw_perturbation()
        
        % Deactivate button motion function
        set(pert_gui_handle,'WindowButtonMotionFcn',   @(a,b) []);
        
    end

%% fun stop draw perturbation
    function draw_perturbation()
        
        % Handles to the two axes
        pert_upanel_current	= findobj(pert_gui_handle, 'tag', 'pert_upanel_current');
        axes_up             = getappdata(pert_upanel_current, 'h_axes_up');
        
        % Get pointer location w.r.t. current perturbation plot
        Screen_xy 	= get(0,'PointerLocation');
        Figure_xy  	= getpixelposition(pert_gui_handle);
        Axes_xy    	= getpixelposition(axes_up, true);
        Xlim        = get(axes_up, 'XLim');
        Ylim        = get(axes_up, 'YLim');
        
        axes_x      = Screen_xy(1) - Axes_xy(1) - Figure_xy(1);
        axes_x      = axes_x/Axes_xy(3)*(Xlim(2)-Xlim(1)) + Xlim(1);
        axes_y      = Screen_xy(2) - Axes_xy(2) - Figure_xy(2);
        axes_y      = axes_y/Axes_xy(4)*(Ylim(2)-Ylim(1)) + Ylim(1);
        
        % If mouse is inside the plot, update interface
        if Xlim(1)<axes_x && axes_x<Xlim(2) && Ylim(1)<axes_y && axes_y<Ylim(2)
            
            % Get Data
            npert   = getappdata(pert_gui_handle, 'npert');
            
            % Find close point
            [~, idx] = min(abs(axes_x-npert.x));
            
            % Choose only one value
            if length(idx) > 1
                idx = idx(1);
            end
            
            % Update position
            npert.y(idx) = axes_y;
            
            % Get plot data
            ph  = getappdata(pert_gui_handle,'ph');
            ph2 = getappdata(pert_gui_handle,'ph2');
            
            % Update plots
            set(ph,'YData',npert.y);
            set(ph2,'YData',npert.y);
            
            % Update Data
            setappdata(pert_gui_handle, 'ph', ph);
            setappdata(pert_gui_handle, 'ph2', ph2);
            setappdata(pert_gui_handle, 'npert', npert);
            
        end
        
    end

end