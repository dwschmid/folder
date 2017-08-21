function new_material(Action)

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
new_material_gui_handle = findobj(0, 'tag', 'new_material_gui_handle', 'type', 'figure');

switch lower(Action)
    case 'initialize'
        %% INITIALIZE
        
        %  Delete figure if it already exists
        if ~isempty(new_material_gui_handle)
            delete(new_material_gui_handle);
        end
        
        % - Create gui
        new_material('create_gui');
        
        % Set gui name
        new_material_gui_handle = findobj(0, 'tag', 'new_material_gui_handle', 'type', 'figure');
        set(new_material_gui_handle,'Name','New Material');
        
        % - Folder Default Values
        new_material('default_values');
        
        % - Update Uicontrols
        new_material('uicontrol_update');
        
        % - Buttons enable
        new_material('buttons_enable');
        
        
    case 'modify'  
        %% MODIFY
        
        %  Delete figure if it already exists
        if ~isempty(new_material_gui_handle)
            delete(new_material_gui_handle);
        end
        
        % - Create gui
        new_material('create_gui');
        
        % Set gui name
        new_material_gui_handle = findobj(0, 'tag', 'new_material_gui_handle', 'type', 'figure');
        set(new_material_gui_handle,'Name','Modify Material');
        
        % Modify tag pf the Add button
        new_upanel_app = findobj(new_material_gui_handle,'tag','new_upanel_app');
        set(findobj(new_upanel_app,'tag','new_add'),'String','Modify')
        set(findobj(new_upanel_app,'tag','new_add'),'tag','new_modify')
        
        % - Read modified data
        new_material('modified_values')

        % - Update Uicontrols
        new_material('uicontrol_update');
        
        % - Buttons enable
        new_material('buttons_enable')
        
    case 'create_gui'
        %% CREATE GUI
        Screensize      = get(0, 'ScreenSize');
        
        % Create dialog window
        new_material_gui_handle = figure( ...
            'Units','pixels', 'tag','new_material_gui_handle',...
            'NumberTitle', 'off', 'DockControls', 'off', 'MenuBar', 'none', 'ToolBar', 'none',...
            'Resize','off',...
            'pos', [Screensize(3)/5, Screensize(4)/2, 200, 200], 'Color',get(0, 'DefaultUipanelBackgroundColor'));
        
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
        
        text_width      = 2.8*b_width;
        field_width     = 2.8*b_width;
        fig_width       = text_width+field_width+2*gap;
        fig_height      = 10*(b_height+gap)+3*gap;
        
        % Modify figure width
        set(new_material_gui_handle,'pos',[Screensize(3)/5, Screensize(4)/2, fig_width, fig_height])
        
        mod_height = 1*(b_height+gap)+gap;
        vis_height = 8*(b_height+gap)+gap;
        app_height = 1*(b_height+gap)+gap;
        
        b1                      = uiextras.VBox('Parent', new_material_gui_handle);
        new_upanel_mod          = uibuttongroup('Parent', b1,'Tag','new_upanel_mod');
        new_upanel_vis          = uipanel('Parent', b1, 'Tag','new_upanel_vis');
        new_upanel_app          = uipanel('Parent', b1, 'Tag','new_upanel_app');
        set( b1, 'Sizes', [-mod_height -vis_height -app_height]);
        
        
        %% Mode panel
        uicontrol('Parent', new_upanel_mod, 'style', 'radiobutton', 'String', 'm + n', 'tag','Rn',...
            'tooltipstring','Set flow law using viscosity and power-law exponent parameters.',...
            'position', [gap, gap, text_width, b_height]);
        uicontrol('Parent', new_upanel_mod, 'style', 'radiobutton', 'String', 'n + Q + A', 'tag','nQAT',...
            'tooltipstring','Set flow law using power-law exponent, activation energy, pre-exponential parameter, and temperature paraemters.',...
            'position', [gap+text_width, gap, field_width, b_height]);
        set(new_upanel_mod,'SelectionChangeFcn',@(a,b)  new_material('buttons_enable'));
        
        %% Name panel
        % Text
        uicontrol('Parent', new_upanel_vis, 'style', 'text', 'String', 'Name', 'HorizontalAlignment', 'left',...
            'position', [gap, 7*(b_height+gap)+gap, text_width, b_height]);
        % Field
        uicontrol('Parent', new_upanel_vis, 'style', 'edit', 'String', '', 'BackgroundColor','w',...
            'callback',  @(a,b)  new_material('uicontrol_callback'),...
            'tag', 'new_name', ...
            'position', [gap+text_width, 7*(b_height+gap)+gap, field_width, b_height]);
        
        %% Choice panel
        % VISCOSITY RATIO
        % Text
        uicontrol('Parent', new_upanel_vis, 'style', 'text', 'String', 'm (Apparent Background Viscosity)','HorizontalAlignment', 'left', ...
            'position', [gap, 6*(b_height+gap)+gap, text_width, b_height]);
        % Field
        uicontrol('Parent', new_upanel_vis, 'style', 'edit', 'String', '', 'BackgroundColor','w',...
            'callback',  @(a,b)  new_material('uicontrol_callback'),...
            'tag', 'new_vis', ...
            'position', [gap+text_width, 6*(b_height+gap)+gap, field_width, b_height]);
        
        % Text
        uicontrol('Parent', new_upanel_vis, 'style', 'text', 'String', 'm_0/m (Viscosity at Zero Shear Rate)','HorizontalAlignment', 'left', ...
            'position', [gap, 5*(b_height+gap)+gap, text_width, b_height]);
        % Field
        uicontrol('Parent', new_upanel_vis, 'style', 'edit', 'String', '', 'BackgroundColor','w',...
            'callback',  @(a,b)  new_material('uicontrol_callback'),...
            'tag', 'new_vis0', ...
            'position', [gap+text_width, 5*(b_height+gap)+gap, field_width, b_height]);
        
        % Text
        uicontrol('Parent', new_upanel_vis, 'style', 'text', 'String', 'm_inf/m (Viscosity at Infinite Shear Rate)','HorizontalAlignment', 'left', ...
            'position', [gap, 4*(b_height+gap)+gap, text_width, b_height]);
        % Field
        uicontrol('Parent', new_upanel_vis, 'style', 'edit', 'String', '', 'BackgroundColor','w',...
            'callback',  @(a,b)  new_material('uicontrol_callback'),...
            'tag', 'new_visINF', ...
            'position', [gap+text_width, 4*(b_height+gap)+gap, field_width, b_height]);
        
        % STRESS EXPONENT
        % Text
        uicontrol('Parent', new_upanel_vis, 'style', 'text', 'String', 'n (Stress Exponent)', 'HorizontalAlignment', 'left',...
            'position', [gap, 3*(b_height+gap)+gap, text_width, b_height]);
        % Field
        uicontrol('Parent', new_upanel_vis, 'style', 'edit', 'String', '', 'BackgroundColor','w',...
            'callback',  @(a,b)  new_material('uicontrol_callback'),...
            'tag', 'new_stress', ...
            'position', [gap+text_width, 3*(b_height+gap)+gap, field_width, b_height]);
        
        % Q
        % Text
        uicontrol('Parent', new_upanel_vis, 'style', 'text', 'String', 'Q (Activation Energy)', 'HorizontalAlignment', 'left',...
            'position', [gap, 2*(b_height+gap)+gap, text_width, b_height]);
        % Field
        uicontrol('Parent', new_upanel_vis, 'style', 'edit', 'String', '', 'BackgroundColor','w',...
            'callback',  @(a,b)  new_material('uicontrol_callback'),...
            'tag', 'new_Q', ...
            'position', [gap+text_width, 2*(b_height+gap)+gap, field_width, b_height]);
        
        % A
        % Text
        uicontrol('Parent', new_upanel_vis, 'style', 'text', 'String', 'A (Pre-exponential Parameter)', 'HorizontalAlignment', 'left',...
            'position', [gap, 1*(b_height+gap)+gap, text_width, b_height]);
        % Field
        uicontrol('Parent', new_upanel_vis, 'style', 'edit', 'String', '', 'BackgroundColor','w',...
            'callback',  @(a,b)  new_material('uicontrol_callback'),...
            'tag', 'new_A', ...
            'position', [gap+text_width, 1*(b_height+gap)+gap, field_width, b_height]);
        
        % Remarks
        % Text
        uicontrol('Parent', new_upanel_vis, 'style', 'text', 'String', 'Remarks','HorizontalAlignment', 'left', ...
            'position', [gap, gap, text_width, b_height]);
        % Field
        uicontrol('Parent', new_upanel_vis, 'style', 'edit', 'String', '', 'BackgroundColor','w',...
            'callback',  @(a,b)  new_material('uicontrol_callback'),...
            'tag', 'new_remarks', ...
            'position', [gap+text_width, gap, field_width, b_height]);
        
        
        %% Done & Cancel panel
        % Done Button
        uicontrol('Parent', new_upanel_app, 'style', 'pushbutton', 'String', 'Add',...
            'tag', 'new_add', ...
            'callback',  @(a,b)  new_material('uicontrol_callback'),...
            'position', [fig_width-2*(b_width+gap), gap, b_width, b_height]);
        
        % Cancel Button
        uicontrol('Parent', new_upanel_app, 'style', 'pushbutton', 'String', 'Cancel',...
            'tag', 'new_cancel', ...
            'callback',  @(a,b)  new_material('uicontrol_callback'),...
            'position', [fig_width-(b_width+gap), gap, b_width, b_height]);
        
     
    case 'default_values'
        %% Default values
        
        new.name    = '';
        new.vis     = [];
        new.vis0    = [];
        new.visINF  = [];
        new.n       = [];
        new.Q       = [];
        new.A       = [];
        new.col     = [1 1 1];
        new.info    = '';
        
        setappdata(new_material_gui_handle, 'new', new);
        
    case 'modified_values'
        %% Modified values
        materials_gui_handle = findobj(0, 'tag', 'materials_gui_handle', 'type', 'figure');
        
        rheology = getappdata(materials_gui_handle, 'rheology');
        
        new.name    = rheology.data{rheology.line,2};
        new.vis     = rheology.data{rheology.line,3};
        new.vis0    = rheology.data{rheology.line,4};
        new.visINF  = rheology.data{rheology.line,5};
        new.n       = rheology.data{rheology.line,6};
        new.Q       = rheology.data{rheology.line,7};
        new.A       = rheology.data{rheology.line,8};
        new.col     = rheology.data{rheology.line,9};
        new.info    = rheology.data{rheology.line,10};
        new.line    = rheology.line;
        
        % Setup data
        setappdata(new_material_gui_handle, 'new', new);
        
        % Mark proper mode
        flag = isempty(new.Q);
        if flag
            set(findobj(new_material_gui_handle, 'tag','Rn'),  'Value',1)
            set(findobj(new_material_gui_handle, 'tag','nQAT'),'Value',0)
        else
            set(findobj(new_material_gui_handle, 'tag','Rn'),  'Value',0)
            set(findobj(new_material_gui_handle, 'tag','nQAT'),'Value',1)
        end
        
        
    case 'uicontrol_update'
        %% Update Uicontrols
        
        new = getappdata(new_material_gui_handle, 'new');
        
        set(findobj(new_material_gui_handle, 'tag', 'new_name'),   	'string', new.name);
        set(findobj(new_material_gui_handle, 'tag', 'new_vis'),   	'string', num2str(new.vis));
        set(findobj(new_material_gui_handle, 'tag', 'new_vis0'),   	'string', num2str(new.vis0));
        set(findobj(new_material_gui_handle, 'tag', 'new_visINF'), 	'string', num2str(new.visINF));
        set(findobj(new_material_gui_handle, 'tag', 'new_stress'), 	'string', num2str(new.n));
        set(findobj(new_material_gui_handle, 'tag', 'new_Q'),       'string', num2str(new.Q));
        set(findobj(new_material_gui_handle, 'tag', 'new_A'),     	'string', num2str(new.A));
        set(findobj(new_material_gui_handle, 'tag', 'new_remarks'), 'string', num2str(new.info));
        
        
    case 'uicontrol_callback'
        %% Uicontrol callback
        
        % Who is calling
        wcbo            = gcbo;
        Whoiscalling    = get(wcbo, 'tag');
        
        % Get data
        new = getappdata(new_material_gui_handle, 'new');
        
        
        switch Whoiscalling 
              
            case 'new_name'
                new.name    = get(gcbo,  'string');
                
            case 'new_vis'
                if ~isnan(str2double(get(wcbo,  'string')))
                    new.vis   	= str2double(get(gcbo,  'string'));
                else
                    new.vis     = [];
                end
                
            case 'new_vis0'
                if ~isnan(str2double(get(wcbo,  'string')))
                    new.vis0   	= str2double(get(gcbo,  'string'));
                else
                    new.vis0    = [];
                end
            
            case 'new_visINF'
                if ~isnan(str2double(get(wcbo,  'string')))
                    new.visINF   = str2double(get(gcbo,  'string'));
                else
                    new.visINF   = [];
                end
                
            case 'new_stress'
                if ~isnan(str2double(get(wcbo,  'string')))
                    new.n       = str2double(get(wcbo,  'string'));
                else
                    new.n       = [];
                end
                
            case 'new_Q'
                if ~isnan(str2double(get(wcbo,  'string')))
                    new.Q       = str2double(get(gcbo,  'string'));
                else
                    new.Q       = [];
                end
                
            case 'new_A'
                if ~isnan(str2double(get(wcbo,  'string')))
                    new.A       = str2double(get(gcbo,  'string'));
                else
                    new.A       = [];
                end
                
            case 'new_remarks'
                new.info    = get(gcbo,  'string');
            
            case 'new_add'
                
                % Get data
                flag  = get(findobj(new_material_gui_handle, 'tag','Rn'),'Value');
                
                Name = get(findobj(new_material_gui_handle, 'tag', 'new_name'),'string');
                R = get(findobj(new_material_gui_handle, 'tag', 'new_vis'),'string');
                R0 = get(findobj(new_material_gui_handle, 'tag', 'new_vis0'),'string');
                RINF = get(findobj(new_material_gui_handle, 'tag', 'new_visINF'),'string');
                n = get(findobj(new_material_gui_handle, 'tag', 'new_stress'),'string');
                Q = get(findobj(new_material_gui_handle, 'tag', 'new_Q'),'string');
                A = get(findobj(new_material_gui_handle, 'tag', 'new_A'),'string');
                
                if flag
                    if isempty(Name)
                        warndlg('Name is missing.', 'Error!', 'modal');
                        return;
                    elseif isempty(R)
                        warndlg('Viscosity value is missing.', 'Error!', 'modal');
                        return;
                    elseif isempty(R0)
                        warndlg('Viscosity value is missing.', 'Error!', 'modal');
                        return;
                    elseif isempty(RINF)
                        warndlg('Viscosity value is missing.', 'Error!', 'modal');
                        return;
                    elseif isempty(n)
                        warndlg('Stress value is missing.', 'Error!', 'modal');
                        return;
                    end
                else
                    if isempty(Name)
                        warndlg('Name is missing.', 'Error!', 'modal');
                        return;
                    elseif isempty(R0)
                        warndlg('Viscosity value is missing.', 'Error!', 'modal');
                        return;
                    elseif isempty(RINF)
                        warndlg('Viscosity value is missing.', 'Error!', 'modal');
                        return;    
                    elseif isempty(n)
                        warndlg('Stress value is missing.', 'Error!', 'modal');
                        return;
                    elseif isempty(Q)
                        warndlg('Activation energy value is missing.', 'Error!', 'modal');
                        return;
                    elseif isempty(A)
                        warndlg('Pre-exponential factor is missing.', 'Error!', 'modal');
                        return;
                    end
                end
                
                % find materials gui
                materials_gui_handle = findobj(0, 'tag', 'materials_gui_handle', 'type', 'figure');
                
                % Get data
                rheology  = getappdata(materials_gui_handle, 'rheology');
                data      = rheology.data;
                
                ii = size(data,1)+1;
                data{ii,1}  = num2str(ii);
                data{ii,2}  = new.name;
                data{ii,3}  = num2str(new.vis);
                data{ii,4}  = num2str(new.vis0);
                data{ii,5}  = num2str(new.visINF);
                data{ii,6}  = num2str(new.n);
                data{ii,7}  = num2str(new.Q);
                data{ii,8}  = num2str(new.A);
                data{ii,9}  = new.col;
                data{ii,10} = new.info;
                
                rheology.data = data;
                
                % Update data
                setappdata(materials_gui_handle, 'rheology', rheology);
                
                %try
                    materials('update_table')
                %catch
                %    errordlg('Main figure gone.');
                %end
                
                delete(new_material_gui_handle);
                return;
                
            case 'new_modify'
                
                % Get data
                flag  = get(findobj(new_material_gui_handle, 'tag','Rn'),'Value');
                
                Name = get(findobj(new_material_gui_handle, 'tag', 'new_name'),'string');
                R    = get(findobj(new_material_gui_handle, 'tag', 'new_vis'),'string');
                R0   = get(findobj(new_material_gui_handle, 'tag', 'new_vis0'),'string');
                RINF = get(findobj(new_material_gui_handle, 'tag', 'new_visINF'),'string');
                n    = get(findobj(new_material_gui_handle, 'tag', 'new_stress'),'string');
                Q    = get(findobj(new_material_gui_handle, 'tag', 'new_Q'),'string');
                A    = get(findobj(new_material_gui_handle, 'tag', 'new_A'),'string');
                Info = get(findobj(new_material_gui_handle, 'tag', 'new_remarks'),'string');
                
                if flag
                    if isempty(Name)
                        warndlg('Name is missing.', 'Error!', 'modal');
                        return;
                    elseif isempty(R)
                        warndlg('Viscosity value is missing.', 'Error!', 'modal');
                        return;
                    elseif isempty(R0)
                        warndlg('Viscosity value is missing.', 'Error!', 'modal');
                        return;
                    elseif isempty(RINF)
                        warndlg('Viscosity value is missing.', 'Error!', 'modal');
                        return;
                    elseif isempty(n)
                        warndlg('Stress value is missing.', 'Error!', 'modal');
                        return;
                    end
                else
                    if isempty(Name)
                        warndlg('Name is missing.', 'Error!', 'modal');
                        return;
                    elseif isempty(n)
                        warndlg('Stress value is missing.', 'Error!', 'modal');
                        return;
                    elseif isempty(Q)
                        warndlg('Activation energy value is missing.', 'Error!', 'modal');
                        return;
                    elseif isempty(A)
                        warndlg('Pre-exponential factor is missing.', 'Error!', 'modal');
                        return;
                    end
                end
                
                % Find materials gui
                materials_gui_handle = findobj(0, 'tag', 'materials_gui_handle', 'type', 'figure');
                    
                % Get data
                rheology  = getappdata(materials_gui_handle, 'rheology');
                data      = rheology.data;
                line      = rheology.line;
                
                data{line,1}  = data{line,1};
                data{line,2}  = new.name;
                data{line,3}  = num2str(new.vis);
                data{line,4}  = num2str(new.vis0);
                data{line,5}  = num2str(new.visINF);
                data{line,6}  = num2str(new.n);
                data{line,7}  = num2str(new.Q);
                data{line,8}  = num2str(new.A);
                data{line,10} = new.info;
                
                rheology.data = data;
                
                % Update data
                setappdata(materials_gui_handle, 'rheology', rheology);
                
                try
                    materials('update_table')
                catch
                    errordlg('Main figure gone.');
                end
                
                delete(new_material_gui_handle);
                return;
            
            case 'new_cancel'
                delete(new_material_gui_handle);
                return;
                
        end
        
        % - Update data
        setappdata(new_material_gui_handle, 'new', new);
        
        % - Update Uicontrols
        new_material('uicontrol_update');
               
    
    case 'buttons_enable'
        %% Buttons enable
        
        new = getappdata(new_material_gui_handle, 'new');
        
        % Get data       
        flag = get(findobj(new_material_gui_handle, 'tag','Rn'),'Value');
        
        if flag
            
            % Clear fields
            new.Q = [];
            new.A = [];
            
            % - Update data
            setappdata(new_material_gui_handle, 'new', new);
            
            % - Update Uicontrols
            new_material('uicontrol_update');
            
            % Disable
            set(findobj(new_material_gui_handle, 'tag', 'new_Q'), 'enable', 'off');
            set(findobj(new_material_gui_handle, 'tag', 'new_A'), 'enable', 'off');
            
            % Enable
            set(findobj(new_material_gui_handle, 'tag', 'new_vis'), 'enable', 'on');
            
        else
            
            % Clear fields
            new.vis = [];
            
            % - Update data
            setappdata(new_material_gui_handle, 'new', new);
            
            % - Update Uicontrols
            new_material('uicontrol_update');
            
            % Enable
            set(findobj(new_material_gui_handle, 'tag', 'new_Q'), 'enable', 'on');
            set(findobj(new_material_gui_handle, 'tag', 'new_A'), 'enable', 'on');
            
            % Disable
            set(findobj(new_material_gui_handle, 'tag', 'new_vis'), 'enable', 'off');
        end
         
end
end


