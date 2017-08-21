function vector_setting(Action)

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
vector_gui_handle = findobj(0, 'tag', 'vector_gui_handle', 'type', 'figure');

switch lower(Action)
    case 'initialize'
        
        %  Delete figure if it already exists
        if ~isempty(vector_gui_handle)
            delete(vector_gui_handle);
        end
        
        %% Initialize
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
        text_width      = 2*b_width;
        field_width     = 2*b_width+gap;
        
        fig_width       = text_width+field_width+3*gap;
        fig_height      = 7*(b_height+gap)+2*gap;
        
        % Create dialog window
        vector_gui_handle = figure( ...
            'Name' ,'Vector Plotting Options', 'Units','pixels', 'tag','vector_gui_handle',...
            'NumberTitle', 'off', 'DockControls', 'off', 'MenuBar', 'none', 'ToolBar', 'none',...
            'Resize','off',...
            'pos', [Screensize(3)/5, (Screensize(4)-fig_height)/2, fig_width, fig_height], 'Color',get(0, 'DefaultUipanelBackgroundColor'));
                
        % Vector
        vector_upanel       = uiextras.VBox('Parent', vector_gui_handle);
        vector_upanel_span 	= uipanel('Parent', vector_upanel, 'Tag','vector_upanel_span','Title', '');
        vector_upanel_apply = uipanel('Parent', vector_upanel, 'Tag','vector_upanel_apply','Title', '');
        span_height      	= 6*(b_height+gap)+1*gap;
        apply_height    	= 1*(b_height+gap)+1*gap;
        set( vector_upanel, 'Sizes', [span_height apply_height]);
        
        
        %% - Span
        % x-grid Points 
        uicontrol('Parent', vector_upanel_span, 'style', 'text', 'String', 'x-grid Points', 'HorizontalAlignment', 'left',...
            'position', [gap, 5*(b_height+gap)+gap, text_width, b_height],...
            'tooltipstring','Number of arrows plotted in the horizontal direction.');
        % Field
        obj.vector_x_density = uicontrol('Parent', vector_upanel_span, 'style', 'edit', 'String', '', 'BackgroundColor','w',...
            'callback',  @(a,b)  vector_setting('uicontrol_callback'),...
            'tag', 'vector_x_density', ...
            'position', [gap+text_width+gap, 5*(b_height+gap)+gap, field_width, b_height]);
        
        % x-grid Span
        obj.vector_x_span = uicontrol('Parent', vector_upanel_span, 'style', 'checkbox', 'String', 'x-grid Span', 'HorizontalAlignment', 'left',...
            'position', [gap, 4*(b_height+gap)+2*gap, text_width, b_height],...
            'callback',  @(a,b)  vector_setting('uicontrol_callback'),...
            'tag','vector_x_span',...
            'tooltipstring','Arrow span in the horizontal direction.');
        % Field
        obj.vector_xmin = uicontrol('Parent', vector_upanel_span, 'style', 'edit', 'String', 'xmin', 'BackgroundColor','w',...
            'callback',  @(a,b)  vector_setting('uicontrol_callback'),...
            'tag', 'vector_xmin', ...
            'position', [2*(b_width+gap), 4*(b_height+gap)+gap, b_width, b_height]);
        % Field
        obj.vector_xmax = uicontrol('Parent', vector_upanel_span, 'style', 'edit', 'String', 'xmax', 'BackgroundColor','w',...
            'callback',  @(a,b)  vector_setting('uicontrol_callback'),...
            'tag', 'vector_xmax', ...
            'position', [3*(b_width+gap), 4*(b_height+gap)+gap, b_width, b_height]);
        
        % Irregular case
        obj.vector_irregular = uicontrol('Parent', vector_upanel_span, 'style', 'checkbox', 'String', 'Irregular Grid', 'HorizontalAlignment', 'left',...
            'position', [gap, 3*(b_height+gap)+2*gap, text_width, b_height],...
            'callback',  @(a,b)  vector_setting('uicontrol_callback'),...
            'tag','vector_irregular',...
            'tooltipstring','Different arrow spacing in vertical direction.');
        
        % y-grid Points 
        uicontrol('Parent', vector_upanel_span, 'style', 'text', 'String', 'y-grid Points', 'HorizontalAlignment', 'left',...
            'position', [gap, 2*(b_height+gap)+gap, text_width, b_height],...
            'tooltipstring','Number of vectors plotted in the vertical direction.');
        % Field
        obj.vector_y_density = uicontrol('Parent', vector_upanel_span, 'style', 'edit', 'String', '', 'BackgroundColor','w',...
            'callback',  @(a,b)  vector_setting('uicontrol_callback'),...
            'tag', 'vector_y_density', ...
            'position', [gap+text_width+gap, 2*(b_height+gap)+gap, field_width, b_height]);
        
        % y-grid Span
        obj.vector_y_span = uicontrol('Parent', vector_upanel_span, 'style', 'checkbox', 'String', 'y-grid Span', 'HorizontalAlignment', 'left',...
            'position', [gap, 1*(b_height+gap)+2*gap, text_width, b_height],...
            'callback',  @(a,b)  vector_setting('uicontrol_callback'),...
            'tag','vector_y_span',...
            'tooltipstring','Arrow span in the vertical direction.');
        % Field
        obj.vector_ymin = uicontrol('Parent', vector_upanel_span, 'style', 'edit', 'String', 'ymin', 'BackgroundColor','w',...
            'callback',  @(a,b)  vector_setting('uicontrol_callback'),...
            'tag', 'vector_ymin', ...
            'position', [2*(b_width+gap), 1*(b_height+gap)+gap, b_width, b_height]);
        % Field
        obj.vector_ymax = uicontrol('Parent', vector_upanel_span, 'style', 'edit', 'String', 'ymax', 'BackgroundColor','w',...
            'callback',  @(a,b)  vector_setting('uicontrol_callback'),...
            'tag', 'vector_ymax', ...
            'position', [3*(b_width+gap), 1*(b_height+gap)+gap, b_width, b_height]);
        
        % Colours
        uicontrol('Parent', vector_upanel_span, 'style', 'pushbutton', 'String', 'Colours',...
            'callback',  @(a,b) setting,...
            'position', [fig_width-(b_width+gap), gap, b_width, b_height]);
        
        %% - Apply & Done & Cancel
        % Apply Button
        obj.vector_apply = uicontrol('Parent', vector_upanel_apply, 'style', 'pushbutton', 'String', 'Apply',...
            'tag', 'vector_apply', ...
            'callback',  @(a,b)  vector_setting('vector_apply'),...
            'position', [fig_width-3*(b_width+gap), gap, b_width, b_height]);
        
        % Done Button
        obj.vector_done = uicontrol('Parent', vector_upanel_apply, 'style', 'pushbutton', 'String', 'Done',...
            'tag', 'vector_done', ...
            'callback',  @(a,b)  vector_setting('vector_done'),...
            'position', [fig_width-2*(b_width+gap), gap, b_width, b_height]);
        
        % Cancel Button
        uicontrol('Parent', vector_upanel_apply, 'style', 'pushbutton', 'String', 'Close',...
            'tag', 'vector_cancel', ...
            'callback',  @(a,b) close(gcf),...
            'position', [fig_width-(b_width+gap), gap, b_width, b_height]);
        
        % Store in Figure Appdata
        setappdata(vector_gui_handle, 'obj', obj);
        
        % - Folder Default Values
        vector_setting('default_values');
        
        % - Update Uicontrols
        vector_setting('uicontrol_update');
        
        % - Enable buttons
        vector_setting('buttons_enable');
        
        
    case 'default_values'
        %% Default values
        
        folder_gui_handle = findobj(0, 'tag', 'folder_gui_handle',        'type', 'figure');
        
        if ~isempty(folder_gui_handle)
            
            fold    = getappdata(folder_gui_handle, 'fold');
                  
            vector.x_density = fold.vector.x_density;
            vector.x_span    = fold.vector.x_span;
            vector.xmin      = fold.vector.xmin;
            vector.xmax      = fold.vector.xmax;
            vector.irregular = fold.vector.irregular;
            vector.y_density = fold.vector.y_density;
            vector.y_span    = fold.vector.y_span;
            vector.ymin      = fold.vector.ymin;
            vector.ymax      = fold.vector.ymax;
            
        end
        
        setappdata(vector_gui_handle, 'vector', vector);
        
    case 'uicontrol_update'
        %% Update Uicontrols
        
        % Get data
        obj    = getappdata(vector_gui_handle, 'obj');
        vector = getappdata(vector_gui_handle, 'vector');
        
        set(obj.vector_x_density,     'string', num2str(vector.x_density));
        set(obj.vector_x_span,        'value',  vector.x_span);
        
        if ~isempty(vector.xmin)
            set(obj.vector_xmin,      'string', num2str(vector.xmin));
            set(obj.vector_xmax,      'string', num2str(vector.xmax));
        else
            set(obj.vector_xmin,      'string', 'xmin');
            set(obj.vector_xmax,      'string', 'xmax');
        end
        set(obj.vector_irregular,     'value',  vector.irregular);
        set(obj.vector_y_density,     'string', num2str(vector.y_density));
        set(obj.vector_y_span,        'value',  vector.y_span);
        if ~isempty(vector.ymin)
            set(obj.vector_ymin,      'string', num2str(vector.ymin));
            set(obj.vector_ymax,      'string', num2str(vector.ymax));
        else
            set(obj.vector_ymin,      'string', 'ymin');
            set(obj.vector_ymax,      'string', 'ymax');
        end
        
    case 'buttons_enable'
        %% Buttons enable
        
        % Get data
        obj    = getappdata(vector_gui_handle, 'obj');
        vector = getappdata(vector_gui_handle, 'vector');
                        
        % Switch on quiver options only when fold run data exist
        % Find other gui
        folder_gui_handle = findobj(0, 'tag', 'folder_gui_handle',        'type', 'figure');
        try      
            %  Get fold data
            fold        = getappdata(folder_gui_handle, 'fold');
            
            if isfield(fold, 'NODES_run')
                
                set(obj.vector_x_density,     'enable', 'on');
                set(obj.vector_x_span,        'enable', 'on');
                set(obj.vector_irregular,     'enable', 'on');
                
                if get(obj.vector_irregular, 'value') == 1
                    set(obj.vector_y_density, 'enable', 'on');
                else
                    set(obj.vector_y_density, 'enable', 'off');
                end
                
                set(obj.vector_y_span,        'enable', 'on');
                % quiver_x_span
                if vector.x_span == 1
                    set(obj.vector_xmin,    	'enable', 'on');
                    set(obj.vector_xmax,    	'enable', 'on');
                else
                    set(obj.vector_xmin,    	'enable', 'off');
                    set(obj.vector_xmax,    	'enable', 'off');
                end
                % quiver_y_span
                if vector.y_span == 1
                    set(obj.vector_ymin,    	'enable', 'on');
                    set(obj.vector_ymax,    	'enable', 'on');
                else
                    set(obj.vector_ymin,    	'enable', 'off');
                    set(obj.vector_ymax,    	'enable', 'off');
                end
                
            end 
        catch
            
            set(obj.vector_x_density,     'enable', 'off');
            set(obj.vector_x_span,        'enable', 'off');
            set(obj.vector_xmin,          'enable', 'off');
            set(obj.vector_xmax,          'enable', 'off');
            set(obj.vector_irregular,     'enable', 'off');
            set(obj.vector_y_density,     'enable', 'off');
            set(obj.vector_y_span,        'enable', 'off');
            set(obj.vector_ymin,          'enable', 'off');
            set(obj.vector_ymax,          'enable', 'off');
            
        end
        
    case 'uicontrol_callback'
        %% Uicontrol callback
        
        % Who is calling
        wcbo            = gcbo;
        Whoiscalling    = get(wcbo, 'tag');
        
        % Get data
        vector = getappdata(vector_gui_handle, 'vector');
            
        switch Whoiscalling
                
            case 'vector_x_density'
                
                if str2double(get(wcbo,  'string')) > 2
                    
                    if mod(str2double(get(wcbo,  'string')),1)==0
                        vector.x_density = str2double(get(wcbo,  'string'));
                    else
                        errordlg('The value should be an integer.');
                    end
                else
                    errordlg('The value should be larger than 2.');
                end
           
            case 'vector_x_span'
                vector.x_span 	= get(wcbo,  'value');
                
                %Get data from other gui
                folder_gui_handle = findobj(0, 'tag', 'folder_gui_handle',        'type', 'figure');
                
                if vector.x_span == 1
                    % Set values to the min & max of the box size
                    try
                        fold        = getappdata(folder_gui_handle, 'fold');
                        vector.xmin = fold.NODES(1,1);
                        vector.xmax = fold.NODES(1,2);
                    end
                else
                    vector.xmin = [];
                    vector.xmax = [];
                end
            
            case 'vector_xmin'
                
                if str2double(get(wcbo,  'string')) < vector.xmax
                    vector.xmin    = str2double(get(wcbo,  'string'));
                else
                    errordlg('The value should be smaller than xmax.');
                end
                
            case 'vector_xmax'
                
                if str2double(get(wcbo,  'string')) > vector.xmin
                    vector.xmax    = str2double(get(wcbo,  'string'));
                else
                    errordlg('The value should be larger than xmin.');
                end
                
            case 'vector_irregular'
                vector.irregular   = get(wcbo,  'value');
                
                folder_gui_handle = findobj(0, 'tag', 'folder_gui_handle',        'type', 'figure');
                
                if vector.irregular == 1 && isempty(vector.y_density)
                    
                    try
                        fold    = getappdata(folder_gui_handle, 'fold');
                        
                        x       = linspace(fold.NODES_run(1,fold.num.it),fold.NODES_run(3,fold.num.it),fold.vector.x_density);
                        dx      = x(2)-x(1);
                        
                        if isempty(vector.ymin)
                            vector.y_density = ceil(-2*min(fold.MESH.NODES(2,:))/dx);
                        else
                            vector.y_density = ceil((fold.vector.ymax-fold.vector.ymin)/dx);
                        end
                        
                    catch
                        vector.y_density = 20;
                    end
                end
                 
                if vector.irregular == 0
                    vector.y_density  = [];
                end
                
            case 'vector_y_density'
                if str2double(get(wcbo,  'string')) > 2
                    
                    if mod(str2double(get(wcbo,  'string')),1)==0
                        vector.y_density = str2double(get(wcbo,  'string'));
                    else
                        errordlg('The value should be an integer.');
                    end
                else
                    errordlg('The value should be larger than 2.');
                end
                 
            case 'vector_y_span'
                vector.y_span 	= get(wcbo,  'value');
                
                %Get data from other gui
                folder_gui_handle = findobj(0, 'tag', 'folder_gui_handle',        'type', 'figure');
                
                if vector.y_span == 1
                    
                    try
                        fold              = getappdata(folder_gui_handle, 'fold');
                        
                        % Set values to the min & max of the box size
                        vector.ymin =  fold.NODES(2,1);
                        vector.ymax = -fold.NODES(2,2);
                    end
                else
                    vector.ymin = [];
                    vector.ymax = [];
                end
             
            case 'vector_ymin'
                
                if str2double(get(wcbo,  'string')) < vector.ymax
                    vector.ymin    = str2double(get(wcbo,  'string'));
                else
                    errordlg('The value should be smaller than ymax.');
                end
                
            case 'vector_ymax'
                
                if str2double(get(wcbo,  'string')) > vector.ymin
                    vector.ymax    = str2double(get(wcbo,  'string'));
                else
                    errordlg('The value should be larger than ymin.');
                end
        end
        
        % - Update data
        setappdata(vector_gui_handle, 'vector', vector);
        
        % - Enable buttons
        vector_setting('buttons_enable');
        
        % - Update Uicontrols
        vector_setting('uicontrol_update');
        
    case 'vector_apply'
        %% Apply 
        
        % Get data
        vector = getappdata(vector_gui_handle, 'vector');
        
        % Check if the main figure exist
        folder_gui_handle = findobj(0, 'tag', 'folder_gui_handle',        'type', 'figure');
        
        % Update the FOLDER GUI
        try
            %  Get fold data
            fold        = getappdata(folder_gui_handle, 'fold');
            
            % Overwrite data
            fold.vector.x_density = vector.x_density;
            fold.vector.y_density = vector.y_density;
            fold.vector.x_span    = vector.x_span;
            fold.vector.xmin      = vector.xmin;
            fold.vector.xmax      = vector.xmax;
            fold.vector.irregular = vector.irregular;
            fold.vector.y_density = vector.y_density;
            fold.vector.y_span    = vector.y_span;
            fold.vector.ymin      = vector.ymin;
            fold.vector.ymax      = vector.ymax;
            
            % Reset vector data
            fold.vector.X = [];
            fold.vector.Y = [];
            
            % Update fold data
            setappdata(folder_gui_handle, 'fold', fold);
            
            % Update Main Plot
            folder('plot_update');
            
        catch
            errordlg(err.message, 'Folder Error');
        end
        
    case 'vector_done'
        %% Done
        
        % Apply changes
        vector_setting('vector_apply');
        
        % Close figure
        close(vector_gui_handle);

end
end


