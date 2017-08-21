function markers_setting(Action)

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
markers_gui_handle = findobj(0, 'tag', 'markers_gui_handle', 'type', 'figure');

switch lower(Action)
    case 'initialize'
        
        %  Delete figure if it already exists
        if ~isempty(markers_gui_handle)
            delete(markers_gui_handle);
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
        fig_height      = 6*(b_height+gap)+2*gap;
        
        % Create dialog window
        markers_gui_handle = figure( ...
            'Name' ,'Passive Markers Setup Options', 'Units','pixels', 'tag','markers_gui_handle',...
            'NumberTitle', 'off', 'DockControls', 'off', 'MenuBar', 'none', 'ToolBar', 'none',...
            'Resize','off',...
            'pos', [Screensize(3)/5, (Screensize(4)-fig_height)/2, fig_width, fig_height], 'Color',get(0, 'DefaultUipanelBackgroundColor'),...
            'WindowStyle', 'modal');
                
        markers_upanel     = uiextras.VBox('Parent', markers_gui_handle);
        markers_upanel_general   = uipanel('Parent', markers_upanel, 'Tag','markers_upanel_general');
        markers_upanel_apply     = uipanel('Parent', markers_upanel, 'Tag','markers_upanel_apply');
        general_height           = 5*(b_height+gap)+gap;
        apply_height             = 1*(b_height+gap)+gap;
        set(markers_upanel, 'Sizes', [general_height apply_height]);
               
        %% - Passive Markers
        % x-grid Points 
        uicontrol('Parent', markers_upanel_general, 'style', 'text', 'String', 'Cell Number', 'HorizontalAlignment', 'left',...
            'position', [gap, 4*(b_height+gap)+gap, text_width, b_height],...
            'tooltipstring',sprintf('Number of cells defined in the horizontal direction exept from the ''Bar'' case,\n where number of cells is defined in the vertical direction.'));
        % Field
        obj.markers_cell_num = uicontrol('Parent', markers_upanel_general, 'style', 'edit', 'String', '', 'BackgroundColor','w',...
            'callback',  @(a,b)  markers_setting('uicontrol_callback'),...
            'tag', 'markers_cell_num', ...
            'position', [gap+text_width+gap, 4*(b_height+gap)+gap, field_width, b_height]);
        
        % Number of points per cell
        uicontrol('Parent', markers_upanel_general, 'style', 'text', 'String', 'Resolution','HorizontalAlignment', 'left', ...
            'position', [gap, 3*(b_height+gap)+gap, text_width, b_height],...
            'tooltipstring','Number of markers per cell.');
        % Field
        obj.markers_resolution = uicontrol('Parent', markers_upanel_general, 'style', 'edit', 'String', '', 'BackgroundColor','w',...
            'callback',  @(a,b)  markers_setting('uicontrol_callback'),...
            'tag', 'markers_resolution', ...
            'position', [gap+text_width+gap, 3*(b_height+gap)+gap, field_width, b_height]);
        
        % x-grid Span
        obj.markers_x_span = uicontrol('Parent', markers_upanel_general, 'style', 'checkbox', 'String', 'Horizontal Cell Span', 'HorizontalAlignment', 'left',...
            'position', [gap, 2*(b_height+gap)+2*gap, text_width, b_height],...
            'callback',  @(a,b)  markers_setting('uicontrol_callback'),...
            'tag','markers_x_span',...
            'tooltipstring','Cell span in the horizontal direction.');
        % Field
        obj.markers_xmin = uicontrol('Parent', markers_upanel_general, 'style', 'edit', 'String', 'xmin', 'BackgroundColor','w',...
            'callback',  @(a,b)  markers_setting('uicontrol_callback'),...
            'tag', 'markers_xmin', ...
            'position', [2*(b_width+gap), 2*(b_height+gap)+gap, b_width, b_height]);
        % Field
        obj.markers_xmax = uicontrol('Parent', markers_upanel_general, 'style', 'edit', 'String', 'xmax', 'BackgroundColor','w',...
            'callback',  @(a,b)  markers_setting('uicontrol_callback'),...
            'tag', 'markers_xmax', ...
            'position', [3*(b_width+gap), 2*(b_height+gap)+gap, b_width, b_height]);
        
        % y-grid Span
        obj.markers_y_span = uicontrol('Parent', markers_upanel_general, 'style', 'checkbox', 'String', 'Vertical Cell Span', 'HorizontalAlignment', 'left',...
            'position', [gap, 1*(b_height+gap)+2*gap, text_width, b_height],...
            'callback',  @(a,b)  markers_setting('uicontrol_callback'),...
            'tag','markers_y_span',...
            'tooltipstring','Cell span in the vertical direction.');
        % Field
        obj.markers_ymin = uicontrol('Parent', markers_upanel_general, 'style', 'edit', 'String', 'ymin', 'BackgroundColor','w',...
            'callback',  @(a,b)  markers_setting('uicontrol_callback'),...
            'tag', 'markers_ymin', ...
            'position', [2*(b_width+gap), 1*(b_height+gap)+gap, b_width, b_height]);
        % Field
        obj.markers_ymax = uicontrol('Parent', markers_upanel_general, 'style', 'edit', 'String', 'ymax', 'BackgroundColor','w',...
            'callback',  @(a,b)  markers_setting('uicontrol_callback'),...
            'tag', 'markers_ymax', ...
            'position', [3*(b_width+gap), 1*(b_height+gap)+gap, b_width, b_height]);
        
        % Colours
        uicontrol('Parent', markers_upanel_general, 'style', 'pushbutton', 'String', 'Colours',...
            'callback',  @(a,b) setting,...
            'position', [fig_width-(b_width+gap), gap, b_width, b_height]);
        

        %% - Apply & Cancel
        % Apply Button
        obj.markers_done = uicontrol('Parent', markers_upanel_apply, 'style', 'pushbutton', 'String', 'Apply',...
            'tag', 'markers_done', ...
            'callback',  @(a,b)  markers_setting('markers_apply'),...
            'position', [fig_width-3*(b_width+gap), gap, b_width, b_height]);
        
        % Done Button
        obj.markers_done = uicontrol('Parent', markers_upanel_apply, 'style', 'pushbutton', 'String', 'Done',...
            'tag', 'markers_done', ...
            'callback',  @(a,b)  markers_setting('markers_done'),...
            'position', [fig_width-2*(b_width+gap), gap, b_width, b_height]);
        
        % Cancel Button
        uicontrol('Parent', markers_upanel_apply, 'style', 'pushbutton', 'String', 'Cancel',...
            'tag', 'markers_cancel', ...
            'callback',  @(a,b) close(gcf),...
            'position', [fig_width-(b_width+gap), gap, b_width, b_height]);
        
        % Store in Figure Appdata
        setappdata(markers_gui_handle, 'obj', obj);
        
        % - Folder Default Values
        markers_setting('default_values');
        
        % - Update Uicontrols
        markers_setting('uicontrol_update');
        
        % - Enable buttons
        markers_setting('buttons_enable');
        
        
    case 'default_values'
        %% Default values
        
        folder_gui_handle = findobj(0, 'tag', 'folder_gui_handle',        'type', 'figure');
        
        if ~isempty(folder_gui_handle)
            
            fold    = getappdata(folder_gui_handle, 'fold');
            
            markers.cell_num        = fold.markers.cell_num;
            markers.type            = fold.markers.type;
            markers.resolution      = fold.markers.resolution;
            markers.x_span          = fold.markers.x_span;
            markers.xmin            = fold.markers.xmin;
            markers.xmax            = fold.markers.xmax;
            markers.y_span          = fold.markers.y_span;
            markers.ymin            = fold.markers.ymin;
            markers.ymax            = fold.markers.ymax;
        end
        
        setappdata(markers_gui_handle, 'markers', markers);
        
    case 'uicontrol_update'
        %% Update Uicontrols
        
        % Get data
        obj     = getappdata(markers_gui_handle, 'obj');
        markers = getappdata(markers_gui_handle, 'markers');
        
        % General
        set(obj.markers_cell_num,            'string', num2str(markers.cell_num));
        set(obj.markers_resolution,          'string', num2str(markers.resolution));
        set(obj.markers_x_span,              'value',  markers.x_span);
        if ~isempty(markers.xmin)
            set(obj.markers_xmin,             'string', num2str(markers.xmin));
            set(obj.markers_xmax,             'string', num2str(markers.xmax));
        else
            set(obj.markers_xmin,             'string', 'xmin');
            set(obj.markers_xmax,             'string', 'xmax');
        end
        set(obj.markers_y_span,               'value',  markers.y_span);
        if ~isempty(markers.ymin)
            set(obj.markers_ymin,             'string', num2str(markers.ymin));
            set(obj.markers_ymax,             'string', num2str(markers.ymax));
        else
            set(obj.markers_ymin,             'string', 'ymin');
            set(obj.markers_ymax,             'string', 'ymax');
        end
        
    case 'buttons_enable'
        %% Buttons enable
        
        % Get data
        obj     = getappdata(markers_gui_handle, 'obj');
        markers = getappdata(markers_gui_handle, 'markers');
                        
        % Switch off field options
        set(obj.markers_cell_num,    	'enable', 'off');
        set(obj.markers_resolution,  	'enable', 'off');
        set(obj.markers_x_span,    	'enable', 'off');
        set(obj.markers_xmin,        	'enable', 'off');
        set(obj.markers_xmax,       	'enable', 'off');
        set(obj.markers_y_span,      	'enable', 'off');
        set(obj.markers_ymin,        	'enable', 'off');
        set(obj.markers_ymax,        	'enable', 'off');
        
        % Switch on quiver options only when fold run data exist
        % Find other gui
        folder_gui_handle = findobj(0, 'tag', 'folder_gui_handle',        'type', 'figure');
        try      
            %  Get fold data
            fold        = getappdata(folder_gui_handle, 'fold');
            
            if ~isfield(fold, 'NODES_run')
                
                set(obj.markers_cell_num,    	'enable', 'on');
                set(obj.markers_resolution,  	'enable', 'on');
                set(obj.markers_x_span,       'enable', 'on');
                set(obj.markers_y_span,       'enable', 'on');
                if markers.x_span == 1
                    set(obj.markers_xmin,    	'enable', 'on');
                    set(obj.markers_xmax,    	'enable', 'on');
                end
                if markers.y_span == 1
                    set(obj.markers_ymin,    	'enable', 'on');
                    set(obj.markers_ymax,    	'enable', 'on');
                end
            end
        end
        
    case 'uicontrol_callback'
        %% Uicontrol callback
        
        % Who is calling
        wcbo            = gcbo;
        Whoiscalling    = get(wcbo, 'tag');
        
        % Get data
        markers = getappdata(markers_gui_handle, 'markers');
            
        
        switch Whoiscalling
            
            case 'markers_cell_num'
                
                if str2double(get(wcbo,  'string'))>2
                    if mod(str2double(get(wcbo,  'string')),1)==0
                        markers.cell_num   = str2double(get(wcbo,  'string'));
                    else
                        errordlg('The value must be an integer.');
                    end
                else
                    errordlg('The value must be larger than 2.');
                end
            
            case 'markers_resolution'
                
                if str2double(get(wcbo,  'string'))>5
                    if mod(str2double(get(wcbo,  'string')),1)==0
                        markers.resolution   = str2double(get(wcbo,  'string'));
                    else
                        errordlg('The value must be an integer.');
                    end
                else
                    errordlg('The value should be larger than 5.');
                end
            
            case 'markers_x_span'
                markers.x_span 	= get(wcbo,  'value');
                
                %Get data from other gui
                folder_gui_handle = findobj(0, 'tag', 'folder_gui_handle',        'type', 'figure');
                
                if markers.x_span == 1
                    % Set values to the min & max of the box size
                    try
                        fold         	= getappdata(folder_gui_handle, 'fold');
                        markers.xmin    = fold.NODES(1,1);
                        markers.xmax    = fold.NODES(1,end);
                    end
                else
                    markers.xmin = [];
                    markers.xmax = [];
                end
            
            case 'markers_xmin'
                
                %Get data from other gui
                folder_gui_handle = findobj(0, 'tag', 'folder_gui_handle',        'type', 'figure');
                
                try
                    fold              = getappdata(folder_gui_handle, 'fold');
                    
                    if str2double(get(wcbo,  'string')) < fold.NODES(1,1)
                        errordlg('The value should be outside the domain size.');
                        markers_setting('uicontrol_update')
                        return;
                    end
                end
                
                if str2double(get(wcbo,  'string')) < markers.xmax
                    markers.xmin    = str2double(get(wcbo,  'string'));
                else
                    errordlg('The value should be smaller than xmax.');
                    return;
                end
                
            case 'markers_xmax'
                
                %Get data from other gui
                folder_gui_handle = findobj(0, 'tag', 'folder_gui_handle',        'type', 'figure');
                
                try
                    fold              = getappdata(folder_gui_handle, 'fold');
                    
                    if str2double(get(wcbo,  'string')) > fold.NODES(1,2)
                        errordlg('The value should be outside the domain size.');
                        markers_setting('uicontrol_update')
                        return;
                    end
                end
                
                if str2double(get(wcbo,  'string')) > markers.xmin
                    markers.xmax    = str2double(get(wcbo,  'string'));
                else
                    errordlg('The value should be larger than xmin.');
                    markers_setting('uicontrol_update')
                    return;
                end
                
            case 'markers_y_span'
                markers.y_span 	= get(wcbo,  'value');
                
                %Get data from other gui
                folder_gui_handle = findobj(0, 'tag', 'folder_gui_handle',        'type', 'figure');
                
                if markers.y_span == 1
                    % Set values to the min & max of the box size
                    try
                        fold         	= getappdata(folder_gui_handle, 'fold');
                        markers.ymin    = fold.NODES(2,1);
                        markers.ymax    = fold.NODES(2,end);
                    end
                else
                    markers.ymin = [];
                    markers.ymax = [];
                end
            
            case 'markers_ymin'
                
                %Get data from other gui
                folder_gui_handle = findobj(0, 'tag', 'folder_gui_handle',        'type', 'figure');
                
                try
                    fold              = getappdata(folder_gui_handle, 'fold');
                    if str2double(get(wcbo,  'string')) < fold.NODES(2,1)
                        errordlg('The value should be outside the domain size.');
                        markers_setting('uicontrol_update')
                        return;
                    end
                end
                
                if str2double(get(wcbo,  'string')) < markers.ymax
                    markers.ymin    = str2double(get(wcbo,  'string'));
                else
                    errordlg('The value should be smaller than ymax.');
                    markers_setting('uicontrol_update')
                    return;
                end
                
            case 'markers_ymax'
                
                %Get data from other gui
                folder_gui_handle = findobj(0, 'tag', 'folder_gui_handle',        'type', 'figure');
                
                try
                    fold              = getappdata(folder_gui_handle, 'fold');
                    
                    if str2double(get(wcbo,  'string')) > fold.NODES(2,end)
                        errordlg('The value should be outside the domain size.');
                        markers_setting('uicontrol_update')
                        return;
                    end
                end
                
                if str2double(get(wcbo,  'string')) > markers.ymin
                    markers.ymax    = str2double(get(wcbo,  'string'));
                else
                    errordlg('The value should be larger than ymin.');
                    markers_setting('uicontrol_update')
                    return;
                end
                
        end
        
        % - Update data
        setappdata(markers_gui_handle, 'markers', markers);
        
        % - Enable buttons
        markers_setting('buttons_enable');
        
        % - Update Uicontrols
        markers_setting('uicontrol_update');
        
    case 'markers_apply'
        %% Apply 
        
        % Get data
        markers = getappdata(markers_gui_handle, 'markers');
        
        % Check if the main figure exist
        folder_gui_handle = findobj(0, 'tag', 'folder_gui_handle',        'type', 'figure');
        
        % Update the FOLDER GUI
%         try
            %  Get fold data
            fold        = getappdata(folder_gui_handle, 'fold');
            
            % Overwrite data
            fold.markers.cell_num   = markers.cell_num; 
            fold.markers.resolution = markers.resolution;
            fold.markers.x_span     = markers.x_span;
            fold.markers.xmin       = markers.xmin;
            fold.markers.xmax       = markers.xmax;
            fold.markers.y_span     = markers.y_span;
            fold.markers.ymin       = markers.ymin;
            fold.markers.ymax       = markers.ymax;
            
            % Update fold data
            setappdata(folder_gui_handle, 'fold', fold);
            
            % Update Main Plot
            folder('uicontrol_callback');
            
%         catch
%           errordlg('Main figure gone.');
%         end
        
    case 'markers_done'
        %% Done
        
        % Apply changes
        markers_setting('markers_apply');
        
        % Close figure
        close(markers_gui_handle);
        
end
end


