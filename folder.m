function folder(Action)
% Original author:    Marta Adamuszek
% Last committed:     $Revision: 87 $
% Last changed by:    $Author: schmid $
% Last changed date:  $Date: 2017-08-21 15:54:21 +0200 (Mon, 21 Aug 2017) $
%--------------------------------------------------------------------------

%% Input Check
if nargin==0
    Action = 'initialize';
end

%% Find GUI
folder_gui_handle = findobj(0, 'tag', 'folder_gui_handle', 'type', 'figure');

switch lower(Action)
    case 'initialize'
        %% INITIALIZE
        
        %  Delete figure if it already exists
        if ~isempty(folder_gui_handle)
            delete(folder_gui_handle);
        end
        
        %  Add required folders
        if ~isdeployed
            folder_path    =  fileparts(mfilename('fullpath'));
            addpath(fullfile(folder_path));
            addpath(fullfile(folder_path, 'colormaps'));
            addpath(fullfile(folder_path, 'doc'));
            addpath(fullfile(folder_path, 'ext', 'Buttons'));
            addpath(fullfile(folder_path, 'ext', 'Growth_rate'));
            addpath(fullfile(folder_path, 'ext', 'GUILayoutToolbox', 'layout'));
            addpath(fullfile(folder_path, 'ext', 'MSOLVER'));
            addpath(genpath(fullfile(folder_path, 'ext', 'mutils-0.4-2')));
            addpath(fullfile(folder_path, 'ext', 'poly_stuff'));
            addpath(fullfile(folder_path, 'int'));
            addpath(fullfile(folder_path, 'perturbation'));
            addpath(fullfile(folder_path, 'rheology'));
        end
        
        %% - Check C++ Redistributable Installed
        % Mutils was compiled with the Microsoft Visual C++ 2012 compiler.
        % The corresponding redistributable must be installed.
        % Check it only for windows
        if ispc
            try
                % Check registry key
                cpp_installed   = winqueryreg('HKEY_LOCAL_MACHINE','SOFTWARE\Microsoft\DevDiv\VC\Servicing\11.0\RuntimeMinimum', 'Install');
            catch
                cpp_installed   = 0;
            end
            if ~cpp_installed
                url='www.microsoft.com/en-us/download/details.aspx?id=30679';
                
                ant=inputdlg(...
                    {'mutils requires the x64 Microsoft Visual C++ 2012 Redistributable';...
                    'Click OK to go to:';
                    url},...
                    'C++ Redistributable Not Installed',...
                    0,...
                    {'';'';url});
                
                if ~isempty(ant)
                    web(url, '-browser');
                    return;
                else
                    return;
                end
            end
        end
        
        %% - Figure Setup
        Screensize      = get(0, 'ScreenSize');
        x_res           = Screensize(3);
        y_res           = Screensize(4);
        
        test_figure     = figure('Units', 'pixels','pos',round([10 10 200  200]));
        % Default character size
        test_button     = uicontrol('Parent',test_figure,'style', 'text', 'String', 'Finite Strain');
        test_text       = text(0,0,'Finite Strain');
        set(test_text,'FontName',get(test_button,'FontName'),'FontSize',get(test_button,'FontSize'),'Units','Pixels');
        TextSize   = get(test_text,'Extent');
        delete(test_button);
        close(gcf)
        
        if Screensize(4)<768
            uiwait(warndlg('The screen resolution of your device can be too low to correctly display the GUI.', 'Error!', 'modal'));
        end
        
        fracx           = 10;
        gap             = 5;
        
        if Screensize(4) < 800
            b_height   = 17;
            gap        = 4;
        else
            b_height   = 20;
        end
        
        b_width    = 2*round((TextSize(3)+4*gap)/2);
        gui_width  = x_res/fracx*(fracx-2);
        gui_height = (2+8+3+2+3+5)*(b_height+gap)+(3+3+3+4+4+4+5)*gap+b_height;
        gui_x      = (x_res-gui_width)/2;
        gui_y      = (y_res-gui_height-6*gap)/2;
        
        folder_gui_handle = figure(...
            'Units', 'pixels','pos',round([gui_x gui_y gui_width  gui_height]),...
            'Name', 'FOLDER by M. Adamuszek, D. W. Schmid, & M. Dabrowski',...
            'Tag', 'folder_gui_handle',...
            'NumberTitle', 'off', ...
            'DockControls', 'off', ...
            'ToolBar', 'none', ...
            'MenuBar', 'none',...
            'Color', get(0, 'DefaultUipanelBackgroundColor'),...
            'Units', 'Pixels', ...
            'Renderer', 'zbuffer'); %zbuffer so that contour plots work
        
        % Figure Icon - Undocumented
        warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
        Icon_path	= which('folder_icon.png');
        set(get(folder_gui_handle,'JavaFrame'),'FigureIcon', javax.swing.ImageIcon(Icon_path));
        warning('on','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
        
        %  Save default sizes in figure
        setappdata(folder_gui_handle, 'b_height', b_height);
        setappdata(folder_gui_handle, 'b_width',  b_width);
        setappdata(folder_gui_handle, 'gap',      gap);
        
        %% - Menu Entries
        % Project
        h1 = uimenu('Parent',folder_gui_handle, 'Label','Project');
        %  New Project
        obj.folder_new_project = ...
            uimenu('Parent',h1, 'Label', 'New Project', 'tag', 'folder_new_project', ...
            'Callback', @(a,b) folder('restart'), 'Separator','off', 'enable', 'on', 'Accelerator', 'N');
        %  Open Project
        obj.folder_open_project = ...
            uimenu('Parent',h1, 'Label', 'Open Project', 'tag', 'folder_open_project', ...
            'Callback', @(a,b) folder('open_project'), 'Separator','off', 'enable', 'on', 'Accelerator', 'O');
        %  Save As Project
        obj.folder_save_as_project = ...
            uimenu('Parent',h1, 'Label', 'Save Project', 'tag', 'folder_save_as_project', ...
            'Callback', @(a,b) folder('save_as_project'), 'Separator','off', 'enable', 'on');
        %  Exit
        uimenu('Parent',h1, 'Label', 'Exit', ...
            'Callback', @(a,b) close(gcf), 'Separator','on', 'enable', 'on', 'Accelerator', 'Q');
        
        
        %  Geometry
        h3  = uimenu('Parent',folder_gui_handle, 'Label','Geometry');
        
        %  Load
        obj.folder_load  = ...
            uimenu('Parent',h3, 'Label', 'Load', 'tag', 'folder_load', ...
            'Callback', @(a,b) folder('folder_load'), 'Separator','off', 'enable', 'on');
        %  Save
        obj.folder_save = ...
            uimenu('Parent',h3, 'Label', 'Save', 'tag', 'folder_save', ...
            'Callback', @(a,b) folder('folder_save'), 'Separator','off', 'enable', 'on');
        %  Quick Model Setup
        obj.folder_quick_model = ...
            uimenu('Parent',h3, 'Label', 'Quick Model Setup', 'tag', 'quick_model', ...
            'Callback', @(a,b) quick_model_setup, 'Separator','off', 'enable', 'on', 'Accelerator', 'T');
        %  Shift Interfaces
        obj.folder_shift_interfaces = ...
            uimenu('Parent',h3, 'Label', 'Shift Interfaces', 'tag', 'shift_interfaces', ...
            'Separator','off', 'enable', 'on');
        %  Modify Interfaces
        obj.folder_modify_interfaces = ...
            uimenu('Parent',h3, 'Label', 'Apply to All Interfaces', 'tag', 'modify_interfaces', ...
            'Separator','on', 'enable', 'on');
        
        %  New Perturbation
        obj.folder_new_pert = ...
            uimenu('Parent',h3, 'Label', 'New Perturbation', ...
            'Callback', @(a,b) new_perturbation, 'Separator','on', 'enable', 'on', 'Accelerator', 'P');
        %  Load Perturbation
        obj.folder_load_pert = ...
            uimenu('Parent',h3, 'Label', 'Load Perturbation', ...
            'Callback', @(a,b) folder('load_perturbation'), 'Separator','off', 'enable', 'on');
        %  Import From FGT
        obj.import_pert_FGT = ...
            uimenu('Parent',h3, 'Label', 'Import Perturbation from FGT', ...
            'Callback', @(a,b) folder('load_from_fgt'), 'Separator','off', 'enable', 'on');
        
        %  Export to FGT
        uimenu('Parent',h3, 'Label', 'Export to FGT', 'tag', 'folder_export',...
            'Callback', @(a,b) folder('folder_export'), 'Separator','on', 'enable', 'on', 'Accelerator', 'E');
        %  Export to workspace
        uimenu('Parent',h3, 'Label', 'Export to Workspace', 'tag', 'folder_export_workspace',...
            'Callback', @(a,b) folder('folder_export_workspace'), 'Separator','off', 'enable', 'on');
        
        uimenu('Parent',obj.folder_shift_interfaces, 'Label', 'Align in the Center', 'tag', 'shift_center', ...
            'Callback', @(a,b) folder('uicontrol_callback'), 'Separator','off', 'enable', 'on');
        uimenu('Parent',obj.folder_shift_interfaces, 'Label', 'Shift by Value', 'tag', 'shift_by_value', ...
            'Callback', @(a,b) folder('uicontrol_callback'), 'Separator','off', 'enable', 'on');
        uimenu('Parent',obj.folder_shift_interfaces, 'Label', 'Set position of the Lowermost Interface', 'tag', 'shift_lower_interface', ...
            'Callback', @(a,b) folder('uicontrol_callback'), 'Separator','off', 'enable', 'on');
        uimenu('Parent',obj.folder_shift_interfaces, 'Label', 'Set position of the Uppermost Interface', 'tag', 'shift_upper_interface', ...
            'Callback', @(a,b) folder('uicontrol_callback'), 'Separator','off', 'enable', 'on');
        
        uimenu('Parent',obj.folder_modify_interfaces, 'Label', 'Perturbation', 'tag', 'set_pert', ...
            'Callback', @(a,b) folder('uicontrol_callback'), 'Separator','off', 'enable', 'on');
        uimenu('Parent',obj.folder_modify_interfaces, 'Label', 'Amplitude', 'tag', 'set_amplitude', ...
            'Callback', @(a,b) folder('uicontrol_callback'), 'Separator','off', 'enable', 'on');
        uimenu('Parent',obj.folder_modify_interfaces, 'Label', 'Wavelength', 'tag', 'set_wavelength', ...
            'Callback', @(a,b) folder('uicontrol_callback'), 'Separator','off', 'enable', 'on');
        uimenu('Parent',obj.folder_modify_interfaces, 'Label', 'Shift', 'tag', 'set_shift', ...
            'Callback', @(a,b) folder('uicontrol_callback'), 'Separator','off', 'enable', 'on');
        uimenu('Parent',obj.folder_modify_interfaces, 'Label', 'Bell Width', 'tag', 'set_bell', ...
            'Callback', @(a,b) folder('uicontrol_callback'), 'Separator','off', 'enable', 'on');
        uimenu('Parent',obj.folder_modify_interfaces, 'Label', 'Hurst Exponent', 'tag', 'set_hurst', ...
            'Callback', @(a,b) folder('uicontrol_callback'), 'Separator','off', 'enable', 'on');
        uimenu('Parent',obj.folder_modify_interfaces, 'Label', 'nx', 'tag', 'set_nx', ...
            'Callback', @(a,b) folder('uicontrol_callback'), 'Separator','off', 'enable', 'on');
        
        %  Materials
        h4  = uimenu('Parent',folder_gui_handle, 'Label','Materials');
        
        %  Materials
        uimenu('Parent',h4, 'Label', 'Materials Table', ...
            'Callback', @(a,b) materials, 'Separator','off', 'enable', 'on', 'Accelerator', 'M');
        
        %  Options
        h5  = uimenu('Parent',folder_gui_handle, 'Label','Options');
        
        %  Plot Option
        uimenu('Parent',h5, 'Label', 'Plotting', ...
            'Callback', @(a,b) setting, 'Separator','off', 'enable', 'on');
        %  Run Options
        obj.folder_run_menu = ...
            uimenu('Parent',h5, 'Label', 'Run', 'tag','run_menu',...
            'Callback', @(a,b) run_opts, 'Separator','off', 'enable', 'on');
        %  Selection Option
        uimenu('Parent',h5, 'Label', 'Selection', ...
            'Callback', @(a,b) selection, 'Separator','off', 'enable', 'on');
        %  Markers Option
        obj.folder_markers_menu = ...
            uimenu('Parent',h5, 'Label', 'Markers', 'tag','markers_menu',...
            'Callback', @(a,b) markers_setting, 'Separator','on', 'enable', 'on');
        %  Strain Ellipse Option
        obj.folder_fstrain_menu = ...
            uimenu('Parent',h5, 'Label', 'Finite Strain', 'tag', 'fstrain_menu',...
            'Callback', @(a,b) fstrain_setting, 'Separator','off', 'enable', 'on');
        %  Vector Option
        obj.folder_vector_menu = ...
            uimenu('Parent',h5, 'Label', 'Vector', 'tag', 'vector_menu',...
            'Callback', @(a,b) vector_setting, 'Separator','on', 'enable', 'on');
        %  Tensor Option
        obj.folder_tensor_menu = ...
            uimenu('Parent',h5, 'Label', 'Tensor', 'tag','tensor_menu',...
            'Callback', @(a,b) tensor_setting, 'Separator','off', 'enable', 'on');
        
        %  Help
        h6  = uimenu('Parent',folder_gui_handle, 'Label','Help');
        %  Growth Rate
        uimenu('Parent',h6, 'Label', 'Growth Rate', ...
            'Callback', @(a,b) growth_rate, 'Separator','off', 'enable', 'on', 'Accelerator', 'G');
        % Help
        uimenu('Parent',h6, 'Label', 'Help', ...
            'Callback', @(a,b) folder('help'), 'Separator','on', 'enable', 'on', 'Accelerator', 'H');
        % About Folder
        uimenu('Parent',h6, 'Label', 'About Folder', ...
            'Callback', @(a,b) about_folder, 'Separator','on', 'enable', 'on');
        
        
        %% - Toolbar
        % Load the Redo icon
        ToolbarButtons = load('ToolbarButtons.mat');
        
        toolbar = uitoolbar('parent', folder_gui_handle, 'handleVisibility', 'off','tag','FigureToolBar');
        
        % Add icons
        FileOpen            = uitoolfactory(toolbar, 'Standard.FileOpen');
        hFileOpen           = findall(gcf, 'tooltipstring', 'Open File');
        set(hFileOpen, 'ClickedCallback', @(a,b) folder('open_project'),'tooltipstring','Open Project','Separator','off')
        obj.save_project    = uipushtool(toolbar,'cdata',ToolbarButtons.save_project, 'tooltip','Save Project',...
            'Separator','off','ClickedCallback',@(a,b) folder('save_as_project'));
        %obj.save_project_as = uipushtool(toolbar,'cdata',ToolbarButtons.save_project_as, 'tooltip','Save Project As',...
        %    'Separator','off','ClickedCallback',@(a,b) folder('save_as_project'));
        
        obj.quick_model = uipushtool(toolbar,'cdata',ToolbarButtons.quick, 'tooltip','Quick Model Setup',...
            'Separator','on','ClickedCallback',@(a,b) quick_model_setup);
        obj.home            = uipushtool(toolbar,'cdata',ToolbarButtons.home, 'tooltip','Restart',...
            'Separator','off','ClickedCallback',@(a,b) folder('restart'));
        
        %SaveFigure      = uitoolfactory(toolbar, 'Standard.SaveFigure');
        %PrintFigure     = uitoolfactory(toolbar, 'Standard.PrintFigure');
        % Modify save figure callback as a default one does not work
        % properly
        %hSave = findall(gcf, 'tooltipstring', 'Save Figure');
        %set(hSave, 'ClickedCallback', 'filemenufcn(gcbf,''FileSave''),set(gcf, ''FileName'', '''')')
        %set(hSave, 'ClickedCallback', @(a,b) folder('save_project'),'tooltipstring','Save Project')
        
        ZoomIn          = uitoolfactory(toolbar, 'Exploration.ZoomIn');
        ZoomOut         = uitoolfactory(toolbar, 'Exploration.ZoomOut');
        Pan             = uitoolfactory(toolbar, 'Exploration.Pan');
        %uitoolfactory(toolbar, 'Standard.EditPlot');
        set(ZoomIn,'Separator','on');
        
        obj.image       = uipushtool(toolbar,'cdata',ToolbarButtons.image, 'tooltip','Save Image',...
            'Separator','on','ClickedCallback',@(a,b) folder('folder_figure'));
        
        obj.profile     = uipushtool(toolbar,'cdata',ToolbarButtons.profile, 'tooltip','Run information',...
            'Separator','on','ClickedCallback',@(a,b) run_info);
        
        obj.growth_rate = uipushtool(toolbar,'cdata',ToolbarButtons.growth_rate, 'tooltip','Growth Rates',...
            'Separator','on','ClickedCallback',@(a,b) growth_rate);
        
        %% - Main Layout
        % Panels dimensions
        panel_width             = 3*b_width+4*gap;
        text_width              = 1.5*(b_width)+gap;
        box_width               = 1.5*(b_width)+gap;
        
        domain_panel            = 2*(b_height+gap)+3*gap;
        interface_panel         = 8*(b_height+gap)+3*gap;
        region_panel            = 3*(b_height+gap)+3*gap;
        markers_panel           = 2*(b_height+gap)+4*gap;
        strain_panel            = 3*(b_height+gap)+4*gap;
        
        time_panel              = 2*(b_height+gap)+3*gap;
        scalar_panel            = 6*(b_height+gap)+3*gap;
        vector_panel            = 5*(b_height+gap)+3*gap;
        tensor_panel            = 6*(b_height+gap)+3*gap;
        
        plotting_panel          = 5*(b_height+gap)+4*gap;
        
        status_panel            = 1*(b_height+gap)+3*gap;
        
        % Division of the figure into panels
        upanel                  = uiextras.HBox('Parent', folder_gui_handle);
        
        processing_panel        = uiextras.VBox('Parent', upanel, 'Spacing', gap);
        
        obj.tab_panel           = uiextras.TabPanel('Parent', processing_panel, ...
            'Tag','tab_panel'); %,'Callback',@(a,b) folder('uicontrol_callback'));
        
        % Pre-processing
        left_panel1             = uiextras.VBox('Parent', obj.tab_panel, 'Spacing', gap);
        folder_domain_panel     = uipanel( 'Parent', left_panel1,'Title','Domain','Tag','folder_upanel_domain');
        folder_interface_panel  = uipanel( 'Parent', left_panel1,'Title','Interface','Tag','folder_upanel_interface');
        folder_region_panel     = uipanel( 'Parent', left_panel1,'Title','Region','Tag','folder_upanel_region');
        folder_marker_panel     = uipanel( 'Parent', left_panel1,'Title','Passive Markers and Finite Strain','Tag','folder_upanel_region');
        folder_strain_panel     = uipanel( 'Parent', left_panel1,'Title','Deformation','Tag','folder_upanel_strain');
        set( left_panel1, 'Sizes', [domain_panel interface_panel region_panel markers_panel strain_panel]);
        
        % Post-processing
        left_panel2             = uiextras.VBox('Parent', obj.tab_panel, 'Spacing', gap);
        folder_time_panel       = uipanel( 'Parent', left_panel2,'Title','Time Step','Tag','folder_upanel_time');
        folder_scalar_panel     = uipanel( 'Parent', left_panel2,'Title','Scalar Field','Tag','folder_upanel_scalar');
        folder_vector_panel     = uipanel( 'Parent', left_panel2,'Title','Vector Field','Tag','folder_upanel_vector');
        folder_tensor_panel     = uipanel( 'Parent', left_panel2,'Title','Tensor Field','Tag','folder_upanel_tensor');
        set( left_panel2, 'Sizes', [time_panel scalar_panel vector_panel tensor_panel]);
        
        obj.tab_panel.TabNames    	= {'Pre-Processing', 'Post-Processing'};
        obj.tab_panel.TabSize     	= text_width-2*gap;
        obj.tab_panel.SelectedChild = 1;
        obj.tab_panel.Callback      = @(a,b) folder('uicontrol_callback');
        
        folder_plotting_panel   = uipanel( 'Parent', processing_panel,'Title','Plotting','Tag','folder_upanel_plotting');
        set(processing_panel, 'Sizes', [(domain_panel+interface_panel+region_panel+markers_panel+strain_panel)+2*b_height plotting_panel]);
        
        right_panel             = uiextras.VBox('Parent', upanel, 'Spacing', gap);
        folder_fold_panel       = uipanel( 'Parent', right_panel,'Title','FOLDER','Tag','folder_fold_panel');
        
        bottom_panel            = uiextras.HBox('Parent', right_panel);
        folder_mesh_info_panel  = uipanel( 'Parent', bottom_panel,'Title','Info About Numerics','Tag','folder_upanel_mesh_info');
        folder_status_panel  	= uipanel( 'Parent', bottom_panel,'Title','Status Bar','Tag','folder_upanel_status');
        
        set( bottom_panel, 'Sizes', [gap+8.5*(b_width+gap) -1]);
        
        set( right_panel, 'Sizes', [-1 status_panel]);
        
        set( upanel, 'Sizes', [panel_width -1]);
        
        
        %% -- Domain
        % DOMAIN WIDTH
        %   Text
        uicontrol('Parent', folder_domain_panel, 'style', 'text', 'String', 'Domain Width', 'HorizontalAlignment', 'left', ...
            'position', [gap, domain_panel-2*gap-(b_height+gap), text_width, b_height]);
        %   Field
        obj.folder_domain_width = ...
            uicontrol('Parent', folder_domain_panel, 'style', 'edit', 'String', '','BackgroundColor','w', ...
            'callback',  @(a,b)  folder('uicontrol_callback'),...
            'tag', 'folder_domain_width', ...
            'position', [gap+text_width, domain_panel-2*gap-(b_height+gap), box_width, b_height]);
        
        % DOMAIN HEIGHT
        %   Text
        uicontrol('Parent', folder_domain_panel, 'style', 'text', 'String', 'Domain Height', 'HorizontalAlignment', 'left', ...
            'position', [gap, domain_panel-2*gap-2*(b_height+gap), text_width, b_height]);
        %  Field
        obj.folder_domain_height = ...
            uicontrol('Parent', folder_domain_panel, 'style', 'edit', 'String', '','BackgroundColor','w', ...
            'callback',  @(a,b)  folder('uicontrol_callback'),...
            'tag', 'folder_domain_height', ...
            'position', [gap+text_width, domain_panel-2*gap-2*(b_height+gap), box_width, b_height]);
        
        
        %% -- Interface
        % BUTTON
        buttons = load('buttons.mat');
        
        % INTERFACE
        % NEW INTERFACE BUTTON
        obj.folder_new_interface = ...
            uicontrol('Parent', folder_interface_panel, 'style', 'pushbutton', 'String', 'New', ...
            'tag', 'folder_new_interface', ...
            'tooltipstring','Create new interface.',...
            'callback', @(a,b) folder('uicontrol_callback'), ... %Digitization may be going on
            'position', [gap, interface_panel-2*(b_height-gap)-1*gap, b_width, b_height]);
        
        % REMOVE INTERFACE BUTTON
        obj.folder_remove_interface = ...
            uicontrol('Parent', folder_interface_panel, 'style', 'pushbutton', 'String', 'Remove', ...
            'tag', 'folder_remove_interface', ...
            'tooltipstring','Remove interface.',...
            'callback', @(a,b) folder('uicontrol_callback'), ... %Digitization may be going on
            'position', [panel_width-2*(b_width+gap), interface_panel-2*(b_height-gap)-1*gap, b_width, b_height]);
        
        %   Left Button
        obj.face_number_left = ...
            uicontrol('Parent', folder_interface_panel, 'style', 'pushbutton',...
            'cdata', double(buttons.buttonLeft), 'units', 'pixels',...
            'tag', 'face_number_left',...
            'callback',  @i_number, ...
            'position', [panel_width-3*(b_height)-1*gap, interface_panel-2*(b_height-gap)-1*gap, b_height, b_height],...
            'enable', 'off');
        
        %   Interface number
        obj.face_number = ...
            uicontrol('Parent', folder_interface_panel, 'style', 'text', 'String', '1', ...
            'tag','face_number',...
            'position', [panel_width-2*(b_height)-1*gap, interface_panel-2*(b_height-gap)-2*gap, b_height, b_height]);
        
        %   Right Button
        obj.face_number_right = ...
            uicontrol('Parent', folder_interface_panel, 'style', 'pushbutton',...
            'cdata', buttons.buttonRght, 'units', 'pixels',...
            'tag', 'face_number_right',...
            'callback',  @i_number, ...
            'position', [panel_width-1*(b_height+gap), interface_panel-2*(b_height-gap)-1*gap, b_height, b_height],...
            'enable', 'off');
        
        % POSITION
        %   Text
        uicontrol('Parent', folder_interface_panel, 'style', 'text', 'String', 'Position', 'HorizontalAlignment', 'left', ...
            'position', [gap, interface_panel-2*(b_height+gap)-2*gap, text_width, b_height],...
            'tooltipstring','Middle position of the interface.');
        %  Field
        obj.folder_position = ...
            uicontrol('Parent', folder_interface_panel, 'style', 'edit', 'String', '','BackgroundColor','w', ...
            'callback',  @(a,b)  folder('uicontrol_callback'),...
            'tag', 'folder_position', ...
            'position', [gap+text_width, interface_panel-2*(b_height+gap)-2*gap, box_width, b_height]);
        
        % PERTURBATION
        %   Text
        uicontrol('Parent', folder_interface_panel, 'style', 'text', 'String', 'Perturbation', 'HorizontalAlignment', 'left', ...
            'position', [gap, interface_panel-3*(b_height+gap)-2*gap, text_width, b_height],...
            'tooltipstring','Initial interface roughness.');
        %   Field
        obj.folder_pert = ...
            uicontrol('Parent', folder_interface_panel, 'style', 'popupmenu', 'String', {'Sine';'Red Noise'; 'White Noise'; 'Gaussian Noise'; 'Step'; 'Triangle'; 'Bell'}, 'value', 1, ...
            'callback',  @(a,b)  folder('uicontrol_callback'),'BackgroundColor','w', ...
            'tag', 'folder_pert', ...
            'position', [gap+text_width, interface_panel-3*(b_height+gap)-2*gap, box_width-(gap+b_height), b_height]);
        %   Icon
        %   Icon
        obj.folder_pert_icon = ...
            uicontrol('Parent', folder_interface_panel, 'style', 'pushbutton',...
            'cdata', buttons.noise, 'units', 'pixels',...
            'tag', 'folder_material_icon',...
            'callback',  @(a,b) new_perturbation, ...
            'position', [gap+text_width+box_width-b_height, interface_panel-3*(b_height+gap)-2*gap, b_height, b_height]);
        
        % AMPLITUDE
        %   Text
        uicontrol('Parent', folder_interface_panel, 'style', 'text', 'String', 'Amplitude', 'HorizontalAlignment', 'left', ...
            'position', [gap, interface_panel-4*(b_height+gap)-2*gap, text_width, b_height],...
            'tooltipstring','Initial amplitude of the perturbation.');
        %   Field
        obj.folder_ampl = ...
            uicontrol('Parent', folder_interface_panel, 'style', 'edit', 'String', '','BackgroundColor','w', ...
            'callback',  @(a,b)  folder('uicontrol_callback'),...
            'tag', 'folder_ampl', ...
            'position', [gap+text_width, interface_panel-4*(b_height+gap)-2*gap, box_width, b_height]);
        
        % WAVELENGTH
        %    Text
        uicontrol('Parent', folder_interface_panel, 'style', 'text', 'String', 'Wavelength', 'HorizontalAlignment', 'left', ...
            'position', [gap, interface_panel-5*(b_height+gap)-2*gap, text_width, b_height],...
            'tooltipstring',sprintf('Initial wavelegth of the perturbation. In the case of Gaussian noise this is a correlation wavelength.'));
        %   Field
        obj.folder_wave = ...
            uicontrol('Parent', folder_interface_panel, 'style', 'edit', 'String', '','BackgroundColor','w', ...
            'callback',  @(a,b)  folder('uicontrol_callback'),...
            'tag', 'folder_wave', ...
            'position', [gap+text_width, interface_panel-5*(b_height+gap)-2*gap, box_width, b_height]);
        
        % PHASE SHIFT
        %   Text
        uicontrol('Parent', folder_interface_panel, 'style', 'text', 'String', 'Shift', 'HorizontalAlignment', 'left', ...
            'position', [gap, interface_panel-6*(b_height+gap)-2*gap, text_width, b_height],...
            'tooltipstring',sprintf('Shift of the initial perturbation. Domain width represents the full period.'));
        %   Field
        obj.folder_phase_shift = ...
            uicontrol('Parent', folder_interface_panel, 'style', 'edit', 'String', '','BackgroundColor','w', ...
            'callback',  @(a,b)  folder('uicontrol_callback'),...
            'tag', 'folder_phase_shift', ...
            'position', [gap+text_width, interface_panel-6*(b_height+gap)-2*gap, box_width, b_height]);
        
        % BELL WIDTH
        %   Text
        obj.folder_bell_width_text = ...
            uicontrol('Parent', folder_interface_panel, 'style', 'text', 'String', 'Bell Width', 'HorizontalAlignment', 'left', ...
            'position', [gap, interface_panel-7*(b_height+gap)-2*gap, text_width, b_height],...
            'tag','folder_bell_width_text', ...
            'tooltipstring',sprintf('Width of the bell-shape perturbation.'));
        %   Position field
        obj.folder_bell_width = ...
            uicontrol('Parent', folder_interface_panel, 'style', 'edit', 'String', '','BackgroundColor','w', ...
            'callback',  @(a,b)  folder('uicontrol_callback'),...
            'tag', 'folder_bell_width', ...
            'position', [gap+text_width, interface_panel-7*(b_height+gap)-2*gap, box_width, b_height]);
        
        % NX
        %   Text
        uicontrol('Parent', folder_interface_panel, 'style', 'text', 'String', 'nx', 'HorizontalAlignment', 'left', ...
            'position', [gap, interface_panel-8*(b_height+gap)-2*gap, text_width, b_height],...
            'tooltipstring','Number nodes on the interface.');
        %   Field
        obj.folder_nx = ...
            uicontrol('Parent', folder_interface_panel, 'style', 'edit', 'String', '','BackgroundColor','w', ...
            'callback',  @(a,b)  folder('uicontrol_callback'),...
            'tag', 'folder_nx', ...
            'position', [gap+text_width, interface_panel-8*(b_height+gap)-2*gap, box_width, b_height]);
        
        
        %% -- Regions
        % REGION
        %   Left Button
        obj.region_number_left = ...
            uicontrol('Parent', folder_region_panel, 'style', 'pushbutton',...
            'cdata', buttons.buttonLeft, 'units', 'pixels',...
            'tag', 'region_number_left',...
            'callback',  @i_number, ...
            'position', [panel_width-3*(b_height)-gap, region_panel-2*(b_height-gap)-1*gap, b_height, b_height],...
            'enable', 'off');
        
        %   Region number
        obj.region_number = ...
            uicontrol('Parent', folder_region_panel, 'style', 'text', 'String', '1', ...
            'tag','region_number',...
            'position', [panel_width-2*(b_height)-gap, region_panel-2*(b_height-gap)-2*gap, b_height, b_height]);
        
        %   Right Button
        obj.region_number_right = ...
            uicontrol('Parent', folder_region_panel, 'style', 'pushbutton',...
            'cdata', buttons.buttonRght, 'units', 'pixels',...
            'tag', 'region_number_right',...
            'callback',  @i_number, ...
            'position', [panel_width-1*(b_height+gap), region_panel-2*(b_height-gap)-1*gap, b_height, b_height],...
            'enable', 'off');
        
        % MATERIAL
        %   Text
        uicontrol('Parent', folder_region_panel, 'style', 'text', 'String', 'Material', 'HorizontalAlignment', 'left', ...
            'position', [gap, region_panel-2*(b_height+gap)-2*gap, text_width, b_height],...
            'tooltipstring','Choose material from the list.');
        %   Field
        Input_data = load('material_parameters.mat');
        obj.folder_material = ...
            uicontrol('Parent', folder_region_panel, 'style', 'popupmenu', 'String', {char(Input_data.data{:,2})}, 'value', 1, ...
            'callback',  @(a,b)  folder('uicontrol_callback'),'BackgroundColor','w', ...
            'tag', 'folder_material', ...
            'position', [gap+text_width, region_panel-2*(b_height+gap)-2*gap, box_width-(gap+b_height), b_height]);
        %   Icon
        obj.folder_material_icon = ...
            uicontrol('Parent', folder_region_panel, 'style', 'pushbutton',...
            'cdata', buttons.table, 'units', 'pixels',...
            'tag', 'folder_material_icon',...
            'callback',  @(a,b) materials, ...
            'position', [gap+text_width+box_width-b_height, region_panel-2*(b_height+gap)-2*gap, b_height, b_height]);
        
        % AREA
        %   Text
        uicontrol('Parent', folder_region_panel, 'style', 'text', 'String', 'Triangle Area', 'HorizontalAlignment', 'left', ...
            'position', [gap, region_panel-3*(b_height+gap)-2*gap, text_width, b_height],...
            'tooltipstring','Maximum area of the triangle mesh.');
        %   Field
        obj.folder_area = ...
            uicontrol('Parent', folder_region_panel, 'style', 'edit', 'String', '', ...
            'callback',  @(a,b)  folder('uicontrol_callback'),'BackgroundColor','w', ...
            'tag', 'folder_area', ...
            'position', [gap+text_width, region_panel-3*(b_height+gap)-2*gap, box_width, b_height]);
        
        %% -- Passive Markers and Finite Strain
        % MARKERS
        %   Checkbox
        obj.folder_markers_set = ...
            uicontrol('Parent', folder_marker_panel, 'style', 'checkbox', 'String', 'Markers', 'Value', 0, ...
            'callback',  @(a,b)  folder('uicontrol_callback'), ...
            'tag', 'folder_markers_set', ...
            'position', [gap, 1*(b_height+gap)+gap, b_width, b_height]);
        
        %   Field
        obj.folder_markers_type = ...
            uicontrol('Parent', folder_marker_panel, 'style', 'popupmenu', 'String', {'Layers','Bars','Grid','Circles','Polygrains'}, 'value', 3, ...
            'callback',  @(a,b)  folder('uicontrol_callback'),'BackgroundColor','w', ...
            'tag', 'folder_markers_type', ...
            'position', [gap+1*(b_width+gap), 1*(b_height+gap)+gap, b_width, b_height]);
        
        % MARKERS OPTION
        %    Run Option Button
        obj.folder_markers_options = ...
            uicontrol('Parent', folder_marker_panel, 'style', 'pushbutton', 'String', 'Options', ...
            'tag', 'folder_markers_options', ...
            'callback', @(a,b) markers_setting, ...
            'position', [panel_width-(b_width+gap), 1*(b_height+gap)+gap, b_width, b_height]);
        
        % FINITE STRAIN
        %   Checkbox
        obj.folder_fstrain_set = ...
            uicontrol('Parent', folder_marker_panel, 'style', 'checkbox', 'String', 'Finite Strain', 'Value', 0, ...
            'callback',  @(a,b)  folder('uicontrol_callback'), ...
            'tag', 'folder_fstrain_set', ...
            'position', [gap, gap, b_width, b_height]);
        
        % MARKERS OPTION
        %    Run Option Button
        obj.folder_fstrain_options = ...
            uicontrol('Parent', folder_marker_panel, 'style', 'pushbutton', 'String', 'Options', ...
            'tag', 'folder_fstrain_options', ...
            'callback', @(a,b) fstrain_setting, ...
            'position', [panel_width-(b_width+gap), gap, b_width, b_height]);
        
        
        %% -- Deformation
        % DEFORMATION TYPE
        obj.folder_strain_shortening = ...
            uicontrol('Parent', folder_strain_panel, 'style', 'radiobutton', 'String', 'Shortening',...
            'tag','folder_strain_shortening',...
            'callback',  @(a,b)  folder('uicontrol_callback'),...
            'position', [gap, strain_panel-3*gap-b_height, 1.5*b_width, b_height]);
        obj.folder_strain_extension = ...
            uicontrol('Parent', folder_strain_panel, 'style', 'radiobutton', 'String', 'Extension',...
            'tag','folder_strain_extension',...
            'callback',  @(a,b)  folder('uicontrol_callback'),...
            'position', [gap+text_width, strain_panel-3*gap-b_height, 1.5*b_width, b_height]);
        
        % AMOUNT OF DEFORMATION
        %   Text
        uicontrol('Parent', folder_strain_panel, 'style', 'text', 'String', 'Deformation (%)', 'HorizontalAlignment', 'left', ...
            'position', [gap, strain_panel-3*gap-2*(b_height+gap), text_width, b_height],...
            'tooltipstring','Amount of deformation in (%). The value should be > 0.');
        %   Field
        obj.folder_shortening = ...
            uicontrol('Parent', folder_strain_panel, 'style', 'edit', 'String', '', 'BackgroundColor','w',...
            'callback',  @(a,b)  folder('uicontrol_callback'),...
            'tag', 'folder_shortening', ...
            'position', [gap+text_width, strain_panel-3*gap-2*(b_height+gap), box_width, b_height]);
        
        % RUN OPTION
        %    Run Option Button
        obj.folder_run_options = ...
            uicontrol('Parent', folder_strain_panel, 'style', 'pushbutton', 'String', 'Options', ...
            'tag', 'folder_run_options', ...
            'callback', @(a,b) run_opts, ...
            'position', [panel_width-2*(b_width+gap), strain_panel-3*gap-3*(b_height+gap), b_width, b_height]);
        
        % RUN
        %    Run Button
        obj.folder_run = ...
            uicontrol('Parent', folder_strain_panel, 'style', 'pushbutton', 'String', 'Save & Run', ...
            'BackgroundColor',[0 64 64]/255,'ForegroundColor','w',...
            'tag', 'folder_run', ...
            'callback', @(a,b) folder('folder_run'), ...
            'position', [panel_width-(b_width+gap), strain_panel-3*gap-3*(b_height+gap), b_width, b_height]);
        
        
        %% -- Time step
        %   Slider
        obj.folder_slider = ...
            uicontrol('Parent', folder_time_panel, 'style', 'slider','Min',0,'Max',1,'Value',0,...
            'Sliderstep',[1 1],...
            'callback',  @(a,b)  folder('uicontrol_callback'), ...
            'tag', 'folder_slider', ...
            'BackgroundColor','w', ...
            'position', [gap, gap+(b_height+gap), (panel_width-3*gap)*2/3, b_height],...
            'enable','off');
        
        %   Number of Time Steps
        obj.folder_time = ...
            uicontrol('Parent', folder_time_panel, 'style', 'text', 'String', '0/10', ...
            'tag', 'folder_time', ...
            'position', [gap+(panel_width-3*gap)*2/3+gap, gap+(b_height+gap), b_width, b_height]);
        
        %% -- Play buttons
        PlayButtons = load('PlayButtons.mat');
        
        %   START button
        obj.folder_play_go_start = ...
            uicontrol('Parent', folder_time_panel, 'style', 'pushbutton',...
            'cdata', PlayButtons.Start, 'units', 'pixels',...
            'tag', 'folder_play_go_start',...
            'callback',  @(a,b)  folder('folder_play'), ...
            'position', [gap, gap, b_height, b_height],...
            'enable', 'off');
        
        %   PLAY BACK button
        obj.folder_play_backward = ...
            uicontrol('Parent', folder_time_panel, 'style', 'pushbutton',...
            'cdata', PlayButtons.PlayBack, 'units', 'pixels',...
            'tag', 'folder_play_backward',...
            'callback',  @(a,b)  folder('folder_play'), ...
            'position', [gap+(b_height+gap), gap, b_height, b_height],...
            'enable', 'off');
        
        %   STOP button
        obj.folder_play_stop = ...
            uicontrol('Parent', folder_time_panel, 'style', 'pushbutton',...
            'cdata', PlayButtons.Stop, 'units', 'pixels',...
            'tag', 'folder_play_stop',...
            'callback',  @(a,b)  folder('folder_play'), ...
            'position', [gap+2*(b_height+gap), gap, b_height, b_height],...
            'enable', 'off');
        
        %   PLAY button
        obj.folder_play_forward = ...
            uicontrol('Parent', folder_time_panel, 'style', 'pushbutton',...
            'cdata', PlayButtons.Play, 'units', 'pixels',...
            'tag', 'folder_play_forward',...
            'callback',  @(a,b)  folder('folder_play'), ...
            'position', [gap+3*(b_height+gap), gap, b_height, b_height],...
            'enable', 'off');
        
        %   END button
        obj.folder_play_go_end = ...
            uicontrol('Parent', folder_time_panel, 'style', 'pushbutton',...
            'cdata', PlayButtons.End, 'units', 'pixels',...
            'tag', 'folder_play_go_end',...
            'callback',  @(a,b)  folder('folder_play'), ...
            'position', [gap+4*(b_height+gap), gap, b_height, b_height],...
            'enable', 'off');
        
        %   MOVIE button
        obj.folder_movie = ...
            uicontrol('Parent', folder_time_panel, 'style', 'pushbutton',...
            'cdata', PlayButtons.Movie, 'units', 'pixels',...
            'tag', 'folder_movie',...
            'callback',  @(a,b)  folder('folder_movie'), ...
            'position', [gap+5*(b_height+gap), gap, b_height, b_height],...
            'enable', 'off');
        
        %% -- Scalar Field
        %   Plotting Options Field
        obj.folder_plotting = ...
            uicontrol('Parent', folder_scalar_panel, 'style', 'popupmenu', ...
            'String', {'Regions';'Total Velocity';'Perturbing Velocity';'Apparent Viscosity';...
            'Rate of Deformation';'Stress';'Deviatoric Stress';'Pressure'},'value', 1, ...
            'callback',  @(a,b)  folder('uicontrol_callback'),'BackgroundColor','w', ...
            'tag', 'folder_plotting', ...
            'position', [gap, 5*(b_height+gap)+gap, (panel_width-3*gap)*2/3, b_height]);
        
        % Plotting Options Component Field
        obj.folder_plotting_component = ...
            uicontrol('Parent', folder_scalar_panel, 'style', 'popupmenu', ...
            'String', {'none'},'value', 1, ...
            'callback',  @(a,b)  folder('uicontrol_callback'),'BackgroundColor','w', ...
            'tag', 'folder_plotting_component', ...
            'position', [gap+gap+(panel_width-3*gap)*2/3, 5*(b_height+gap)+gap, (panel_width-3*gap)*1/3, b_height]);
        
        % Colormap Type
        uicontrol('Parent', folder_scalar_panel, 'style', 'text', 'String', 'Colourmap Type','HorizontalAlignment', 'left', ...
            'position', [gap, 4*(b_height+gap)+gap, text_width, b_height]);
        % Field
        obj.folder_colormap_type = ...
            uicontrol('Parent', folder_scalar_panel, 'style', 'popupmenu',...
            'String', {'Monochromatic';'Bichromatic';'Diverging';'Miscellaneous'},...
            'callback',  @(a,b)  folder('uicontrol_callback'),...
            'tag', 'folder_colormap_type', 'BackgroundColor','w',...
            'position', [gap+text_width, 4*(b_height+gap)+gap, box_width, b_height]);
        
        % Colormap
        uicontrol('Parent', folder_scalar_panel, 'style', 'text', 'String', 'Colourmap','HorizontalAlignment', 'left', ...
            'position', [gap, 3*(b_height+gap)+gap, text_width, b_height]);
        % Field
        obj.folder_colormap = ...
            uicontrol('Parent', folder_scalar_panel, 'style', 'popupmenu',...
            'String', {'blues';'browns';'gray';'greens';'oranges';'purples'; 'reds'; 'violets'},...
            'callback',  @(a,b)  folder('uicontrol_callback'),...
            'tag', 'folder_colormap', 'BackgroundColor','w',...
            'position', [gap+text_width, 3*(b_height+gap)+gap, box_width, b_height]);
        
        % Number of Colors
        uicontrol('Parent', folder_scalar_panel, 'style', 'text', 'String', 'Number of Colours','HorizontalAlignment', 'left', ...
            'position', [gap, 2*(b_height+gap)+gap, text_width, b_height],...
            'tooltipstring','Number of colours in the colormap.');
        % Field
        obj.folder_ncolors = ...
            uicontrol('Parent', folder_scalar_panel, 'style', 'edit','String','',...
            'callback',  @(a,b)  folder('uicontrol_callback'),...
            'tag', 'folder_ncolors', 'BackgroundColor','w',...
            'position', [gap+text_width, 2*(b_height+gap)+gap, box_width, b_height]);
        
        % c-lim
        obj.folder_clim = ...
            uicontrol('Parent', folder_scalar_panel, 'style', 'checkbox', 'String', 'c-lim',...
            'tag','folder_clim',...
            'callback',  @(a,b)  folder('uicontrol_callback'),...
            'position', [gap, 1*(b_height+gap)+gap, b_width, b_height]);
        % - Field c-min
        obj.folder_cmin = ...
            uicontrol('Parent', folder_scalar_panel, 'style', 'edit', 'String', 'cmin', 'BackgroundColor','w',...
            'callback',  @(a,b)  folder('uicontrol_callback'),...
            'tag', 'folder_cmin','enable','off', ...
            'position', [gap+1*(b_width+gap), 1*(b_height+gap)+gap, b_width, b_height]);
        % - Field c-max
        obj.folder_cmax = ...
            uicontrol('Parent', folder_scalar_panel, 'style', 'edit', 'String', 'cmax', 'BackgroundColor','w',...
            'callback',  @(a,b)  folder('uicontrol_callback'),...
            'tag', 'folder_cmax', 'enable','off',...
            'tooltipstring','Set limits in the color dimension.',...
            'position', [gap+2*(b_width+gap), 1*(b_height+gap)+gap, b_width, b_height]);
        
        % FLIP COLORMAP
        obj.folder_flip = ...
            uicontrol('Parent', folder_scalar_panel, 'style', 'checkbox', 'String', 'Flip Colourmap', 'tag','folder_flip',...
            'callback',  @(a,b)  folder('uicontrol_callback'),...
            'tooltipstring','Reverse colourmap.',...
            'position', [gap, 0*(b_height+gap)+gap, text_width, b_height]);
        
        % LOG-SCALE COLORMAP
        obj.folder_logscale = ...
            uicontrol('Parent', folder_scalar_panel, 'style', 'checkbox', 'String', 'Log-Scale', 'tag','folder_logscale',...
            'callback',  @(a,b)  folder('uicontrol_callback'),...
            'tooltipstring',sprintf('Use colourmap in logarythmic quantities.\nIn case of negative values, it calcualtes the logarythm of the absolute value.'),...
            'position', [gap+text_width, 0*(b_height+gap)+gap, text_width, b_height]);
        
        %% -- Vector Field
        %   Vector
        obj.folder_vector = ...
            uicontrol('Parent', folder_vector_panel, 'style', 'checkbox', 'String', 'Vector', 'Value', 0, ...
            'tag', 'folder_vector', 'enable', 'off', ...
            'callback', @(a,b) folder('uicontrol_callback'), ...
            'position', [gap,  4*(b_height+gap)+gap, b_width, b_height]);
        
        % Velocity
        uicontrol('Parent', folder_vector_panel, 'style', 'text', 'String', 'Parameter', 'HorizontalAlignment', 'left',...
            'position', [gap, 3*(b_height+gap)+gap, text_width, b_height],...
            'tooltipstring','Parameter visualized by the vector field.');
        % Field
        obj.folder_vector_opts = ...
            uicontrol('Parent', folder_vector_panel, 'style', 'popupmenu', 'String', {'Total Velocity','Perturbing Velocity'}, 'BackgroundColor','w',...
            'callback',  @(a,b)  folder('uicontrol_callback'),...
            'tag', 'folder_vector_opts', ...
            'position', [gap+text_width, 3*(b_height+gap)+gap, box_width, b_height]);
        
        % Relative Size
        uicontrol('Parent', folder_vector_panel, 'style', 'text', 'String', 'Relative Size', 'HorizontalAlignment', 'left',...
            'position', [gap, 2*(b_height+gap), text_width, b_height],...
            'tooltipstring','Relative arrow magnitude.');
        % Field
        obj.folder_vector_relative = ...
            uicontrol('Parent', folder_vector_panel, 'style', 'popupmenu', 'String', {'Proportional','Logarithmic','Equal'}, 'BackgroundColor','w',...
            'callback',  @(a,b)  folder('uicontrol_callback'),...
            'tag', 'folder_vector_relative', ...
            'position', [gap+text_width, 2*(b_height+gap)+gap, box_width, b_height]);
        
        % Scaling
        uicontrol('Parent', folder_vector_panel, 'style', 'text', 'String', 'Scale Size', 'HorizontalAlignment', 'left',...
            'position', [gap, 1*(b_height+gap), text_width, b_height],...
            'tooltipstring','Scale arrow magnitude.');
        % Field
        obj.folder_vector_scaling = ...
            uicontrol('Parent', folder_vector_panel, 'style', 'edit', 'String', '', 'BackgroundColor','w',...
            'callback',  @(a,b)  folder('uicontrol_callback'),...
            'tag', 'folder_vector_scaling', ...
            'position', [gap+text_width, 1*(b_height+gap)+gap, box_width, b_height]);
        
        % Vector Options
        obj.folder_vector_options = ...
            uicontrol('Parent', folder_vector_panel, 'style', 'pushbutton', 'String', 'Options', ...
            'tag', 'folder_vector_options', ...
            'callback', @(a,b) vector_setting, ...
            'position', [panel_width-b_width-gap, 0*(b_height+gap)+gap, b_width, b_height]);
        
        %% -- Tensor Field
        %   Tensor
        obj.folder_tensor = ...
            uicontrol('Parent', folder_tensor_panel, 'style', 'checkbox', 'String', 'Tensor', 'Value', 0, ...
            'tag', 'folder_tensor', 'enable', 'off', ...
            'callback', @(a,b) folder('uicontrol_callback'), ...
            'position', [gap,  5*(b_height+gap)+gap, b_width, b_height]);
        
        % Parameter
        uicontrol('Parent', folder_tensor_panel, 'style', 'text', 'String', 'Parameter', 'HorizontalAlignment', 'left',...
            'position', [gap, 4*(b_height+gap)+gap, text_width, b_height],...
            'tooltipstring','Parameter visualized by the tensor field.');
        % Field
        obj.folder_tensor_opts = ...
            uicontrol('Parent', folder_tensor_panel, 'style', 'popupmenu',...
            'String', {'Rate of Deformation';'Stress';'Deviatoric Stress'},...
            'callback',  @(a,b)  folder('uicontrol_callback'),...
            'tag', 'folder_tensor_opts', 'BackgroundColor','w',...
            'position', [gap+text_width, 4*(b_height+gap)+gap, box_width, b_height]);
        
        % Style
        uicontrol('Parent', folder_tensor_panel, 'style', 'text', 'String', 'Style', 'HorizontalAlignment', 'left',...
            'position', [gap, 3*(b_height+gap)+gap, text_width, b_height],...
            'tooltipstring','Glyph type used to visualize the tensor field.');
        % Field
        obj.folder_tensor_style = ...
            uicontrol('Parent', folder_tensor_panel, 'style', 'popupmenu',...
            'String', {'Max Principle Axis Direction';'Min Principle Axis Direction';'Max and Min Principle Axis Direction';...
            'Ellypse Glyphs'},...
            'callback',  @(a,b)  folder('uicontrol_callback'),...
            'tag', 'folder_tensor_style', 'BackgroundColor','w',...
            'position', [gap+text_width, 3*(b_height+gap)+gap, box_width, b_height]);
        
        % Relative Size
        uicontrol('Parent', folder_tensor_panel, 'style', 'text', 'String', 'Relative Size', 'HorizontalAlignment', 'left',...
            'position', [gap, 2*(b_height+gap)+gap, text_width, b_height],...
            'tooltipstring','Relative glyph size.');
        % Field
        obj.folder_tensor_relative = ...
            uicontrol('Parent', folder_tensor_panel, 'style', 'popupmenu',...
            'String', {'Proportional';'Logarithmic';'Equal'},...
            'callback',  @(a,b)  folder('uicontrol_callback'),...
            'tag', 'folder_tensor_relative', 'BackgroundColor','w',...
            'position', [gap+text_width, 2*(b_height+gap)+gap, box_width, b_height]);
        
        % Scaling
        uicontrol('Parent', folder_tensor_panel, 'style', 'text', 'String', 'Scale Size', 'HorizontalAlignment', 'left',...
            'position', [gap, 1*(b_height+gap)+gap, text_width, b_height],...
            'tooltipstring','Scale glyph size.');
        % Field
        obj.folder_tensor_scaling = ...
            uicontrol('Parent', folder_tensor_panel, 'style', 'edit','String', '',...
            'callback',  @(a,b)  folder('uicontrol_callback'),...
            'tag', 'folder_tensor_scaling', 'BackgroundColor','w',...
            'position', [gap+text_width, 1*(b_height+gap)+gap, box_width, b_height]);
        
        % Tensor Options
        obj.folder_tensor_options = ...
            uicontrol('Parent', folder_tensor_panel, 'style', 'pushbutton', 'String', 'Options', ...
            'tag', 'folder_tensor_options', ...
            'callback', @(a,b) tensor_setting, ...
            'position', [panel_width-b_width-gap, 0*(b_height+gap)+gap, b_width, b_height]);
        
        
        %% -- Plotting
        %   Mesh
        obj.folder_mesh = ...
            uicontrol('Parent', folder_plotting_panel, 'style', 'checkbox', 'String', 'Mesh', 'Value', 1, ...
            'tag', 'folder_mesh', 'enable', 'on', ...
            'callback', @(a,b) folder('plot_update'), ...
            'position', [gap,  plotting_panel-1*(gap+b_height)-3*gap, b_width, b_height]);
        
        %   Markers
        obj.folder_markers = ...
            uicontrol('Parent', folder_plotting_panel, 'style', 'checkbox', 'String', 'Markers', 'Value', 1, ...
            'tag', 'folder_markers', 'enable', 'on', ...
            'callback', @(a,b) folder('plot_update'), ...
            'position', [gap+b_width+gap,  plotting_panel-1*(gap+b_height)-3*gap, b_width, b_height]);
        
        %   Finite Strain
        obj.folder_fstrain = ...
            uicontrol('Parent', folder_plotting_panel, 'style', 'checkbox', 'String', 'Finite Strain', 'Value', 1, ...
            'tag', 'folder_fstrain', 'enable', 'on', ...
            'callback', @(a,b) folder('plot_update'), ...
            'position', [panel_width-b_width-gap,  plotting_panel-1*(gap+b_height)-3*gap, b_width, b_height]);
        
        %   Colorbar/Legend
        obj.folder_colorbar = ...
            uicontrol('Parent', folder_plotting_panel, 'style', 'checkbox', 'String', 'Colourbar', 'Value', 1, ...
            'tag', 'folder_colorbar', 'enable', 'on', ...
            'callback', @(a,b) folder('plot_update'), ...
            'position', [gap,  plotting_panel-2*(gap+b_height)-3*gap, b_width, b_height]);
        % Field
        obj.folder_colorbar_position = ...
            uicontrol('Parent', folder_plotting_panel, 'style', 'popupmenu',...
            'String', {'Right outside';'Right inside';'Bottom outside';'Bottom inside';},...
            'callback',  @(a,b)  folder('uicontrol_callback'),...
            'tag', 'folder_colorbar_position', 'BackgroundColor','w',...
            'position', [gap+text_width, plotting_panel-2*(gap+b_height)-3*gap, box_width, b_height]);
        
        
        %   Plotting Options (Setting)
        uicontrol('Parent', folder_plotting_panel, 'style', 'pushbutton', 'String', 'Options',...
            'tag', 'folder_plotting_options', 'enable', 'on', ...
            'callback', @(a,b) setting, ...
            'position', [panel_width-b_width-gap, plotting_panel-3*(gap+b_height)-3*gap, b_width, b_height]);
        
        
        % AXIS
        %   Show all
        obj.plot_axis_tight = ...
            uicontrol('Parent', folder_plotting_panel, 'style', 'checkbox', 'String', 'Show all',...
            'tag','plot_axis_tight',...
            'callback',  @(a,b) folder('uicontrol_callback'),'value', 1, ...
            'position', [gap, plotting_panel-3*(gap+b_height)-3*gap, b_width, b_height]);
        
        %   Axis on
        obj.plot_axis_on = ...
            uicontrol('Parent', folder_plotting_panel, 'style', 'checkbox', 'String', 'Axis on',...
            'tag','plot_axis_on',...
            'callback',  @(a,b) folder('plot_update'),'value',1,...
            'position', [gap+b_width+gap, plotting_panel-3*(gap+b_height)-3*gap, b_width, b_height]);
        
        %   x-lim text
        obj.plot_xlim = ...
            uicontrol('Parent', folder_plotting_panel, 'style', 'checkbox', 'String', 'x-lim',...
            'tag','plot_xlim',...
            'callback',  @(a,b) folder('uicontrol_callback'),...
            'position', [gap, plotting_panel-4*(gap+b_height)-3*gap, text_width, b_height]);
        %   Field x-min
        obj.plot_xmin = ...
            uicontrol('Parent', folder_plotting_panel, 'style', 'edit', 'String', 'xmin', 'BackgroundColor','w',...
            'callback',  @(a,b) folder('uicontrol_callback'),...
            'tag', 'plot_xmin','enable','off', ...
            'position', [gap+b_width+gap, plotting_panel-4*(gap+b_height)-3*gap, b_width, b_height]);
        %   Field x-max
        obj.plot_xmax = ...
            uicontrol('Parent', folder_plotting_panel, 'style', 'edit', 'String', 'xmax', 'BackgroundColor','w',...
            'callback',  @(a,b) folder('uicontrol_callback'),...
            'tag', 'plot_xmax', 'enable','off',...
            'position', [gap+2*b_width+2*gap, plotting_panel-4*(gap+b_height)-3*gap, b_width, b_height]);
        
        %   y-lim text
        obj.plot_ylim = ...
            uicontrol('Parent', folder_plotting_panel, 'style', 'checkbox', 'String', 'y-lim', 'tag','plot_ylim',...
            'callback',  @(a,b) folder('uicontrol_callback'),...
            'position', [gap, plotting_panel-5*(gap+b_height)-3*gap, text_width, b_height]);
        %   Field y-min
        obj.plot_ymin = ...
            uicontrol('Parent', folder_plotting_panel, 'style', 'edit', 'String', 'ymin', 'BackgroundColor','w',...
            'callback',  @(a,b) folder('uicontrol_callback'),...
            'tag', 'plot_ymin','enable','off', ...
            'position', [gap+b_width+gap, plotting_panel-5*(gap+b_height)-3*gap, b_width, b_height]);
        %   Field y-max
        obj.plot_ymax = ...
            uicontrol('Parent', folder_plotting_panel, 'style', 'edit', 'String', 'ymax', 'BackgroundColor','w',...
            'callback',  @(a,b) folder('uicontrol_callback'),...
            'tag', 'plot_ymax', 'enable','off',...
            'position', [gap+2*b_width+2*gap, plotting_panel-5*(gap+b_height)-3*gap, b_width, b_height]);
        
        %% -- Status Bar
        % MESH INFO
        % NODES
        %   Text
        uicontrol('Parent', folder_mesh_info_panel, 'style', 'text', 'String', 'NODES:','HorizontalAlignment', 'Left',...
            'position', [gap+0*(b_width+gap), gap, b_width, b_height],...
            'tooltipstring','Number of nodes');
        %   Field
        obj.folder_mesh_nod = ...
            uicontrol('Parent', folder_mesh_info_panel, 'style', 'text', 'String', '','HorizontalAlignment', 'Left', ...
            'tag','folder_mesh_nod',...
            'position', [gap+1*(b_width+gap), gap, b_width, b_height]);
        
        % ELEMS
        %   Text
        uicontrol('Parent', folder_mesh_info_panel, 'style', 'text', 'String', 'ELEMS:','HorizontalAlignment', 'Left', ...
            'position', [gap+2*(b_width+gap), gap, b_width, b_height],...
            'tooltipstring','Number of elements');
        %  Field
        obj.folder_mesh_nel = ...
            uicontrol('Parent', folder_mesh_info_panel, 'style', 'text', 'String', '','HorizontalAlignment', 'Left',...
            'tag','folder_mesh_nel', ...
            'position', [gap+3*(b_width+gap), gap, b_width, b_height]);
        
        % MARKER POINTS
        %   Text
        uicontrol('Parent', folder_mesh_info_panel, 'style', 'text', 'String', 'MARKERS:','HorizontalAlignment', 'Left', ...
            'position', [gap+4*(b_width+gap), gap, b_width, b_height],...
            'tooltipstring','Number of passive marker points');
        %  Field
        obj.folder_mesh_nmarkers = ...
            uicontrol('Parent', folder_mesh_info_panel, 'style', 'text', 'String', '','HorizontalAlignment', 'Left', ...
            'tag','folder_mesh_nmarkers', ...
            'position', [gap+5*(b_width+gap), gap, b_width, b_height]);
        
        % STRAIN ELLIPSES
        %   Text
        uicontrol('Parent', folder_mesh_info_panel, 'style', 'text', 'String', 'STRAIN ELLIPSES:','HorizontalAlignment', 'Left',...
            'position', [gap+6*(b_width+gap), gap, 1.5*b_width, b_height],...
            'tooltipstring','Number of strain ellipses');
        %  Field
        obj.folder_mesh_nellipse = ...
            uicontrol('Parent', folder_mesh_info_panel, 'style', 'text', 'String', '','HorizontalAlignment', 'Left',...
            'tag','folder_mesh_nellipse', ...
            'position', [gap+7.5*(b_width+gap), gap, b_width, b_height]);
        
        % STATUS BAR
        obj.folder_status_bar_text = ...
            uicontrol('Parent', folder_status_panel, 'style', 'text', 'String', '','HorizontalAlignment', 'Left', ...
            'tag', 'folder_status_bar_text',...
            'position', [gap, gap, 3*text_width, b_height]);
        
        % Store in Figure Appdata
        setappdata(folder_gui_handle, 'obj', obj);
        
        %% -- Fold Plot
        h_cont  = uicontainer('parent', folder_fold_panel,'tag','folder_fold_uicontainer','ButtonDownFcn',@color_region);
        h_axes  = axes('parent', h_cont,'ActivePositionProperty', 'outerposition');
        box(h_axes, 'on');
        
        % Tags on axes store in appdata of parent
        setappdata(folder_fold_panel, 'h_axes', h_axes);
        setappdata(folder_fold_panel, 'h_cont', h_cont);
        
        % - Get Default Values
        folder('default_values');
        
        % - Create Interface & Mesh
        folder('interface_update')
        
        % - Update Uicontrols
        folder('uicontrol_update');
        
        % - Buttons Enable
        folder('buttons_enable')
        
        % - Update Plot
        folder('plot_update');
        
        
    case 'open_project'
        %% OPEN PROJECT
        
        % Get obj data
        fold = getappdata(folder_gui_handle, 'fold');
        obj  = getappdata(folder_gui_handle, 'obj');
        if isfield(fold,'run_output')
            folder_name = uigetdir(fold.run_output);
        else
            folder_name = uigetdir;
        end
        
        if length(folder_name)>1
            
            load([folder_name,filesep,'fold.mat'])
            
            fold.run_output   = [folder_name,filesep];
            set(folder_gui_handle,'Name',['FOLDER: ',fold.run_output])
            
            setappdata(folder_gui_handle, 'fold', fold);
        end
        
        if isfield(fold, 'NODES_run')
            tab_panel               = obj.tab_panel;
            tab_panel.SelectedChild = 2;
        else
            tab_panel               = obj.tab_panel;
            tab_panel.SelectedChild = 1;
        end
        
        % reset face and region selection
        face   = 0;
        region = 0;
        setappdata(folder_gui_handle, 'face', face);
        setappdata(folder_gui_handle, 'region', region);
        
        % - Create Interface & Mesh
        folder('interface_update')
        
        % - Update Uicontrols
        folder('uicontrol_update');
        
        % - Buttons Enable
        folder('buttons_enable')
        
        % - Update Plot
        folder('plot_update');
        
    case 'save_as_project'
        %% SAVE AS PROJECT
        
        % Get obj data
        fold = getappdata(folder_gui_handle, 'fold');
        obj  = getappdata(folder_gui_handle, 'obj');
        
        % Who is calling
        wcbo            = gcbo;
        Whoiscalling    = get(wcbo, 'Tag');
        
        if isfield(fold,'run_output')
            folder_name = uigetdir(fold.run_output,'Select Directory to Save Data.');
        else
            folder_name = uigetdir(fold.folder_path,'Select Directory to Save Data.');
        end
        folder_name = [folder_name,filesep];
        
        % If any folder is selected
        if length(folder_name)>2
            
            % Check if folder is empty
            D = dir(folder_name);
            
            if size(D,1)>2
                
                % Ask if want to overwrite
                ButtonName = questdlg('The folder is not empty. Do you want to overwrite data?.', ...
                    'Overwrite Data', ...
                    'Yes', 'No', 'No');
                
                if strcmp(ButtonName, 'No') || size(ButtonName,1)==0
                    fold.save = 0;
                    setappdata(folder_gui_handle, 'fold', fold);
                    return;
                else
                    fold.save = 1;
                end
            end
            
            % Check if run data exist
            if isfield(fold,'NODES_run')
                % run data exist
                
                if strcmpi(folder_name,fold.run_output)
                    % Overwrite data to the same folder
                    return;
                else
                    % Copying files to new folder
                    
                    %  Update status bar
                    set(obj.folder_status_bar_text,'string','Folder is busy. Copying files.')
                    
                    %copyfile(fold.run_output_temp,folder_name);
                    copying_file(fold.run_output,folder_name);
                    
                    %  Update status bar
                    set(obj.folder_status_bar_text,'string','')
                end
                
            else
                % run data does not exist
                fold.save = 1;
                
                % Remove all files and folders
                delete([folder_name,'*.mat']);
                if isdir([folder_name,'run_output'])
                    rmdir([folder_name,'run_output'],'s');
                end
                
                fold.popts.plot_selection           = 1;
                fold.popts.plot_selection_component = 1;
                %if isfield(fold, 'NODES_run')
                %    fold                            = rmfield(fold, 'NODES_run');
                %end
                
                % - Change Tab Panel
                obj                     = getappdata(folder_gui_handle, 'obj');
                tab_panel               = obj.tab_panel;
                tab_panel.SelectedChild = 1;
            end
            
            % Change path name and update title bar
            fold.run_output = folder_name;
            set(folder_gui_handle,'Name',['FOLDER: ',fold.run_output])
            
            % Save data
            setappdata(folder_gui_handle, 'fold', fold);
            
            % Save fold data
            save([fold.run_output,'fold'],'fold');
            
        else
            % In case no folder is selected do not allow to save data
            fold.save = 0;
            setappdata(folder_gui_handle, 'fold', fold);
        end
        
    case 'default_values'
        %% DEFAULT VALUES
        
        folder_path             = mfilename('fullpath');
        [pathstr, ~, ~]         = fileparts(folder_path);
        fold.folder_path        = [pathstr,filesep];
        
        %  Create output folder or if exist empty it
        set(folder_gui_handle,'Name',['FOLDER: '])
        
        % Box
        fold.box.width                      = 10;
        fold.box.height                     = 10;
        
        % Interface
        fold.face(1).y                      = -0.5;
        fold.face(2).y                      =  0.5;
        
        for ii = 1:2
            fold.face(ii).pert              = 1;
            fold.face(ii).ampl              = 0.1;
            fold.face(ii).wave              = fold.box.width;
            fold.face(ii).shift             = 0;
            fold.face(ii).width             = 1;
            fold.face(ii).nx                = 50;
        end
        
        % Rheology
        if ~isdeployed
            Input_data          = load([fold.folder_path,filesep,'rheology',filesep,'material_parameters.mat']);
        else
            Input_data          = load('material_parameters.mat');
        end
        fold.material_data  = Input_data.data;
        
        % Region
        fold.region(1).area                 = 1e-1;
        fold.region(1).material             = 1;
        fold.region(2).area                 = 1e-1;
        fold.region(2).material             = 5;
        fold.region(3).area                 = 1e-1;
        fold.region(3).material             = 1;
        
        % Passive Markers
        fold.markers.set                    = 0;
        fold.markers.type                   = 3;
        fold.markers.MARKERS                = [];
        fold.markers.cell_num               = 30;
        fold.markers.resolution             = 50;
        fold.markers.x_span                 = 0;
        fold.markers.xmin                   = [];
        fold.markers.xmax                   = [];
        fold.markers.y_span                 = 0;
        fold.markers.ymin                   = [];
        fold.markers.ymax                   = [];
        
        % Finite Strain
        fold.fstrain.set                    = 0;
        fold.fstrain.FSTRAIN                = [];
        fold.fstrain.FSTRAIN_grid           = [];
        fold.fstrain.cell_num               = 30;
        fold.fstrain.resolution             = 50;
        fold.fstrain.x_span                 = 0;
        fold.fstrain.xmin                   = [];
        fold.fstrain.xmax                   = [];
        fold.fstrain.y_span                 = 0;
        fold.fstrain.ymin                   = [];
        fold.fstrain.ymax                   = [];
        
        % Numerics
        fold.num.strain_mode                = 1;
        fold.num.strain                     = 50;
        fold.num.it       	                = 1;
        fold.num.nt       	                = 10;
        fold.num.temperature                = 300;
        fold.num.strain_rate                = 1e-15;
        fold.num.solver                     = 3;
        fold.num.picards                    = 5;
        fold.num.newtons                	= 10;
        fold.num.relres                     = 1e-6;
        fold.num.epsil                      = 1e-2;
        
        fold.max_tri_elem                   = 3e5; % nnodes=~3*nel
        fold.MESH.NODES                     = [];
        fold.MESH.ELEMS                     = [];
        
        % Selection options
        fold.selection.line_color         	= [0.8471 0.1608 0];
        fold.selection.line_width          	= 2;
        fold.selection.marker             	= 'o';
        fold.selection.marker_size        	= 6;
        fold.selection.marker_color       	= [0.8471 0.1608 0];
        fold.selection.marker_edge_color 	= [0.8471 0.1608 0];
        fold.selection.region_color        	= 0.9*[0.6 0.2 0];
        
        % Plotting options
        fold.FGT_data                       = 0;
        fold.popts.plot_selection           = 1;
        fold.popts.plot_selection_component = 1;
        % - Axis
        fold.popts.xmin                     = [];
        fold.popts.xmax                     = [];
        fold.popts.ymin                     = [];
        fold.popts.ymax                     = [];
        
        % - General
        fold.popts.axis_y                   = 1;
        fold.popts.layer_thick              = 1;
        fold.popts.layer_color              = 0.3*[1 1 1];
        fold.popts.mesh_thick               = 1;
        fold.popts.mesh_color               = 0.3*[1 1 1];
        fold.popts.marker_thick             = 1;
        fold.popts.marker_color             = [0.4660    0.6740    0.1880];
        fold.popts.fstrain_thick            = 1;
        fold.popts.fstrain_color            = [0.6350    0.0780    0.1840];
        fold.popts.vector_thick             = 1;
        fold.popts.vector_color             = 0.3*[0 0 0];
        fold.popts.tensor_thick             = 1;
        fold.popts.tensor_color1        	= [0.8500    0.3250    0.0980];
        fold.popts.tensor_color2          	= [0         0.4470    0.7410];
        
        % - Scalar Field
        fold.popts.colormap_type            = 4;
        fold.popts.colormap                 = 2;
        fold.popts.clim                     = 0;
        fold.popts.cmin                     = [];
        fold.popts.cmax                     = [];
        fold.popts.ncolors                  = 64;
        fold.popts.flip                     = 0;
        fold.popts.logscale                 = 0;
        
        % - Vector Field
        fold.vector.opts              = 2;
        fold.vector.relative          = 1;
        fold.vector.scaling           = 1;
        fold.vector.x_density         = 20;
        fold.vector.x_span            = 0;
        fold.vector.xmin              = [];
        fold.vector.xmax              = [];
        fold.vector.irregular         = 0;
        fold.vector.y_density         = [];
        fold.vector.y_span            = 0;
        fold.vector.ymin              = [];
        fold.vector.ymax              = [];
        % Tensor
        fold.tensor.opts              = 1;
        fold.tensor.style             = 3;
        fold.tensor.relative          = 1;
        fold.tensor.scaling           = 1;
        fold.tensor.x_density         = 15;
        fold.tensor.x_span            = 0;
        fold.tensor.xmin              = [];
        fold.tensor.xmax              = [];
        fold.tensor.irregular         = 0;
        fold.tensor.y_density         = [];
        fold.tensor.y_span            = 0;
        fold.tensor.ymin              = [];
        fold.tensor.ymax              = [];
        
        % - Colorbar
        fold.popts.colorbar_position  = 1;
        
        % - Set default object setting
        obj = getappdata(folder_gui_handle, 'obj');
        
        set(obj.folder_markers_set,	'value',0)
        set(obj.folder_fstrain_set,	'value',0)
        set(obj.folder_mesh,        'value',1)
        set(obj.folder_markers,  	'value',1)
        set(obj.folder_fstrain,     'value',1)
        set(obj.folder_vector,      'value',0)
        set(obj.folder_tensor,  	'value',0)
        set(obj.plot_xlim,          'value',0)
        set(obj.plot_ylim,          'value',0)
        
        % Update perturbation list
        pert_name = {'Sine';'Red Noise'; 'White Noise'; 'Gaussian Noise'; 'Step'; 'Triangle'; 'Bell'};
        set(obj.folder_pert, 'String',pert_name);
        
        % Store in Figure Appdata
        setappdata(folder_gui_handle, 'fold', fold);
        
        % Set default interface and region number
        face   = 0;
        setappdata(folder_gui_handle, 'face', face);
        region = 0;
        setappdata(folder_gui_handle, 'region', region);
        
        
    case 'interface_update'
        %% INTERFACE UPDATE
        
        %  Get data
        fold        = getappdata(folder_gui_handle, 'fold');
        obj         = getappdata(folder_gui_handle, 'obj');
        
        %  Update status bar
        set(obj.folder_status_bar_text,'string','FOLDER is busy. Loading data.');
        
        % Create new interface or load data
        if ~isfield(fold, 'NODES_run')
            
            % Generate new interface geometry if not loaded from FGT
            if fold.FGT_data==0
                for ii = 1:length(fold.face)
                    if fold.face(ii).pert <= 7
                        % Default perturbations
                        pert            = perturbation(fold.face(ii).pert, fold.face(ii).wave, fold.box.width, fold.face(ii).shift, fold.face(ii).width, fold.face(ii).nx, fold.face(ii).ampl);
                        
                        fold.face(ii).X = linspace(-fold.box.width/2,fold.box.width/2,fold.face(ii).nx);
                        fold.face(ii).Y = pert+fold.face(ii).y;
                    else
                        % User defined perturbations
                        x               = fold.pert(fold.face(ii).pert-7).x;
                        fold.face(ii).X = x*fold.box.width/(max(x)-min(x));
                        fold.face(ii).Y = fold.face(ii).ampl*fold.pert(fold.face(ii).pert-7).y+fold.face(ii).y;
                        fold.face(ii).nx= length(fold.face(ii).X);
                    end
                end
            end
            
            % Triangle input
            [NODES, SEGMENTS, PHASE_PTS, PHASE_idx, REGIONS, opts] = geometry_for_traingle(fold);
            tristr.points         = NODES;
            tristr.segments       = uint32(SEGMENTS);  % note segments have to be uint32
            tristr.regions        = PHASE_PTS;
            
            % Generate mesh using triangle
            try
                MESH              = mtriangle(opts, tristr);
                display(['MESH NODES        : ' num2str(size(MESH.NODES,2))]);
                display(['MESH TRIANGLES    : ' num2str(size(MESH.ELEMS,2))]);
            catch err
                % If triangle does not work provide tips
                uiwait(warndlg(err.message, 'modal'));
                return;
            end
            
            % Save into fold structure
            fold.NODES          = NODES;
            fold.MESH           = MESH;
            fold.MESH_opts      = opts;
            fold.SEGM           = SEGMENTS;
            fold.REGIONS        = REGIONS;
            fold.PHASE_idx      = PHASE_idx;
            
        else
            
            % Initialize data for load
            NODES_run   = [];
            
            % Load interface geometry from run
            load([fold.run_output,'run_output',filesep,'nodes_',num2str(fold.num.it,'%.4d')]);
            temp = load([fold.run_output,'run_output',filesep,'run_',num2str(fold.num.it,'%.4d')],'MESH');
            
            % Find interfaces
            for ii = 1:length(fold.PHASE_idx)-1
                idx            = fold.PHASE_idx(ii+1)-1+(1:fold.face(ii).nx);
                fold.face(ii).X = NODES_run(1,idx);
                fold.face(ii).Y = NODES_run(2,idx);
            end
            
            % Save into fold structure
            fold.NODES          = NODES_run;
            fold.MESH           = temp.MESH;
            fold.Vel            = [];
            fold.Pressure       = [];
            fold.Mu_app         = [];
            
            clear NODES_run temp
            
        end
        
        % Update Folder data
        setappdata(folder_gui_handle, 'fold', fold);
        
        %  Update status bar
        set(obj.folder_status_bar_text,'string','');
        
        
    case 'uicontrol_update'
        %% UICONTROL UPDATE
        
        % Get Folder data
        fold    = getappdata(folder_gui_handle, 'fold');
        face   	= getappdata(folder_gui_handle, 'face');
        region 	= getappdata(folder_gui_handle, 'region');
        obj 	= getappdata(folder_gui_handle, 'obj');
        
        % Update uicontrols
        % - Domain
        set(obj.folder_domain_width,       'string', num2str(fold.box.width));
        set(obj.folder_domain_height,      'string', num2str(fold.box.height));
        
        % - Interface number (show parameters when > 0  and disactivate it when = 0)
        if face>0
            set(obj.face_number,            'string', num2str(face));
            set(obj.folder_position,        'string', num2str(fold.face(face).y));
            set(obj.folder_pert,            'value',  fold.face(face).pert);
            set(obj.folder_ampl,            'string', num2str(fold.face(face).ampl));
            set(obj.folder_wave,            'string', num2str(fold.face(face).wave));
            set(obj.folder_phase_shift,     'string', num2str(fold.face(face).shift));
            set(obj.folder_bell_width,      'string', num2str(fold.face(face).width));
            set(obj.folder_nx,              'string', num2str(fold.face(face).nx));
        else
            set(obj.face_number,            'string', num2str([]));
            set(obj.folder_position,        'string', num2str([]));
            set(obj.folder_pert,            'value',  1);
            set(obj.folder_ampl,            'string', num2str([]));
            set(obj.folder_wave,            'string', num2str([]));
            set(obj.folder_phase_shift,     'string', num2str([]));
            set(obj.folder_bell_width,      'string', num2str([]));
            set(obj.folder_nx,              'string', num2str([]));
        end
        
        % - Region number (show parameters when > 0  and disactivate it when = 0)
        if region>0
            set(obj.region_number,          'string', num2str(region));
            if size(fold.material_data,1)>=region
                set(obj.folder_material, 	'value',  fold.region(region).material);
            else
                set(obj.folder_material,  	'value',  1);
            end
            set(obj.folder_area,            'string',  num2str(fold.region(region).area));
        else
            set(obj.region_number,          'string', num2str([]));
            set(obj.folder_material,        'value',  1);
            set(obj.folder_area,            'string', num2str([]));
        end
        %   Update material list
        set(obj.folder_material,            'string', {char(fold.material_data{:,2})});
        
        % - Passive Markers and Finite Strain
        if fold.markers.set == 1
            set(obj.folder_markers_type,    'value',  fold.markers.type);
        end
        
        % - Deformation
        set(obj.folder_strain_shortening,  'value',  (fold.num.strain_mode+1)/2);
        set(obj.folder_strain_extension,   'value',  (-fold.num.strain_mode+1)/2);
        set(obj.folder_shortening,         'string', num2str(fold.num.strain));
        set(obj.folder_time,               'string', [num2str(fold.num.it-1),'/',num2str(fold.num.nt)]);
        set(obj.folder_slider,             'value',  fold.num.it);
        
        % - Scalar Field
        set(obj.folder_plotting,           'value', fold.popts.plot_selection);
        set(obj.folder_plotting_component, 'value', fold.popts.plot_selection_component);
        if ~isempty(intersect(fold.popts.plot_selection,[1 4 8]))
            % no components e.g. regions,pressure
            set(obj.folder_plotting_component,'String', {'none'})
        elseif ~isempty(intersect(fold.popts.plot_selection,[2 3]))
            % vectors e.g. velocity
            set(obj.folder_plotting_component,'String', {'magnitude','x','y'})
        elseif ~isempty(intersect(fold.popts.plot_selection,[5 6 7]))
            % tensors e.g. stress
            set(obj.folder_plotting_component,'String', {'II invariant','xx','yy','xy'})
        end
        set(obj.folder_colormap_type,        'value',  fold.popts.colormap_type);
        if fold.popts.colormap_type == 1
            set(obj.folder_colormap,'String',...
                {'blues';'browns';'gray';'greens';'oranges';'purples'; 'reds'; 'violets'});
        elseif fold.popts.colormap_type == 2
            set(obj.folder_colormap,'String',...
                {'blue_black';'blue_purple';'orange_black';'green_blue';'purple_blue';'yellow_black'; 'yellow_green'; 'yellow_red'});
        elseif fold.popts.colormap_type == 3
            set(obj.folder_colormap,'String',...
                {'purple_white_green';'orange_white_blue';'brown_white_green';'red_white_blue';'red_white_black';'red_yellow_blue'; 'red_yellow_green'});
        elseif fold.popts.colormap_type == 4
            set(obj.folder_colormap,'String',...
                {'earth';'parula';'rainbow';'spectral';'stern';'terrain'; 'haze'});
        end
        set(obj.folder_colormap,        'value',  fold.popts.colormap);
        set(obj.folder_clim,          	'value',  fold.popts.clim);
        set(obj.folder_cmin,           	'string', num2str(fold.popts.cmin));
        set(obj.folder_cmax,          	'string', num2str(fold.popts.cmax));
        set(obj.folder_ncolors,       	'string', num2str(fold.popts.ncolors));
        set(obj.folder_flip,          	'value',  fold.popts.flip);
        set(obj.folder_logscale,        'value',  fold.popts.logscale);
        
        % - Vector field
        set(obj.folder_vector_opts,    	'value',  fold.vector.opts);
        set(obj.folder_vector_relative,	'value',  fold.vector.relative);
        set(obj.folder_vector_scaling, 	'string', num2str(fold.vector.scaling));
        
        % - Tensor field
        set(obj.folder_tensor_opts,    	'value',  fold.tensor.opts);
        set(obj.folder_tensor_style,  	'value',  fold.tensor.style);
        set(obj.folder_tensor_relative, 'value',  fold.tensor.relative);
        set(obj.folder_tensor_scaling, 	'string', num2str(fold.tensor.scaling));
        
        % - Legend/Colorbar position
        set(obj.folder_colorbar_position,    'value',  fold.popts.colorbar_position);
        
        % - Axes
        if get(obj.plot_xlim, 'value') == 1
            if isempty(fold.popts.xmin)
                % Get current value
                folder_fold_panel	= findobj(folder_gui_handle, 'tag', 'folder_fold_panel');
                h_axes              = getappdata(folder_fold_panel, 'h_axes');
                temp                = get(h_axes,'XLim');
                fold.popts.xmin     = temp(1);
                fold.popts.xmax     = temp(2);
            else
                % Update value
                set(obj.plot_xmin,       	'string', num2str(fold.popts.xmin));
                set(obj.plot_xmax,       	'string', num2str(fold.popts.xmax));
            end
        end
        if get(obj.plot_ylim, 'value') == 1
            if isempty(fold.popts.ymin)
                % Get current value
                folder_fold_panel	= findobj(folder_gui_handle, 'tag', 'folder_fold_panel');
                h_axes              = getappdata(folder_fold_panel, 'h_axes');
                temp                = get(h_axes,'YLim');
                fold.popts.ymin     = temp(1);
                fold.popts.ymax     = temp(2);
            else
                % Update value
                set(obj.plot_ymin,      'string', num2str(fold.popts.ymin));
                set(obj.plot_ymax,     	'string', num2str(fold.popts.ymax));
            end
        end
        
        % - Info
        if size(fold.MESH.NODES,2)<1e6
            set(obj.folder_mesh_nod,   	'string', num2str(size(fold.MESH.NODES,2)),'ForegroundColor',0.3*[1 1 1],'FontWeight','normal');
            set(obj.folder_mesh_nel,    'string', num2str(size(fold.MESH.ELEMS,2)),'ForegroundColor',0.3*[1 1 1],'FontWeight','normal');
        else
            % Mark numbers in red in case of large number of elements
            set(obj.folder_mesh_nod,   	'string', num2str(size(fold.MESH.NODES,2)),'ForegroundColor','r','FontWeight','bold');
            set(obj.folder_mesh_nel,   	'string', num2str(size(fold.MESH.ELEMS,2)),'ForegroundColor','r','FontWeight','bold');
        end
        
        if size(fold.markers.MARKERS,2)<1e8
            set(obj.folder_mesh_nmarkers, 'string', num2str(size(fold.markers.MARKERS,2)), 'ForegroundColor',0.3*[1 1 1],'FontWeight','normal');
        else
            set(obj.folder_mesh_nmarkers, 'string', num2str(size(fold.markers.MARKERS,2)), 'ForegroundColor','r','FontWeight','normal');
        end
        if size(fold.fstrain.FSTRAIN,2)<1e3
            set(obj.folder_mesh_nellipse, 'string', num2str(size(fold.fstrain.FSTRAIN,2)), 'ForegroundColor',0.3*[1 1 1],'FontWeight','normal');
        else
            set(obj.folder_mesh_nellipse, 'string', num2str(size(fold.fstrain.FSTRAIN,2)), 'ForegroundColor',0.3*[1 1 1],'FontWeight','normal');
        end
        
        %  Update status bar
        set(obj.folder_status_bar_text,'string','')
        
        % Update Folder Data
        setappdata(folder_gui_handle, 'fold', fold);
        
    case 'buttons_enable'
        %% BUTTONS ENABLE
        % Here we enable / disable GUI elements depending on if we have run
        % data or not.
        
        % Get data
        fold      = getappdata(folder_gui_handle, 'fold');
        face      = getappdata(folder_gui_handle, 'face');
        region    = getappdata(folder_gui_handle, 'region');
        obj       = getappdata(folder_gui_handle, 'obj');
        
        % Check if we run data exist or not
        if ~isfield(fold, 'NODES_run') || fold.num.it==1
            % No run data or initial step
            
            % Main Menu
            set(obj.folder_load,                'enable', 'on');
            set(obj.folder_quick_model,         'enable', 'on');
            set(obj.folder_shift_interfaces,    'enable', 'on');
            set(obj.folder_modify_interfaces,   'enable', 'on');
            set(obj.folder_new_pert,            'enable', 'on');
            set(obj.folder_load_pert,           'enable', 'on');
            set(obj.import_pert_FGT,            'enable', 'on');
            set(obj.folder_run_menu,            'enable', 'on');
            set(obj.profile,                    'enable', 'off');
            
            % - Domain
            if fold.FGT_data == 0
                set(obj.folder_domain_width,   'enable', 'on');
            else
                set(obj.folder_domain_width,   'enable', 'off');
            end
            set(obj.folder_domain_height,      'enable', 'on');
            
            % - Interface
            set(obj.face_number_right,         'enable', 'off');
            set(obj.face_number_left,          'enable', 'off');
            if length(fold.face)>face
                set(obj.face_number_right,     'enable', 'on');
            end
            if face>0
                set(obj.face_number_left,      'enable', 'on');
            end
            
            set(obj.folder_new_interface,      'enable', 'on');
            set(obj.folder_remove_interface,   'enable', 'on');
            if length(fold.face)==1
                set(obj.folder_remove_interface,    'enable', 'off');
            elseif face<1
                set(obj.folder_remove_interface,    'enable', 'off');
            end
            if fold.FGT_data == 1
                set(obj.folder_new_interface,   'enable', 'off');
                set(obj.folder_remove_interface,'enable', 'off');
            end
            
            set(obj.folder_position,        'enable', 'on');
            set(obj.folder_pert,            'enable', 'on');
            set(obj.folder_ampl,            'enable', 'on');
            set(obj.folder_wave,            'enable', 'on');
            set(obj.folder_phase_shift,     'enable', 'on');
            set(obj.folder_bell_width,      'enable', 'on');
            set(obj.folder_nx,              'enable', 'on');
            
            if face>0 && fold.FGT_data == 0
                
                if fold.face(face).pert == 1
                    set(obj.folder_bell_width,  'enable', 'off');
                elseif fold.face(face).pert == 2 || fold.face(face).pert == 3
                    set(obj.folder_wave,        'enable', 'off');
                    set(obj.folder_phase_shift, 'enable', 'off');
                    set(obj.folder_bell_width,  'enable', 'off');
                elseif fold.face(face).pert == 4
                    set(obj.folder_phase_shift, 'enable', 'off');
                elseif fold.face(face).pert == 5
                    set(obj.folder_wave,        'enable', 'off');
                    set(obj.folder_bell_width,  'enable', 'off');
                elseif fold.face(face).pert == 6
                    set(obj.folder_bell_width,  'enable', 'off');
                elseif fold.face(face).pert == 7
                    set(obj.folder_wave,        'enable', 'off');
                elseif  fold.face(face).pert > 7
                    set(obj.folder_wave,    	'enable', 'off');
                    set(obj.folder_phase_shift, 'enable', 'off');
                    set(obj.folder_bell_width,  'enable', 'off');
                    set(obj.folder_nx,          'enable', 'off');
                end
            else
                set(obj.folder_position,        'enable', 'off');
                set(obj.folder_pert,            'enable', 'off');
                set(obj.folder_ampl,            'enable', 'off');
                set(obj.folder_wave,            'enable', 'off');
                set(obj.folder_phase_shift,     'enable', 'off');
                set(obj.folder_bell_width,      'enable', 'off');
                set(obj.folder_nx,              'enable', 'off');
            end
            
            % - Regions
            set(obj.region_number_right,        'enable', 'off');
            set(obj.region_number_left,         'enable', 'off');
            if length(fold.region)>region
                set(obj.region_number_right,    'enable', 'on');
            end
            if region>0
                set(obj.region_number_left,     'enable', 'on');
                set(obj.folder_material,        'enable', 'on');
                set(obj.folder_area,            'enable', 'on');
            else
                set(obj.folder_material,        'enable', 'off');
                set(obj.folder_area,            'enable', 'off');
            end
            
            % - Passive Markers and Finite Strain
            set(obj.folder_markers_set,         'enable', 'on', 'value', fold.markers.set);
            if fold.markers.set == 1
                set(obj.folder_markers_type,    'enable', 'on');
                set(obj.folder_markers_options,	'enable', 'on');
                set(obj.folder_markers,         'enable', 'on');
                if ~isfield(fold, 'NODES_run')
                    set(obj.folder_markers_menu,'enable', 'on');
                else
                    set(obj.folder_markers_menu,'enable', 'off');
                end
            else
                set(obj.folder_markers_type,    'enable', 'off');
                set(obj.folder_markers_options,	'enable', 'off');
                set(obj.folder_markers,         'enable', 'off');
                set(obj.folder_markers_menu,    'enable', 'off');
                
            end
            set(obj.folder_fstrain_set,         'enable', 'on', 'value', fold.fstrain.set);
            if fold.fstrain.set == 1
                set(obj.folder_fstrain_options,	'enable', 'on');
                set(obj.folder_fstrain,         'enable', 'on');
                if ~isfield(fold, 'NODES_run')
                    set(obj.folder_fstrain_menu,'enable', 'on');
                else
                    set(obj.folder_fstrain_menu,'enable', 'off');
                end
            else
                set(obj.folder_fstrain_options,	'enable', 'off');
                set(obj.folder_fstrain,         'enable', 'off');
                set(obj.folder_fstrain_menu,    'enable', 'off');
            end
            
            % - Deformation
            if ~isfield(fold, 'NODES_run')
                set(obj.folder_slider,    'enable', 'off');
            else
                set(obj.folder_slider,    'enable', 'on',...
                    'min', 1, 'max', fold.num.nt+1, 'value', fold.num.it, 'SliderStep', [1/fold.num.nt 1/fold.num.nt]);
            end
            set(obj.folder_run,                 'enable', 'on');
            set(obj.folder_run_options,         'enable', 'on');
            
            
            if ~isfield(fold, 'NODES_run')
                % - Play
                set(obj.folder_play_go_start,       'enable', 'off');
                set(obj.folder_play_backward,       'enable', 'off');
                set(obj.folder_play_stop,           'enable', 'off');
                set(obj.folder_play_forward,        'enable', 'off');
                set(obj.folder_play_go_end,         'enable', 'off');
                set(obj.folder_movie,               'enable', 'off');
                % - Scalar Field
                set(obj.folder_plotting,           	'value', 1, 'enable', 'off');
                set(obj.folder_plotting_component,	'value', 1, 'enable', 'off');
                set(obj.folder_colormap_type,       'enable', 'off');
                set(obj.folder_colormap,            'enable', 'off');
                set(obj.folder_ncolors,             'enable', 'off');
                set(obj.folder_clim,                'enable', 'off');
                set(obj.folder_cmin,                'enable', 'off');
                set(obj.folder_cmax,                'enable', 'off');
                set(obj.folder_flip,                'enable', 'off');
                set(obj.folder_logscale,            'enable', 'off');
                % - Vector field
                set(obj.folder_vector,              'value', 0, 'enable', 'off');
                set(obj.folder_vector_opts,         'enable', 'off');
                set(obj.folder_vector_relative,     'enable', 'off');
                set(obj.folder_vector_scaling,      'enable', 'off');
                set(obj.folder_vector_options,      'enable', 'off');
                set(obj.folder_vector_menu,       	'enable', 'off');
                % - Tensor field
                set(obj.folder_tensor,              'value', 0, 'enable', 'off');
                set(obj.folder_tensor_opts,         'enable', 'off');
                set(obj.folder_tensor_style,        'enable', 'off');
                set(obj.folder_tensor_relative,     'enable', 'off');
                set(obj.folder_tensor_scaling,      'enable', 'off');
                set(obj.folder_tensor_options,      'enable', 'off');
                set(obj.folder_tensor_menu,        	'enable', 'off');
            else
                % - Play
                set(obj.folder_play_go_start,       'enable', 'off');
                set(obj.folder_play_backward,       'enable', 'off');
                set(obj.folder_play_stop,           'enable', 'off');
                set(obj.folder_play_forward,        'enable', 'on');
                set(obj.folder_play_go_end,         'enable', 'on');
                set(obj.folder_movie,               'enable', 'on');
                
                % - Scalar
                set(obj.folder_plotting,           	'enable', 'on');
                set(obj.folder_plotting_component, 	'enable', 'on');
                if get(obj.folder_plotting,'value')==1
                    set(obj.folder_colormap_type,  	'enable', 'off');
                    set(obj.folder_colormap,      	'enable', 'off');
                    set(obj.folder_ncolors,       	'enable', 'off');
                    set(obj.folder_clim,          	'enable', 'off');
                    set(obj.folder_cmin,            'enable', 'off');
                    set(obj.folder_cmax,            'enable', 'off');
                    set(obj.folder_flip,          	'enable', 'off');
                    set(obj.folder_logscale,      	'enable', 'off');
                else
                    set(obj.folder_colormap_type,  	'enable', 'on');
                    set(obj.folder_colormap,      	'enable', 'on');
                    set(obj.folder_ncolors,       	'enable', 'on');
                    set(obj.folder_clim,         	'enable', 'on');
                    if get(obj.folder_clim,'value')==1
                        set(obj.folder_cmin,      	'enable', 'on');
                        set(obj.folder_cmax,      	'enable', 'on');
                    else
                        set(obj.folder_cmin,      	'enable', 'off');
                        set(obj.folder_cmax,      	'enable', 'off');
                    end
                    set(obj.folder_flip,          	'enable', 'on');
                    set(obj.folder_logscale,      	'enable', 'on');
                end
                
                % - Vector field
                set(obj.folder_vector,              'enable', 'on');
                if get(obj.folder_vector,'value')==1
                    set(obj.folder_vector_opts,         'enable', 'on');
                    set(obj.folder_vector_relative,     'enable', 'on');
                    set(obj.folder_vector_scaling,      'enable', 'on');
                    set(obj.folder_vector_options,      'enable', 'on');
                    set(obj.folder_vector_menu,       	'enable', 'on');
                else
                    set(obj.folder_vector_opts,         'enable', 'off');
                    set(obj.folder_vector_relative,     'enable', 'off');
                    set(obj.folder_vector_scaling,      'enable', 'off');
                    set(obj.folder_vector_options,      'enable', 'off');
                    set(obj.folder_vector_menu,       	'enable', 'off');
                end
                % - Tensor field
                set(obj.folder_tensor,              'enable', 'on');
                if get(obj.folder_tensor,'value')==1
                    set(obj.folder_tensor_opts,         'enable', 'on');
                    set(obj.folder_tensor_style,        'enable', 'on');
                    set(obj.folder_tensor_relative,     'enable', 'on');
                    set(obj.folder_tensor_scaling,      'enable', 'on');
                    set(obj.folder_tensor_options,      'enable', 'on');
                    set(obj.folder_tensor_menu,        	'enable', 'on');
                else
                    set(obj.folder_tensor_opts,         'enable', 'off');
                    set(obj.folder_tensor_style,        'enable', 'off');
                    set(obj.folder_tensor_relative,     'enable', 'off');
                    set(obj.folder_tensor_scaling,      'enable', 'off');
                    set(obj.folder_tensor_options,      'enable', 'off');
                    set(obj.folder_tensor_menu,        	'enable', 'off');
                end
            end
            
        else
            % We have run data
            
            % Main Menu
            set(obj.folder_load,                'enable', 'off');
            set(obj.folder_quick_model,         'enable', 'off');
            set(obj.folder_shift_interfaces,    'enable', 'off');
            set(obj.folder_modify_interfaces,   'enable', 'off');
            set(obj.folder_new_pert,            'enable', 'off');
            set(obj.folder_load_pert,           'enable', 'off');
            set(obj.import_pert_FGT,            'enable', 'off');
            set(obj.folder_run_menu,            'enable', 'off');
            set(obj.folder_markers_menu,    	'enable', 'off');
            set(obj.folder_fstrain_menu,      	'enable', 'off');
            set(obj.profile,                    'enable', 'on');
            
            % - Domain
            set(obj.folder_domain_width,   'enable',  'off');
            set(obj.folder_domain_height,  'enable',  'off');
            
            % - Interface
            set(obj.face_number_right,     'enable',  'off');
            set(obj.face_number_left,      'enable',  'off');
            if length(fold.face)>face
                set(obj.face_number_right, 'enable',  'on');
            end
            if face>0
                set(obj.face_number_left,  'enable', 'on');
            end
            set(obj.folder_new_interface,  'enable', 'off');
            set(obj.folder_remove_interface,'enable','off');
            set(obj.folder_position,       'enable', 'off');
            set(obj.folder_pert,           'enable', 'off');
            set(obj.folder_ampl,           'enable', 'off');
            set(obj.folder_wave,           'enable', 'off');
            set(obj.folder_phase_shift,    'enable', 'off');
            set(obj.folder_bell_width,     'enable', 'off');
            set(obj.folder_nx,             'enable', 'off');
            
            % - Regions
            set(obj.region_number_right,   'enable', 'off');
            set(obj.region_number_left,    'enable', 'off');
            if length(fold.region)>region
                set(obj.region_number_right,'enable', 'on');
            end
            if region>0
                set(obj.region_number_left,'enable', 'on');
            end
            set(obj.folder_material,       'enable', 'off');
            set(obj.folder_area,           'enable', 'off');
            
            % - Passive markers and Finite Strain
            set(obj.folder_markers_set,         'enable', 'off','value',fold.markers.set);
            set(obj.folder_markers_type,        'value', 3, 'enable', 'off');
            set(obj.folder_markers_options,   	'enable', 'off');
            if fold.markers.set == 1
                set(obj.folder_markers,         'enable', 'on');
            else
                set(obj.folder_markers,         'enable', 'off');
            end
            set(obj.folder_fstrain_set,         'enable', 'off','value',fold.fstrain.set);
            set(obj.folder_fstrain_options,     'enable', 'off');
            if fold.fstrain.set == 1
                set(obj.folder_fstrain,         'enable', 'on');
            else
                set(obj.folder_fstrain,         'enable', 'off');
            end
            
            % Update slider values
            set(obj.folder_slider,  'enable', 'on', 'min', 1, 'max', fold.num.nt+1, 'value', fold.num.it, 'SliderStep', [1/fold.num.nt 1/fold.num.nt]);
            set(obj.folder_run,      	'enable', 'off');
            set(obj.folder_run_options, 'enable', 'off');
            
            % - Play
            set(obj.folder_play_go_start,       'enable', 'on');
            set(obj.folder_play_backward,       'enable', 'on');
            set(obj.folder_play_stop,           'enable', 'off');
            if fold.num.it-1==fold.num.nt
                set(obj.folder_play_forward,  	'enable', 'off');
                set(obj.folder_play_go_end,   	'enable', 'off');
                set(obj.folder_movie,           'enable', 'on');
            else
                set(obj.folder_play_forward,   	'enable', 'on');
                set(obj.folder_play_go_end,    	'enable', 'on');
                set(obj.folder_movie,           'enable', 'on');
            end
            
            set(obj.folder_plotting,           	'enable', 'on');
            set(obj.folder_plotting_component,	'enable', 'on');
            % Scalar Field
            if get(obj.folder_plotting,'value')==1
                set(obj.folder_colormap_type,  	'enable', 'off');
                set(obj.folder_colormap,      	'enable', 'off');
                set(obj.folder_ncolors,       	'enable', 'off');
                set(obj.folder_clim,          	'enable', 'off');
                set(obj.folder_cmin,            'enable', 'off');
                set(obj.folder_cmax,            'enable', 'off');
                set(obj.folder_flip,            'enable', 'off');
                set(obj.folder_logscale,        'enable', 'off');
            else
                set(obj.folder_colormap_type,  	'enable', 'on');
                set(obj.folder_colormap,      	'enable', 'on');
                set(obj.folder_ncolors,       	'enable', 'on');
                set(obj.folder_clim,         	'enable', 'on');
                if get(obj.folder_clim,'value')==1
                    set(obj.folder_cmin,      	'enable', 'on');
                    set(obj.folder_cmax,      	'enable', 'on');
                else
                    set(obj.folder_cmin,      	'enable', 'off');
                    set(obj.folder_cmax,      	'enable', 'off');
                end
                set(obj.folder_flip,          	'enable', 'on');
                set(obj.folder_logscale,       	'enable', 'on');
            end
            % - Vector field
            set(obj.folder_vector,              'enable', 'on');
            if get(obj.folder_vector,'value')==1
                set(obj.folder_vector_opts,    	'enable', 'on');
                set(obj.folder_vector_relative, 'enable', 'on');
                set(obj.folder_vector_scaling, 	'enable', 'on');
                set(obj.folder_vector_options, 	'enable', 'on');
                set(obj.folder_vector_menu,     'enable', 'on');
            else
                set(obj.folder_vector_opts,   	'enable', 'off');
                set(obj.folder_vector_relative, 'enable', 'off');
                set(obj.folder_vector_scaling, 	'enable', 'off');
                set(obj.folder_vector_options, 	'enable', 'off');
                set(obj.folder_vector_menu,     'enable', 'off');
            end
            % - Tensor field
            set(obj.folder_tensor,              'enable', 'on');
            if get(obj.folder_tensor,'value')==1
                set(obj.folder_tensor_opts,   	'enable', 'on');
                set(obj.folder_tensor_style,  	'enable', 'on');
                set(obj.folder_tensor_relative,	'enable', 'on');
                set(obj.folder_tensor_scaling,	'enable', 'on');
                set(obj.folder_tensor_options, 	'enable', 'on');
                set(obj.folder_tensor_menu,     'enable', 'on');
            else
                set(obj.folder_tensor_opts,  	'enable', 'off');
                set(obj.folder_tensor_style,	'enable', 'off');
                set(obj.folder_tensor_relative,	'enable', 'off');
                set(obj.folder_tensor_scaling, 	'enable', 'off');
                set(obj.folder_tensor_options, 	'enable', 'off');
                set(obj.folder_tensor_menu,     'enable', 'off');
            end
        end
        
        % Colorbar/Legend
        if get(obj.folder_plotting, 'value') == 1
            set(obj.folder_colorbar,   'String', 'Legend');
        else
            set(obj.folder_colorbar,   'String', 'Colorbar');
        end
        
        % Activate xlim & ylim only when axis_tight is off
        if get(obj.plot_axis_tight, 'value') == 1
            
            set(obj.plot_xlim,    'enable', 'off');
            set(obj.plot_xmin,    'enable', 'off');
            set(obj.plot_xmax,    'enable', 'off');
            set(obj.plot_ylim,    'enable', 'off');
            set(obj.plot_ymin,    'enable', 'off');
            set(obj.plot_ymax,    'enable', 'off');
            
        else
            set(obj.plot_xlim,    'enable', 'on');
            if get(obj.plot_xlim, 'value') == 1
                set(obj.plot_xmin,    'enable', 'on');
                set(obj.plot_xmax,    'enable', 'on');
            else
                set(obj.plot_xmin,    'enable', 'off', 'String','xmin');
                set(obj.plot_xmax,    'enable', 'off', 'String','xmax');
            end
            set(obj.plot_ylim,    'enable', 'on');
            if get(obj.plot_ylim, 'value') == 1
                set(obj.plot_ymin,    'enable', 'on');
                set(obj.plot_ymax,    'enable', 'on');
            else
                set(obj.plot_ymin,    'enable', 'off', 'String','ymin');
                set(obj.plot_ymax,    'enable', 'off', 'String','ymax');
            end
        end
        
    case 'uicontrol_callback'
        %% UICONTROL CALLBACK
        
        % Get object handles
        obj       = getappdata(folder_gui_handle, 'obj');
        
        %  Update status bar
        set(obj.folder_status_bar_text,'string','FOLDER is busy. Updating data.')
        
        % Who is calling
        wcbo            = gcbo;
        Whoiscalling    = get(wcbo, 'Tag');
        
        % If it is empty it is likely the tab_panel. No idea why it does
        % not show up when we ask gcbo. file comment on FEX?
        % Need to figure out if we go from 2 to 1 or 1 to 2
        % Other possibility is that folder_run has caused a tab panel
        % switch once results are obtained.
        % Additional problem is with different versions of GUILayout and
        % SelectedChild is mixed up
        if verLessThan('matlab', '8.4.0')
            if isempty(Whoiscalling) && obj.tab_panel.SelectedChild == 2
                Whoiscalling = 'tab_panel_child1';
            end
            if isempty(Whoiscalling) && obj.tab_panel.SelectedChild == 1
                Whoiscalling = 'tab_panel_child2';
            end
            if strcmpi(Whoiscalling, 'folder_run') && obj.tab_panel.SelectedChild == 1
                Whoiscalling = 'tab_panel_child2';
            end
        else
            if isempty(Whoiscalling) && obj.tab_panel.SelectedChild == 1
                Whoiscalling = 'tab_panel_child1';
            end
            if isempty(Whoiscalling) && obj.tab_panel.SelectedChild == 2
                Whoiscalling = 'tab_panel_child2';
            end
            if strcmpi(Whoiscalling, 'folder_run') && obj.tab_panel.SelectedChild == 2
                Whoiscalling = 'tab_panel_child2';
            end
        end
        
        
        if isempty(Whoiscalling)
            %  Update status bar & bail out
            set(obj.folder_status_bar_text,'string','')
            return;
        end
        
        %  Get data
        fold        = getappdata(folder_gui_handle, 'fold');
        face        = getappdata(folder_gui_handle, 'face');
        region      = getappdata(folder_gui_handle, 'region');
        
        % Check input parameter
        if strcmpi(Whoiscalling,'folder_domain_width') || strcmpi(Whoiscalling,'folder_domain_height') || ...
                strcmpi(Whoiscalling,'folder_position') || strcmpi(Whoiscalling,'folder_ampl') || ...
                strcmpi(Whoiscalling,'folder_wave') || strcmpi(Whoiscalling,'folder_phase_shift') || ...
                strcmpi(Whoiscalling,'folder_bell_width') || strcmpi(Whoiscalling,'folder_nx') || ...
                strcmpi(Whoiscalling,'folder_area') || strcmpi(Whoiscalling,'folder_shortening') || ...
                strcmpi(Whoiscalling,'folder_ncolors') || strcmpi(Whoiscalling,'folder_cmin') || strcmpi(Whoiscalling,'folder_cmax') || ...
                strcmpi(Whoiscalling,'folder_vector_scaling') || strcmpi(Whoiscalling,'folder_tensor_scaling') || ...
                strcmpi(Whoiscalling,'plot_xmin') || strcmpi(Whoiscalling,'plot_xmax') || ...
                strcmpi(Whoiscalling,'plot_ymin') || strcmpi(Whoiscalling,'plot_ymax')
            
            if isnan(str2double(get(gcbo,  'string')))
                warndlg('Wrong input argument.', 'Error!', 'modal');
                folder('uicontrol_update');
                return;
            end
        end
        
        % Check if previous run data exists and what to do
        if isfield(fold, 'NODES_run') && ~isempty(fold.NODES_run) && ~strcmpi(Whoiscalling, 'folder_slider') && ~strcmpi(Whoiscalling, 'tab_panel_child1') && ~strcmpi(Whoiscalling, 'tab_panel_child2') && ...
                ~strcmpi(Whoiscalling,'materials_apply') && ~strcmpi(Whoiscalling,'materials_done') && ...
                ~strcmpi(Whoiscalling,'folder_plotting') && ~strcmpi(Whoiscalling,'folder_plotting_component') && ...
                ~strcmpi(Whoiscalling,'folder_colormap_type') && ~strcmpi(Whoiscalling,'folder_colormap') && ~strcmpi(Whoiscalling,'folder_ncolors') && ...
                ~strcmpi(Whoiscalling,'folder_flip') && ~strcmpi(Whoiscalling,'folder_logscale') && ...
                ~strcmpi(Whoiscalling,'folder_clim') && ~strcmpi(Whoiscalling,'folder_cmin') && ~strcmpi(Whoiscalling,'folder_cmax') && ...
                ~strcmpi(Whoiscalling,'folder_vector') && ~strcmpi(Whoiscalling,'folder_vector_opts') && ~strcmpi(Whoiscalling,'folder_vector_relative') && ~strcmpi(Whoiscalling,'folder_vector_scaling') && ...
                ~strcmpi(Whoiscalling,'folder_tensor') && ~strcmpi(Whoiscalling,'folder_tensor_opts') && ~strcmpi(Whoiscalling,'folder_tensor_style') && ~strcmpi(Whoiscalling,'folder_tensor_relative') && ~strcmpi(Whoiscalling,'folder_tensor_scaling') && ...
                ~strcmpi(Whoiscalling,'fstrain_done') && ...
                ~strcmpi(Whoiscalling,'folder_colorbar_position') && ~strcmpi(Whoiscalling,'plot_axis_tight') &&...
                ~strcmpi(Whoiscalling,'plot_xlim') && ~strcmpi(Whoiscalling,'plot_xmin') && ~strcmpi(Whoiscalling,'plot_xmax') &&...
                ~strcmpi(Whoiscalling,'plot_ylim') && ~strcmpi(Whoiscalling,'plot_ymin') && ~strcmpi(Whoiscalling,'plot_ymax') && ...
                ~strcmpi(Whoiscalling,'Standard.FileOpen')
            
            ButtonName = questdlg('Do you want to modify setup?', ...
                'Modify setup', ...
                'Yes', 'No', 'No');
            
            if strcmp(ButtonName, 'Yes')
                fold                                = rmfield(fold, 'NODES_run');
                fold.popts.plot_selection           = 1;
                fold.popts.plot_selection_component = 1;
                %fold.num.strain                     = 50;
                
                % - Change Tab Panel
                obj       = getappdata(folder_gui_handle, 'obj');
                tab_panel = obj.tab_panel;
                tab_panel.SelectedChild = 1;
            else
                % Reset uicontrol to previous value
                folder('uicontrol_update');
                folder('buttons_enable');
                
                % Update statusbar
                set(obj.folder_status_bar_text,'string','')
                return;
            end
        end
        
        switch Whoiscalling
            
            %% -- Tab Panel
            case 'tab_panel_child1'
                fold.num.it = 1;
                fold.popts.plot_selection = 1;
                fold.popts.plot_selection_components = 1;
                
            case 'tab_panel_child2'
                
                if ~isfield(fold, 'NODES_run')
                    fold.num.it = 1;
                else
                    fold.num.it = fold.num.nt+1;
                end
                
                %% -- Domain
            case 'folder_domain_width'
                
                % Prevent from traingle crash
                % Rough estimation of number of triangles
                width   = str2double(get(wcbo,  'string'));
                nel_est = width*sum(diff([-fold.box.height/2; vertcat(fold.face.y); fold.box.height/2])./vertcat(fold.region.area));
                if nel_est > fold.max_tri_elem
                    warndlg('The resolution with respect to the domain size is too high and can cause the program to crash.', 'Error!', 'modal');
                else
                    if width>0
                        fold.box.width          = str2double(get(wcbo,  'string'));
                    else
                        warndlg('The domain width must be greater than 0.', 'Error!', 'modal');
                        folder('uicontrol_update');
                        return;
                    end
                end
                
            case 'folder_domain_height'
                
                if fold.FGT_data == 0
                    % Prevent from traingle crash
                    % Rough estimation of number of triangles
                    height  = str2double(get(wcbo,  'string'));
                    nel_est = fold.box.width*sum(diff([-height/2; vertcat(fold.face.y); height/2])./vertcat(fold.region.area));
                    if nel_est > fold.max_tri_elem
                        warndlg('The resolution with respect to the domain size is too high and can cause the program to crash.', 'Error!', 'modal');
                        folder('uicontrol_update');
                        return;
                    end
                    
                    % Number of interfaces
                    nface = length(vertcat(fold.face.y));
                    
                    % Change only if the box embeds all the interfaces
                    if -str2double(get(wcbo,'string'))/2 < (fold.face(1).y     - abs(fold.face(1).ampl) - fold.num.epsil) &&...
                            str2double(get(wcbo,'string'))/2 > (fold.face(nface).y + abs(fold.face(nface).ampl) + fold.num.epsil)
                        fold.box.height         = str2double(get(wcbo,  'string'));
                    else
                        warndlg('The domian resolution is too small and does not embed all interfaces.', 'Error!', 'modal');
                        folder('uicontrol_update');
                        return;
                    end
                    
                else
                    if -str2double(get(wcbo,'string'))/2 < min(horzcat(fold.face.Y)) && str2double(get(wcbo,'string'))/2 > max(horzcat(fold.face.Y))
                        fold.box.height         = str2double(get(wcbo,  'string'));
                    else
                        warndlg('The domian resolution is too small and does not embed all interfaces.', 'Error!', 'modal');
                        folder('uicontrol_update');
                        return;
                    end
                end
                
                %% -- Interface
            case 'folder_new_interface'
                
                % Find new interface position
                if length(fold.face)==1
                    if fold.face(1).ampl < 1
                        y = fold.face(1).y+1;
                    else
                        y = fold.face(1).y+2*fold.face(1).ampl+1;
                    end
                else
                    y = fold.face(end).y + (fold.face(end).y-fold.face(end-1).y);
                end
                
                % Check if the interface is not defined outside the domain
                ii        = length(fold.face)+1;
                if y > fold.box.height/2 - 2*fold.face(ii-1).ampl
                    warndlg('New interface is defined outside the domain.', 'Error!', 'modal');
                    return;
                end
                
                % Prevent from traingle crash
                % Rough estimation of number of triangles
                yy      = [-fold.box.height/2; vertcat(fold.face.y); y; fold.box.height/2];
                area    = [vertcat(fold.region.area); fold.region(end).area];
                nel_est = fold.box.width*sum(diff(yy)./area);
                if nel_est > fold.max_tri_elem
                    warndlg('The resolution with respect to the domain size is too high and can cause the program to crash.', 'Error!', 'modal');
                    folder('uicontrol_update');
                    return;
                end
                
                % Set new values
                % Interface
                fold.face(ii).y      	 = y;
                fold.face(ii).pert     	 = fold.face(ii-1).pert;
                fold.face(ii).ampl       = fold.face(ii-1).ampl;
                fold.face(ii).wave       = fold.face(ii-1).wave;
                fold.face(ii).shift  	 = fold.face(ii-1).shift;
                fold.face(ii).width    	 = fold.face(ii-1).width;
                fold.face(ii).nx         = fold.face(ii-1).nx;
                
                % Region
                fold.region(ii+1).area    	   = fold.region(ii).area;
                fold.region(ii+1).material     = fold.region(ii).material;
                face = ii;
                
            case 'folder_remove_interface'
                
                % Prevent from traingle crash
                % Rough estimation of number of triangles
                yy           = [-fold.box.height/2; vertcat(fold.face.y); fold.box.height/2];
                yy(face)     = [];
                area         = vertcat(fold.region.area);
                area(face+1) = [];
                nel_est = fold.box.width*sum(diff(yy)./area);
                if nel_est > fold.max_tri_elem
                    warndlg('The resolution with respect to the domain size is too high and can cause the program to crash.', 'Error!', 'modal');
                    folder('uicontrol_update');
                    return;
                end
                
                fold.face(face)     = [];
                fold.region(face+1) = [];
                
                if length(fold.face)<face
                    face = face-1;
                end
                if length(fold.region)<region
                    region = region-1;
                end
                
            case 'folder_position'
                
                new_y       = str2double(get(wcbo,  'string'));
                
                % Check if layer position is within the box
                if new_y-abs(fold.face(face).ampl) < -fold.box.height/2 + fold.num.epsil || new_y + abs(fold.face(face).ampl) > fold.box.height/2 - fold.num.epsil
                    warndlg('The interface position cannot be defined outside the domain.', 'Error!', 'modal');
                    folder('uicontrol_update');
                    return;
                end
                
                % If new position does not change
                if new_y == fold.face(face).y
                    folder('uicontrol_update');
                    return;
                end
                
                idx       = 1:length(fold.face);
                idx(face) = [];
                y         = vertcat(fold.face(idx).y);
                idx_new   = find(sort([y;new_y]) == new_y);
                
                % Check if position of new interface overlaps with neighbouring interface
                if idx_new(1)-1 > 0 % bound from bottom
                    ybot = fold.face(idx_new(1)-1).y + abs(fold.face(idx_new(1)-1).ampl) + fold.num.epsil;
                else
                    ybot = -fold.box.height/2 + fold.num.epsil;
                end
                if idx_new(1)+1 <= length(vertcat(fold.face.y)) % bound from top
                    ytop = fold.face(idx_new(1)+1).y - abs(fold.face(idx_new(1)+1).ampl) - fold.num.epsil;
                else
                    ytop = fold.box.height/2 - fold.num.epsil;
                end
                
                if length(idx_new) ~= 1 || new_y-abs(fold.face(face).ampl) < ybot  ||   new_y+abs(fold.face(face).ampl) > ytop
                    warndlg('New position can cause some interfaces to intersect.', 'Error!', 'modal');
                    folder('uicontrol_update');
                    return;
                end
                
                % Update new position
                fold.face(face).y  = str2double(get(wcbo,  'string'));
                
                % Sort position if necessary
                if idx_new ~= face
                    yy    = vertcat(fold.face.y);
                    [order, idx] = sort(yy);
                    fold.face   = fold.face(idx);
                    fold.region = fold.region([idx; max(idx)+1]);
                end
                
            case 'folder_pert'
                
                fold.face(face).pert      = get(wcbo,  'value');
                
                % Modify name
                if fold.face(face).pert == 4
                    set(obj.folder_bell_width_text,'String','Hurst Exponent','tooltipstring',sprintf(''))
                    % Set default value
                    fold.face(face).width = 1;
                else
                    set(obj.folder_bell_width_text,'String','Bell Width','tooltipstring',sprintf('Width of the bell-shape perturbation.'))
                end
                
            case 'folder_ampl'
                
                %Check the possible range of the interface position
                if face-1 > 0 % bound from bottom
                    ybot = fold.face(face-1).y + abs(fold.face(face-1).ampl) + fold.num.epsil;
                else
                    ybot = -fold.box.height/2 + fold.num.epsil;
                end
                if face+1 <= length(vertcat(fold.face.y)) % bound from top
                    ytop = fold.face(face+1).y - abs(fold.face(face+1).ampl) - fold.num.epsil;
                else
                    ytop = fold.box.height/2 - fold.num.epsil;
                end
                
                if fold.face(face).y-abs(str2double(get(wcbo,'string'))) > ybot   &&   fold.face(face).y+abs(str2double(get(wcbo,'string'))) < ytop
                    fold.face(face).ampl     = str2double(get(wcbo,  'string'));
                else
                    warndlg('High amplitude perturbation causes the neighbouring interfaces to intersect.', 'Error!', 'modal');
                    folder('uicontrol_update');
                    return;
                end
                
            case 'folder_wave'
                
                % Check if the wavelength is a positive value
                if str2double(get(wcbo,  'string')) <= 0
                    warndlg('The wavelength must be a positive value.', 'Error!', 'modal');
                    folder('uicontrol_update');
                    return;
                end
                
                fold.face(face).wave     = str2double(get(wcbo,  'string'));
                
            case 'folder_phase_shift'
                
                % Check if pert shift is not outside the domain
                if fold.face(face).pert ~= 4
                    if str2double(get(wcbo,  'string')) < -fold.box.width/2 || str2double(get(wcbo,  'string')) > fold.box.width/2
                        warndlg('The value must be smaller than half of the domain width.', 'Error!', 'modal');
                        folder('uicontrol_update');
                        return;
                    end
                end
                
                fold.face(face).shift    = str2double(get(wcbo,  'string'));
                
            case 'folder_bell_width'
                
                if fold.face(face).pert ~= 4
                    % Check if the bell width is a positive value
                    if str2double(get(wcbo,  'string')) <= 0
                        warndlg('The bell width must be a positive value.', 'Error!', 'modal');
                        folder('uicontrol_update');
                        return;
                    end
                else
                    % Check if the Hurst exponent is between 0-1
                    if str2double(get(wcbo,  'string')) < 0 || str2double(get(wcbo,  'string')) > 1
                        warndlg('The Hurst exponent value must be between 0 and 1.', 'Error!', 'modal');
                        folder('uicontrol_update');
                        return;
                    end
                end
                
                fold.face(face).width    = str2double(get(wcbo,  'string'));
                
            case 'folder_nx'
                
                % Check if number of points on the interface is > 2
                if str2double(get(wcbo,  'string')) < 3
                    warndlg('Number of points on the interface should be larger than 2.', 'Error!', 'modal');
                    folder('uicontrol_update');
                    return;
                end
                if mod(str2double(get(gcbo,'string')),1)~=0
                    warndlg('Value must be an integer.', 'Error!', 'modal');
                    folder('uicontrol_update');
                    return;
                end
                
                fold.face(face).nx       = str2double(get(wcbo,  'string'));
                
            case 'shift_center'
                
                shift = -(fold.face(1).y + (fold.face(end).y-fold.face(1).y)/2);
                
                if shift+fold.face(1).y < -fold.box.height/2 || shift+fold.face(end).y > fold.box.height/2
                    warndlg('Position of interfaces exceeds the domain size.', 'Error!', 'modal');
                    return;
                else
                    for iface = 1:length(fold.face)
                        fold.face(iface).y = fold.face(iface).y + shift;
                    end
                end
                
            case 'shift_by_value'
                
                % Create input dialog box
                answer = inputdlg('Shift all interfaces by a value', 'Shift Interfaces', [1 50]);
                
                if ~isempty(answer)
                    if ~isnan(str2double(answer))
                        shift  = str2double(answer);
                        if shift+fold.face(1).y < -fold.box.height/2 || shift+fold.face(end).y > fold.box.height/2
                            warndlg('Position of interfaces exceeds the domain size.', 'Error!', 'modal');
                            return;
                        else
                            for iface = 1:length(fold.face)
                                fold.face(iface).y = fold.face(iface).y + shift;
                            end
                        end
                    else
                        warndlg('Wrongly assinged value.', 'Error!', 'modal');
                        return;
                    end
                end
                
            case 'shift_lower_interface'
                
                % Create input dialog box
                answer = inputdlg('Set position of the lowermost interface to', 'Shift Interfaces', [1 50]);
                
                if ~isempty(answer)
                    if ~isnan(str2double(answer))
                        shift  = str2double(answer)-fold.face(1).y;
                        if shift+fold.face(1).y < -fold.box.height/2 || shift+fold.face(end).y > fold.box.height/2
                            warndlg('Position of interfaces exceeds the domain size.', 'Error!', 'modal');
                            return;
                        else
                            for iface = 1:length(fold.face)
                                fold.face(iface).y = fold.face(iface).y + shift;
                            end
                        end
                    else
                        warndlg('Wrongly assinged value.', 'Error!', 'modal');
                        return;
                    end
                end
                
            case 'shift_upper_interface'
                
                % Create input dialog box
                answer = inputdlg('Set position of the lowermost interface to', 'Shift Interfaces', [1 50]);
                if ~isempty(answer)
                    if ~isnan(str2double(answer))
                        shift  = str2double(answer)-fold.face(end).y;
                        if shift+fold.face(1).y < -fold.box.height/2 || shift+fold.face(end).y > fold.box.height/2
                            warndlg('Position of interfaces exceeds the domain size.', 'Error!', 'modal');
                            return;
                        else
                            for iface = 1:length(fold.face)
                                fold.face(iface).y = fold.face(iface).y + shift;
                            end
                        end
                    else
                        warndlg('Wrongly assinged value.', 'Error!', 'modal');
                        folder('uicontrol_callback');
                        return;
                    end
                end
                
            case 'set_pert'
                
                
                str = get(obj.folder_pert, 'String');
                
                [Selection,ok] = listdlg('PromptString','Select perturbation:',...
                    'SelectionMode','single',...
                    'ListString',str);
                
                if ok == 1
                    for iface = 1:length(fold.face)
                        fold.face(iface).pert = Selection;
                    end
                end
                
            case 'set_amplitude'
                
                % Create input dialog box
                answer = inputdlg('Set amplitude for all interfaces.', 'Wavelength', [1 50]);
                if ~isempty(answer)
                    if ~isnan(str2double(answer))
                        
                        yy = [-fold.box.height/2; vertcat(fold.face.y); fold.box.height/2];
                        
                        if min(diff(yy))/2-fold.num.epsil > str2double(answer)
                            for iface = 1:length(fold.face)
                                fold.face(iface).ampl     = str2double(answer);
                            end
                        else
                            warndlg('High amplitude perturbation causes the neighbouring interfaces to intersect.', 'Error!', 'modal');
                            folder('uicontrol_update');
                            return;
                        end
                        
                    else
                        warndlg('Wrongly assinged value.', 'Error!', 'modal');
                        folder('uicontrol_callback');
                        return;
                    end
                end
                
            case 'set_wavelength'
                
                % Create input dialog box
                answer = inputdlg('Set wavelength for all interfaces.', 'Wavelength', [1 50]);
                if ~isempty(answer)
                    if ~isnan(str2double(answer))
                        
                        % Check if the wavelength is a positive value
                        if str2double(answer) <= 0
                            warndlg('The wavelength must be a positive value.', 'Error!', 'modal');
                            folder('uicontrol_update');
                            return;
                        end
                        
                        for iface = 1:length(fold.face)
                            fold.face(iface).wave     = str2double(answer);
                        end
                        
                    else
                        warndlg('Wrongly assinged value.', 'Error!', 'modal');
                        folder('uicontrol_callback');
                        return;
                    end
                end
                
            case 'set_shift'
                
                % Create input dialog box
                answer = inputdlg('Set shift for all interfaces.', 'Wavelength', [1 50]);
                if ~isempty(answer)
                    if ~isnan(str2double(answer))
                        
                        if str2double(answer) < -fold.box.width/2 || str2double(answer) > fold.box.width/2
                            warndlg('The value must be smaller than half of the domain width.', 'Error!', 'modal');
                            folder('uicontrol_update');
                            return;
                        end
                        
                        for iface = 1:length(fold.face)
                            fold.face(iface).shift   = str2double(answer);
                        end
                        
                    else
                        warndlg('Wrongly assinged value.', 'Error!', 'modal');
                        folder('uicontrol_callback');
                        return;
                    end
                end
                
            case 'set_bell'
                
                % Create input dialog box
                answer = inputdlg('Set bell width for all interfaces.', 'Wavelength', [1 50]);
                if ~isempty(answer)
                    if ~isnan(str2double(answer))
                        
                        if str2double(get(wcbo,  'string')) <= 0
                            warndlg('The bell width must be a positive value.', 'Error!', 'modal');
                            folder('uicontrol_update');
                            return;
                        end
                        
                        for iface = 1:length(fold.face)
                            fold.face(iface).width   = str2double(answer);
                        end
                        
                    else
                        warndlg('Wrongly assinged value.', 'Error!', 'modal');
                        folder('uicontrol_callback');
                        return;
                    end
                end
                
            case 'set_hurst'
                
                % Create input dialog box
                answer = inputdlg('Set Hurst exponent for all interfaces.', 'Wavelength', [1 50]);
                if ~isempty(answer)
                    if ~isnan(str2double(answer))
                        
                        if str2double(answer) < 0 || str2double(answer) > 1
                            warndlg('The Hurst exponent value must be between 0 and 1.', 'Error!', 'modal');
                            folder('uicontrol_update');
                            return;
                        end
                        
                        for iface = 1:length(fold.face)
                            fold.face(iface).width   = str2double(answer);
                        end
                        
                    else
                        warndlg('Wrongly assinged value.', 'Error!', 'modal');
                        folder('uicontrol_callback');
                        return;
                    end
                end
                
            case 'set_nx'
                
                % Create input dialog box
                answer = inputdlg('Set shift for all interfaces.', 'Wavelength', [1 50]);
                if ~isempty(answer)
                    if ~isnan(str2double(answer))
                        
                        % Check if number of points on the interface is > 2
                        if str2double(answer) < 3
                            warndlg('Number of points on the interface should be larger than 2.', 'Error!', 'modal');
                            folder('uicontrol_update');
                            return;
                        end
                        if mod(str2double(answer),1)~=0
                            warndlg('Value must be an integer.', 'Error!', 'modal');
                            folder('uicontrol_update');
                            return;
                        end
                        
                        for iface = 1:length(fold.face)
                            fold.face(iface).nx   = str2double(answer);
                        end
                        
                    else
                        warndlg('Wrongly assinged value.', 'Error!', 'modal');
                        folder('uicontrol_callback');
                        return;
                    end
                end
                
                
                %% -- Regions
            case 'folder_material'
                
                fold.region(region).material 	= get(wcbo,  'value');
                
                fold.region(region).vis         = str2double(fold.material_data{fold.region(region).material,3});
                fold.region(region).vis_0       = str2double(fold.material_data{fold.region(region).material,4});
                fold.region(region).vis_INF     = str2double(fold.material_data{fold.region(region).material,5});
                fold.region(region).n           = str2double(fold.material_data{fold.region(region).material,6});
                fold.region(region).Q           = str2double(fold.material_data{fold.region(region).material,7});
                fold.region(region).A           = str2double(fold.material_data{fold.region(region).material,8});
                
            case 'folder_area'
                
                % Check if the value is positive
                if str2double(get(wcbo,  'string')) < 0
                    warndlg('Triangle area must be a positive value.', 'Error!', 'modal');
                    folder('uicontrol_update');
                    return;
                end
                
                % Check if the value is not too small
                if str2double(get(wcbo,  'string')) < 1e-6
                    warndlg('Traingle area is too small.', 'Error!', 'modal');
                    folder('uicontrol_update');
                    return;
                end
                
                % Prevent from traingle crash
                % Rough estimation of number of triangles
                area            = vertcat(fold.region.area);
                area(region)    = str2double(get(wcbo,  'string'));
                nel_est         = fold.box.width*sum(diff([-fold.box.height/2; vertcat(fold.face.y); fold.box.height/2])./area);
                if nel_est > fold.max_tri_elem
                    warndlg('The resolution with respect to the domain size is too high and can cause the program to crash.', 'Error!', 'modal');
                    folder('uicontrol_update');
                    return;
                end
                
                fold.region(region).area        = str2double(get(wcbo,  'string'));
                
                %% -- Markers and Finite Strain
            case 'folder_markers_set'
                fold.markers.set = get(wcbo,  'value');
                
            case 'folder_markers_type'
                fold.markers.type = get(wcbo,  'value');
                
            case 'folder_fstrain_set'
                fold.fstrain.set = get(wcbo,  'value');
                
                %% -- Deformation
            case 'folder_strain_shortening'
                if get(wcbo,  'value') == 1
                    fold.num.strain_mode  	= +1;
                    fold.num.strain         = 50;
                else
                    fold.num.strain_mode  	= -1;
                    fold.num.strain         = 100;
                end
                
            case 'folder_strain_extension'
                if get(wcbo,  'value') == 1
                    fold.num.strain_mode  	= -1;
                else
                    fold.num.strain_mode  	= +1;
                end
                
            case 'folder_shortening'
                if str2double(get(wcbo,  'string')) >= 0;
                    if fold.num.strain_mode == 1 % in case of shortening
                        if str2double(get(wcbo,  'string')) <= 90;
                            fold.num.strain = str2double(get(wcbo,  'string'));
                        else
                            warndlg('Amount of shortening should not exceed 90%.', 'Error!', 'modal');
                            folder('uicontrol_update');
                            return;
                        end
                    else
                        fold.num.strain     = str2double(get(wcbo,  'string'));
                    end
                else
                    warndlg('Amount of deformation should be a positive value.', 'Error!', 'modal');
                    folder('uicontrol_update');
                    return;
                end
                
                %% -- Time step
            case 'folder_slider'
                fold.num.it             = round(get(wcbo,  'value'));
                
                %% -- Scalar Field
            case 'folder_plotting'
                
                fold.popts.plot_selection 	      = get(wcbo,  'value');
                % Modify plotting_selection_component options
                fold.popts.plot_selection_component = 1;
                % Reset c-lim scale
                fold.popts.clim   	= 0;
                fold.popts.cmin    	= [];
                fold.popts.cmax    	= [];
                
            case 'folder_plotting_component'
                
                fold.popts.plot_selection_component = get(wcbo,  'value');
                
            case 'folder_colormap_type'
                fold.popts.colormap_type = get(wcbo,  'value');
                
                % Modify colormap
                fold.popts.colormap  = 1;
                
            case 'folder_colormap'
                fold.popts.colormap  = get(wcbo,  'value');
                
            case 'folder_ncolors'
                if str2double(get(wcbo,  'string'))>1 && str2double(get(wcbo,  'string'))<=256
                    if mod(str2double(get(wcbo,  'string')),1)==0
                        fold.popts.ncolors   = str2double(get(wcbo,  'string'));
                    else
                        errordlg('The value must be an integer.');
                    end
                elseif str2double(get(wcbo,  'string'))<2
                    errordlg('The value must be larger than 1.');
                elseif str2double(get(wcbo,  'string'))>256
                    errordlg('The value cannot be larger than 256.');
                else
                    errordlg('Wrongly assinged value.');
                end
                
            case 'folder_clim'
                fold.popts.clim   	= get(wcbo,  'value');
                
                if get(obj.folder_clim, 'value') == 1
                    % Get current value
                    folder_fold_panel	= findobj(folder_gui_handle, 'tag', 'folder_fold_panel');
                    h_axes              = getappdata(folder_fold_panel, 'h_axes');
                    temp                = get(h_axes,'CLim');
                    fold.popts.cmin    	= temp(1);
                    fold.popts.cmax    	= temp(2);
                else
                    fold.popts.cmin    	= [];
                    fold.popts.cmax    	= [];
                end
                
            case 'folder_cmin'
                if isempty( str2double(get(wcbo,'string')) ) || isnan( str2double(get(wcbo,'string')) )
                    errordlg('Assign c-min value.');
                    return;
                end
                if str2double(get(wcbo,'string')) >= fold.popts.cmax
                    errordlg('Wrongly assinged c-min and c-max values.');
                    return;
                end
                
                fold.popts.cmin      = str2double(get(wcbo,  'string'));
                
            case 'folder_cmax'
                if isempty( str2double(get(wcbo,'string')) ) || isnan( str2double(get(wcbo,'string')) )
                    errordlg('Assign c-max value.');
                    return;
                end
                if fold.popts.cmin >= str2double(get(wcbo,'string'))
                    errordlg('Wrongly assinged c-min and c-max values.');
                    return;
                end
                
                fold.popts.cmax      = str2double(get(wcbo,  'string'));
                
            case 'folder_flip'
                fold.popts.flip     = get(wcbo,  'value');
                
            case 'folder_logscale'
                fold.popts.logscale     = get(wcbo,  'value');
                
                %% -- Vector Field
            case 'folder_vector'
                set(obj.folder_vector,'value',get(wcbo,  'value'));
                
            case 'folder_vector_opts'
                fold.vector.opts        = get(wcbo,  'value');
                
            case 'folder_vector_relative'
                fold.vector.relative 	= get(wcbo,  'value');
                
            case 'folder_vector_scaling'
                if str2double(get(wcbo,  'string')) < 0
                    errordlg('The value must be positive.');
                    return;
                end
                fold.vector.scaling 	= str2double(get(wcbo,  'string'));
                
                %% -- Tensor Field
            case 'folder_tensor'
                set(obj.folder_tensor,'value',get(wcbo,  'value'));
                
            case 'folder_tensor_opts'
                fold.tensor.opts        = get(wcbo,  'value');
                
            case 'folder_tensor_style'
                fold.tensor.style       = get(wcbo,  'value');
                
            case 'folder_tensor_relative'
                fold.tensor.relative    = get(wcbo,  'value');
                
            case 'folder_tensor_scaling'
                if str2double(get(wcbo,  'string')) < 0
                    errordlg('The value must be positive.');
                    return;
                end
                fold.tensor.scaling 	= str2double(get(wcbo,  'string'));
                
                %% -- Plotting
            case 'folder_colorbar_position'
                fold.popts.colorbar_position  = get(wcbo,  'value');
                
            case 'plot_xlim'
                
                if get(obj.plot_xlim, 'value') == 1
                    
                    % Get current value
                    folder_fold_panel	= findobj(folder_gui_handle,'tag', 'folder_fold_panel');
                    h_axes              = getappdata(folder_fold_panel, 'h_axes');
                    temp                = get(h_axes,'XLim');
                    fold.popts.xmin     = temp(1);
                    fold.popts.xmax     = temp(2);
                    
                else
                    % Set to empty when is off
                    fold.popts.xmin     = [];
                    fold.popts.xmax     = [];
                end
                
            case 'plot_xmin'
                
                % Check if the value is correct
                if isempty(fold.popts.xmin) || isnan(fold.popts.xmin)
                    errordlg('Assign x-min value.');
                    return;
                end
                % Check if xmin<xmax
                if fold.popts.xmin >= fold.popts.xmax
                    errordlg('Wrongly assinged x-min and x-max values.');
                    return;
                end
                
                fold.popts.xmin     = str2double(get(wcbo,  'string'));
                
            case 'plot_xmax'
                
                % Check if the value is correct
                if isempty(fold.popts.xmax) || isnan(fold.popts.xmin)
                    errordlg('Assign x-max value.');
                    return;
                end
                % Check if xmin<xmax
                if fold.popts.xmin >= fold.popts.xmax
                    errordlg('Wrongly assinged x-min and x-max values.');
                    return;
                end
                fold.popts.xmax     = str2double(get(wcbo,  'string'));
                
            case 'plot_ylim'
                
                if get(obj.plot_ylim, 'value') == 1
                    
                    % Get current value if was empty
                    folder_fold_panel	= findobj(folder_gui_handle,'tag', 'folder_fold_panel');
                    h_axes              = getappdata(folder_fold_panel, 'h_axes');
                    temp                = get(h_axes,'YLim');
                    fold.popts.ymin     = temp(1);
                    fold.popts.ymax     = temp(2);
                    
                else
                    % Set to empty when is off
                    fold.popts.ymin     = [];
                    fold.popts.ymax     = [];
                end
                
            case 'plot_ymin'
                
                % Check if the value is correct
                if isempty(fold.popts.ymin) || isnan(fold.popts.ymin)
                    errordlg('Assign y-min value.');
                    return;
                end
                % Check if ymin<ymax
                if fold.popts.ymin >= fold.popts.ymax
                    errordlg('Wrongly assinged y-min and y-max values.');
                    return;
                end
                fold.popts.ymin     = str2double(get(wcbo,  'string'));
                
            case 'plot_ymax'
                
                % Check if the value is correct
                if isempty(fold.popts.ymax) || isnan(fold.popts.ymin)
                    errordlg('Assign y-max value.');
                    return;
                end
                % Check if ymin<ymax
                if fold.popts.ymin >= fold.popts.ymax
                    errordlg('Wrongly assinged y-min and y-max values.');
                    return;
                end
                fold.popts.ymax     = str2double(get(wcbo,  'string'));
                
                
                %% -- External callbacks
            case {'tip_done','tip_apply'}
                % Note: Callback from hint figure
                
                wavelength_gui_handle = findobj(0, 'tag', 'wavelength_gui_handle', 'type', 'figure');
                tip  = getappdata(wavelength_gui_handle, 'tip');
                
                fold.box.width = tip.boxw;
                for ii = 1:length(fold.face)
                    fold.face(ii).wave = tip.wave;
                end
                
            case {'materials_apply','materials_done'}
                % Note: Callback from materials figure
                
                % Find material gui
                materials_gui_handle = findobj(0, 'tag', 'materials_gui_handle','type', 'figure');
                
                % Get data
                rheology = getappdata(materials_gui_handle, 'rheology');
                data     = rheology.data;
                
                % Check if modifications can be applied
                if max(vertcat(fold.region.material))>size(data,1)
                    errordlg('Modifications in the material table cannot be applied in the current model.');
                    return;
                end
                
                fold.material_data = data;
                
            case {'ropts_done','ropts_apply'}
                % Note: Callback from run option figure
                
                % Find run options gui
                ropts_gui_handle = findobj(0, 'tag', 'ropts_gui_handle','type', 'figure');
                ropts = getappdata(ropts_gui_handle, 'ropts');
                
                fold.num.solver         = ropts.solver ;
                fold.num.nt             = ropts.nt;
                fold.num.temperature    = ropts.temperature;
                fold.num.strain_rate    = ropts.strain_rate;
                fold.num.picards        = ropts.picards;
                fold.num.newtons        = ropts.newtons;
                fold.num.relres         = ropts.relres;
                
        end
        
        %% - Generate markers
        if strcmpi(Whoiscalling,'folder_domain_width') || strcmpi(Whoiscalling,'folder_domain_height') || ...
                strcmpi(Whoiscalling,'folder_markers_set') || strcmpi(Whoiscalling,'folder_markers_type') || ...
                strcmpi(Whoiscalling,'markers_done')
            
            if get(obj.folder_markers_set,'value') > 0
                
                % Prepare markers input
                if isempty(fold.markers.xmin)
                    Xbot = [-fold.box.width/2   fold.box.width/2];
                else
                    Xbot = [fold.markers.xmin fold.markers.xmax];
                end
                if isempty(fold.markers.ymin)
                    Ybot = [-fold.box.height/2 -fold.box.height/2];
                else
                    Ybot = [fold.markers.ymin fold.markers.ymin];
                end
                if isempty(fold.markers.xmax)
                    Xtop = [-fold.box.width/2   fold.box.width/2];
                else
                    Xtop = [fold.markers.xmin fold.markers.xmax];
                end
                if isempty(fold.markers.ymax)
                    Ytop = [ fold.box.height/2  fold.box.height/2];
                else
                    Ytop = [fold.markers.ymax fold.markers.ymax];
                end
                
                % Create passive markers patterns
                fold.markers.MARKERS = create_marker_grid(Xbot, Ybot, Xtop, Ytop, ...
                    fold.markers.type, fold.markers.cell_num, fold.markers.resolution);
            else
                fold.markers.MARKERS = [];
            end
        end
        
        %% - Generate Finite Strain Ellispes
        if strcmpi(Whoiscalling,'folder_domain_width') || strcmpi(Whoiscalling,'folder_domain_height') || ...
                strcmpi(Whoiscalling,'folder_fstrain_set') || strcmpi(Whoiscalling,'fstrain_apply') || strcmpi(Whoiscalling,'fstrain_done')
            
            if fold.fstrain.set > 0
                
                if fold.fstrain.x_span == 1
                    xmin = max([fold.fstrain.xmin, fold.NODES(1,1)]);
                    xmax = min([fold.fstrain.xmax, fold.NODES(1,2)]);
                else
                    xmin = -fold.box.width/2;
                    xmax =  fold.box.width/2;
                end
                
                if fold.fstrain.y_span == 1
                    ymin = max([fold.fstrain.ymin, fold.NODES(2,1)]);
                    ymax = min([fold.fstrain.ymax, fold.NODES(2,end)]);
                else
                    ymin = -fold.box.height/2;
                    ymax =  fold.box.height/2;
                end
                
                % Establish Grid
                ncell  = fold.fstrain.cell_num;
                x      = linspace(xmin,xmax,ncell+1);
                grid_size = x(2)-x(1);
                x      = x(1:end-1)+grid_size/2;
                y      = (ymin+grid_size/2):grid_size:(ymax-grid_size/2);
                sy     = ((ymax-ymin-grid_size)-(length(y)-1)*grid_size)/2;
                y      = y + sy; % shift points to the center
                
                [X, Y] = ndgrid(x,y);
                X = X(:)';
                Y = Y(:)';
                
                fold.nfstrain               = length(X(:));
                fold.fstrain.grid_size      = grid_size;
                fold.fstrain.FSTRAIN_grid   = [X(:)'; Y(:)'];
                fold.fstrain.FSTRAIN        = [ones(1,fold.nfstrain); zeros(1,fold.nfstrain); zeros(1,fold.nfstrain); ones(1,fold.nfstrain)];
            else
                fold.nfstrain               = 0;
                fold.fstrain.FSTRAIN_grid   = [];
                fold.fstrain.FSTRAIN        = [];
            end
        end
        
        % Update Data
        setappdata(folder_gui_handle, 'fold', fold);
        setappdata(folder_gui_handle, 'face', face);
        setappdata(folder_gui_handle, 'region', region);
        
        
        % - Modify Interface & remesh if necessary
        if (~strcmpi(Whoiscalling, 'tab_panel_child1') && ~strcmpi(Whoiscalling, 'tab_panel_child2') &&  ~strcmpi(Whoiscalling, 'folder_material') && ...
                ~strcmpi(Whoiscalling,'folder_markers_set') && ~strcmpi(Whoiscalling,'markers_apply') && ~strcmpi(Whoiscalling,'markers_done') && ~strcmpi(Whoiscalling,'folder_markers_type') && ...
                ~strcmpi(Whoiscalling,'folder_fstrain_set') && ~strcmpi(Whoiscalling,'fstrain_apply') && ~strcmpi(Whoiscalling,'fstrain_done') && ...
                ~strcmpi(Whoiscalling,'folder_strain_shortening') && ~strcmpi(Whoiscalling,'folder_strain_extension') && ~strcmpi(Whoiscalling,'folder_shortening') &&...
                ~strcmpi(Whoiscalling,'ropts_done') && ~strcmpi(Whoiscalling,'ropts_apply') &&...
                ~strcmpi(Whoiscalling,'materials_done') && ~strcmpi(Whoiscalling,'materials_apply') &&...
                ~strcmpi(Whoiscalling,'folder_plotting') && ~strcmpi(Whoiscalling,'folder_plotting_component') && ...
                ~strcmpi(Whoiscalling,'folder_colormap_type') && ~strcmpi(Whoiscalling,'folder_colormap') && ~strcmpi(Whoiscalling,'folder_ncolors') && ~strcmpi(Whoiscalling,'folder_flip') && ~strcmpi(Whoiscalling,'folder_logscale') && ...
                ~strcmpi(Whoiscalling,'folder_clim') && ~strcmpi(Whoiscalling,'folder_cmin') && ~strcmpi(Whoiscalling,'folder_cmax') && ...
                ~strcmpi(Whoiscalling,'folder_vector') && ~strcmpi(Whoiscalling,'folder_vector_opts') && ~strcmpi(Whoiscalling,'folder_vector_relative') && ~strcmpi(Whoiscalling,'folder_vector_scaling') && ...
                ~strcmpi(Whoiscalling,'folder_tensor') && ~strcmpi(Whoiscalling,'folder_tensor_opts') && ~strcmpi(Whoiscalling,'folder_tensor_style') && ~strcmpi(Whoiscalling,'folder_tensor_relative') && ~strcmpi(Whoiscalling,'folder_tensor_scaling') && ...
                ~strcmpi(Whoiscalling,'folder_colorbar_position') && ~strcmpi(Whoiscalling,'plot_axis_tight') && ...
                ~strcmpi(Whoiscalling,'plot_xlim') && ~strcmpi(Whoiscalling,'plot_xmin') && ~strcmpi(Whoiscalling,'plot_xmax') && ...
                ~strcmpi(Whoiscalling,'plot_ylim') && ~strcmpi(Whoiscalling,'plot_ymin') && ~strcmpi(Whoiscalling,'plot_ymax') ) || ...
                ( ( strcmpi(Whoiscalling, 'tab_panel_child1') || strcmpi(Whoiscalling, 'tab_panel_child2')) && isfield(fold, 'NODES_run'))
            folder('interface_update')
        end
        
        %  Update status bar
        set(obj.folder_status_bar_text,'string','')
        
        % - Update Uicontrols
        folder('uicontrol_update');
        
        % - Buttons Enable
        folder('buttons_enable')
        
        % - Update Plot
        folder('plot_update');
        
    case 'plot_update'
        %% PLOT UPDATE
        
        %  Get data
        fold      	= getappdata(folder_gui_handle, 'fold');
        face        = getappdata(folder_gui_handle, 'face');
        region      = getappdata(folder_gui_handle, 'region');
        obj         = getappdata(folder_gui_handle, 'obj');
        
        %  Update status bar
        set(obj.folder_status_bar_text,'string','FOLDER is busy. Plotting.')
        
        %  Find plotting axes
        folder_fold_panel	= findobj(folder_gui_handle,'tag', 'folder_fold_panel');
        h_axes              = getappdata(folder_fold_panel, 'h_axes');
        
        % Clear
        cla(h_axes,'reset');
        get(h_axes,'Position');
        
        % Plot
        hold(h_axes, 'on');
        
        % Loop over regions
        for ireg = 1:length(fold.region)
            
            % Check
            plot_title               = get(obj.folder_plotting,'string');
            plot_title2              = get(obj.folder_plotting_component,'string');
            
            %% - c-values
            switch fold.popts.plot_selection
                
                case 1
                    %% -- Materials
                    
                    Hn = fold.material_data{fold.region(ireg).material,9};
                    
                case 2
                    %% -- Velocity (Total)
                    if isempty(fold.Vel)
                        
                        % Load data
                        temp = [];
                        temp = load([fold.run_output,'run_output',filesep,'run_',  num2str(fold.num.it,'%.4d')],'Vel');
                        fold.Vel = temp.Vel;
                        
                        clear temp
                    end
                    
                    switch fold.popts.plot_selection_component
                        
                        case 1
                            % magnitude
                            vx  = fold.Vel(1:2:end);
                            vy  = fold.Vel(2:2:end);
                            Hn  = sqrt(vx.^2 +vy.^2);
                            
                        case 2
                            % vx
                            Hn  = fold.Vel(1:2:end);
                            
                        case 3
                            % vy
                            Hn  = fold.Vel(2:2:end);
                            
                    end
                    
                    %c   = reshape(Hn(fold.MESH.ELEMS(1:3,fold.MESH.elem_markers==ireg)), 3, sum(fold.MESH.elem_markers==ireg));
                    
                case 3
                    %% -- Velocity (Perturbing)
                    if isempty(fold.Vel)
                        
                        % Load data
                        temp = [];
                        temp = load([fold.run_output,'run_output',filesep,'run_',  num2str(fold.num.it,'%.4d')],'Vel');
                        fold.Vel = temp.Vel;
                        
                        clear temp
                    end
                    
                    if fold.num.strain_mode == 1
                        % Shortening
                        Dxx = -1;
                    else
                        % Extension
                        Dxx = 1;
                    end
                    
                    switch fold.popts.plot_selection_component
                        
                        case 1
                            % magnitude
                            vx      = fold.Vel(1:2:end);
                            vy      = fold.Vel(2:2:end);
                            % Background deformation
                            vx_back = Dxx*fold.MESH.NODES(1,:)';
                            vy_back = -Dxx*fold.MESH.NODES(2,:)';
                            
                            Hn      = sqrt((vx-vx_back).^2 +(vy-vy_back).^2);
                            
                        case 2
                            % vx
                            vx      = fold.Vel(1:2:end);
                            % Background deformation
                            vx_back = Dxx*fold.MESH.NODES(1,:)';
                            
                            Hn      = vx-vx_back;
                            
                        case 3
                            % vy
                            vy      = fold.Vel(2:2:end);
                            % Background deformation
                            vy_back = -Dxx*fold.MESH.NODES(2,:)';
                            
                            Hn      = vy-vy_back;
                            
                    end
                    
                    
                case 4
                    %% -- Apparent viscosity
                    if isempty(fold.Mu_app)
                        
                        % Load data
                        temp = [];
                        temp = load([fold.run_output,'run_output',filesep,'run_',  num2str(fold.num.it,'%.4d')],'Mu_app');
                        fold.Mu_app = temp.Mu_app;
                        
                        clear temp
                    end
                    
                    Hn = fold.Mu_app;
                    
                    
                case 5
                    %% -- Rate of deformation
                    if isempty(fold.Vel)
                        
                        % Load data
                        temp = [];
                        temp = load([fold.run_output,'run_output',filesep,'run_',  num2str(fold.num.it,'%.4d')],'Vel');
                        
                        fold.Vel = temp.Vel;
                        clear temp
                    end
                    
                    % Calculate strain rate
                    nelblo           = 1e3;
                    [Exx, Eyy, Exy]  = strain_rate(fold.Vel, fold.MESH, nelblo);
                    
                    switch fold.popts.plot_selection_component
                        
                        case 1
                            % II invariant
                            Hn = sqrt((Exx-Eyy).^2./4+Exy.^2);
                            
                        case 2
                            % xx
                            Hn = Exx;
                            
                        case 3
                            % yy
                            Hn = Eyy;
                            
                        case 4
                            % xy
                            Hn = Exy;
                            
                    end
                    
                case 6
                    %% -- Stress
                    if isempty(fold.Vel) || isempty(fold.Mu_app) || isempty(fold.Pressure)
                        
                        % Load data
                        temp = [];
                        temp = load([fold.run_output,'run_output',filesep,'run_',  num2str(fold.num.it,'%.4d')],'Vel','Mu_app','Pressure');
                        fold.Vel        = temp.Vel;
                        fold.Mu_app     = temp.Mu_app;
                        fold.Pressure	= temp.Pressure;
                        
                        clear temp
                    end
                    
                    % Calculate stress
                    nelblo           = 1e3;
                    [Exx, Eyy, Exy]  = strain_rate(fold.Vel, fold.MESH, nelblo);
                    Sxx              = 2*fold.Mu_app.*Exx;
                    Syy              = 2*fold.Mu_app.*Eyy;
                    Sxy              = 2*fold.Mu_app.*Exy;
                    
                    Pressure = [fold.Pressure;...
                        (fold.Pressure(2,:)+fold.Pressure(3,:))/2;...
                        (fold.Pressure(1,:)+fold.Pressure(3,:))/2;...
                        (fold.Pressure(1,:)+fold.Pressure(2,:))/2;...
                        (fold.Pressure(1,:)+fold.Pressure(2,:)+fold.Pressure(2,:))/3;];
                    
                    switch fold.popts.plot_selection_component
                        
                        case 1
                            % II invariant
                            Hn   = sqrt((Sxx-Syy).^2./4+Sxy.^2);
                            
                        case 2
                            % xx
                            Hn   = Sxx - Pressure;
                            
                        case 3
                            % yy
                            Hn   = Syy - Pressure;
                            
                        case 4
                            % xy
                            Hn   = Sxy;
                            
                    end
                    
                case 7
                    %% -- Deviatoric Stress
                    if isempty(fold.Vel) || isempty(fold.Mu_app)
                        
                        % Load data
                        temp = [];
                        temp = load([fold.run_output,'run_output',filesep,'run_',  num2str(fold.num.it,'%.4d')],'Vel','Mu_app');
                        fold.Vel        = temp.Vel;
                        fold.Mu_app     = temp.Mu_app;
                        
                        clear temp
                    end
                    
                    % Calculate stress
                    nelblo           = 1e3;
                    [Exx, Eyy, Exy]  = strain_rate(fold.Vel, fold.MESH, nelblo);
                    Sxx              = 2*fold.Mu_app.*Exx;
                    Syy              = 2*fold.Mu_app.*Eyy;
                    Sxy              = 2*fold.Mu_app.*Exy;
                    
                    switch fold.popts.plot_selection_component
                        
                        case 1
                            % II invariant
                            Hn   = sqrt((Sxx-Syy).^2./4+Sxy.^2);
                            
                        case 2
                            % xx
                            Hn   = Sxx;
                            
                        case 3
                            % yy
                            Hn   = Syy;
                            
                        case 4
                            % xy
                            Hn   = Sxy;
                            
                    end
                    
                case 8
                    %% -- Pressure
                    if isempty(fold.Pressure)
                        
                        % Load data
                        temp = [];
                        temp = load([fold.run_output,'run_output',filesep,'run_',  num2str(fold.num.it,'%.4d')],'Pressure');
                        fold.Pressure	= temp.Pressure;
                        
                        clear temp
                        
                    end
                    
                    Hn = [fold.Pressure;...
                        (fold.Pressure(2,:)+fold.Pressure(3,:))/2;...
                        (fold.Pressure(1,:)+fold.Pressure(3,:))/2;...
                        (fold.Pressure(1,:)+fold.Pressure(2,:))/2;...
                        (fold.Pressure(1,:)+fold.Pressure(2,:)+fold.Pressure(2,:))/3;];
                    
            end
            
            %% - Plot
            % Triangle coordinates
            if fold.popts.plot_selection == 1
                
                X   = reshape(fold.MESH.NODES(1,fold.MESH.ELEMS(1:3,fold.MESH.elem_markers==ireg)), 3, sum(fold.MESH.elem_markers==ireg));
                Y   = reshape(fold.MESH.NODES(2,fold.MESH.ELEMS(1:3,fold.MESH.elem_markers==ireg)), 3, sum(fold.MESH.elem_markers==ireg));
                
            else
                
                idx = [fold.MESH.ELEMS([1 6 5],fold.MESH.elem_markers==ireg), ...
                    fold.MESH.ELEMS([6 2 4],fold.MESH.elem_markers==ireg), ...
                    fold.MESH.ELEMS([6 4 5],fold.MESH.elem_markers==ireg), ...
                    fold.MESH.ELEMS([5 4 3],fold.MESH.elem_markers==ireg)];
                
                % For velocity plot divide the mesh into smaller triangle
                X   = reshape(fold.MESH.NODES(1,idx), 3, size(idx,2));
                Y   = reshape(fold.MESH.NODES(2,idx), 3, size(idx,2));
                
            end
            
            if fold.popts.plot_selection == 1
                
                c   = Hn;
                
            elseif fold.popts.plot_selection == 2 || fold.popts.plot_selection==3
                
                c   = Hn(idx);
                
            else
                
                c    = [Hn([1 6 5],fold.MESH.elem_markers==ireg),...
                    Hn([6 2 4],fold.MESH.elem_markers==ireg),...
                    Hn([6 4 5],fold.MESH.elem_markers==ireg),...
                    Hn([5 4 3],fold.MESH.elem_markers==ireg)];
                
            end
            
            
            if fold.popts.logscale==0
                fh(ireg) = patch(X, Y, c, 'Parent', h_axes);
            else
                fh(ireg) = patch(X, Y, log10(abs(c)), 'Parent', h_axes);
            end
            
            % Mark triangle edges if necessary
            if get(obj.folder_mesh,'value')==1
                set(fh(ireg),'EdgeColor',fold.popts.mesh_color,'LineWidth',fold.popts.mesh_thick);
            else
                set(fh(ireg),'EdgeColor','none');
            end
            
            % Modify controls according to the selected field
            set(fh(ireg),'ButtonDownFcn',@color_region,'Tag',num2str(ireg));
            
            % Attach uicontext menu to the field
            hcmenu = uicontextmenu('Parent',folder_gui_handle);
            if isnan(str2double(fold.material_data{fold.region(ireg).material,7}))
                item1 = uimenu(hcmenu, 'Label', ['No: ',num2str( fold.material_data{fold.region(ireg).material,1} )],...
                    'tag',num2str(fold.region(ireg).material),'callback',@(a,b)  materials);
                item2 = uimenu(hcmenu, 'Label', ['Name: ',num2str( fold.material_data{fold.region(ireg).material,2} )],...
                    'tag',num2str(fold.region(ireg).material),'callback',@(a,b)  materials);
                item3 = uimenu(hcmenu, 'Label', ['m: ',num2str( fold.material_data{fold.region(ireg).material,3} )],...
                    'tag',num2str(fold.region(ireg).material),'callback',@(a,b)  materials);
                item4 = uimenu(hcmenu, 'Label', ['m_0/m: ',num2str( fold.material_data{fold.region(ireg).material,4} )],...
                    'tag',num2str(fold.region(ireg).material),'callback',@(a,b)  materials);
                item5 = uimenu(hcmenu, 'Label', ['m_inf/m: ',num2str( fold.material_data{fold.region(ireg).material,5} )],...
                    'tag',num2str(fold.region(ireg).material),'callback',@(a,b)  materials);
                item6 = uimenu(hcmenu, 'Label', ['n: ',num2str( fold.material_data{fold.region(ireg).material,6} )],...
                    'tag',num2str(fold.region(ireg).material),'callback',@(a,b)  materials);
            else
                item1 = uimenu(hcmenu, 'Label', ['No.: ',num2str( fold.material_data{fold.region(ireg).material,1} )],...
                    'tag',num2str(fold.region(ireg).material),'callback',@(a,b)  materials);
                item2 = uimenu(hcmenu, 'Label', ['Name: ',num2str( fold.material_data{fold.region(ireg).material,2} )],...
                    'tag',num2str(fold.region(ireg).material),'callback',@(a,b)  materials);
                item3 = uimenu(hcmenu, 'Label', ['m_0/m: ',num2str( fold.material_data{fold.region(ireg).material,4} )],...
                    'tag',num2str(fold.region(ireg).material),'callback',@(a,b)  materials);
                item4 = uimenu(hcmenu, 'Label', ['m_inf/m: ',num2str( fold.material_data{fold.region(ireg).material,5} )],...
                    'tag',num2str(fold.region(ireg).material),'callback',@(a,b)  materials);
                item5 = uimenu(hcmenu, 'Label', ['n: ',num2str( fold.material_data{fold.region(ireg).material,6} )],...
                    'tag',num2str(fold.region(ireg).material),'callback',@(a,b)  materials);
                item6 = uimenu(hcmenu, 'Label', ['Q: ',num2str( fold.material_data{fold.region(ireg).material,7} )],...
                    'tag',num2str(fold.region(ireg).material),'callback',@(a,b)  materials);
                item7 = uimenu(hcmenu, 'Label', ['A: ',num2str( fold.material_data{fold.region(ireg).material,8} )],...
                    'tag',num2str(fold.region(ireg).material),'callback',@(a,b)  materials);
            end
            set(fh(ireg),'uicontextmenu',hcmenu);
            
        end
        
        %% - Mark selected region & interface
        % Regions
        if region>0
            fh2 = fill(fold.NODES(1,[fold.REGIONS{region} fold.REGIONS{region}(1)]),fold.NODES(2,[fold.REGIONS{region} fold.REGIONS{region}(1)]), fold.selection.region_color, 'Parent', h_axes);
            
            % Attach uicontext menu to the selected field
            hcmenu = uicontextmenu('Parent',folder_gui_handle);
            if isnan(str2double(fold.material_data{fold.region(ireg).material,7}))
                item1 = uimenu(hcmenu, 'Label', ['No: ',num2str( fold.material_data{fold.region(ireg).material,1} )],...
                    'tag',num2str(fold.region(ireg).material),'callback',@(a,b)  materials);
                item2 = uimenu(hcmenu, 'Label', ['Name: ',num2str( fold.material_data{fold.region(ireg).material,2} )],...
                    'tag',num2str(fold.region(ireg).material),'callback',@(a,b)  materials);
                item3 = uimenu(hcmenu, 'Label', ['m: ',num2str( fold.material_data{fold.region(ireg).material,3} )],...
                    'tag',num2str(fold.region(ireg).material),'callback',@(a,b)  materials);
                item4 = uimenu(hcmenu, 'Label', ['m_0/m: ',num2str( fold.material_data{fold.region(ireg).material,4} )],...
                    'tag',num2str(fold.region(ireg).material),'callback',@(a,b)  materials);
                item5 = uimenu(hcmenu, 'Label', ['m_inf/m: ',num2str( fold.material_data{fold.region(ireg).material,5} )],...
                    'tag',num2str(fold.region(ireg).material),'callback',@(a,b)  materials);
                item6 = uimenu(hcmenu, 'Label', ['n: ',num2str( fold.material_data{fold.region(ireg).material,6} )],...
                    'tag',num2str(fold.region(ireg).material),'callback',@(a,b)  materials);
            else
                item1 = uimenu(hcmenu, 'Label', ['No.: ',num2str( fold.material_data{fold.region(ireg).material,1} )],...
                    'tag',num2str(fold.region(ireg).material),'callback',@(a,b)  materials);
                item2 = uimenu(hcmenu, 'Label', ['Name: ',num2str( fold.material_data{fold.region(ireg).material,2} )],...
                    'tag',num2str(fold.region(ireg).material),'callback',@(a,b)  materials);
                item3 = uimenu(hcmenu, 'Label', ['m_0/m: ',num2str( fold.material_data{fold.region(ireg).material,4} )],...
                    'tag',num2str(fold.region(ireg).material),'callback',@(a,b)  materials);
                item4 = uimenu(hcmenu, 'Label', ['m_inf/m: ',num2str( fold.material_data{fold.region(ireg).material,5} )],...
                    'tag',num2str(fold.region(ireg).material),'callback',@(a,b)  materials);
                item5 = uimenu(hcmenu, 'Label', ['n: ',num2str( fold.material_data{fold.region(ireg).material,6} )],...
                    'tag',num2str(fold.region(ireg).material),'callback',@(a,b)  materials);
                item6 = uimenu(hcmenu, 'Label', ['Q: ',num2str( fold.material_data{fold.region(ireg).material,7} )],...
                    'tag',num2str(fold.region(ireg).material),'callback',@(a,b)  materials);
                item7 = uimenu(hcmenu, 'Label', ['A: ',num2str( fold.material_data{fold.region(ireg).material,8} )],...
                    'tag',num2str(fold.region(ireg).material),'callback',@(a,b)  materials);
            end
            set(fh2,'uicontextmenu',hcmenu);
            
        else
            fh2 = fill(1,1,fold.selection.region_color, 'Parent', h_axes, 'XData',[],'YData',[],'Parent', h_axes);
        end
        
        % Mark box frame and interfaces
        plot(fold.NODES(1,[1 2 size(fold.NODES,2) size(fold.NODES,2)-1 1]),...
            fold.NODES(2,[1 2 size(fold.NODES,2) size(fold.NODES,2)-1 1]),...
            'Color',fold.popts.layer_color,'LineWidth',fold.popts.layer_thick,'Parent', h_axes);
        % Loop over interfaces
        for iint = 1:length(fold.face)
            lh = plot(h_axes, fold.face(iint).X,fold.face(iint).Y,'Color',fold.popts.layer_color,'LineWidth',fold.popts.layer_thick);
            set(lh,'ButtonDownFcn',@color_line,'Tag',num2str(iint));
        end
        
        % Interface
        if face>0
            lh2 = plot(h_axes, fold.face(face).X,fold.face(face).Y,'Color',fold.selection.line_color,...
                'LineWidth',fold.selection.line_width,'Marker',fold.selection.marker,...
                'MarkerFaceColor',fold.selection.marker_color,'MarkerSize',fold.selection.marker_size,'MarkerEdgeColor',fold.selection.marker_edge_color);
        else
            lh2 = plot(h_axes, 1,1,'Color',fold.selection.line_color,'XData',[],'YData',[],...
                'LineWidth',fold.selection.line_width,'Marker',fold.selection.marker,...
                'MarkerFaceColor',fold.selection.marker_color,'MarkerSize',fold.selection.marker_size,'MarkerEdgeColor',fold.selection.marker_edge_color);
        end
        setappdata(folder_fold_panel,'fh2',fh2)
        setappdata(folder_fold_panel,'lh2',lh2)
        
        %% - Markers
        if get(obj.folder_markers_set, 'value') && get(obj.folder_markers, 'value')
            
            try
                if fold.num.it ==1
                    MARKERS_run = fold.markers.MARKERS;
                else
                    MARKERS_run = [];
                    load([fold.run_output,'run_output',filesep,'markers_',num2str(fold.num.it,'%.4d')])
                end
            catch
                MARKERS_run = fold.markers.MARKERS;
            end
            
            ph = plot(MARKERS_run(1,:),MARKERS_run(2,:),...
                'Parent', h_axes, 'Color',fold.popts.marker_color,'LineWidth',fold.popts.marker_thick);
            
            if verLessThan('matlab', '8.4.0')
                set(ph,'Hittest','off');
            else
                set(ph,'Hittest','off', 'PickableParts', 'none');
            end
            
            clear MARKERS_run
        end
        
        %% - Finite strain
        % Generate ellipse glyphs
        if get(obj.folder_fstrain_set, 'value') && get(obj.folder_fstrain, 'value')
            
            try
                FSTRAIN_run         = [];
                FSTRAIN_GRID_run    = [];
                load([fold.run_output,'run_output',filesep,'fstrain_',     num2str(fold.num.it,'%.4d')])
                load([fold.run_output,'run_output',filesep,'fstrain_grid_',num2str(fold.num.it,'%.4d')])
            catch
                FSTRAIN_run      = fold.fstrain.FSTRAIN;
                FSTRAIN_GRID_run = fold.fstrain.FSTRAIN_grid;
            end
            
            [ab, phi, ~] = finite_strain_2d(FSTRAIN_run);
            
            % Scale
            scale       = 0.5*0.8*fold.fstrain.grid_size;
            D1          = scale*ab(2,:);
            D2          = scale*ab(1,:);
            x0          = FSTRAIN_GRID_run(1:2:end);
            y0          = FSTRAIN_GRID_run(2:2:end);
            
            % Ellipse grid
            nx          = fold.fstrain.resolution+1;
            theta       = linspace(0,2*pi,nx);
            Xb          = bsxfun(@times, cos(phi(:)), D1(:)*cos(theta))+...
                bsxfun(@times,-sin(phi(:)), D2(:)*sin(theta));
            Yb          = bsxfun(@times, sin(phi(:)), D1(:)*cos(theta))+...
                bsxfun(@times, cos(phi(:)), D2(:)*sin(theta));
            Xb          = [bsxfun(@minus, x0(:), Xb)'; NaN(1,size(Xb,1))];
            Yb          = [bsxfun(@minus, y0(:), Yb)'; NaN(1,size(Yb,1))];
            Xb          = Xb(:);
            Yb          = Yb(:);
            
            % Positive values
            hp = plot(Xb,Yb,'Color',fold.popts.fstrain_color,'LineWidth',fold.popts.fstrain_thick,'Parent', h_axes);
            set(hp,'Hittest','off')
            
            clear Xb Yb FSTRAIN_run FSTRAIN_GRID_run
        end
        
        %% - Vector
        if get(obj.folder_vector, 'value')
            
            nx      = fold.vector.x_density;
            
            % Define the x-grid values
            if isempty(fold.vector.xmin)
                x = linspace(min(fold.MESH.NODES(1,:)),max(fold.MESH.NODES(1,:)),nx);
            else
                x = linspace(fold.vector.xmin,fold.vector.xmax,nx);
                x = x(x>=min(fold.MESH.NODES(1,:)) & x<=max(fold.MESH.NODES(1,:)));
            end
            
            % Define the y-grid values
            if fold.vector.irregular==0
                % Regular
                dx = x(2)-x(1);
                
                if isempty(fold.vector.ymin)
                    ny = ceil(-2*min(fold.MESH.NODES(2,:))/dx);
                    y  = linspace(min(fold.MESH.NODES(2,:)),max(fold.MESH.NODES(2,:)),ny);
                else
                    ny = ceil((fold.vector.ymax-fold.vector.ymin)/dx);
                    y = linspace(fold.vector.ymin,fold.vector.ymax,ny);
                end
            else
                % Irregular
                ny = fold.vector.y_density;
                
                if isempty(fold.vector.ymin)
                    y = linspace(min(fold.MESH.NODES(2,:)),max(fold.MESH.NODES(2,:)),ny);
                else
                    y = linspace(fold.vector.ymin,fold.vector.ymax,ny);
                    y = y(y>=min(fold.MESH.NODES(2,:)) & y<=max(fold.MESH.NODES(2,:)));
                end
            end
            
            % Define grid
            [X,Y]         = meshgrid(x,y);
            fold.vector.X = X(:)';
            fold.vector.Y = Y(:)';
            
            if isempty(fold.Vel)
                % Load data
                temp = [];
                temp = load([fold.run_output,'run_output',filesep,'run_',  num2str(fold.num.it,'%.4d')],'Vel');
                fold.Vel = temp.Vel;
                clear temp
            end
            
            % Calculate values
            [fold.vector.Vx,fold.vector.Vy] = ...
                vector_grid_calculations(fold.vector.X,fold.vector.Y,fold.MESH,fold.Vel(1:2:end),fold.Vel(2:2:end),fold.vector.opts);
            
            % Find scaling
            if fold.vector.relative == 1
                % Proportional
                Vx = fold.vector.Vx;
                Vy = fold.vector.Vy;
            elseif fold.vector.relative == 2
                % Logarythmic
                % Find vector length
                M  = sqrt(fold.vector.Vx.^2+fold.vector.Vy.^2);
                % Find the scaling value
                S  = log10(M);
                S(isinf(S)) = 0;
                S  = (S-min(S)+1)./M;
                Vx = S.*fold.vector.Vx;
                Vy = S.*fold.vector.Vy;
            elseif fold.vector.relative == 3
                % Equal
                S  = sqrt(fold.vector.Vx.^2+fold.vector.Vy.^2);
                Vx = 1./S.*fold.vector.Vx;
                Vy = 1./S.*fold.vector.Vy;
            end
            
            % Plot vector
            quiver(fold.vector.X,fold.vector.Y, Vx, Vy, 'k',...
                'LineWidth',fold.popts.vector_thick,'Color',fold.popts.vector_color,'Parent',h_axes,...
                'AutoScale','on','AutoScaleFactor',0.9*fold.vector.scaling,'Hittest','off');
        end
        
        
        %% - Tensor
        if get(obj.folder_tensor, 'value')
            
            nx      = fold.tensor.x_density;
            
            % Define the x-grid values
            if isempty(fold.tensor.xmin)
                x = linspace(min(fold.MESH.NODES(1,:)),max(fold.MESH.NODES(1,:)),nx);
            else
                x = linspace(fold.tensor.xmin,fold.tensor.xmax,nx);
                x = x(x>=min(fold.MESH.NODES(1,:)) & x<=max(fold.MESH.NODES(1,:)));
            end
            
            % Define the y-grid values
            if fold.tensor.irregular ==0
                % Regualar
                dx = x(2)-x(1);
                
                if isempty(fold.tensor.ymin)
                    ny = ceil(-2*min(fold.MESH.NODES(2,:))/dx);
                    y  = linspace(min(fold.MESH.NODES(2,:)),max(fold.MESH.NODES(2,:)),ny);
                else
                    ny = ceil((fold.tensor.ymax-fold.tensor.ymin)/dx);
                    y = linspace(fold.tensor.ymin,fold.tensor.ymax,ny);
                    y = y(y>=min(fold.MESH.NODES(2,:)) & y<=max(fold.MESH.NODES(2,:)));
                end
            else
                % Irregular
                if isempty(fold.tensor.y_density)
                    dx = x(2)-x(1);
                    if isempty(fold.tensor.ymin)
                        ny = ceil(-2*min(fold.MESH.NODES(2,:))/dx);
                        y  = linspace(min(fold.MESH.NODES(2,:)),max(fold.MESH.NODES(2,:)),ny);
                    else
                        ny = ceil((fold.tensor.ymax-fold.tensor.ymin)/dx);
                        y = linspace(fold.tensor.ymin,fold.tensor.ymax,ny);
                        y = y(y>=min(fold.MESH.NODES(2,:)) & y<=max(fold.MESH.NODES(2,:)));
                    end
                else
                    ny = fold.tensor.y_density;
                end
                
                if isempty(fold.tensor.ymin)
                    y = linspace(min(fold.MESH.NODES(2,:)),max(fold.MESH.NODES(2,:)),ny);
                else
                    y = linspace(fold.tensor.ymin,fold.tensor.ymax,ny);
                    y = y(y>=min(fold.MESH.NODES(2,:)) & y<=max(fold.MESH.NODES(2,:)));
                end
            end
            
            [X,Y]         	= meshgrid(x,y);
            %fold.tensor  	= [];
            fold.tensor.X   = X(:)';
            fold.tensor.Y   = Y(:)';
            
            %%TODO
            Mu = zeros(1,length(fold.region));
            N  = zeros(1,length(fold.region));
            
            for ii = 1:length(fold.region)
                Mu(ii) = str2double(fold.material_data{fold.region(ii).material,3});
                N(ii)  = str2double(fold.material_data{fold.region(ii).material,6});
            end
            
            if isempty(fold.Vel) || isempty(fold.Pressure)
                % Load data
                temp = [];
                temp = load([fold.run_output,'run_output',filesep,'run_',  num2str(fold.num.it,'%.4d')],'Vel','Pressure');
                fold.Vel        = temp.Vel;
                fold.Pressure   = temp.Pressure;
                clear temp
            end
            
            % Calculate values
            [fold.tensor.V1,fold.tensor.V2,fold.tensor.D1,fold.tensor.D2] = ...
                tensor_grid_calculations(fold.tensor.X,fold.tensor.Y,fold.MESH,...
                fold.Vel(1:2:end),fold.Vel(2:2:end),fold.Pressure,...
                Mu,N, fold.tensor.opts);
            
            % Find scaling
            if fold.tensor.relative == 1
                % Proportional
                D1 = fold.tensor.D1;
                D2 = fold.tensor.D2;
            elseif fold.tensor.relative == 2
                % Logarythmic
                D1 = sign(fold.tensor.D1).*log10(abs(fold.tensor.D1)+1);
                D2 = sign(fold.tensor.D2).*log10(abs(fold.tensor.D2)+1);
            elseif fold.tensor.relative == 3
                % Equal
                D1 = 0*fold.tensor.D1+sign(fold.tensor.D1);
                D2 = 0*fold.tensor.D2+sign(fold.tensor.D2);
            end
            max_vector = max(abs([D1 D2]));
            grid_size  = max([diff(fold.tensor.X), diff(fold.tensor.Y)]);
            scale      = 0.8*fold.tensor.scaling*grid_size/max_vector;
            
            D1 = scale*D1;
            D2 = scale*D2;
            V1 = fold.tensor.V1;
            V2 = fold.tensor.V2;
            
            % Generate tensor glyphs
            if fold.tensor.style == 4
                
                % Tensor linearly scaled
                [Xr, Yr, Xb, Yb] = generate_ellipse_glyphs(fold.tensor.X, fold.tensor.Y,...
                    0.5*D1,0.5*D2,...
                    atan(V1(2,:)./V1(1,:)));
                
                % Positive values
                idx1 = fold.tensor.D1>=0;
                hp = patch(Xr(idx1,:)',Yr(idx1,:)',fold.popts.tensor_color1,'Parent', h_axes);
                set(hp,'EdgeColor','none','Hittest','off')
                
                % Negative values
                idx2 = fold.tensor.D1<0;
                hp = patch(Xr(idx2,:)',Yr(idx2,:)',fold.popts.tensor_color2,'Parent', h_axes);
                set(hp,'EdgeColor','none','Hittest','off')
                
                % Positive values
                idx1 = fold.tensor.D2>=0;
                hp = patch(Xb(idx1,:)',Yb(idx1,:)',fold.popts.tensor_color1,'Parent', h_axes);
                set(hp,'EdgeColor','none','Hittest','off')
                
                % Negative values
                idx2 = fold.tensor.D2<0;
                hp = patch(Xb(idx2,:)',Yb(idx2,:)',fold.popts.tensor_color2,'Parent', h_axes);
                set(hp,'EdgeColor','none','Hittest','off')
                
            end
            
            if fold.tensor.style == 1
                if fold.tensor.D1(1)>=fold.tensor.D2(1)
                    idx  = fold.tensor.D1;
                    X    = fold.tensor.X;
                    Y    = fold.tensor.Y;
                    D    = D1;
                    V    = V1;
                else
                    idx  = fold.tensor.D2;
                    X    = fold.tensor.X;
                    Y    = fold.tensor.Y;
                    D    = D2;
                    V    = V2;
                end
            elseif fold.tensor.style == 2
                if fold.tensor.D1(1)<fold.tensor.D2(1)
                    idx  = fold.tensor.D1;
                    X    = fold.tensor.X;
                    Y    = fold.tensor.Y;
                    D    = D1;
                    V    = V1;
                else
                    idx  = fold.tensor.D2;
                    X    = fold.tensor.X;
                    Y    = fold.tensor.Y;
                    D    = D2;
                    V    = V2;
                end
            elseif fold.tensor.style > 2
                idx  = [fold.tensor.D1 fold.tensor.D2];
                X    = [fold.tensor.X fold.tensor.X];
                Y    = [fold.tensor.Y fold.tensor.Y];
                D    = [D1 D2];
                V    = [V1 V2];
            end
            
            Xel  = [X-0.5*D.*V(1,:);...
                X+0.5*D.*V(1,:);...
                nan(1,size(idx,2))];
            
            Yel  = [Y-0.5*D.*V(2,:);...
                Y+0.5*D.*V(2,:);...
                nan(1,size(idx,2))];
            
            
            if fold.tensor.style < 4
                % Colored lines for axis plotting
                
                % Positive values
                x_plot = Xel(:,idx>=0);
                y_plot = Yel(:,idx>=0);
                plot(h_axes, x_plot(:), y_plot(:),...
                    'Color',fold.popts.tensor_color1,'LineWidth',fold.popts.tensor_thick,'Hittest','off');
                % Negative values
                x_plot = Xel(:,idx<0);
                y_plot = Yel(:,idx<0);
                plot(h_axes, x_plot(:), y_plot(:),...
                    'Color',fold.popts.tensor_color2,'LineWidth',fold.popts.tensor_thick,'Hittest','off');
            else
                % Black lines for glyphs
                %plot(h_axes,Xel(:),Yel(:),...
                %    'Color','k','LineWidth',fold.popts.tensor_thick,'Hittest','off');
            end
        end
        
        %% - Axes
        box(h_axes, 'on');
        colormap(h_axes,'default')
        axis(h_axes,'equal')
        if isfield(fold, 'NODES_run')
            xlim(h_axes, [fold.NODES_run -fold.NODES_run])
        else
            if ~isfield(fold,'NODES')
                xlim(h_axes, [-fold.box.width/2 fold.box.width/2])
            else
                xlim(h_axes, [fold.NODES(1,1) fold.NODES(1,2)])
            end
        end
        
        if get(obj.plot_xlim, 'value')
            xlim(h_axes,[fold.popts.xmin fold.popts.xmax])
        end
        if get(obj.plot_ylim, 'value')
            ylim(h_axes,[fold.popts.ymin fold.popts.ymax])
        end
        
        if get(obj.plot_axis_tight, 'value')
            axis(h_axes,'tight')
        end
        if ~get(obj.plot_axis_on, 'value')
            axis(h_axes,'off')
        end
        
        daspect(h_axes,[fold.popts.axis_y,1,1])
        
        if fold.popts.clim
            caxis(h_axes,[fold.popts.cmin fold.popts.cmax])
        end
        
        set(h_axes, 'layer', 'top', 'TickDir', 'in');
        
        
        %% - Colormaps
        mycmap = load_colormap(fold.popts.colormap_type, fold.popts.colormap);
        % Flip colormap
        if fold.popts.flip
            mycmap = flipud(mycmap);
        end
        colormap(h_axes,mycmap);
        
        % Contours
        if fold.popts.ncolors ~= size(mycmap,1)
            
            % Interpolate data
            mycmap = [interp1(linspace(1,64,size(mycmap(:,1),1)),mycmap(:,1),linspace(1,64,fold.popts.ncolors))', ...
                interp1(linspace(1,64,size(mycmap(:,1),1)),mycmap(:,2),linspace(1,64,fold.popts.ncolors))',...
                interp1(linspace(1,64,size(mycmap(:,1),1)),mycmap(:,3),linspace(1,64,fold.popts.ncolors))'];
            colormap(h_axes,mycmap);
        end
        
        %% - Colorbar/Legend
        if get(obj.folder_colorbar, 'value')
            if get(obj.folder_plotting, 'value')==1
                legend_positions   = {'northeastoutside','northeast','southeastoutside','southeast'};
                legend_orientation = {'vertical','vertical','vertical','vertical'};
                labels             = char(fold.material_data{vertcat(fold.region(length(fold.region):-1:1).material),2});
                hl = legend(fh(end:-1:1),labels,'Location',legend_positions{fold.popts.colorbar_position},...
                    'Orientation',legend_orientation{fold.popts.colorbar_position});
                %set(hl,'FontName','MyriadPro-Regular','FontSize',8);
            else
                colorbar_positions = {'eastoutside','east','southoutside','south'};
                colorbar('peer',h_axes,'Location',colorbar_positions{fold.popts.colorbar_position},'tag','axis_colorbar')
                set(gcf, 'renderer', 'zbuffer')
            end
        end
        if get(obj.folder_colorbar,'value') == 1
            set(obj.folder_colorbar_position, 'enable', 'on')
        else
            set(obj.folder_colorbar_position, 'enable', 'off')
        end
        
        %% - Title
        if isfield(fold, 'NODES_run')
            if fold.num.strain_mode == 1
                stain = (-fold.box.width/2-fold.NODES(1,1))/(-fold.box.width/2);
                if ~strcmp(plot_title2{fold.popts.plot_selection_component},'none')
                    %title(h_axes, ['\bf{',plot_title{fold.popts.plot_selection},':  ',plot_title2{fold.popts.plot_selection_component},'}' char(10) '\rm{Shortening = }',num2str( stain*100 ,'%.1f' ), '%'])
                    title(h_axes, {['\bf{',plot_title{fold.popts.plot_selection},':  ',plot_title2{fold.popts.plot_selection_component},'}'],['\rm{Shortening = }',num2str( stain*100 ,'%.1f' ), '%']} )
                else
                    title(h_axes, {['\bf{',plot_title{fold.popts.plot_selection},'}']; ['\rm{Shortening = }',num2str( stain*100 ,'%.1f' ), '%']})
                end
            else
                stain = (fold.NODES(1,1)+fold.box.width/2)/(-fold.box.width/2);
                if ~strcmp(plot_title2{fold.popts.plot_selection_component},'none')
                    title(h_axes, {['\bf{',plot_title{fold.popts.plot_selection},':  ',plot_title2{fold.popts.plot_selection_component},'}']; ['\rm{Extension = }',num2str( stain*100 ,'%.1f' ), '%']})
                else
                    title(h_axes, {['\bf{',plot_title{fold.popts.plot_selection},'}']; ['\rm{Extension = }',num2str( stain*100 ,'%.1f' ), '%']})
                end
            end
        else
            title(h_axes, {['\bf{',plot_title{fold.popts.plot_selection},'}']; ['\rm{Deformation = }',num2str( 0 ,'%.1f' ), '%']})
        end
        
        %  Update status bar
        set(obj.folder_status_bar_text,'string','')
        
        %  Write data into storage
        setappdata(folder_gui_handle, 'fold', fold);
        
        
    case 'folder_load'
        %% LOAD GEOMETRY
        
        %  Get data
        fold        = getappdata(folder_gui_handle, 'fold');
        
        %  Load
        [filename, pathname] = uigetfile({'*.mat', 'Folder Input Files'}, 'Pick a file');
        
        if length(filename)==1 && filename==0
            return;
        end
        
        try
            switch filename(end-2:end)
                case 'mat'
                    Input_data  = load([pathname,filename]);
                    fold.face       = Input_data.fold.face;
                    fold.region     = Input_data.fold.region;
                    fold.box.width	= max(fold.face(1).X)-min(fold.face(1).X);
                    fold.box.height	= 5*(max(fold.face(end).Y)-min(fold.face(1).Y));
            end
        catch err
            errordlg(err.message, 'Folder Load Error');
            return;
        end
        
        fold.FGT_data  = 1;
        
        %  Write data into storage
        setappdata(folder_gui_handle, 'fold', fold);
        
        % - Create Interface & Mesh
        folder('interface_update')
        
        % Change Run Data State
        folder('buttons_enable');
        
        % Update Uicontrols
        folder('uicontrol_update');
        
        % Plot Update
        folder('plot_update');
        
    case 'folder_save'
        %% SAVE GEOMETRY
        
        %  Get data
        fold    = getappdata(folder_gui_handle, 'fold');
        %  Geometry
        data.face   = fold.face;
        data.region = fold.region;
        fold        = data;
        
        if isempty(fold)
            warndlg('No data to save!', 'FOLDER');
            return;
        end
        
        if isfield(fold,'run_output')
            [Filename, Pathname] = uiputfile(...
                {'*.mat'},...
                'Save as',fold.run_output);
        else
            [Filename, Pathname] = uiputfile(...
                {'*.mat'},...
                'Save as');
        end
        
        if ~(length(Filename)==1 && Filename==0)
            save([Pathname, Filename], 'fold');
        end
        
    case 'restart'
        %% RESTART
        
        % - Folder Default Values
        folder('default_values');
        
        % - Create Interface & Mesh
        folder('interface_update')
        
        % - Update Uicontrols
        folder('uicontrol_update');
        
        % - Buttons Enable
        folder('buttons_enable')
        
        % - Update Plot
        folder('plot_update');
        
        % - Change Tab Panel
        obj       = getappdata(folder_gui_handle, 'obj');
        tab_panel = obj.tab_panel;
        tab_panel.SelectedChild = 1;
        
        % - Update other guis
        popts_gui_handle = findobj(0, 'tag', 'popts_gui_handle', 'type', 'figure');
        if ~isempty(popts_gui_handle)
            setting('buttons_enable')
        end
        
    case 'load_perturbation'
        %% LOAD PERTURBATION
        
        %  Load in files
        [filename, pathname] = uigetfile({'*.mat', 'Folder Input Files'}, ...
            'Pick a file', ['perturbation',filesep,'perturbation.mat']);
        
        if length(filename)==1 && filename==0
            return;
        end
        
        try
            switch filename(end-2:end)
                case 'mat'
                    Input_data  = load([pathname,filename]);
            end
        catch err
            errordlg(err.message, 'Folder Load Error');
            return;
        end
        
        %  Get data
        fold        = getappdata(folder_gui_handle, 'fold');
        
        % Identify index
        if isfield(fold,'pert')
            idx = length(fold.pert) + 1;
        else
            idx = 1;
        end
        
        fold.pert(idx).name = filename(1:end-4);
        fold.pert(idx).x    = Input_data.npert.xx;
        fold.pert(idx).y    = Input_data.npert.yy;
        
        % Update perturbation list
        pert_name = {'Sine';'Red Noise'; 'White Noise'; 'Gaussian Noise'; 'Step'; 'Triangle'; 'Bell'};
        pert_name = [pert_name;cellstr(strvcat(fold.pert.name))];
        
        % Get object handles
        obj       = getappdata(folder_gui_handle, 'obj');
        set(obj.folder_pert, 'String',pert_name);
        
        %  Write data into storage
        setappdata(folder_gui_handle, 'fold', fold);
        
        
    case 'load_from_fgt'
        %% LOAD FROM FGT
        
        %  Load in files
        [filename, pathname] = uigetfile({'*.mat', 'Folder Input Files'}, ...
            'Pick a file', ['fgt_file.mat']);
        
        if length(filename)==1 && filename==0
            return;
        end
        
        try
            switch filename(end-2:end)
                case 'mat'
                    Input_data  = load([pathname,filename]);
            end
        catch err
            errordlg(err.message, 'Folder Load Error');
            return;
        end
        
        % Analyse input data
        xcoor    = [];
        ycoor    = [];
        y1coor   = [];
        xmincoor = [];
        xmaxcoor = [];
        for ii = 1:size(Input_data.Fold,2) % loop over fold numbers
            for j = 1:2 % loop over interfaces
                % First point must be the most leftmost point otherwise
                % flip data
                if Input_data.Fold(ii).Face(j).X.Full(1) > Input_data.Fold(ii).Face(j).X.Full(end)
                    Input_data.Fold(ii).Face(j).X.Full = fliplr(Input_data.Fold(ii).Face(j).X.Full);
                    Input_data.Fold(ii).Face(j).Y.Full = fliplr(Input_data.Fold(ii).Face(j).Y.Full);
                end
                xcoor       = [xcoor    Input_data.Fold(ii).Face(j).X.Full];
                ycoor       = [ycoor    Input_data.Fold(ii).Face(j).Y.Full];
                y1coor      = [y1coor   Input_data.Fold(ii).Face(j).Y.Full(1)];
                xmincoor    = [xmincoor Input_data.Fold(ii).Face(j).X.Full(1)];
                xmaxcoor    = [xmaxcoor Input_data.Fold(ii).Face(j).X.Full(end)];
            end
        end
        xmin = max(xmincoor);
        xmax = min(xmaxcoor);
        
        % Make sure all interfaces span over the same width
        for ii = 1:length(Input_data.Fold) % loop over fold numbers
            for j = 1:2 % loop over interfaces
                
                % First point
                idx = find(Input_data.Fold(ii).Face(j).X.Full<=xmin);
                if length(idx) == 1
                    Input_data.Fold(ii).Face(j).X.Full(1) = xmin;
                else
                    Input_data.Fold(ii).Face(j).X.Full(idx(1:end-1)) = [];
                    Input_data.Fold(ii).Face(j).Y.Full(idx(1:end-1)) = [];
                    Input_data.Fold(ii).Face(j).X.Full(1) = xmin;
                end
                
                % Last point
                idx = find(Input_data.Fold(ii).Face(j).X.Full>=xmax);
                if length(idx) == 1
                    Input_data.Fold(ii).Face(j).X.Full(end) = xmax;
                else
                    Input_data.Fold(ii).Face(j).X.Full(idx(2:end)) = [];
                    Input_data.Fold(ii).Face(j).Y.Full(idx(2:end)) = [];
                    Input_data.Fold(ii).Face(j).X.Full(end) = xmax;
                end
                
                % Remove points that are too close to each other
                dist = sqrt( diff(Input_data.Fold(ii).Face(j).X.Full).^2 + diff(Input_data.Fold(ii).Face(j).Y.Full).^2);
                idx = dist(dist<1e-6);
                if ~isempty(idx)
                    % Do not remove first and last points
                    if idx(1) == 1
                        idx(1) = 2;
                    end
                    if idx(end) == length(Input_data.Fold(ii).Face(j).X.Full)
                        idx(end) = length(Input_data.Fold(ii).Face(j).X.Full)-1;
                    end
                    Input_data.Fold(ii).Face(j).X.Full(idx) = [];
                    Input_data.Fold(ii).Face(j).Y.Full(idx) = [];
                end
            end
        end
        
        %  Get data
        fold        = getappdata(folder_gui_handle, 'fold');
        obj         = getappdata(folder_gui_handle, 'obj');
        
        %  Change the box width
        fold.box.width              = xmax-xmin;
        fold.box.height             = 5*(xmax-xmin);
        
        %  Modify face data
        fold.face   = [];
        [~,order] = sort(y1coor);
        count = 0;
        for ii = 1:length(Input_data.Fold)
            for j = 1:2
                count = count + 1;
                
                fold.face(order(count)).X       = Input_data.Fold(ii).Face(j).X.Full-Input_data.Fold(ii).Face(j).X.Full(1)-fold.box.width/2;
                fold.face(order(count)).Y       = Input_data.Fold(ii).Face(j).Y.Full-min(ycoor)-(max(ycoor)-min(ycoor))/2;
                fold.face(order(count)).nx      = length(Input_data.Fold(ii).Face(j).Y.Full);
                
                fold.face(order(count)).y       = (max(fold.face(order(count)).Y)+min(fold.face(order(count)).Y))/2;
                fold.face(order(count)).pert    = 9;
                fold.face(order(count)).ampl   	= (max(fold.face(order(count)).Y)-min(fold.face(order(count)).Y))/2;
                fold.face(order(count)).wave   	= [];
                fold.face(order(count)).shift  	= [];
                fold.face(order(count)).width  	= [];
            end
        end
        
        % Update perturbation list
        pert_name = {'Sine';'Red Noise'; 'White Noise'; 'Gaussian Noise'; 'Step'; 'Triangle'; 'Bell'; 'FGT data'};
        set(obj.folder_pert, 'String',pert_name);
        
        % Modify region data
        fold.region = [];
        for ii = 1:count+1
            fold.region(ii).area         = 1e-1;
            fold.region(ii).material     = 1;
        end
        
        %  Write info that data comes from FGT
        fold.FGT_data = 1;
        
        %  Write data into storage
        setappdata(folder_gui_handle, 'fold', fold);
        
        % - Create Interface & Mesh
        folder('interface_update')
        
        % - Update Uicontrols
        folder('uicontrol_update');
        
        % - Buttons Enable
        folder('buttons_enable')
        
        % - Update Plot
        folder('plot_update');
        
        
    case 'folder_run'
        %% RUN
        
        %  First save
        folder('save_as_project')
        
        
        %  Get data and object handles
        fold        = getappdata(folder_gui_handle, 'fold');
        obj         = getappdata(folder_gui_handle, 'obj');
        
        if fold.save==0
            return;
        end
        
        %  Update status bar
        set(obj.folder_status_bar_text,'string','FOLDER is busy. Calculating.')
        
        %  Close previous waitbars if exist
        h = findobj(0,'tag','TMWWaitbar');
        delete(h);
        
        %  Show waitbar
        h = waitbar(0,'Calculating. Estimating completion time...','CreateCancelBtn',...
            'setappdata(gcbf,''canceling'',1)');
        setappdata(h,'canceling',0)
        
        hw=findobj(h,'Type','Patch');
        set(hw,'EdgeColor',[0.5 0.5 0.5],'FaceColor',[0.4 0.4 0.4])
        
        %  Create output folder or if exist empty it
        if ~isdir([fold.run_output,'run_output'])
            mkdir([fold.run_output,'run_output']);
        else
            delete([fold.run_output,'run_output',filesep,'*.mat']);
        end
        
        %  Time integration with fixed time step
        if fold.num.strain_mode  == 1;
            fold.num.tspan 	= linspace(0,-log(1-fold.num.strain/100),fold.num.nt+1);
        else
            fold.num.tspan 	= linspace(0, log(1+fold.num.strain/100),fold.num.nt+1);
        end
        
        fold.nnodes = size(fold.NODES,2);
        
        %  Eliminate markers with nan values from the solver input
        MARKERS_temp    = fold.markers.MARKERS(:);
        idx_marker      = ~isnan(MARKERS_temp);
        MARKERS_temp    = MARKERS_temp(idx_marker);
        MARKERS_temp    = reshape(MARKERS_temp,2,length(MARKERS_temp)/2);
        fold.nmarkers   = size(MARKERS_temp,2);
        
        %  Collect finite strain points
        fold.nfstrain   = size(fold.fstrain.FSTRAIN,2);
        
        %  Solver
        try
            total = tic;
            %RESULT      = ode_solvers(@(t,x)vel_fem(t,x,fold), fold.num.tspan, fold.NODES, fold.num.solver, MARKERS_temp, fold.fstrain.FSTRAIN_grid, fold.fstrain.FSTRAIN, 1);
            ode_solvers(@(t,x)vel_solver(t,x,fold), fold.num.tspan, fold.NODES, fold.num.solver, fold.run_output, ...
                fold.markers.MARKERS, fold.fstrain.FSTRAIN_grid, fold.fstrain.FSTRAIN, 1);
            
            % Save info about the run time
            load([fold.run_output,'run_output',filesep,'numerics.mat'],'data');
            data(1).total_time = toc(total);
            toc(total)
            save([fold.run_output,'run_output',filesep,'numerics.mat'],'data')
            
        catch err
            errordlg(err.message, 'Folder Run Error.');
            delete(h)
            return;
        end
        
        % In the case of canelling close and return
        h = findobj(0,'tag','TMWWaitbar');
        if getappdata(h,'canceling')
            delete(h)
            %return;
        end
        h = findobj(0,'tag','TMWWaitbar');
        if ~isempty(h)
            delete(h)
        end
        
        % In case of error of cancelling find the last saved data
        filelist = what([fold.run_output,'run_output',filesep]);
        fold.num.nt = sum(cell2mat(regexp(filelist.mat,'node','once')))-2;
        
        % Mark the presence of run - record the maximum extend of the domain
        if fold.num.strain_mode == 1
            fold.NODES_run = -fold.box.width/2;
        else
            temp = [];
            temp = load([fold.run_output,'run_output',filesep,'nodes_',  num2str(fold.num.nt+1,'%.4d')],'NODES_run');
            fold.NODES_run = temp.NODES_run(1,1);
        end
        
        % Update current folder with data
        fold.run_output = fold.run_output;
        
        %  Make sure that final fold shape is plotted
        fold.num.it             = fold.num.nt+1;
        
        
        %  Update status bar
        set(obj.folder_status_bar_text,'string','')
        
        %  Write data into storage
        setappdata(folder_gui_handle, 'fold', fold);
        
        %  Change Run Data State
        folder('buttons_enable');
        %  Plot Update
        folder('interface_update');
        %  Plot Update
        folder('plot_update');
        %  Uicontrols Update
        folder('uicontrol_update');
        
        % Save data
        save([fold.run_output,'fold'],'fold');
        
        tab_panel               = obj.tab_panel;
        tab_panel.SelectedChild = 2;
        
        
    case 'folder_play'
        %% PLAY
        
        %  Get data
        fold        = getappdata(folder_gui_handle, 'fold');
        obj         = getappdata(folder_gui_handle, 'obj');
        
        %  Update status bar
        set(obj.folder_status_bar_text,'string','FOLDER is busy. Play data.')
        
        % Who is calling
        wcbo            = gcbo;
        Whoiscalling    = get(wcbo, 'tag');
        
        switch Whoiscalling
            
            case 'folder_play_go_start'
                fold.num.it             = 1;
                
                %  Write data into storage
                setappdata(folder_gui_handle, 'fold', fold);
                
            case 'folder_play_backward'
                
                % Set an interrupt flag and write into storage
                flag = 0;
                setappdata(folder_gui_handle, 'flag', flag);
                
                %  Enable appropreate play buttons
                set(obj.folder_play_go_start,   'enable', 'off');
                set(obj.folder_play_backward,   'enable', 'off');
                set(obj.folder_play_stop,       'enable', 'on');
                set(obj.folder_play_forward,    'enable', 'off');
                set(obj.folder_play_go_end,     'enable', 'off');
                set(obj.folder_movie,           'enable', 'on');
                
                for ii = fold.num.it-1:-1:1
                    
                    % Check for a status of an interrupt flag
                    flag = getappdata(folder_gui_handle, 'flag');
                    if flag == 1
                        break;
                    end
                    
                    fold.num.it = ii;
                    %  Write data into storage
                    setappdata(folder_gui_handle, 'fold', fold);
                    
                    tic;
                    % - Create Interface & Mesh
                    folder('interface_update')
                    % - Update Uicontrols
                    folder('uicontrol_update');
                    % - Update Plot
                    folder('plot_update');
                    drawnow;
                    
                    % In case of fast update, pause for a second
                    tstep = toc;
                    if tstep < 1
                        pause(0.7-tstep);
                    end
                end
                
            case 'folder_play_stop'
                
                % Set an interrupt flag and write into storage
                flag = 1;
                setappdata(folder_gui_handle, 'flag', flag);
                
            case 'folder_play_forward'
                
                % Set an interrupt flag and write into storage
                flag = 0;
                setappdata(folder_gui_handle, 'flag', flag);
                
                %  Enable appropreate play buttons
                set(obj.folder_play_go_start,   'enable', 'off');
                set(obj.folder_play_backward,   'enable', 'off');
                set(obj.folder_play_stop,       'enable', 'on');
                set(obj.folder_play_forward,    'enable', 'off');
                set(obj.folder_play_go_end,     'enable', 'off');
                set(obj.folder_movie,           'enable', 'off');
                
                for ii = fold.num.it+1:fold.num.nt+1
                    
                    % Check for a status of an interrupt flag
                    flag = getappdata(folder_gui_handle, 'flag');
                    if flag == 1
                        break;
                    end
                    
                    fold.num.it = ii;
                    %  Write data into storage
                    setappdata(folder_gui_handle, 'fold', fold);
                    
                    tic;
                    % - Create Interface & Mesh
                    folder('interface_update')
                    % - Update Uicontrols
                    folder('uicontrol_update');
                    % - Update Plot
                    folder('plot_update');
                    drawnow;
                    
                    % In case of fast update, pause for a second
                    tstep = toc;
                    if tstep < 1
                        pause(0.7-tstep);
                    end
                end
                
            case 'folder_play_go_end'
                fold.num.it             = fold.num.nt+1;
                
                %  Write data into storage
                setappdata(folder_gui_handle, 'fold', fold);
                
        end
        
        %  Change Run Data State
        folder('buttons_enable');
        % - Create Interface & Mesh
        folder('interface_update')
        % - Update Uicontrols
        folder('uicontrol_update');
        % - Update Plot
        folder('plot_update');
        drawnow;
        
        %  Update status bar
        set(obj.folder_status_bar_text,'string','');
        
    case 'folder_figure'
        %% SAVE FIGURE
        
        %  Get data
        fold      	= getappdata(folder_gui_handle, 'fold');
        
        %  Open dialogbox
        if isfield(fold,'run_output')
            [filename, pathname] = uiputfile(...
                {'*.png';'*.jpg';'*.bmp';'*.tif';'*.eps'},...
                'Save as',fold.run_output);
        else
            [filename, pathname] = uiputfile(...
                {'*.png';'*.jpg';'*.bmp';'*.tif';'*.eps'},...
                'Save as');
        end
        
        % If any folder is selected
        if length(filename)>1
            
            %  Find plotting axes
            folder_fold_panel	= findobj(folder_gui_handle,'tag', 'folder_fold_panel');
            h_axes              = getappdata(folder_fold_panel, 'h_axes');
            h_cont              = getappdata(folder_fold_panel, 'h_cont');
            
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
            
            %colorbar
            
            % Print
            print(hidden_plot, '-dpng', '-r300', [pathname,filename]);
            
            % Delete figure
            delete(hidden_plot);
        end
        
    case 'folder_movie'
        %% SAVE MOVIE
        
        %  Get data
        fold      	= getappdata(folder_gui_handle, 'fold');
        obj         = getappdata(folder_gui_handle, 'obj');
        
        %  Open dialogbox
        [filename, pathname] = uiputfile(...
            {'*.png';'*.jpg';'*.tif'},...
            'Save as',fold.run_output);
        
        % If any folder is selected
        if length(filename)>1
            
            %  Find plotting axes
            folder_fold_panel	= findobj(folder_gui_handle,'tag', 'folder_fold_panel');
            h_axes              = getappdata(folder_fold_panel, 'h_axes');
            h_cont              = getappdata(folder_fold_panel, 'h_cont');
            
            % Get size of the container
            Position    = getpixelposition(h_cont);
            
            % Get current colormap
            Map         = colormap(h_axes);
            
            % Set an interrupt flag and write into storage
            flag = 0;
            setappdata(folder_gui_handle, 'flag', flag);
            
            for ii = 1:fold.num.nt+1
                
                % Check for a status of an interrupt flag
                flag = getappdata(folder_gui_handle, 'flag');
                if flag == 1
                    break;
                end
                
                fold.num.it = ii;
                
                %  Write data into storage
                setappdata(folder_gui_handle, 'fold', fold);
                
                % Make hidden figure of the same size
                % Switch to visible to see what is going on.
                hidden_plot = figure('units','pixels', 'pos', Position,...
                    'NumberTitle','off', 'Name','Hidden Plot','tag','folder_hidden_plot',...
                    'MenuBar','none',...
                    'visible', 'off', ...
                    'Color', [1 1 1]);
                
                set(hidden_plot, 'PaperPositionMode','auto');
                
                % - Create Interface & Mesh
                folder('interface_update')
                % - Update Uicontrols
                folder('uicontrol_update');
                % - Update Plot
                folder('plot_update');
                
                set(obj.folder_play_go_start,   'enable', 'off');
                set(obj.folder_play_backward,   'enable', 'off');
                set(obj.folder_play_stop,       'enable', 'on');
                set(obj.folder_play_forward,    'enable', 'off');
                set(obj.folder_play_go_end,     'enable', 'off');
                set(obj.folder_movie,           'enable', 'off');
                
                drawnow
                
                % Copy the container to the figure
                new_handle  = copyobj(h_cont, hidden_plot);
                
                % Activate colormap
                colormap(Map);
                
                % White background
                set(new_handle, 'BackgroundColor', [1 1 1]);
                
                % Separate name from extension
                [~,name,ext] = fileparts(filename);
                %  Create output folder or if exist empty it
                if ii == 1
                    mkdir([pathname,name]);
                end
                % Print
                print(hidden_plot, '-dpng', '-r300', [pathname,name,filesep,name,'_',num2str(ii-1,'%.4d'),ext]);
                
                % Delete figure
                delete(hidden_plot);
            end
            
        end
        
    case 'folder_export'
        %% EXPORT TO FGT
        
        %  Get data
        fold          = getappdata(folder_gui_handle, 'fold');
        Fold_temp     = fold.NODES;
        idx           = [fold.PHASE_idx(2:end) size(fold.NODES,2)-1];
        
        %  Write data in FGT format
        if ~mod(length(fold.face),2)
            count = 1;
            for j = 1:length(fold.face)/2
                for ii = 1:2
                    Fold(j).Face(ii).X.Ori = Fold_temp(1,idx(count):idx(count+1)-1);
                    Fold(j).Face(ii).Y.Ori = Fold_temp(2,idx(count):idx(count+1)-1);
                    count = count+1;
                end
            end
        else
            warndlg('Number of interfaces must be a multiplicity of 2.', 'Error!', 'modal');
            return;
        end
        
        if isfield(fold,'run_output')
            [Filename, Pathname] = uiputfile(...
                {'*.mat'},...
                'Save as',fold.run_output);
        else
            [Filename, Pathname] = uiputfile(...
                {'*.mat'},...
                'Save as');
        end
        
        if ~(length(Filename)==1 && Filename==0)
            save([Pathname, Filename], 'Fold');
        end
        
    case 'folder_export_workspace'
        %% EXPORT TO WORKSPACE
        
        %  Get data
        fold        = getappdata(folder_gui_handle, 'fold');
        
        % Export into workspace
        checkLabels = {'Save data named:'};
        varNames    = {'fold'};
        items       = {fold};
        export2wsdlg(checkLabels,varNames,items,...
            'Save FOLDER Data to Workspace');
        
    case 'help'
        %% HELP
        Path_folder_help   = which('folder_help.pdf');
        web(Path_folder_help, '-browser'); 
        
end

%% fun copying files
    function copying_file(sourcefolder, destinationfolder)
        
        %  Close previous waitbars if exist
        h = findobj(0,'tag','TMWWaitbar');
        delete(h)
        
        % Waitbar
        h = waitbar(0,'Saving files.','CreateCancelBtn',...
            'setappdata(gcbf,''canceling'',1)');
        setappdata(h,'canceling',0)
        
        hw=findobj(h,'Type','Patch');
        set(hw,'EdgeColor',[0.5 0.5 0.5],'FaceColor',[0.4 0.4 0.4])
        
        % Find total folder size
        D = dir([sourcefolder,'run_output']);
        foldersize = sum([D.bytes]);
        currentsize= 0;
        
        % Copy folder data
        copyfile([sourcefolder,'fold.mat'],destinationfolder);
        
        if ~isdir([destinationfolder,'run_output'])
            mkdir([destinationfolder,'run_output']);
        end
        
        % Loop over files
        for step = 1:size(D,1)-2
            
            copyfile([sourcefolder,'run_output',filesep,D(step+2).name],[destinationfolder,'run_output',filesep]);
            currentsize = currentsize + D(step+2).bytes;
            
            % Update waitbar
            waitbar( currentsize / foldersize, h)
            if getappdata(h,'canceling')
                break;
            end
        end
        
        %  Close waitbar
        h = findobj(0,'tag','TMWWaitbar');
        if ~isempty(h)
            delete(h)
        end
    end

%% fun geometry for traingle
    function [NODES, SEGM, PHASE_PTS, PHASE_idx, REGIONS, opts] = geometry_for_traingle(fold)
        
        % Initialize output
        NODES     = zeros(2,sum(vertcat(fold.face.nx))+4);
        SEGM      = zeros(2,2*sum(vertcat(fold.face.nx))+4);
        PHASE_PTS = zeros(4,length(fold.face)+1);
        PHASE_idx = zeros(1,length(fold.face)+1);
        REGIONS   = cell(1,length(fold.face)+1);
        
        % box bottom
        if ~isfield(fold,'NODES_run')
            NODES(:,1:2) = [-fold.box.width/2, fold.box.width/2;...
                -fold.box.height/2*ones(1,2)];
        else
            NODES(:,1:2) = [fold.NODES_run(1,fold.num.it), -fold.NODES_run(1,fold.num.it);...
                fold.NODES_run(2,fold.num.it),  fold.NODES_run(2,fold.num.it)];
        end
        
        % Interfaces
        idx_nodes = cumsum([2; vertcat(fold.face.nx); 2]);
        for ii = 1:length(fold.face)
            NODES(:,(idx_nodes(ii)+1):idx_nodes(ii+1))  = [fold.face(ii).X; fold.face(ii).Y];
        end
        
        % Box top
        if ~isfield(fold,'NODES_run')
            NODES(:,end-1:end) = [-fold.box.width/2, fold.box.width/2;...
                fold.box.height/2*ones(1,2)];
        else
            NODES(:,end-1:end) = [ fold.NODES_run(1,fold.num.it), -fold.NODES_run(1,fold.num.it);...
                -fold.NODES_run(2,fold.num.it), -fold.NODES_run(2,fold.num.it)];
        end
        
        idx_nodes = [0; idx_nodes];
        idx_seg   = [2; vertcat(fold.face.nx); 2];
        idx_seg   = idx_seg(1:end-1)+idx_seg(2:end);
        
        for ii = 1:length(fold.region)
            
            SEG            = [idx_nodes(ii)+1:idx_nodes(ii+1) idx_nodes(ii+2):-1:idx_nodes(ii+1)+1];
            idx            = (1:idx_seg(ii))+sum(idx_seg(1:ii-1));
            SEGM(:,idx)    = [SEG; [SEG(2:end) SEG(1)]];
            REGIONS{ii}     = SEG;
            PHASE_idx(ii)   = idx_nodes(ii)+1;
            %PHASE_PTS(:,ii) = [NODES(1,idx_nodes(ii)+1)+1e-3 NODES(2,idx_nodes(ii)+1)+1e-3 ii fold.region(ii).area]';
            PHASE_PTS(:,ii) = [NODES(1,idx_nodes(ii)+1)+ 1e-6 ...
                NODES(2,idx_nodes(ii)+1)+ (NODES(2,idx_nodes(ii+1)+1)-NODES(2,idx_nodes(ii)+1))/10 ...
                ii ...
                fold.region(ii).area]';
        end
        
        % TRIANGLE
        % Set triangle options
        opts = [];
        opts.element_type     = 'tri7';   % element type
        opts.gen_neighbors    = 1;        % generate element neighbors
        opts.gen_elmarkers    = 1;        % generate element markers
        opts.triangulate_poly = 1;
        opts.min_angle        = 32;
        opts.other_options    = 'aAQ';
        
    end

%% fun vector grid calculations
    function [Vx_pts,Vy_pts] = vector_grid_calculations(X,Y,MESH,Vx,Vy,mode)
        % Calculates velocity components on the grid
        
        grid = [X;Y];
        
        % Boundary conditions
        WS.xmin   = min(MESH.NODES(1,:));
        WS.xmax   = max(MESH.NODES(1,:));
        WS.ymin   = min(MESH.NODES(2,:));
        WS.ymax   = max(MESH.NODES(2,:));
        
        warning('off','MATLAB:triangulation:PtsNotInTriWarnId');
        map_pm    = tsearch2(MESH.NODES, MESH.ELEMS(1:3,:), grid, WS);
        
        opts.nthreads = 1;
        
        if mode==1
            % Total velocity
            V      = [Vx';Vy'];
            vel_pm = einterp(MESH, V, grid, map_pm, opts);
        else
            % Perturbing velocity
            if fold.num.strain_mode == 1
                Dxx = -1; % Shortening
            else
                Dxx =  1; % Extension
            end
            
            vx_back =  Dxx*fold.MESH.NODES(1,:)';
            vy_back = -Dxx*fold.MESH.NODES(2,:)';
            V    = [Vx'-vx_back';Vy'-vy_back'];
            
            vel_pm = einterp(MESH, V, grid, map_pm, opts);
        end
        
        Vx_pts = vel_pm(1,:);
        Vy_pts = vel_pm(2,:);
        
    end

%% fun tensor grid calculations
    function [V1 ,V2, D1, D2] = tensor_grid_calculations(X, Y, MESH, Vx, Vy, P, Mu, N, tensor_mode)
        % Calculates strain rate/stress components on the grid
        
        % Calculates velocity derivatives in the grid points
        [dVxdx, dVxdy, dVydx, dVydy, uv_pts, map_pm] = dVdx_grid(X, Y, Vx, Vy, MESH);
        
        % Calculate strain
        Exx_pts  =  2/3* dVxdx - 1/3* dVydy;
        Eyy_pts  =  2/3* dVydy - 1/3* dVxdx;
        Exy_pts  =  1/2*(dVxdy +      dVydx);
        
        % Calculate stress
        if tensor_mode > 1
            % Total stress
            
            grid = [X;Y];
            
            % Boundary conditions
            WS.xmin   = min(MESH.NODES(1,:));
            WS.xmax   = max(MESH.NODES(1,:));
            WS.ymin   = min(MESH.NODES(2,:));
            WS.ymax   = max(MESH.NODES(2,:));
            
            % map_pm    = tsearch2(MESH.NODES, MESH.ELEMS(1:3,:), grid, WS);
            
            opts.nthreads = 1;
            
            % Deviatoric stress
            ER_II       = sqrt(((Exx_pts-Eyy_pts).^2.)/4+Exy_pts.^2);
            Mu_app  	= Mu(MESH.elem_markers(map_pm)).*ER_II.^(1./N(MESH.elem_markers(map_pm))-1);
            
            Sxx_pts     = 2*Mu_app.*Exx_pts;
            Syy_pts 	= 2*Mu_app.*Eyy_pts;
            Sxy_pts    	= 2*Mu_app.*Exy_pts;
            
            if tensor_mode == 2
                % Total stress
                N = [1-sum(uv_pts); uv_pts];
                press_pts = sum(N.*P(:,map_pm));
                Sxx_pts = Sxx_pts - press_pts;
                Syy_pts = Syy_pts - press_pts;
            end
        end
        
        % Alocate memory
        npts    = length(X);
        V1      = zeros(2, npts);
        V2      = zeros(2, npts);
        D1      = zeros(1, npts);
        D2      = zeros(1, npts);
        
        % Loop over grid points
        for ip=1:npts
            
            if tensor_mode == 1
                A = [Exx_pts(ip) Exy_pts(ip);Exy_pts(ip) Eyy_pts(ip)];
            else
                A = [Sxx_pts(ip) Sxy_pts(ip);Sxy_pts(ip) Syy_pts(ip)];
            end
            
            % Eigenvectos and eigenvalue of the strain tensor
            [V,D]    = eig(A);
            
            V1(:,ip) = V(:,1);
            V2(:,ip) = V(:,2);
            D1(:,ip) = D(1,1);
            D2(:,ip) = D(2,2);
            
        end
    end

%% fun generate tensor glyphs
    function [Xr, Yr, Xb, Yb] = generate_ellipse_glyphs(x0, y0, a, b, phi)
        
        nx      = 10;
        theta_r = linspace(-pi/4,pi/4,nx);
        Xr = bsxfun(@times, cos(phi(:)), a(:)*[sin(theta_r) -sin(-theta_r)])+...
            bsxfun(@times,-sin(phi(:)), b(:)*[cos(theta_r) -cos( theta_r)]);
        Yr = bsxfun(@times, sin(phi(:)), a(:)*[sin(theta_r) -sin(-theta_r)])+...
            bsxfun(@times, cos(phi(:)), b(:)*[cos(theta_r) -cos( theta_r)]);
        Xr = bsxfun(@minus, x0(:), Xr);
        Yr = bsxfun(@minus, y0(:), Yr);
        
        theta_b = linspace(-pi/4,-3*pi/4,nx);
        Xb = bsxfun(@times, cos(phi(:)), a(:)*[sin(theta_b)  sin(-theta_b)])+...
            bsxfun(@times,-sin(phi(:)), b(:)*[cos(theta_b)  cos( theta_b)]);
        Yb = bsxfun(@times, sin(phi(:)), a(:)*[sin(theta_b)  sin(-theta_b)])+...
            bsxfun(@times, cos(phi(:)), b(:)*[cos(theta_b)  cos( theta_b)]);
        Xb = bsxfun(@minus, x0(:), Xb);
        Yb = bsxfun(@minus, y0(:), Yb);
    end

%% fun number of interface and region
    function i_number(obj, event_obj)
        
        % Get data
        face      = getappdata(folder_gui_handle, 'face');
        region    = getappdata(folder_gui_handle, 'region');
        
        if strcmp(get(gco,'Tag'),'face_number_left')
            face      = face - 1;
        elseif strcmp(get(gco,'Tag'),'face_number_right')
            face      = face + 1;
        elseif strcmp(get(gco,'Tag'),'region_number_left')
            region    = region - 1;
        elseif strcmp(get(gco,'Tag'),'region_number_right')
            region    = region + 1;
        end
        
        setappdata(folder_gui_handle, 'face', face);
        setappdata(folder_gui_handle, 'region', region);
        
        % Enable buttons
        folder('buttons_enable');
        
        % Controlls update
        folder('uicontrol_update')
        
        % Plot Update
        folder('plot_update');
        
    end

%% fun choose color region
    function color_region(obj, event_obj)
        
        % Who is calling
        wcbo            = gcbo;
        Whoiscalling    = get(wcbo, 'tag');
        
        if strcmp(Whoiscalling,'folder_fold_uicontainer')
            
            % Set region and face values
            region = 0;
            setappdata(folder_gui_handle, 'region', region);
            face   = 0;
            setappdata(folder_gui_handle, 'face', face);
            
            % Diselect line
            lh2  = getappdata(folder_fold_panel,'lh2');
            set(lh2,'XData',[],'YData',[])
            
        else
            
            % Set region value
            region = str2double(get(gco,'Tag'));
            setappdata(folder_gui_handle, 'region', region);
        end
        
        % Mark selected region
        fh2  = getappdata(folder_fold_panel,'fh2');
        fold = getappdata(folder_gui_handle, 'fold');
        
        if region>0
            set(fh2,'XData',fold.NODES(1,[fold.REGIONS{region} fold.REGIONS{region}(1)]),...
                'YData',fold.NODES(2,[fold.REGIONS{region} fold.REGIONS{region}(1)]));
            hcmenu = uicontextmenu('Parent',folder_gui_handle);
            
            % Attach uicontext menu again because previous one was covered
            % with a new patch
            if isnan(str2double(fold.material_data{fold.region(ireg).material,7}))
                item1 = uimenu(hcmenu, 'Label', ['No: ',num2str( fold.material_data{fold.region(ireg).material,1} )],...
                    'tag',num2str(fold.region(ireg).material),'callback',@(a,b)  materials);
                item2 = uimenu(hcmenu, 'Label', ['Name: ',num2str( fold.material_data{fold.region(ireg).material,2} )],...
                    'tag',num2str(fold.region(ireg).material),'callback',@(a,b)  materials);
                item3 = uimenu(hcmenu, 'Label', ['m: ',num2str( fold.material_data{fold.region(ireg).material,3} )],...
                    'tag',num2str(fold.region(ireg).material),'callback',@(a,b)  materials);
                item4 = uimenu(hcmenu, 'Label', ['m_0/m: ',num2str( fold.material_data{fold.region(ireg).material,4} )],...
                    'tag',num2str(fold.region(ireg).material),'callback',@(a,b)  materials);
                item5 = uimenu(hcmenu, 'Label', ['m_inf/m: ',num2str( fold.material_data{fold.region(ireg).material,5} )],...
                    'tag',num2str(fold.region(ireg).material),'callback',@(a,b)  materials);
                item6 = uimenu(hcmenu, 'Label', ['n: ',num2str( fold.material_data{fold.region(ireg).material,6} )],...
                    'tag',num2str(fold.region(ireg).material),'callback',@(a,b)  materials);
            else
                item1 = uimenu(hcmenu, 'Label', ['No.: ',num2str( fold.material_data{fold.region(ireg).material,1} )],...
                    'tag',num2str(fold.region(ireg).material),'callback',@(a,b)  materials);
                item2 = uimenu(hcmenu, 'Label', ['Name: ',num2str( fold.material_data{fold.region(ireg).material,2} )],...
                    'tag',num2str(fold.region(ireg).material),'callback',@(a,b)  materials);
                item3 = uimenu(hcmenu, 'Label', ['m_0/m: ',num2str( fold.material_data{fold.region(ireg).material,4} )],...
                    'tag',num2str(fold.region(ireg).material),'callback',@(a,b)  materials);
                item4 = uimenu(hcmenu, 'Label', ['m_inf/m: ',num2str( fold.material_data{fold.region(ireg).material,5} )],...
                    'tag',num2str(fold.region(ireg).material),'callback',@(a,b)  materials);
                item5 = uimenu(hcmenu, 'Label', ['n: ',num2str( fold.material_data{fold.region(ireg).material,6} )],...
                    'tag',num2str(fold.region(ireg).material),'callback',@(a,b)  materials);
                item6 = uimenu(hcmenu, 'Label', ['Q: ',num2str( fold.material_data{fold.region(ireg).material,7} )],...
                    'tag',num2str(fold.region(ireg).material),'callback',@(a,b)  materials);
                item7 = uimenu(hcmenu, 'Label', ['A: ',num2str( fold.material_data{fold.region(ireg).material,8} )],...
                    'tag',num2str(fold.region(ireg).material),'callback',@(a,b)  materials);
            end
            set(fh2,'uicontextmenu',hcmenu);
            
        else
            set(fh2,'XData',[],'YData',[]);
        end
        
        % Set data
        setappdata(folder_fold_panel,'fh2',fh2)
        
        % Controlls update
        folder('uicontrol_update')
        
        % Enable buttons
        folder('buttons_enable');
        
        
    end

%% fun choose color line
    function color_line(obj, event_obj)
        
        
        face = str2double(get(gco,'Tag'));
        setappdata(folder_gui_handle, 'face', face);
        
        % Mark selected line
        lh2  = getappdata(folder_fold_panel,'lh2');
        fold = getappdata(folder_gui_handle, 'fold');
        
        if face > 0
            set(lh2,'XData',fold.face(face).X,...
                'YData',fold.face(face).Y)
        else
            set(lh2,'XData',[],'YData',[])
        end
        
        % Controlls update
        folder('uicontrol_update')
        
        % Enable buttons
        folder('buttons_enable');
        
        
    end
end