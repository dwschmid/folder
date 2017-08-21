function quick_model_setup(Action)

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
quick_model_gui_handle = findobj(0, 'tag', 'quick_model_gui_handle', 'type', 'figure');

switch lower(Action)
    case 'initialize'
        %% INITIALIZE
        
        %  Delete figure if it already exists
        if ~isempty(quick_model_gui_handle)
            delete(quick_model_gui_handle);
        end
        
        %% INITIALIZE
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
        
        Screensize      = get(0, 'ScreenSize');
        text_width      = 2*b_width+gap;
        field_width     = 2*b_width+gap;
        
        setup_height        = 8*(b_height+gap)+4*gap;
        materials_height    = 2*(b_height+gap)+4*gap;
        contr_height        = 1*(b_height+gap)+1*gap;
        
        fig_width           = text_width+field_width+3*gap;
        fig_height          = setup_height+materials_height+contr_height;
        
        % Create dialog window
        quick_model_gui_handle = figure( ...
            'Name' ,'Quick Model Setup', 'Units','pixels', 'tag','quick_model_gui_handle',...
            'NumberTitle', 'off', 'DockControls', 'off', 'MenuBar', 'none', 'ToolBar', 'none',...
            'Resize','off',...
            'pos', [Screensize(3)/5, Screensize(4)/2, fig_width, fig_height], 'Color',get(0, 'DefaultUipanelBackgroundColor'));
        
        b1                      = uiextras.VBox('Parent', quick_model_gui_handle);
        mod_upanel_setup        = uipanel('Parent', b1, 'Tag','mod_upanel_setup',       'Title','Geometry');
        mod_upanel_materials    = uipanel('Parent', b1, 'Tag','mod_upanel_materials',   'Title','Materials');
        mod_upanel_controls     = uipanel('Parent', b1, 'Tag','sel_upanel_region');
        set( b1, 'Sizes', [setup_height materials_height contr_height]);
        
        
        %% - Number of interfaces
        % Text
        uicontrol('Parent', mod_upanel_setup, 'style', 'text', 'String', 'Number of Interfaces', 'HorizontalAlignment', 'left', ...
            'position', [gap, 7*(b_height+gap)+gap, text_width, b_height]);
        % Field
        obj.mod_n_interfaces = uicontrol('Parent', mod_upanel_setup, 'style', 'edit', 'String', '', 'BackgroundColor','w',...
            'callback',  @(a,b)  quick_model_setup('uicontrol_callback'),...
            'tag', 'mod_n_interfaces', ...
            'position', [gap+text_width+gap, 7*(b_height+gap)+gap, field_width, b_height]);
        
        %% - Interface separation
        % Text
        uicontrol('Parent', mod_upanel_setup, 'style', 'text', 'String', 'Separation', 'HorizontalAlignment', 'left', ...
            'position', [gap, 6*(b_height+gap)+gap, text_width, b_height],...
            'tooltipstring',sprintf('Separation between interfaces.\nIf more than one number is used, the values are used in the repeating sequence from bottom to top.'));
        % Field
        obj.mod_interface_sep = uicontrol('Parent', mod_upanel_setup, 'style', 'edit', 'String', '', 'BackgroundColor','w',...
            'callback',  @(a,b)  quick_model_setup('uicontrol_callback'),...
            'tag', 'mod_interface_sep', ...
            'position', [gap+text_width+gap, 6*(b_height+gap)+gap, field_width, b_height]);
        
        %% - Perturbation type
        % Text
        uicontrol('Parent', mod_upanel_setup, 'style', 'text', 'String', 'Perturbation', 'HorizontalAlignment', 'left', ...
            'position', [gap, 5*(b_height+gap)+gap, text_width, b_height],...
            'tooltipstring','Perturbation type.');
        % Field
        obj.mod_pert_type = uicontrol('Parent', mod_upanel_setup, 'style', 'popupmenu', 'String', {'Sine';'Red Noise'; 'White Noise'; 'Gaussian Noise'; 'Step'; 'Triangle'; 'Bell'}, 'value', 1, ...
            'callback',  @(a,b)  quick_model_setup('uicontrol_callback'),...
            'tag', 'mod_pert_type', 'BackgroundColor','w',...
            'position', [gap+text_width+gap, 5*(b_height+gap)+gap, field_width, b_height]);
        
        %% - Amplitude
        % Text
        uicontrol('Parent', mod_upanel_setup, 'style', 'text', 'String', 'Amplitude', 'HorizontalAlignment', 'left', ...
            'position', [gap, 4*(b_height+gap)+gap, text_width, b_height],...
            'tooltipstring','Amplitude of the perturbation.');
        % Field
        obj.mod_amplitude = uicontrol('Parent', mod_upanel_setup, 'style', 'edit', 'String', '', ...
            'callback',  @(a,b)  quick_model_setup('uicontrol_callback'),...
            'tag', 'mod_amplitude', 'BackgroundColor','w',...
            'position', [gap+text_width+gap, 4*(b_height+gap)+gap, field_width, b_height]);
        
        %% - Wavelength
        % Text
        uicontrol('Parent', mod_upanel_setup, 'style', 'text', 'String', 'Wavelength', 'HorizontalAlignment', 'left', ...
            'position', [gap, 3*(b_height+gap)+gap, text_width, b_height],...
            'tooltipstring','Wavelength of the perturbation.');
        % Field
        obj.mod_wavelength = uicontrol('Parent', mod_upanel_setup, 'style', 'edit', 'String', '', ...
            'callback',  @(a,b)  quick_model_setup('uicontrol_callback'),...
            'tag', 'mod_wavelength', 'BackgroundColor','w',...
            'position', [gap+text_width+gap, 3*(b_height+gap)+gap, field_width, b_height]);
        
        %% - Shift
        % Text
        uicontrol('Parent', mod_upanel_setup, 'style', 'text', 'String', 'Shift', 'HorizontalAlignment', 'left', ...
            'position', [gap, 2*(b_height+gap)+gap, text_width, b_height],...
            'tooltipstring',sprintf('Shift of the perturbation. Domain width represents the full period.'));
        % Field
        obj.mod_shift = uicontrol('Parent', mod_upanel_setup, 'style', 'edit', 'String', '', ...
            'callback',  @(a,b)  quick_model_setup('uicontrol_callback'), ...
            'tag', 'mod_shift', 'BackgroundColor','w', ...
            'position', [gap+text_width+gap, 2*(b_height+gap)+gap, field_width, b_height]);
        
        %% - Bell width
        % Text
        obj.mod_bell_width_text = uicontrol('Parent', mod_upanel_setup, 'style', 'text', 'String', 'Bell width', 'HorizontalAlignment', 'left', ...
            'position', [gap, 1*(b_height+gap)+gap, text_width, b_height],...
            'tag','mod_bell_width_text',...
            'tooltipstring',sprintf('Width of the bell-shape perturbation.'));
        % Field
        obj.mod_bell_width = uicontrol('Parent', mod_upanel_setup, 'style', 'edit', 'String', '', ...
            'callback',  @(a,b)  quick_model_setup('uicontrol_callback'), ...
            'tag', 'mod_bell_width', 'BackgroundColor','w', 'enable','off',...
            'position', [gap+text_width+gap, 1*(b_height+gap)+gap, field_width, b_height]);
        
        %% - Nx
        % Text
        uicontrol('Parent', mod_upanel_setup, 'style', 'text', 'String', 'nx', 'HorizontalAlignment', 'left', ...
            'position', [gap, 0*(b_height+gap)+gap, text_width, b_height],...
            'tooltipstring','Number nodes on the interface.');
        % Field
        obj.mod_nx = uicontrol('Parent', mod_upanel_setup, 'style', 'edit', 'String', '', ...
            'callback',  @(a,b)  quick_model_setup('uicontrol_callback'),...
            'tag', 'mod_nx', 'BackgroundColor','w', ...
            'position', [gap+text_width+gap, 0*(b_height+gap)+gap, field_width, b_height]);
        
        %% Materials
        % Text
        uicontrol('Parent', mod_upanel_materials, 'style', 'text', 'String', 'Materials', 'HorizontalAlignment', 'left', ...
            'position', [gap, 1*(b_height+gap)+gap, text_width, b_height],...
            'tooltipstring',sprintf('Material (or materials) ID number from the material table.\nIf more than one ID number is used, materials are attributed to the regions\nin the repeating sequence from bottom to top.'));
        % Field
        obj.mod_materials = uicontrol('Parent', mod_upanel_materials, 'style', 'edit', 'String', '', ...
            'callback',  @(a,b)  quick_model_setup('uicontrol_callback'), ...
            'tag', 'mod_materials', 'BackgroundColor','w', ...
            'position', [gap+text_width+gap, 1*(b_height+gap)+gap, field_width-(b_height+gap), b_height]);
        
        % Check in Table Button
        buttons = load('buttons.mat');
        %   Icon
        obj.mod_material_icon = ...
            uicontrol('Parent', mod_upanel_materials, 'style', 'pushbutton',...
            'cdata', buttons.table, 'units', 'pixels',...
            'tag', 'folder_material_icon',...
            'callback',  @(a,b) materials, ...
            'position', [fig_width-(b_height+gap), 1*(b_height+gap)+gap, b_height, b_height]);
        
        %% Triangle Area
        % Text
        uicontrol('Parent', mod_upanel_materials, 'style', 'text', 'String', 'Triangle Area', 'HorizontalAlignment', 'left', ...
            'position', [gap, 0*(b_height+gap)+gap, text_width, b_height],...
            'tooltipstring','Maximum area of the triangle mesh.');
        % Field
        obj.mod_area = uicontrol('Parent', mod_upanel_materials, 'style', 'edit', 'String', '', ...
            'callback',  @(a,b)  quick_model_setup('uicontrol_callback'), ...
            'tag', 'mod_area', 'BackgroundColor','w', ...
            'position', [gap+text_width+gap, 0*(b_height+gap)+gap, field_width, b_height]);
        
        %% -Controls
        % Apply Button
        obj.mod_apply = uicontrol('Parent', mod_upanel_controls, 'style', 'pushbutton', 'String', 'Apply',...
            'tag', 'mod_apply', ...
            'callback',  @(a,b)  quick_model_setup('mod_apply'),...
            'position', [fig_width-3*(b_width+gap), gap, b_width, b_height]);
        
        % Done Button
        obj.mod_done = uicontrol('Parent', mod_upanel_controls, 'style', 'pushbutton', 'String', 'Done',...
            'tag', 'mod_done', ...
            'callback',  @(a,b)  quick_model_setup('mod_done'),...
            'position', [fig_width-2*(b_width+gap), gap, b_width, b_height]);
        
        % Close Button
        uicontrol('Parent', mod_upanel_controls, 'style', 'pushbutton', 'String', 'Close',...
            'callback',  @(a,b)  close(gcf),...
            'position', [fig_width-1*(b_width+gap), gap, b_width, b_height]);
        
        % Store in Figure Appdata
        setappdata(quick_model_gui_handle, 'obj', obj);
        
        % - Folder Default Values
        quick_model_setup('default_values');
        
        % - Update Uicontrols
        quick_model_setup('uicontrol_update');
        
        
    case 'default_values'
        %% DEFAULT VALUES
        
        mod = [];
        
        mod.n_interface             = 4;
        mod.interface_sep           = [1 0.5 1];
        mod.pert_type               = 1;
        mod.amplitude               = 0.1;
        mod.wavelength              = 10;
        mod.shift                   = 0;
        mod.bell_width              = 1;
        mod.nx                      = 100;
        mod.materials               = [1 2];
        mod.area                    = 0.1;
        
        setappdata(quick_model_gui_handle, 'mod', mod);
        
    case 'uicontrol_callback'
        %% UICONTROL_CALLBACK
        
        % Who is calling
        wcbo            = gcbo;
        Whoiscalling    = get(wcbo, 'tag');
        
        if ~strcmpi(Whoiscalling,'mod_pert_type') && ~strcmpi(Whoiscalling,'mod_materials') && ~strcmpi(Whoiscalling,'mod_interface_sep')
            if isnan(str2double(get(gcbo,  'string')))
                warndlg('Wrong input argument.', 'Error!', 'modal');
                quick_model_setup('uicontrol_update');
                return;
            end
        end
        
        % Get data
        mod = getappdata(quick_model_gui_handle, 'mod');
        obj = getappdata(quick_model_gui_handle, 'obj');
        
        % Get fold data
        folder_gui_handle = findobj(0, 'tag', 'folder_gui_handle',        'type', 'figure');
        fold              = getappdata(folder_gui_handle, 'fold');
        
        switch Whoiscalling
            
            case 'mod_n_interfaces'

                if str2double(get(wcbo,  'string')) < 1
                    warndlg('The number must be a positive value.', 'Error!', 'modal');
                    quick_model_setup('uicontrol_update');
                    return;
                end
                if round(str2double(get(wcbo,  'string'))) ~= str2double(get(wcbo,  'string'))
                    warndlg('The number must be an integer.', 'Error!', 'modal');
                    quick_model_setup('uicontrol_update');
                    return;
                end
                
                H = str2double(get(wcbo,'string'))*mod.interface_sep;
                if H >= fold.box.height
                    warndlg('Layer package exceeds the domain size.', 'Error!', 'modal');
                    quick_model_setup('uicontrol_update');
                    return;
                end
                mod.n_interface = str2double(get(wcbo,  'string'));
                
            case 'mod_interface_sep'
                
                %temp       = regexp(get(wcbo,  'string'),['\d+\.?\d+'],'match');
                temp       = regexp(get(wcbo,  'string'), ['\d+\.?\d*'],'match');
                temp       = cellfun(@str2num,temp(:))';
                
                if min(temp) <= 0
                    warndlg('It must be a positive value.', 'Error!', 'modal');
                    quick_model_setup('uicontrol_update');
                    return;
                end
                if min(temp)+1e-2 <= mod.amplitude
                    warndlg('The interface separation must be larger than the perturbation amplitude.', 'Error!', 'modal');
                    quick_model_setup('uicontrol_update');
                    return;
                end
                
                H = repmat(temp,1,mod.n_interface);
                H = H(1:mod.n_interface-1);
                if sum(H)+2*mod.amplitude+1e-2 >= fold.box.height
                    warndlg('Layer package exceeds the domain size.', 'Error!', 'modal');
                    quick_model_setup('uicontrol_update');
                    return;
                end
                mod.interface_sep     = temp;
                
            case 'mod_pert_type'

                mod.pert_type   = get(wcbo,  'value');
                
                % Modify name
                if mod.pert_type == 4
                    set(obj.mod_bell_width_text,'String','Hurst Exponent','tooltipstring',sprintf(''))
                    % Set default value
                    mod.bell_width = 1;
                else
                    set(obj.mod_bell_width_text,'String','Bell Width','tooltipstring',sprintf('Width of the bell-shape perturbation.'))
                end
                
            case 'mod_amplitude'
                
                if str2double(get(wcbo,  'string'))-1e-2 >= 0.5*mod.interface_sep
                    warndlg('The amplitude must be smaller than half of the interface separation.', 'Error!', 'modal');
                    quick_model_setup('uicontrol_update');
                    return;
                end 
                mod.amplitude   = str2double(get(wcbo,  'string'));
                
            case 'mod_wavelength'
                
                if str2double(get(wcbo,  'string')) <= 0
                    warndlg('The wavelength must be a positive value.', 'Error!', 'modal');
                    quick_model_setup('uicontrol_update');
                    return;
                end                   
                
                mod.wavelength  = str2double(get(wcbo,  'string'));
                
            case 'mod_shift'
                
                % Check if pert shift is not outside the domain
                if str2double(get(wcbo,  'string')) < -fold.box.width/2 || str2double(get(wcbo,  'string')) > fold.box.width/2
                    warndlg('Perturabtion shift cannot exceed the domain.', 'Error!', 'modal');
                    quick_model_setup('uicontrol_update');
                    return;
                end
                
                mod.shift       = str2double(get(wcbo,  'string'));
                
            case 'mod_bell_width'
                
                % Check if the bell width is a positive value
                if str2double(get(wcbo,  'string')) <= 0
                    warndlg('The bell width must be a positive value.', 'Error!', 'modal');
                    quick_model_setup('uicontrol_update');
                    return;
                end
                mod.bell_width  = str2double(get(wcbo,  'string'));
                
            case 'mod_nx'
                
                % Check if number of points on the interface is > 2
                if str2double(get(wcbo,  'string')) < 3
                    warndlg('Number of points on the interface should be larger than 2.', 'Error!', 'modal');
                    quick_model_setup('uicontrol_update');
                    return;
                end
                mod.nx          = str2double(get(wcbo,  'string'));
                
            case 'mod_materials'
                
                materials_numbers   = regexp(get(wcbo,  'string'),['\d+'],'match');
                materials_numbers   = cellfun(@str2num,materials_numbers(:))';
                
                if sum(materials_numbers > size(fold.material_data,1))
                    warndlg('Set of materials does not exist.', 'Error!', 'modal');
                    quick_model_setup('uicontrol_update');
                    return
                end                   
                mod.materials       = materials_numbers;
                
            case 'mod_area'
                
                if str2double(get(wcbo,  'string')) <= 0
                    warndlg('The traingle area must be a positive value.', 'Error!', 'modal');
                    quick_model_setup('uicontrol_update');
                    return;
                end                   
                
                mod.area  = str2double(get(wcbo,  'string'));
        end
        
        % Update data
        setappdata(quick_model_gui_handle, 'mod', mod);
        
        % Update uicontrols
        quick_model_setup('uicontrol_update')
        
        % Buttons Enable
        quick_model_setup('buttons_enable')
        
        
    case 'uicontrol_update'
        %% UICONTROL UPDATE
        
        % Get data
        mod = getappdata(quick_model_gui_handle, 'mod');
        obj = getappdata(quick_model_gui_handle, 'obj');
        
        set(obj.mod_n_interfaces,   	'string', num2str(mod.n_interface));
        set(obj.mod_interface_sep,  	'string', num2str(mod.interface_sep));
        set(obj.mod_pert_type,          'value',  mod.pert_type);
        set(obj.mod_amplitude,          'string', num2str(mod.amplitude));
        set(obj.mod_wavelength,         'string', num2str(mod.wavelength));
        set(obj.mod_shift,              'string', num2str(mod.shift));
        set(obj.mod_bell_width,         'string', num2str(mod.bell_width));
        set(obj.mod_nx,                 'string', num2str(mod.nx));
        set(obj.mod_materials,          'string', mat2str(mod.materials));
        set(obj.mod_area,               'string', mat2str(mod.area));
        
        
    case 'buttons_enable'
        %% BUTTONS ENABLE
        
        % Get data
        obj = getappdata(quick_model_gui_handle, 'obj');
        mod = getappdata(quick_model_gui_handle, 'mod');
        
        set(obj.mod_amplitude,  	'enable', 'on');
        set(obj.mod_wavelength,   	'enable', 'on');
        set(obj.mod_shift,          'enable', 'on');
        set(obj.mod_bell_width,   	'enable', 'on');
        set(obj.mod_nx,           	'enable', 'on');
        set(obj.mod_materials,     	'enable', 'on');
                    
        if mod.pert_type == 1
            set(obj.mod_bell_width,     'enable', 'off');
        elseif mod.pert_type == 2 || mod.pert_type == 3
            set(obj.mod_wavelength,   	'enable', 'off');
            set(obj.mod_shift,          'enable', 'off');
            set(obj.mod_bell_width,     'enable', 'off');
        elseif mod.pert_type == 4
            set(obj.mod_shift,          'enable', 'off');
        elseif mod.pert_type == 5
            set(obj.mod_wavelength,   	'enable', 'off');
            set(obj.mod_bell_width,     'enable', 'off');
        elseif mod.pert_type == 6
            set(obj.mod_bell_width,     'enable', 'off');
        elseif mod.pert_type == 7
            set(obj.mod_wavelength,   	'enable', 'off');
        elseif  mod.pert_type > 7
            set(obj.mod_wavelength,    	'enable', 'off');
            set(obj.mod_shift,          'enable', 'off');
            set(obj.mod_bell_width,     'enable', 'off');
            set(obj.mod_nx,             'enable', 'off');
        end
        
    case 'mod_apply'
        %% APPLY
        
        % Get data
        mod = getappdata(quick_model_gui_handle, 'mod');
        
        % Find main gui
        folder_gui_handle = findobj(0, 'tag', 'folder_gui_handle', 'type', 'figure');
        
        if ~isempty(folder_gui_handle)
            
            % Get data
            fold  = getappdata(folder_gui_handle, 'fold');
            fold = rmfield(fold,'face');
            fold = rmfield(fold,'region');
            
            material     = repmat(mod.materials,1,ceil((mod.n_interface+1)/length(mod.materials)));
            
            % Interface
            sep_seq = repmat(mod.interface_sep,1,mod.n_interface);
            sep_seq = sep_seq(1:mod.n_interface-1);
            yy = -sum(sep_seq)/2+[0 cumsum(sep_seq)];
            
            for ii = 1:mod.n_interface
                fold.face(ii).y                 = yy(ii);
                fold.face(ii).pert              = mod.pert_type;
                fold.face(ii).ampl              = mod.amplitude;
                fold.face(ii).wave              = mod.wavelength;
                fold.face(ii).shift             = mod.shift;
                fold.face(ii).width             = mod.bell_width;
                fold.face(ii).nx                = mod.nx;
            end
            
            % Region
            for ii = 1:mod.n_interface+1
                fold.region(ii).area            = mod.area;
                fold.region(ii).material        = material(ii);
            end
            
            % Update data
            setappdata(folder_gui_handle, 'fold', fold);
            
            try
                folder('uicontrol_callback')
            catch err
                errordlg(err.message)
                return;
            end
            
        end
        
    case 'mod_done'
        %% DONE
        
        % Apply changes
        quick_model_setup('mod_apply')
        
        % Close figure
        close(quick_model_gui_handle);
        
end