function tensor_setting(Action)

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
tensor_gui_handle = findobj(0, 'tag', 'tensor_gui_handle', 'type', 'figure');

switch lower(Action)
    case 'initialize'
        
        %  Delete figure if it already exists
        if ~isempty(tensor_gui_handle)
            delete(tensor_gui_handle);
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
        tensor_gui_handle = figure( ...
            'Name' ,'Tensor Plotting Options', 'Units','pixels', 'tag','tensor_gui_handle',...
            'NumberTitle', 'off', 'DockControls', 'off', 'MenuBar', 'none', 'ToolBar', 'none',...
            'Resize','off',...
            'pos', [Screensize(3)/5, (Screensize(4)-fig_height)/2, fig_width, fig_height], 'Color',get(0, 'DefaultUipanelBackgroundColor'));
                
        % tensor
        tensor_upanel       = uiextras.VBox('Parent', tensor_gui_handle);
        tensor_upanel_span 	= uipanel('Parent', tensor_upanel, 'Tag','tensor_upanel_span','Title', '');
        tensor_upanel_apply = uipanel('Parent', tensor_upanel, 'Tag','tensor_upanel_apply','Title', '');
        span_height      	= 6*(b_height+gap)+1*gap;
        apply_height    	= 1*(b_height+gap)+1*gap;
        set( tensor_upanel, 'Sizes', [span_height apply_height]);
        
        
        %% - Span
        % x-grid Points 
        uicontrol('Parent', tensor_upanel_span, 'style', 'text', 'String', 'x-grid Points', 'HorizontalAlignment', 'left',...
            'position', [gap, 5*(b_height+gap)+gap, text_width, b_height],...
            'tooltipstring','Number of glyphs plotted in the horizontal direction.');
        % Field
        obj.tensor_x_density = uicontrol('Parent', tensor_upanel_span, 'style', 'edit', 'String', '', 'BackgroundColor','w',...
            'callback',  @(a,b)  tensor_setting('uicontrol_callback'),...
            'tag', 'tensor_x_density', ...
            'position', [gap+text_width+gap, 5*(b_height+gap)+gap, field_width, b_height]);
        
        % x-grid Span
        obj.tensor_x_span = uicontrol('Parent', tensor_upanel_span, 'style', 'checkbox', 'String', 'x-grid Span', 'HorizontalAlignment', 'left',...
            'position', [gap, 4*(b_height+gap)+2*gap, text_width, b_height],...
            'callback',  @(a,b)  tensor_setting('uicontrol_callback'),...
            'tag','tensor_x_span',...
            'tooltipstring','Glyph span in the horizontal direction.');
        % Field
        obj.tensor_xmin = uicontrol('Parent', tensor_upanel_span, 'style', 'edit', 'String', 'xmin', 'BackgroundColor','w',...
            'callback',  @(a,b)  tensor_setting('uicontrol_callback'),...
            'tag', 'tensor_xmin', ...
            'position', [2*(b_width+gap), 4*(b_height+gap)+gap, b_width, b_height]);
        % Field
        obj.tensor_xmax = uicontrol('Parent', tensor_upanel_span, 'style', 'edit', 'String', 'xmax', 'BackgroundColor','w',...
            'callback',  @(a,b)  tensor_setting('uicontrol_callback'),...
            'tag', 'tensor_xmax', ...
            'position', [3*(b_width+gap), 4*(b_height+gap)+gap, b_width, b_height]);
        
        % Irregular case
        obj.tensor_irregular = uicontrol('Parent', tensor_upanel_span, 'style', 'checkbox', 'String', 'Irregular Grid', 'HorizontalAlignment', 'left',...
            'position', [gap, 3*(b_height+gap)+2*gap, text_width, b_height],...
            'callback',  @(a,b)  tensor_setting('uicontrol_callback'),...
            'tag','tensor_irregular',...
            'tooltipstring','Different glyph spacing in vertical direction.');
        
        % y-grid Points 
        uicontrol('Parent', tensor_upanel_span, 'style', 'text', 'String', 'y-grid Points', 'HorizontalAlignment', 'left',...
            'position', [gap, 2*(b_height+gap)+gap, text_width, b_height],...
            'tooltipstring','Number of glyphs plotted in the vertical direction.');
        % Field
        obj.tensor_y_density = uicontrol('Parent', tensor_upanel_span, 'style', 'edit', 'String', '', 'BackgroundColor','w',...
            'callback',  @(a,b)  tensor_setting('uicontrol_callback'),...
            'tag', 'tensor_y_density', ...
            'position', [gap+text_width+gap, 2*(b_height+gap)+gap, field_width, b_height]);
        
        % y-grid Span
        obj.tensor_y_span = uicontrol('Parent', tensor_upanel_span, 'style', 'checkbox', 'String', 'y-grid Span', 'HorizontalAlignment', 'left',...
            'position', [gap, 1*(b_height+gap)+2*gap, text_width, b_height],...
            'callback',  @(a,b)  tensor_setting('uicontrol_callback'),...
            'tag','tensor_y_span',...
            'tooltipstring','Glyph span in the vertical direction.');
        % Field
        obj.tensor_ymin = uicontrol('Parent', tensor_upanel_span, 'style', 'edit', 'String', 'ymin', 'BackgroundColor','w',...
            'callback',  @(a,b)  tensor_setting('uicontrol_callback'),...
            'tag', 'tensor_ymin', ...
            'position', [2*(b_width+gap), 1*(b_height+gap)+gap, b_width, b_height]);
        % Field
        obj.tensor_ymax = uicontrol('Parent', tensor_upanel_span, 'style', 'edit', 'String', 'ymax', 'BackgroundColor','w',...
            'callback',  @(a,b)  tensor_setting('uicontrol_callback'),...
            'tag', 'tensor_ymax', ...
            'position', [3*(b_width+gap), 1*(b_height+gap)+gap, b_width, b_height]);
        
        % Colours
        uicontrol('Parent', tensor_upanel_span, 'style', 'pushbutton', 'String', 'Colours',...
            'callback',  @(a,b) setting,...
            'position', [fig_width-(b_width+gap), gap, b_width, b_height]);
        
        %% - Apply & Cancel
        % Apply Button
        obj.tensor_apply = uicontrol('Parent', tensor_upanel_apply, 'style', 'pushbutton', 'String', 'Apply',...
            'tag', 'tensor_apply', ...
            'callback',  @(a,b)  tensor_setting('tensor_apply'),...
            'position', [fig_width-3*(b_width+gap), gap, b_width, b_height]);
        
        % Done Button
        obj.tensor_done = uicontrol('Parent', tensor_upanel_apply, 'style', 'pushbutton', 'String', 'Done',...
            'tag', 'tensor_done', ...
            'callback',  @(a,b)  tensor_setting('tensor_done'),...
            'position', [fig_width-2*(b_width+gap), gap, b_width, b_height]);
        
        % Cancel Button
        uicontrol('Parent', tensor_upanel_apply, 'style', 'pushbutton', 'String', 'Close',...
            'tag', 'tensor_cancel', ...
            'callback',  @(a,b) close(gcf),...
            'position', [fig_width-(b_width+gap), gap, b_width, b_height]);
        
        % Store in Figure Appdata
        setappdata(tensor_gui_handle, 'obj', obj);
        
        % - Folder Default Values
        tensor_setting('default_values');
        
        % - Update Uicontrols
        tensor_setting('uicontrol_update');
        
        % - Enable buttons
        tensor_setting('buttons_enable');
        
        
    case 'default_values'
        %% Default values
        
        folder_gui_handle = findobj(0, 'tag', 'folder_gui_handle',        'type', 'figure');
        
        if ~isempty(folder_gui_handle)
            
            fold    = getappdata(folder_gui_handle, 'fold');
                  
            tensor.x_density = fold.tensor.x_density;
            tensor.x_span    = fold.tensor.x_span;
            tensor.xmin      = fold.tensor.xmin;
            tensor.xmax      = fold.tensor.xmax;
            tensor.irregular = fold.tensor.irregular;
            tensor.y_density = fold.tensor.y_density;
            tensor.y_span    = fold.tensor.y_span;
            tensor.ymin      = fold.tensor.ymin;
            tensor.ymax      = fold.tensor.ymax;
        end
        
        setappdata(tensor_gui_handle, 'tensor', tensor);
        
    case 'uicontrol_update'
        %% Update Uicontrols
        
        % Get data
        obj    = getappdata(tensor_gui_handle, 'obj');
        tensor = getappdata(tensor_gui_handle, 'tensor');
        
        set(obj.tensor_x_density,     'string', num2str(tensor.x_density));
        set(obj.tensor_x_span,        'value',  tensor.x_span);
        
        if ~isempty(tensor.xmin)
            set(obj.tensor_xmin,      'string', num2str(tensor.xmin));
            set(obj.tensor_xmax,      'string', num2str(tensor.xmax));
        else
            set(obj.tensor_xmin,      'string', 'xmin');
            set(obj.tensor_xmax,      'string', 'xmax');
        end
        set(obj.tensor_irregular,     'value',  tensor.irregular);
        set(obj.tensor_y_density,     'string', num2str(tensor.y_density));
        set(obj.tensor_y_span,        'value',  tensor.y_span);
        if ~isempty(tensor.ymin)
            set(obj.tensor_ymin,      'string', num2str(tensor.ymin));
            set(obj.tensor_ymax,      'string', num2str(tensor.ymax));
        else
            set(obj.tensor_ymin,      'string', 'ymin');
            set(obj.tensor_ymax,      'string', 'ymax');
        end
        
    case 'buttons_enable'
        %% Buttons enable
        
        % Get data
        obj    = getappdata(tensor_gui_handle, 'obj');
        tensor = getappdata(tensor_gui_handle, 'tensor');
                        
        % Switch on quiver options only when fold run data exist
        % Find other gui
        folder_gui_handle = findobj(0, 'tag', 'folder_gui_handle',        'type', 'figure');
        try      
            %  Get fold data
            fold        = getappdata(folder_gui_handle, 'fold');
            
            if isfield(fold, 'NODES_run')
                
                set(obj.tensor_x_density,     'enable', 'on');
                set(obj.tensor_x_span,        'enable', 'on');
                set(obj.tensor_irregular,     'enable', 'on');
                
                if get(obj.tensor_irregular, 'value') == 1
                    set(obj.tensor_y_density, 'enable', 'on');
                else
                    set(obj.tensor_y_density, 'enable', 'off');
                end
                
                set(obj.tensor_y_span,        'enable', 'on');
                % quiver_x_span
                if tensor.x_span == 1
                    set(obj.tensor_xmin,    	'enable', 'on');
                    set(obj.tensor_xmax,    	'enable', 'on');
                else
                    set(obj.tensor_xmin,    	'enable', 'off');
                    set(obj.tensor_xmax,    	'enable', 'off');
                end
                % quiver_y_span
                if tensor.y_span == 1
                    set(obj.tensor_ymin,    	'enable', 'on');
                    set(obj.tensor_ymax,    	'enable', 'on');
                else
                    set(obj.tensor_ymin,    	'enable', 'off');
                    set(obj.tensor_ymax,    	'enable', 'off');
                end
                
            end 
        catch
            
            set(obj.tensor_x_density,     'enable', 'off');
            set(obj.tensor_x_span,        'enable', 'off');
            set(obj.tensor_xmin,          'enable', 'off');
            set(obj.tensor_xmax,          'enable', 'off');
            set(obj.tensor_irregular,     'enable', 'off');
            set(obj.tensor_y_density,     'enable', 'off');
            set(obj.tensor_y_span,        'enable', 'off');
            set(obj.tensor_ymin,          'enable', 'off');
            set(obj.tensor_ymax,          'enable', 'off');
            
        end
        
    case 'uicontrol_callback'
        %% Uicontrol callback
        
        % Who is calling
        wcbo            = gcbo;
        Whoiscalling    = get(wcbo, 'tag');
        
        % Get data
        tensor = getappdata(tensor_gui_handle, 'tensor');
            
        switch Whoiscalling
                
            case 'tensor_x_density'
                
                if str2double(get(wcbo,  'string')) > 2
                    
                    if mod(str2double(get(wcbo,  'string')),1)==0
                        tensor.x_density = str2double(get(wcbo,  'string'));
                    else
                        errordlg('The value should be an integer.');
                    end
                else
                    errordlg('The value should be larger than 2.');
                end
           
            case 'tensor_x_span'
                tensor.x_span 	= get(wcbo,  'value');
                
                %Get data from other gui
                folder_gui_handle = findobj(0, 'tag', 'folder_gui_handle',        'type', 'figure');
                
                if tensor.x_span == 1
                    % Set values to the min & max of the box size
                    try
                        fold              = getappdata(folder_gui_handle, 'fold');
                        tensor.xmin = fold.NODES(1,1);
                        tensor.xmax = fold.NODES(1,2);
                    end
                else
                    tensor.xmin = [];
                    tensor.xmax = [];
                end
            
            case 'tensor_xmin'
                
                if str2double(get(wcbo,  'string')) < tensor.xmax
                    tensor.xmin    = str2double(get(wcbo,  'string'));
                else
                    errordlg('The value should be smaller than xmax.');
                end
                
            case 'tensor_xmax'
                
                if str2double(get(wcbo,  'string')) > tensor.xmin
                    tensor.xmax    = str2double(get(wcbo,  'string'));
                else
                    errordlg('The value should be larger than xmin.');
                end
                
            case 'tensor_irregular'
                tensor.irregular   = get(wcbo,  'value');
                
                folder_gui_handle = findobj(0, 'tag', 'folder_gui_handle',        'type', 'figure');
                
                if tensor.irregular == 1 && isempty(tensor.y_density)
                    
                    try
                        fold    = getappdata(folder_gui_handle, 'fold');
                        
                        x       = linspace(fold.NODES_run(1,fold.num.it),fold.NODES_run(3,fold.num.it),fold.tensor.x_density);
                        dx      = x(2)-x(1);
                        
                        if isempty(tensor.ymin)
                            tensor.y_density = ceil(-2*min(fold.MESH.NODES(2,:))/dx);
                        else
                            tensor.y_density = ceil((fold.tensor.ymax-fold.tensor.ymin)/dx);
                        end
                        
                    catch
                        tensor.y_density = 20;
                    end
                end
                 
                if tensor.irregular == 0
                    tensor.y_density  = [];
                end
                
            case 'tensor_y_density'
                if str2double(get(wcbo,  'string')) > 2
                    
                    if mod(str2double(get(wcbo,  'string')),1)==0
                        tensor.y_density = str2double(get(wcbo,  'string'));
                    else
                        errordlg('The value should be an integer.');
                    end
                else
                    errordlg('The value should be larger than 2.');
                end
                 
            case 'tensor_y_span'
                tensor.y_span 	= get(wcbo,  'value');
                
                %Get data from other gui
                folder_gui_handle = findobj(0, 'tag', 'folder_gui_handle',        'type', 'figure');
                
                if tensor.y_span == 1
                    
                    try
                        fold              = getappdata(folder_gui_handle, 'fold');
                        
                        % Set values to the min & max of the box size
                        tensor.ymin =  fold.NODES(2,1);
                        tensor.ymax = -fold.NODES(2,2);
                    end
                else
                    tensor.ymin = [];
                    tensor.ymax = [];
                end
             
            case 'tensor_ymin'
                
                if str2double(get(wcbo,  'string')) < tensor.ymax
                    tensor.ymin    = str2double(get(wcbo,  'string'));
                else
                    errordlg('The value should be smaller than ymax.');
                end
                
            case 'tensor_ymax'
                
                if str2double(get(wcbo,  'string')) > tensor.ymin
                    tensor.ymax    = str2double(get(wcbo,  'string'));
                else
                    errordlg('The value should be larger than ymin.');
                end
        end
        
        % - Update data
        setappdata(tensor_gui_handle, 'tensor', tensor);
        
        % - Enable buttons
        tensor_setting('buttons_enable');
        
        % - Update Uicontrols
        tensor_setting('uicontrol_update');
        
        % - Update Main GUI
        %tensor_setting('opts_apply');
        
    case 'tensor_apply'
        %% Apply 
        
        % Get data
        tensor = getappdata(tensor_gui_handle, 'tensor');
        
        % Check if the main figure exist
        folder_gui_handle = findobj(0, 'tag', 'folder_gui_handle',        'type', 'figure');
        
        % Update the FOLDER GUI
        try
            %  Get fold data
            fold        = getappdata(folder_gui_handle, 'fold');
            
            % Overwrite data
            fold.tensor.x_density = tensor.x_density;
            fold.tensor.y_density = tensor.y_density;
            fold.tensor.x_span    = tensor.x_span;
            fold.tensor.xmin      = tensor.xmin;
            fold.tensor.xmax      = tensor.xmax;
            fold.tensor.irregular = tensor.irregular;
            fold.tensor.y_density = tensor.y_density;
            fold.tensor.y_span    = tensor.y_span;
            fold.tensor.ymin      = tensor.ymin;
            fold.tensor.ymax      = tensor.ymax;
            
            % Reset tensor data
            fold.tensor.X = [];
            fold.tensor.Y = [];
            
            % Update fold data
            setappdata(folder_gui_handle, 'fold', fold);
            
            % Update Main Plot
            folder('plot_update');
            
        catch err
            errordlg(err.message, 'Folder Error');
            return;
        end

    case 'tensor_done'
        %% Done
        
        % Apply changes
        tensor_setting('tensor_apply');
        
        % Close figure
        close(tensor_gui_handle);
end
end


