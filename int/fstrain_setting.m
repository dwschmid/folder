function fstrain_setting(Action)

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
fstrain_gui_handle = findobj(0, 'tag', 'fstrain_gui_handle', 'type', 'figure');

switch lower(Action)
    case 'initialize'
        
        %  Delete figure if it already exists
        if ~isempty(fstrain_gui_handle)
            delete(fstrain_gui_handle);
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
        
        text_width      = 2*b_width;
        field_width     = 2*b_width+gap;
        
        Screensize      = get(0, 'ScreenSize');
        fig_width       = text_width+field_width+3*gap;
        fig_height      = 6*(b_height+gap)+2*gap;
        
        % Create dialog window
        fstrain_gui_handle = figure( ...
            'Name' ,'Finite Strain Setup Options', 'Units','pixels', 'tag','fstrain_gui_handle',...
            'NumberTitle', 'off', 'DockControls', 'off', 'MenuBar', 'none', 'ToolBar', 'none',...
            'Resize','off',...
            'pos', [Screensize(3)/5, (Screensize(4)-fig_height)/2, fig_width, fig_height], 'Color',get(0, 'DefaultUipanelBackgroundColor'));
                
        fstrain_upanel     = uiextras.VBox('Parent', fstrain_gui_handle);
        fstrain_upanel_general   = uipanel('Parent', fstrain_upanel, 'Tag','fstrain_upanel_general','Title','');
        fstrain_upanel_apply     = uipanel('Parent', fstrain_upanel, 'Tag','fstrain_upanel_apply','Title','');
        general_height           = 5*(b_height+gap)+gap;
        apply_height             = 1*(b_height+gap)+gap;
        set(fstrain_upanel, 'Sizes', [general_height apply_height]);
               
        %% - Passive Markers
        % x-grid Points 
        uicontrol('Parent', fstrain_upanel_general, 'style', 'text', 'String', 'Cell Number', 'HorizontalAlignment', 'left',...
            'position', [gap, 4*(b_height+gap)+gap, text_width, b_height],...
            'tooltipstring','Number of strain ellipses in the horizontal direction.');
        % Field
        obj.fstrain_cell_num = uicontrol('Parent', fstrain_upanel_general, 'style', 'edit', 'String', '', 'BackgroundColor','w',...
            'callback',  @(a,b)  fstrain_setting('uicontrol_callback'),...
            'tag', 'fstrain_cell_num', ...
            'position', [gap+text_width+gap, 4*(b_height+gap)+gap, field_width, b_height]);
        
        % Number of points per cell
        uicontrol('Parent', fstrain_upanel_general, 'style', 'text', 'String', 'Resolution','HorizontalAlignment', 'left', ...
            'position', [gap, 3*(b_height+gap)+gap, text_width, b_height],...
            'tooltipstring','Number of points describing the ellipse.');
        % Field
        obj.fstrain_resolution = uicontrol('Parent', fstrain_upanel_general, 'style', 'edit', 'String', '', 'BackgroundColor','w',...
            'callback',  @(a,b)  fstrain_setting('uicontrol_callback'),...
            'tag', 'fstrain_resolution', ...
            'position', [gap+text_width+gap, 3*(b_height+gap)+gap, field_width, b_height]);
        
        % x-grid Span
        obj.fstrain_x_span = uicontrol('Parent', fstrain_upanel_general, 'style', 'checkbox', 'String', 'Horizontal Cell Span', 'HorizontalAlignment', 'left',...
            'position', [gap, 2*(b_height+gap)+2*gap, text_width, b_height],...
            'callback',  @(a,b)  fstrain_setting('uicontrol_callback'),...
            'tag','fstrain_x_span',...
            'tooltipstring','Ellipse span in the horizontal direction.');
        % Field
        obj.fstrain_xmin = uicontrol('Parent', fstrain_upanel_general, 'style', 'edit', 'String', 'xmin', 'BackgroundColor','w',...
            'callback',  @(a,b)  fstrain_setting('uicontrol_callback'),...
            'tag', 'fstrain_xmin', ...
            'position', [2*(b_width+gap), 2*(b_height+gap)+gap, b_width, b_height]);
        % Field
        obj.fstrain_xmax = uicontrol('Parent', fstrain_upanel_general, 'style', 'edit', 'String', 'xmax', 'BackgroundColor','w',...
            'callback',  @(a,b)  fstrain_setting('uicontrol_callback'),...
            'tag', 'fstrain_xmax', ...
            'position', [3*(b_width+gap), 2*(b_height+gap)+gap, b_width, b_height]);
        
        % y-grid Span
        obj.fstrain_y_span = uicontrol('Parent', fstrain_upanel_general, 'style', 'checkbox', 'String', 'Vertical Cell Span', 'HorizontalAlignment', 'left',...
            'position', [gap, 1*(b_height+gap)+2*gap, text_width, b_height],...
            'callback',  @(a,b)  fstrain_setting('uicontrol_callback'),...
            'tag','fstrain_y_span',...
            'tooltipstring','Ellipse span in the vertical direction.');
        % Field
        obj.fstrain_ymin = uicontrol('Parent', fstrain_upanel_general, 'style', 'edit', 'String', 'ymin', 'BackgroundColor','w',...
            'callback',  @(a,b)  fstrain_setting('uicontrol_callback'),...
            'tag', 'fstrain_ymin', ...
            'position', [2*(b_width+gap), 1*(b_height+gap)+gap, b_width, b_height]);
        % Field
        obj.fstrain_ymax = uicontrol('Parent', fstrain_upanel_general, 'style', 'edit', 'String', 'ymax', 'BackgroundColor','w',...
            'callback',  @(a,b)  fstrain_setting('uicontrol_callback'),...
            'tag', 'fstrain_ymax', ...
            'position', [3*(b_width+gap), 1*(b_height+gap)+gap, b_width, b_height]);
        
        % Colours
        uicontrol('Parent', fstrain_upanel_general, 'style', 'pushbutton', 'String', 'Colours',...
            'callback',  @(a,b) setting,...
            'position', [fig_width-(b_width+gap), gap, b_width, b_height]);

        %% - Apply & Cancel
        % Apply Button
        obj.fstrain_apply = uicontrol('Parent', fstrain_upanel_apply, 'style', 'pushbutton', 'String', 'Apply',...
            'tag', 'fstrain_apply', ...
            'callback',  @(a,b)  fstrain_setting('fstrain_apply'),...
            'position', [fig_width-3*(b_width+gap), gap, b_width, b_height]);
        
        % Done Button
        obj.fstrain_done = uicontrol('Parent', fstrain_upanel_apply, 'style', 'pushbutton', 'String', 'Done',...
            'tag', 'fstrain_done', ...
            'callback',  @(a,b)  fstrain_setting('fstrain_done'),...
            'position', [fig_width-2*(b_width+gap), gap, b_width, b_height]);
        
        % Cancel Button
        uicontrol('Parent', fstrain_upanel_apply, 'style', 'pushbutton', 'String', 'Close',...
            'tag', 'fstrain_cancel', ...
            'callback',  @(a,b) close(gcf),...
            'position', [fig_width-(b_width+gap), gap, b_width, b_height]);
        
        % Store in Figure Appdata
        setappdata(fstrain_gui_handle, 'obj', obj);
        
        % - Folder Default Values
        fstrain_setting('default_values');
        
        % - Update Uicontrols
        fstrain_setting('uicontrol_update');
        
        % - Enable buttons
        fstrain_setting('buttons_enable');
        
        
    case 'default_values'
        %% Default values
        
        folder_gui_handle = findobj(0, 'tag', 'folder_gui_handle',        'type', 'figure');
        
        if ~isempty(folder_gui_handle)
            
            fold    = getappdata(folder_gui_handle, 'fold');
            
            fstrain.cell_num        = fold.fstrain.cell_num;
            fstrain.resolution      = fold.fstrain.resolution;
            fstrain.x_span          = fold.fstrain.x_span;
            fstrain.xmin            = fold.fstrain.xmin;
            fstrain.xmax            = fold.fstrain.xmax;
            fstrain.y_span          = fold.fstrain.y_span;
            fstrain.ymin            = fold.fstrain.ymin;
            fstrain.ymax            = fold.fstrain.ymax;
            
        end
        
        setappdata(fstrain_gui_handle, 'fstrain', fstrain);
        
    case 'uicontrol_update'
        %% Update Uicontrols
        
        % Get data
        obj     = getappdata(fstrain_gui_handle, 'obj');
        fstrain = getappdata(fstrain_gui_handle, 'fstrain');
        
        % General
        set(obj.fstrain_cell_num,            'string', num2str(fstrain.cell_num));
        set(obj.fstrain_resolution,          'string', num2str(fstrain.resolution));
        set(obj.fstrain_x_span,              'value',  fstrain.x_span);
        if ~isempty(fstrain.xmin)
            set(obj.fstrain_xmin,             'string', num2str(fstrain.xmin));
            set(obj.fstrain_xmax,             'string', num2str(fstrain.xmax));
        else
            set(obj.fstrain_xmin,             'string', 'xmin');
            set(obj.fstrain_xmax,             'string', 'xmax');
        end
        set(obj.fstrain_y_span,               'value',  fstrain.y_span);
        if ~isempty(fstrain.ymin)
            set(obj.fstrain_ymin,             'string', num2str(fstrain.ymin));
            set(obj.fstrain_ymax,             'string', num2str(fstrain.ymax));
        else
            set(obj.fstrain_ymin,             'string', 'ymin');
            set(obj.fstrain_ymax,             'string', 'ymax');
        end
        
    case 'buttons_enable'
        %% Buttons enable
        
        % Get data
        obj     = getappdata(fstrain_gui_handle, 'obj');
        fstrain = getappdata(fstrain_gui_handle, 'fstrain');
                        
        % Switch off field options
        set(obj.fstrain_cell_num,    	'enable', 'off');
        set(obj.fstrain_resolution,  	'enable', 'off');
        set(obj.fstrain_x_span,         'enable', 'off');
        set(obj.fstrain_xmin,        	'enable', 'off');
        set(obj.fstrain_xmax,       	'enable', 'off');
        set(obj.fstrain_y_span,      	'enable', 'off');
        set(obj.fstrain_ymin,        	'enable', 'off');
        set(obj.fstrain_ymax,        	'enable', 'off');
        
        % Switch on quiver options only when fold run data exist
        % Find other gui
        folder_gui_handle = findobj(0, 'tag', 'folder_gui_handle',        'type', 'figure');
        try      
            %  Get fold data
            fold        = getappdata(folder_gui_handle, 'fold');
            
            if ~isfield(fold, 'NODES_run')
                
                set(obj.fstrain_cell_num,    	'enable', 'on');
                set(obj.fstrain_resolution,  	'enable', 'on');
                set(obj.fstrain_x_span,         'enable', 'on');
                set(obj.fstrain_y_span,         'enable', 'on');
                if fstrain.x_span == 1
                    set(obj.fstrain_xmin,    	'enable', 'on');
                    set(obj.fstrain_xmax,    	'enable', 'on');
                end
                if fstrain.y_span == 1
                    set(obj.fstrain_ymin,    	'enable', 'on');
                    set(obj.fstrain_ymax,    	'enable', 'on');
                end
            end
        end
        
    case 'uicontrol_callback'
        %% Uicontrol callback
        
        % Who is calling
        wcbo            = gcbo;
        Whoiscalling    = get(wcbo, 'tag');
        
        % Get data
        fstrain = getappdata(fstrain_gui_handle, 'fstrain');
            
        
        switch Whoiscalling
            
            case 'fstrain_cell_num'
                
                if str2double(get(wcbo,  'string'))>2
                    if mod(str2double(get(wcbo,  'string')),1)==0
                        fstrain.cell_num   = str2double(get(wcbo,  'string'));
                    else
                        errordlg('The value must be an integer.');
                    end
                else
                    errordlg('The value must be larger than 2.');
                end
            
            case 'fstrain_resolution'
                
                if str2double(get(wcbo,  'string'))>5
                    if mod(str2double(get(wcbo,  'string')),1)==0
                        fstrain.resolution   = str2double(get(wcbo,  'string'));
                    else
                        errordlg('The value must be an integer.');
                    end
                else
                    errordlg('The value should be larger than 5.');
                end
            
            case 'fstrain_x_span'
                fstrain.x_span 	= get(wcbo,  'value');
                
                %Get data from other gui
                folder_gui_handle = findobj(0, 'tag', 'folder_gui_handle',        'type', 'figure');
                
                if fstrain.x_span == 1
                    % Set values to the min & max of the box size
                    try
                        fold         	= getappdata(folder_gui_handle, 'fold');
                        fstrain.xmin    = fold.NODES(1,1);
                        fstrain.xmax    = fold.NODES(1,end);
                    end
                else
                    fstrain.xmin = [];
                    fstrain.xmax = [];
                end
            
            case 'fstrain_xmin'
                
                %Get data from other gui
                folder_gui_handle = findobj(0, 'tag', 'folder_gui_handle',        'type', 'figure');
                
                try
                    fold              = getappdata(folder_gui_handle, 'fold');
                    
                    if str2double(get(wcbo,  'string')) < fold.NODES(1,1)
                        errordlg('The value should be outside the domain size.');
                        fstrain_setting('uicontrol_update')
                        return;
                    end
                end
                
                if str2double(get(wcbo,  'string')) < fstrain.xmax
                    fstrain.xmin    = str2double(get(wcbo,  'string'));
                else
                    errordlg('The value should be smaller than xmax.');
                    fstrain_setting('uicontrol_update')
                    return;
                end
                
            case 'fstrain_xmax'
                
                %Get data from other gui
                folder_gui_handle = findobj(0, 'tag', 'folder_gui_handle',        'type', 'figure');
                
                try
                    fold              = getappdata(folder_gui_handle, 'fold');
                    
                    if str2double(get(wcbo,  'string')) > fold.NODES(1,2)
                        errordlg('The value should be outside the domain size.');
                        fstrain_setting('uicontrol_update')
                        return;
                    end
                end
                
                if str2double(get(wcbo,  'string')) > fstrain.xmin
                    fstrain.xmax    = str2double(get(wcbo,  'string'));
                else
                    errordlg('The value should be larger than xmin.');
                    fstrain_setting('uicontrol_update')
                    return;
                end
                
            case 'fstrain_y_span'
                fstrain.y_span 	= get(wcbo,  'value');
                
                %Get data from other gui
                folder_gui_handle = findobj(0, 'tag', 'folder_gui_handle',        'type', 'figure');
                
                if fstrain.y_span == 1
                    % Set values to the min & max of the box size
                    try
                        fold         	= getappdata(folder_gui_handle, 'fold');
                        fstrain.ymin    = fold.NODES(2,1);
                        fstrain.ymax    = fold.NODES(2,end);
                    end
                else
                    fstrain.ymin = [];
                    fstrain.ymax = [];
                end
                            
            case 'fstrain_ymin'
                
                %Get data from other gui
                folder_gui_handle = findobj(0, 'tag', 'folder_gui_handle',        'type', 'figure');
                
                try
                    fold              = getappdata(folder_gui_handle, 'fold');
                    if str2double(get(wcbo,  'string')) < fold.NODES(2,1)
                        errordlg('The value should be outside the domain size.');
                        fstrain_setting('uicontrol_update')
                        return;
                    end
                end
                
                if str2double(get(wcbo,  'string')) < fstrain.ymax
                    fstrain.ymin    = str2double(get(wcbo,  'string'));
                else
                    errordlg('The value should be smaller than ymax.');
                    fstrain_setting('uicontrol_update')
                    return;
                end
                
            case 'fstrain_ymax'
                
                %Get data from other gui
                folder_gui_handle = findobj(0, 'tag', 'folder_gui_handle',        'type', 'figure');
                
                try
                    fold              = getappdata(folder_gui_handle, 'fold');
                    
                    if str2double(get(wcbo,  'string')) > fold.NODES(2,end)
                        errordlg('The value should be outside the domain size.');
                        fstrain_setting('uicontrol_update')
                        return;
                    end
                end
                
                if str2double(get(wcbo,  'string')) > fstrain.ymin
                    fstrain.ymax    = str2double(get(wcbo,  'string'));
                else
                    errordlg('The value should be larger than ymin.');
                    fstrain_setting('uicontrol_update')
                    return;
                end
                
        end
        
        % - Update data
        setappdata(fstrain_gui_handle, 'fstrain', fstrain);
        
        % - Enable buttons
        fstrain_setting('buttons_enable');
        
        % - Update Uicontrols
        fstrain_setting('uicontrol_update');
        
    case 'fstrain_apply'
        %% Apply 
        
        % Get data
        fstrain = getappdata(fstrain_gui_handle, 'fstrain');
        
        % Check if the main figure exist
        folder_gui_handle = findobj(0, 'tag', 'folder_gui_handle',        'type', 'figure');
        
        % Update the FOLDER GUI
%         try
            %  Get fold data
            fold        = getappdata(folder_gui_handle, 'fold');
            
            % Overwrite data
            fold.fstrain.cell_num   = fstrain.cell_num; 
            fold.fstrain.resolution = fstrain.resolution;
            fold.fstrain.x_span     = fstrain.x_span;
            fold.fstrain.xmin       = fstrain.xmin;
            fold.fstrain.xmax       = fstrain.xmax;
            fold.fstrain.y_span     = fstrain.y_span;
            fold.fstrain.ymin       = fstrain.ymin;
            fold.fstrain.ymax       = fstrain.ymax;
            
            % Update fold data
            setappdata(folder_gui_handle, 'fold', fold);
            
            % Update Main Plot
            folder('uicontrol_callback');
            
%         catch
%           errordlg('Main figure gone.');
%         end
        
    case 'fstrain_done'
        %% DONE
        
        % Apply changes
        fstrain_setting('fstrain_apply')
        
        % Close figure
        close(fstrain_gui_handle);
end
end


