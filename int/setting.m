function setting(Action)

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
popts_gui_handle = findobj(0, 'tag', 'popts_gui_handle', 'type', 'figure');

switch lower(Action)
    case 'initialize'
        
        %  Delete figure if it already exists
        if ~isempty(popts_gui_handle)
            delete(popts_gui_handle);
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
        fig_height      = 13*(b_height+gap)+6*(4*gap)+gap;
        
        % Create dialog window
        popts_gui_handle = figure( ...
            'Name' ,'Plot Option', 'Units','pixels', 'tag','popts_gui_handle',...
            'NumberTitle', 'off', 'DockControls', 'off', 'MenuBar', 'none', 'ToolBar', 'none',...
            'Resize','off',...
            'pos', [Screensize(3)/5, (Screensize(4)-fig_height)/2, fig_width, fig_height], 'Color',get(0, 'DefaultUipanelBackgroundColor'));
        
        popts_upanel_general    = uiextras.VBox('Parent', popts_gui_handle);
        popts_upanel_axis       = uipanel('Parent', popts_upanel_general, 'Tag','popts_upanel_yaxis','Title','Scale Axis');
        popts_upanel_layer      = uipanel('Parent', popts_upanel_general, 'Tag','popts_upanel_layer','Title','Layer Outline');
        popts_upanel_mesh       = uipanel('Parent', popts_upanel_general, 'Tag','popts_upanel_mesh','Title', 'Mesh');
        popts_upanel_markers  	= uipanel('Parent', popts_upanel_general, 'Tag','popts_upanel_markers','Title', 'Passive Markers');
        popts_upanel_fstrain  	= uipanel('Parent', popts_upanel_general, 'Tag','popts_upanel_markers','Title', 'Finite Strain');
        popts_upanel_vector  	= uipanel('Parent', popts_upanel_general, 'Tag','popts_upanel_markers','Title', 'Vector');
        popts_upanel_tensor   	= uipanel('Parent', popts_upanel_general, 'Tag','popts_upanel_markers','Title', 'Tensor');
        popts_upanel_control   	= uipanel('Parent', popts_upanel_general, 'Tag','popts_upanel_markers');
        yaxis_height            = 1*(b_height+gap)+4*gap;
        layer_height            = 2*(b_height+gap)+4*gap;
        mesh_height             = 2*(b_height+gap)+4*gap;
        markers_height          = 2*(b_height+gap)+4*gap;
        fstrain_height          = 2*(b_height+gap)+4*gap;
        vector_height           = 2*(b_height+gap)+4*gap;
        tensor_height           = 2*(b_height+gap)+4*gap;
        control_height          = 1*(b_height+gap)+gap;
        set( popts_upanel_general, 'Sizes', [yaxis_height layer_height mesh_height markers_height fstrain_height vector_height tensor_height control_height]);
        
        % Vertical exaggeration
        uicontrol('Parent', popts_upanel_axis, 'style', 'text', 'String', 'Vertical Exaggeration', 'HorizontalAlignment', 'left',...
            'position', [gap, 0*(b_height+gap)+gap, text_width, b_height]);
        % Field
        obj.popts_axis_y = uicontrol('Parent', popts_upanel_axis, 'style', 'edit','String','',...
            'callback',  @(a,b)  setting('uicontrol_callback'),...
            'tag', 'popts_axis_y', 'BackgroundColor','w',...
            'position', [gap+text_width+gap, 0*(b_height+gap)+gap, field_width, b_height]);
        
        % Layer Outline Thickness
        uicontrol('Parent', popts_upanel_layer, 'style', 'text', 'String', 'Line Thickness','HorizontalAlignment', 'left', ...
            'position', [gap, 1*(b_height+gap)+gap, text_width, b_height],...
            'tooltipstring','Thickness of the line that outlines the layer.');
        % Field       
        obj.popts_layer_thick = uicontrol('Parent', popts_upanel_layer, 'style', 'edit','String','',...
            'callback',  @(a,b)  setting('uicontrol_callback'),...
            'tag', 'popts_layer_thick', 'BackgroundColor','w',...
            'position', [gap+text_width+gap, 1*(b_height+gap)+gap, field_width, b_height]);
        
        % Layer Outline Color
        uicontrol('Parent', popts_upanel_layer, 'style', 'text', 'String', 'Line Colour', 'HorizontalAlignment', 'left',...
            'position', [gap, 0*(b_height+gap)+gap, text_width, b_height],...
            'tooltipstring','Colour of the line that outlines the layer.');
        % Field
        obj.popts_layer_color = uicontrol('Parent', popts_upanel_layer, 'style', 'pushbutton',...
            'callback',  @(a,b)  setting('uicontrol_callback'),...
            'tag', 'popts_layer_color', ...
            'position', [gap+text_width+gap, 0*(b_height+gap)+gap, field_width, b_height]);
        
        % Mesh Thickness
        uicontrol('Parent', popts_upanel_mesh, 'style', 'text', 'String', 'Mesh Thickness', 'HorizontalAlignment', 'left',...
            'position', [gap, 1*(b_height+gap)+gap, text_width, b_height],...
            'tooltipstring','Thickness of the mesh lines.');
        % Field
        obj.popts_mesh_thick = uicontrol('Parent', popts_upanel_mesh, 'style', 'edit','String','',...
            'callback',  @(a,b)  setting('uicontrol_callback'),...
            'tag', 'popts_mesh_thick', 'BackgroundColor','w',...
            'position', [gap+text_width+gap, 1*(b_height+gap)+gap, field_width, b_height]);
        
        % Mesh Color
        uicontrol('Parent', popts_upanel_mesh, 'style', 'text', 'String', 'Mesh Colour', 'HorizontalAlignment', 'left',...
            'position', [gap, 0*(b_height+gap)+gap, text_width, b_height],...
            'tooltipstring','Colour of the mesh lines.');
        % Field
        obj.popts_mesh_color = uicontrol('Parent', popts_upanel_mesh, 'style', 'pushbutton',...
            'callback',  @(a,b)  setting('uicontrol_callback'),...
            'tag', 'popts_mesh_color', ...
            'position', [gap+text_width+gap, 0*(b_height+gap)+gap, field_width, b_height]);
      
        % Passive Markers Thickness
        uicontrol('Parent', popts_upanel_markers, 'style', 'text', 'String', 'Line Thickness', 'HorizontalAlignment', 'left',...
            'position', [gap, 1*(b_height+gap)+gap, text_width, b_height],...
            'tooltipstring','Thickness of the passive markers lines.');
        % Field
        obj.popts_marker_thick = uicontrol('Parent', popts_upanel_markers, 'style', 'edit','String','',...
            'callback',  @(a,b)  setting('uicontrol_callback'),...
            'tag', 'popts_marker_thick', 'BackgroundColor','w',...
            'position', [gap+text_width+gap, 1*(b_height+gap)+gap, field_width, b_height]);
        
        % Passive Markers Color
        uicontrol('Parent', popts_upanel_markers, 'style', 'text', 'String', 'Passive Marker Colour', 'HorizontalAlignment', 'left',...
            'position', [gap, 0*(b_height+gap)+gap, text_width, b_height],...
            'tooltipstring','Colour of the passive markers lines.');
        % Field
        obj.popts_marker_color = uicontrol('Parent', popts_upanel_markers, 'style', 'pushbutton',...
            'callback',  @(a,b)  setting('uicontrol_callback'),...
            'tag', 'popts_marker_color', ...
            'position', [gap+text_width+gap, 0*(b_height+gap)+gap, field_width, b_height]);
        
        % Finite Strain Thickness
        uicontrol('Parent', popts_upanel_fstrain, 'style', 'text', 'String', 'Line Thickness', 'HorizontalAlignment', 'left',...
            'position', [gap, 1*(b_height+gap)+gap, text_width, b_height],...
            'tooltipstring','Thickness of the finite strain ellipse lines.');
        % Field
        obj.popts_fstrain_thick = uicontrol('Parent', popts_upanel_fstrain, 'style', 'edit','String','',...
            'callback',  @(a,b)  setting('uicontrol_callback'),...
            'tag', 'popts_fstrain_thick', 'BackgroundColor','w',...
            'position', [gap+text_width+gap, 1*(b_height+gap)+gap, field_width, b_height]);
        
        % Finite Strain Color
        uicontrol('Parent', popts_upanel_fstrain, 'style', 'text', 'String', 'Strain Ellipse Colour', 'HorizontalAlignment', 'left',...
            'position', [gap, 0*(b_height+gap)+gap, text_width, b_height],...
            'tooltipstring','Colour of the finite strain ellipse lines.');
        % Field
        obj.popts_fstrain_color = uicontrol('Parent', popts_upanel_fstrain, 'style', 'pushbutton',...
            'callback',  @(a,b)  setting('uicontrol_callback'),...
            'tag', 'popts_fstrain_color', ...
            'position', [gap+text_width+gap, 0*(b_height+gap)+gap, field_width, b_height]);
        
                
        % Vector Thickness
        uicontrol('Parent', popts_upanel_vector, 'style', 'text', 'String', 'Vector Thickness','HorizontalAlignment', 'left', ...
            'position', [gap, 1*(b_height+gap)+gap, text_width, b_height],...
            'tooltipstring','Arrow thickness.');
        % Field
        obj.popts_vector_thick = uicontrol('Parent', popts_upanel_vector, 'style', 'edit', 'String', '', 'BackgroundColor','w',...
            'callback',  @(a,b)  setting('uicontrol_callback'),...
            'tag', 'popts_vector_thick', ...
            'position', [gap+text_width+gap, 1*(b_height+gap)+gap, field_width, b_height]);
        
        % Color
        uicontrol('Parent', popts_upanel_vector, 'style', 'text', 'String', 'Vector Colour', 'HorizontalAlignment', 'left',...
            'position', [gap, 0*(b_height+gap)+gap, text_width, b_height],...
            'tooltipstring','Arrow colour.');
        % Field
        obj.popts_vector_color = uicontrol('Parent', popts_upanel_vector, 'style', 'pushbutton',...
            'callback',  @(a,b)  setting('uicontrol_callback'),...
            'tag', 'popts_vector_color', ...
            'position', [gap+text_width+gap, 0*(b_height+gap)+gap, field_width, b_height]);
                
        % Tensor Thickness
        uicontrol('Parent', popts_upanel_tensor, 'style', 'text', 'String', 'Glyph Line Thickness','HorizontalAlignment', 'left', ...
            'position', [gap, 1*(b_height+gap)+gap, text_width, b_height],...
            'tooltipstring','Glyph thickness.');
        % Field
        obj.popts_tensor_thick = uicontrol('Parent', popts_upanel_tensor, 'style', 'edit', 'String', '', 'BackgroundColor','w',...
            'callback',  @(a,b)  setting('uicontrol_callback'),...
            'tag', 'popts_tensor_thick', ...
            'position', [gap+text_width+gap, 1*(b_height+gap)+gap, field_width, b_height]);
        
        % Color
        uicontrol('Parent', popts_upanel_tensor, 'style', 'text', 'String', 'Glyph Colour', 'HorizontalAlignment', 'left',...
            'position', [gap, 0*(b_height+gap)+gap, text_width, b_height],...
            'tooltipstring','Glyph colours.');
        % Field
        obj.popts_tensor_color1 = uicontrol('Parent', popts_upanel_tensor, 'style', 'pushbutton',...
            'callback',  @(a,b)  setting('uicontrol_callback'),...
            'String','positive',...
            'tag', 'popts_tensor_color1', ...
            'position', [2*(b_width+gap), 0*(b_height+gap)+gap, b_width, b_height]);
        % Field
        obj.popts_tensor_color2 = uicontrol('Parent', popts_upanel_tensor, 'style', 'pushbutton',...
            'callback',  @(a,b)  setting('uicontrol_callback'),...
            'String','negative',...
            'tag', 'popts_tensor_color2', ...
            'position', [3*(b_width+gap), 0*(b_height+gap)+gap, b_width, b_height]);
        
        % Close Button
        uicontrol('Parent', popts_upanel_control, 'style', 'pushbutton', 'String', 'Close',...
            'callback',  @(a,b) close(gcf),...
            'position', [fig_width-(b_width+gap), gap, b_width, b_height]);
                
        
        % Store in Figure Appdata
        setappdata(popts_gui_handle, 'obj', obj);
        
        % - Folder Default Values
        setting('default_values');
        
        % - Update Uicontrols
        setting('uicontrol_update');
        
        % - Enable buttons
        setting('buttons_enable');
        
        
    case 'default_values'
        %% Default values
        
        folder_gui_handle = findobj(0, 'tag', 'folder_gui_handle',        'type', 'figure');
        
        if ~isempty(folder_gui_handle)
            
            fold    = getappdata(folder_gui_handle, 'fold');
            
            popts.axis_y           = fold.popts.axis_y;
            popts.layer_thick      = fold.popts.layer_thick;
            popts.layer_color      = fold.popts.layer_color;
            
            popts.mesh_thick       = fold.popts.mesh_thick;
            popts.mesh_color       = fold.popts.mesh_color;
            
            popts.marker_thick     = fold.popts.marker_thick;
            popts.marker_color     = fold.popts.marker_color;
            
            popts.fstrain_thick    = fold.popts.fstrain_thick;
            popts.fstrain_color    = fold.popts.fstrain_color;

            popts.vector_thick     = fold.popts.vector_thick;
            popts.vector_color     = fold.popts.vector_color;
            
            popts.tensor_thick     = fold.popts.tensor_thick;
            popts.tensor_color1    = fold.popts.tensor_color1;
            popts.tensor_color2    = fold.popts.tensor_color2;
            
        end
        
        setappdata(popts_gui_handle, 'popts', popts);
        
    case 'uicontrol_update'
        %% Update Uicontrols
        
        % Get data
        obj   = getappdata(popts_gui_handle, 'obj');
        popts = getappdata(popts_gui_handle, 'popts');

        set(obj.popts_axis_y,               'string', num2str(popts.axis_y));
        
        set(obj.popts_layer_thick,          'string', num2str(popts.layer_thick));
        set(obj.popts_layer_color,          'Backgroundcolor', popts.layer_color);
        
        set(obj.popts_mesh_thick,           'string', num2str(popts.mesh_thick));
        set(obj.popts_mesh_color,           'Backgroundcolor', popts.mesh_color);
        
        set(obj.popts_marker_thick,         'string', num2str(popts.marker_thick));
        set(obj.popts_marker_color,         'Backgroundcolor', popts.marker_color);
        
        set(obj.popts_fstrain_thick,        'string', num2str(popts.fstrain_thick));
        set(obj.popts_fstrain_color,        'Backgroundcolor', popts.fstrain_color);
        
        set(obj.popts_vector_thick,         'string', num2str(popts.vector_thick));
        set(obj.popts_vector_color,         'Backgroundcolor', popts.vector_color);
        
        set(obj.popts_tensor_thick,         'string', num2str(popts.tensor_thick));
        set(obj.popts_tensor_color1,        'Backgroundcolor', popts.tensor_color1);
        set(obj.popts_tensor_color2,        'Backgroundcolor', popts.tensor_color2);
        
    case 'buttons_enable'
        %% Buttons enable
        
        % Get data
        obj   = getappdata(popts_gui_handle, 'obj');
                        
        set(obj.popts_vector_thick,         'enable', 'off');
        set(obj.popts_vector_color,         'enable', 'off');
        set(obj.popts_tensor_thick,         'enable', 'off');
        set(obj.popts_tensor_color1,        'enable', 'off');
        set(obj.popts_tensor_color2,        'enable', 'off');
        
        % Switch on vector options only when fold run data exist
        % Find other gui
        folder_gui_handle = findobj(0, 'tag', 'folder_gui_handle',        'type', 'figure');
        try      
            %  Get fold data
            fold        = getappdata(folder_gui_handle, 'fold');
            
            if isfield(fold, 'NODES_run')
                
                set(obj.popts_vector_thick,         'enable', 'on');
                set(obj.popts_vector_color,         'enable', 'on');
                set(obj.popts_tensor_thick,         'enable', 'on');
                set(obj.popts_tensor_color1,        'enable', 'on');
                set(obj.popts_tensor_color2,        'enable', 'on');
                
            end 
        end
        
    case 'uicontrol_callback'
        %% Uicontrol callback
        
        % Who is calling
        wcbo            = gcbo;
        Whoiscalling    = get(wcbo, 'tag');
        
        % Get data
        popts = getappdata(popts_gui_handle, 'popts');
            
        
        switch Whoiscalling
            
            case 'popts_axis_y'
                
                if str2double(get(wcbo,  'string'))>0
                    popts.axis_y   = str2double(get(wcbo,  'string'));
                else
                    errordlg('The value must be larger than 0.');
                end
                
            case 'popts_layer_thick'
                
                if str2double(get(wcbo,  'string'))>=1
                    popts.layer_thick   = str2double(get(wcbo,  'string'));
                else
                    errordlg('The value must be larger than 1.');
                end
            
            case 'popts_layer_color'
                
                col = uisetcolor;
                if size(col,2)>1
                    popts.layer_color = col;
                end
            
            case 'popts_mesh_thick'
                
                if str2double(get(wcbo,  'string'))>=1
                    popts.mesh_thick   = str2double(get(wcbo,  'string'));
                else
                    errordlg('The value must be larger than 1.');
                end
                
            case 'popts_mesh_color'
                
                col = uisetcolor;
                if size(col,2)>1
                    popts.mesh_color = col;
                end
                
            case 'popts_marker_thick'
                
                if str2double(get(wcbo,  'string'))>=1
                    popts.marker_thick   = str2double(get(wcbo,  'string'));
                else
                    errordlg('The value must be larger than 1.');
                end
                
            case 'popts_marker_color'
                
                col = uisetcolor;
                if size(col,2)>1
                    popts.marker_color = col;
                end
                
            case 'popts_fstrain_thick'
                
                if str2double(get(wcbo,  'string'))>=1
                    popts.fstrain_thick   = str2double(get(wcbo,  'string'));
                else
                    errordlg('The value must be larger than 1.');
                end
                
            case 'popts_fstrain_color'
                
                col = uisetcolor;
                if size(col,2)>1
                    popts.fstrain_color = col;
                end
                
            case 'popts_vector_thick'
                if str2double(get(wcbo,  'string')) >= 1
                    popts.vector_thick  = str2double(get(wcbo,  'string'));
                else
                    errordlg('The value should be larger than 1.');
                    return;
                end
                
            case 'popts_vector_color'
                
                col = uisetcolor;
                if size(col,2)>1
                    popts.vector_color = col;
                end
                
            case 'popts_tensor_thick'
                
                if str2double(get(wcbo,  'string'))>=1
                    popts.tensor_thick  = str2double(get(wcbo,  'string'));
                else
                    errordlg('The value should be larger than 1.');
                    return;
                end
                
            case 'popts_tensor_color1'
                
                col = uisetcolor;
                if size(col,2)>1
                    popts.tensor_color1 = col;
                end
                
            case 'popts_tensor_color2'
                
                col = uisetcolor;
                if size(col,2)>1
                    popts.tensor_color2 = col;
                end
                
        end
        
        % - Update data
        setappdata(popts_gui_handle, 'popts', popts);
        
        % - Enable buttons
        setting('buttons_enable');
        
        % - Update Uicontrols
        setting('uicontrol_update');
        
        % - Update Main GUI
        setting('opts_apply');
        
    case 'opts_apply'
        %% Apply 
        
        % Get data
        popts = getappdata(popts_gui_handle, 'popts');
        
        % Check if the main figure exist
        folder_gui_handle = findobj(0, 'tag', 'folder_gui_handle',        'type', 'figure');
        
        % Update the FOLDER GUI
        try
            %  Get fold data
            fold        = getappdata(folder_gui_handle, 'fold');
            
            % Overwrite data
            fold.popts.axis_y           = popts.axis_y;
            
            fold.popts.layer_thick      = popts.layer_thick;
            fold.popts.layer_color      = popts.layer_color;
            
            fold.popts.mesh_thick       = popts.mesh_thick;
            fold.popts.mesh_color       = popts.mesh_color;
            
            fold.popts.marker_thick     = popts.marker_thick;
            fold.popts.marker_color     = popts.marker_color;
            
            fold.popts.fstrain_thick    = popts.fstrain_thick;
            fold.popts.fstrain_color    = popts.fstrain_color;
            
            fold.popts.vector_thick     = popts.vector_thick;
            fold.popts.vector_color     = popts.vector_color;
            
            fold.popts.tensor_thick     = popts.tensor_thick;
            fold.popts.tensor_color1    = popts.tensor_color1;
            fold.popts.tensor_color2    = popts.tensor_color2;
            
            % Update fold data
            setappdata(folder_gui_handle, 'fold', fold);
            
            % Update Main Plot
            folder('plot_update');
            
        catch err
          errordlg(err.message, 'Error');
        end
        
        
end
end


