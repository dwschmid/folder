function selection(Action)

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
selection_gui_handle = findobj(0, 'tag', 'selection_gui_handle', 'type', 'figure');

switch lower(Action)
    case 'initialize'
        %% INITIALIZE
        
        %  Delete figure if it already exists
        if ~isempty(selection_gui_handle)
            delete(selection_gui_handle);
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
        text_width      = 2*b_width;
        field_width     = 2*b_width;
        
        inter_height  = 5*(b_height+gap)+4*gap;
        region_height = 1*(b_height+gap)+4*gap;
        contr_height  = 1*(b_height+gap)+1*gap;
        
        fig_width       = text_width+field_width+3*gap;
        fig_height      = inter_height+region_height+6*gap;
        
        % Create dialog window
        selection_gui_handle = figure( ...
            'Name' ,'Selection Options', 'Units','pixels', 'tag','selection_gui_handle',...
            'NumberTitle', 'off', 'DockControls', 'off', 'MenuBar', 'none', 'ToolBar', 'none',...
            'Resize','off',...
            'pos', [Screensize(3)/5, Screensize(4)/2, fig_width, fig_height], 'Color',get(0, 'DefaultUipanelBackgroundColor'));
        
        b1                      = uiextras.VBox('Parent', selection_gui_handle);
        sel_upanel_interface    = uipanel('Parent', b1, 'Tag','sel_upanel_interface','Title','Interface');
        sel_upanel_region       = uipanel('Parent', b1, 'Tag','sel_upanel_region','Title', 'Regions');
        sel_upanel_controls     = uipanel('Parent', b1, 'Tag','sel_upanel_region');
        set( b1, 'Sizes', [inter_height region_height contr_height]);
        
        
        %% - Line color
        % Text
        uicontrol('Parent', sel_upanel_interface, 'style', 'text', 'String', 'Line Colour', 'HorizontalAlignment', 'left', ...
            'position', [gap, 4*(b_height+gap)+gap, text_width, b_height]);
        % Field
        obj.sel_line_color = uicontrol('Parent', sel_upanel_interface, 'style', 'pushbutton',...
            'callback',  @(a,b)  selection('uicontrol_callback'),...
            'tag', 'sel_line_color', ...
            'position', [gap+text_width+gap, 4*(b_height+gap)+gap, field_width, b_height]);
        
        %% - Line width
        % Text
        uicontrol('Parent', sel_upanel_interface, 'style', 'text', 'String', 'Line Width', 'HorizontalAlignment', 'left', ...
            'position', [gap, 3*(b_height+gap)+gap, text_width, b_height]);
        % Field
        obj.sel_line_width = uicontrol('Parent', sel_upanel_interface, 'style', 'edit', 'String', '', 'BackgroundColor','w',...
            'callback',  @(a,b)  selection('uicontrol_callback'),...
            'tag', 'sel_line_width', ...
            'position', [gap+text_width+gap, 3*(b_height+gap)+gap, field_width, b_height]);
        
         %% - Marker Size
        % Text
        uicontrol('Parent', sel_upanel_interface, 'style', 'text', 'String', 'Marker Size', 'HorizontalAlignment', 'left', ...
            'position', [gap, 2*(b_height+gap)+gap, text_width, b_height]);
        % Field
        obj.sel_maker_size = uicontrol('Parent', sel_upanel_interface, 'style', 'edit', 'String', '', 'BackgroundColor','w',...
            'callback',  @(a,b)  selection('uicontrol_callback'),...
            'tag', 'sel_maker_size', ...
            'position', [gap+text_width+gap, 2*(b_height+gap)+gap, field_width, b_height]);
        
        %% - Marker Face Color
        % Text
        uicontrol('Parent', sel_upanel_interface, 'style', 'text', 'String', 'Marker Face Colour', 'HorizontalAlignment', 'left', ...
            'position', [gap, 1*(b_height+gap)+gap, text_width, b_height]);
        % Field
        obj.sel_marker_color = uicontrol('Parent', sel_upanel_interface, 'style', 'pushbutton',...
            'callback',  @(a,b)  selection('uicontrol_callback'),...
            'tag', 'sel_marker_color', ...
            'position', [gap+text_width+gap, 1*(b_height+gap)+gap, field_width, b_height]);
        
        %% - Marker Edge Color
        % Text
        uicontrol('Parent', sel_upanel_interface, 'style', 'text', 'String', 'Marker Edge Colour', 'HorizontalAlignment', 'left', ...
            'position', [gap, gap, text_width, b_height]);
        % Field
        obj.sel_marker_edge_color = uicontrol('Parent', sel_upanel_interface, 'style', 'pushbutton',...
            'callback',  @(a,b)  selection('uicontrol_callback'),...
            'tag', 'sel_marker_edge_color', ...
            'position', [gap+text_width+gap, gap, field_width, b_height]);
        
        %% - Region Color
        % Text
        uicontrol('Parent', sel_upanel_region, 'style', 'text', 'String', 'Region Colour','HorizontalAlignment', 'left', ...
            'position', [gap, gap, text_width, b_height]);
        % Field
        obj.sel_region_color = uicontrol('Parent', sel_upanel_region, 'style', 'pushbutton',...
            'callback',  @(a,b)  selection('uicontrol_callback'),...
            'tag', 'sel_region_color', ...
            'position', [gap+text_width+gap, gap, field_width, b_height]);
        
        %% -Controls
        % Close Button
        uicontrol('Parent', sel_upanel_controls, 'style', 'pushbutton', 'String', 'Close',...
            'callback',  @(a,b)  close(gcf),...
            'position', [fig_width-gap-b_width, gap, b_width, b_height]);
        
        % Store in Figure Appdata
        setappdata(selection_gui_handle, 'obj', obj);
        
        % - Folder Default Values
        selection('default_values');
        
        % - Update Uicontrols
        selection('uicontrol_update');
        
        
    case 'default_values'
        %% DEFAULT VALUES
        
        sel = [];
        
        % find default data saved in folder_gui_handle
        folder_gui_handle = findobj(0, 'tag', 'folder_gui_handle', 'type', 'figure');
                
        if ~isempty(folder_gui_handle)
            
            % Get data
            fold  = getappdata(folder_gui_handle, 'fold');
            
            sel.line_color               = fold.selection.line_color;
            sel.line_width               = fold.selection.line_width;
            sel.marker_size              = fold.selection.marker_size;
            sel.marker_color             = fold.selection.marker_color;
            sel.marker_edge_color        = fold.selection.marker_edge_color;
            sel.region_color             = fold.selection.region_color;
        end
        
        setappdata(selection_gui_handle, 'sel', sel);
        
    case 'uicontrol_callback'
        %% UICONTROL_CALLBACK
        
        % Who is calling
        wcbo            = gcbo;
        Whoiscalling    = get(wcbo, 'tag');
        
        % Get data
        sel = getappdata(selection_gui_handle, 'sel');
        
        switch Whoiscalling
            
            case 'sel_line_color'
                
                col = uisetcolor;
                if size(col,2)>1
                    sel.line_color = col;
                end
                
            case 'sel_line_width'
                
                if str2double(get(wcbo,  'string')) > 0
                    sel.line_width = str2double(get(wcbo,  'string'));
                else
                    warndlg('Line width must be a positive value.', 'Error!', 'modal');
                    folder('uicontrol_update');
                    return;
                end
                
            case 'sel_maker_size'
                
                if str2double(get(wcbo,  'string')) > 0
                    sel.marker_size = str2double(get(wcbo,  'string'));
                else
                    warndlg('Marker size must be a positive value.', 'Error!', 'modal');
                    folder('uicontrol_update');
                    return;
                end
                
            case 'sel_marker_color'
                
                col = uisetcolor;
                if size(col,2)>1
                    sel.marker_color = col;
                end
               
            case 'sel_marker_edge_color'
                
                col = uisetcolor;
                if size(col,2)>1
                    sel.marker_edge_color = col;
                end
                
            case 'sel_region_color'
                
                col = uisetcolor;
                if size(col,2)>1
                    sel.region_color = col;
                end
                
            case 'sel_done'
                delete(selection_gui_handle);
                return;
                
        end
        
        % Update data
        setappdata(selection_gui_handle, 'sel', sel);
        
        % Update uicontrols
        selection('uicontrol_update')
        
        % Apply changes
        selection('sel_apply')
        
        
    case 'uicontrol_update'
        %% UICONTROL UPDATE
        
        % Get data
        obj = getappdata(selection_gui_handle, 'obj');
        sel = getappdata(selection_gui_handle, 'sel');
        
        set(obj.sel_line_color,      	'Backgroundcolor', sel.line_color);
        set(obj.sel_line_width,         'string',          num2str(sel.line_width));
        set(obj.sel_maker_size,         'string',          num2str(sel.marker_size));
        set(obj.sel_marker_color,       'Backgroundcolor', sel.marker_color);
        set(obj.sel_marker_edge_color, 	'Backgroundcolor', sel.marker_edge_color);
        set(obj.sel_region_color,       'Backgroundcolor', sel.region_color);
        
    case 'sel_apply'
        %% APPLY
        
        % Get data
        sel = getappdata(selection_gui_handle, 'sel');
        
        % Find main gui
        folder_gui_handle = findobj(0, 'tag', 'folder_gui_handle', 'type', 'figure');
        
        if ~isempty(folder_gui_handle)
            
            % Get data
            fold  = getappdata(folder_gui_handle, 'fold');
            
            fold.selection.line_color           = sel.line_color;
            fold.selection.line_width        	= sel.line_width;
            fold.selection.marker_size          = sel.marker_size;
            fold.selection.marker_color         = sel.marker_color;
            fold.selection.marker_edge_color    = sel.marker_edge_color;
            fold.selection.region_color      	= sel.region_color;
            
            % Update data
            setappdata(folder_gui_handle, 'fold', fold);
            
            try
                folder('plot_update')
            catch
                errordlg('Main figure gone.');
            end
            
        end    
end