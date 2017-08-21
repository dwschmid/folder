function materials(Action)

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
materials_gui_handle = findobj(0, 'tag', 'materials_gui_handle', 'type', 'figure');

switch lower(Action)
    case 'initialize'
        
        %  Delete figure if it already exists
        if ~isempty(materials_gui_handle)
            delete(materials_gui_handle);
        end
        
        %  Add current path and subfolders
        addpath(genpath(pwd));
        
        
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
            
        %% - Figure Setup
        Screensize      = get(0, 'ScreenSize');
        fig_width       = 13*(b_width+gap);
        fig_height      = 500;
        gui_x           = (Screensize(3)-fig_width)/2;
        gui_y           = (Screensize(4)-fig_height-6*gap)/2;
       
        % Create dialog window
        materials_gui_handle = figure( ...
            'Name' ,'Materials', 'Units','pixels', 'tag','materials_gui_handle',...
            'NumberTitle', 'off', 'DockControls', 'off', 'MenuBar', 'none', 'ToolBar', 'none',...
            'Resize','on',...
            'pos', [gui_x, gui_y, fig_width, fig_height], 'Color',get(0, 'DefaultUipanelBackgroundColor'));
        
        % Save data
        setappdata(materials_gui_handle, 'b_height', b_height);
        setappdata(materials_gui_handle, 'b_width',  b_width);
        setappdata(materials_gui_handle, 'gap',      gap);
        
        %% - Menu Entries
        %  File
        h1  = uimenu('Parent',materials_gui_handle, 'Label','File');
        
        %  Load
        uimenu('Parent',h1, 'Label', 'Load Data', 'tag', 'materials_load', ...
            'Callback', @(a,b) materials('materials_load'), 'Separator','off', 'enable', 'on', 'Accelerator', 'L');
        %  Save
        uimenu('Parent',h1, 'Label', 'Save Data', 'tag', 'materials_save', ...
            'Callback', @(a,b) materials('materials_save'), 'Separator','off', 'enable', 'on', 'Accelerator', 'S');
        %  Restore
        uimenu('Parent',h1, 'Label', 'Restore Default Data', 'tag', 'materials_restore', ...
            'Callback', @(a,b) materials('materials_restore'), 'Separator','off', 'enable', 'on', 'Accelerator', 'D');
        %  Exit
        uimenu('Parent',h1, 'Label', 'Exit', ...
            'Callback', @(a,b) close(gcf), 'Separator','on', 'enable', 'on', 'Accelerator', 'Q');
        
        
        %% -TABLE
        columnname =   {'No.','Name', 'm', '<html>m<sub>0</sub>/m</html>', '<html>m<sub>inf</sub>/m</html>', 'n', '<html>Q (kJmol<sup>-1</sup>)</html>',...
                        '<html>log<sub>10</sub>A (MPa<sup>-n</sup>s<sup>-1</sup>)</html>', 'Color','Remarks'};
        columnformat = {'numeric','char', 'numeric', 'numeric', 'numeric','numeric','numeric','char'};
        
        b1                          = uiextras.VBox('Parent', materials_gui_handle);
        obj.materials_upanel_table  = uitable('Parent', b1, 'Tag','materials_upanel_table',...
                                              'ColumnName', columnname,'RowName',[],'ColumnFormat', columnformat,...
                                              'ColumnWidth',{b_width/2 2*b_width 'auto' 'auto' 'auto' 'auto' 'auto' 'auto' 'auto' 4*b_width},...
                                              'CellSelectionCallback', @selection );
                                          
        materials_upanel_controls   = uipanel('Parent', b1, 'Tag','tip_upanel_vis');
        set( b1, 'Sizes', [-1 b_height+2*gap]);
        
        %% -CONTROLS
        % New Button
        uicontrol('Parent', materials_upanel_controls, 'style', 'pushbutton', 'String', 'New',...
            'tag', 'materials_new', ...
            'callback',  @(a,b) new_material,...
            'position', [gap, gap, b_width, b_height]);
        % Modify Button
        obj.materials_modify = uicontrol('Parent', materials_upanel_controls, 'style', 'pushbutton', 'String', 'Modify',...
            'tag', 'materials_modify', ...
            'callback',  @(a,b)  new_material('modify'),...
            'position', [gap+(b_width+gap), gap, b_width, b_height]);
        % Remove Button
        obj.materials_remove = uicontrol('Parent', materials_upanel_controls, 'style', 'pushbutton', 'String', 'Remove',...
            'tag', 'materials_remove', ...
            'callback',  @(a,b)  materials('remove'),...
            'position', [gap+2*(b_width+gap), gap, b_width, b_height]);
        
        % Move Up
        obj.materials_move_up = uicontrol('Parent', materials_upanel_controls, 'style', 'pushbutton', 'String', 'Up',...
            'tag', 'materials_move_up', ...
            'callback',  @(a,b)  materials('move_up'),...
            'position', [gap+4*(b_width+gap)-3*gap, gap, b_width, b_height]);
        % Move Down
        obj.materials_move_down = uicontrol('Parent', materials_upanel_controls, 'style', 'pushbutton', 'String', 'Down',...
            'tag', 'materials_move_down', ...
            'callback',  @(a,b)  materials('move_down'),...
            'position', [gap+5*(b_width+gap)-3*gap, gap, b_width, b_height]);
        
        % Apply Button
        obj.materials_apply = uicontrol('Parent', materials_upanel_controls, 'style', 'pushbutton', 'String', 'Apply',...
            'tag', 'materials_apply', ...
            'callback',  @(a,b)  materials('materials_apply'),...
            'position', [fig_width-3*(b_width+gap), gap, b_width, b_height]);
        
        % Done Button
        obj.materials_done = uicontrol('Parent', materials_upanel_controls, 'style', 'pushbutton', 'String', 'Done',...
            'tag', 'materials_done', ...
            'callback',  @(a,b)  materials('materials_done'),...
            'position', [fig_width-2*(b_width+gap), gap, b_width, b_height]);
        
        % Cancel Button
        uicontrol('Parent', materials_upanel_controls, 'style', 'pushbutton', 'String', 'Cancel',...
            'tag', 'materials_exit', ...
            'callback',  @(a,b)  close(gcf),...
            'position', [fig_width-(b_width+gap), gap, b_width, b_height]);
        
        % Store in Figure Appdata
        setappdata(materials_gui_handle, 'obj', obj);
        
        % - Deafault values
        materials('default_values')
        
        % - Table update
        materials('update_table')
        
        
    case 'default_values'
        %% DEFAULT VALUES
        
        % Find main gui
        folder_gui_handle = findobj(0, 'tag', 'folder_gui_handle',        'type', 'figure');
        fold              = getappdata(folder_gui_handle, 'fold');
        
        rheology.data   = fold.material_data;
        rheology.path   = fold.folder_path;
        rheology.line 	= 0;
        
        % - Update data
        setappdata(materials_gui_handle, 'rheology', rheology);
        
        
    case 'update_table'
        %% TABLE UPDATE
        % Get data
        obj       = getappdata(materials_gui_handle, 'obj'); 
        rheology  = getappdata(materials_gui_handle, 'rheology'); 
        plot_data = rheology.data;
        
        % Cell with color
        for i = 1:size(plot_data,1)
            if ~isempty(plot_data{i,9})
                col = dec2hex(round(plot_data{i,9}*255),2)';
                col = ['#';col(:)]';
                plot_data(i,9) = strcat('<html><table border=0 bgcolor=',col,',<font color=',col,',><TR><TD>',{'chose color'},'</TD></TR> </table></html>');
            end
        end
        
        % Mark selected line
        if rheology.line>0
            for i = [1:8 10]
                plot_data(rheology.line,i) = strcat('<html><table border=0 width=400 <TR><TD><b>',{plot_data{rheology.line,i}},'</b></TD></TR> </table></html>');
            end
        end
        
        % Update table
        set(obj.materials_upanel_table,'Data',plot_data)
        
        % - Enable buttons
        materials('buttons_enable')
        
    case 'buttons_enable'
        %% BUTTONS ENABLE
        
        % Get data
        obj       = getappdata(materials_gui_handle, 'obj'); 
        rheology = getappdata(materials_gui_handle, 'rheology'); 
        line     = rheology.line;
        
        % Allow for changes only when no data run exists
        flag = 1;
        
        % Find main gui
        folder_gui_handle = findobj(0, 'tag', 'folder_gui_handle', 'type', 'figure');
               
        if ~isempty(folder_gui_handle)
            
            % Get data
            fold  = getappdata(folder_gui_handle, 'fold');
            
            if isfield(fold, 'NODES_run')
                flag = 0; 
            end
        end
        
        if flag == 1
            set(obj.materials_modify,           'enable', 'on');
            set(obj.materials_remove,           'enable', 'on');
            set(obj.materials_move_up,          'enable', 'on');
            set(obj.materials_move_down,        'enable', 'on');
            
            if line == 0
                set(obj.materials_modify,       'enable', 'off');
                set(obj.materials_remove,       'enable', 'off');
                set(obj.materials_move_up,      'enable', 'off');
                set(obj.materials_move_down,    'enable', 'off');
            elseif line == 1;
                set(obj.materials_move_up,      'enable', 'off');
            elseif line == size(rheology.data,1)
                set(obj.materials_move_down,    'enable', 'off');
            end
        else
            set(obj.materials_modify,           'enable', 'on');
            set(obj.materials_remove,           'enable', 'off');
            set(obj.materials_move_up,          'enable', 'off');
            set(obj.materials_move_down,        'enable', 'off');
        end
        
    case 'materials_apply'
        %% APPLY
        
        % Update main gui if exists        
        try
            folder('uicontrol_callback');
        catch err
            errordlg(err.message);
            return;
        end
     
	case 'materials_done'
        %% DONE
        
        % Apply changes
        materials('materials_apply')
        
        % Close figure
        close(materials_gui_handle);
        
    case 'remove'
        %% REMOVE
        
        % Get data
        rheology = getappdata(materials_gui_handle, 'rheology');
        
        % Check if number of materials is not smaller than the
        % material numbers values
        folder_gui_handle = findobj(0, 'tag', 'folder_gui_handle', 'type', 'figure');
        fold    = getappdata(folder_gui_handle, 'fold');
        
        idx = find(vertcat(fold.region.material)>size(rheology.data,1));
        if ~isempty(idx)
            fold.region(idx).material = 1;
        end
        
        if size(rheology.data,1)>1
            data     = rheology.data;
            % Update numbering
            if rheology.line<size(rheology.data,1)
                data(rheology.line+1:end,1) = data(rheology.line:end-1,1);
            end
            data(rheology.line,:) = [];
            rheology.data = data;
        else
            errordlg('Cannot remove all the materials.');
            return;
        end
        
        if rheology.line > 1
            rheology.line = rheology.line-1;
        else
            rheology.line = 1;
        end
        
        % - Update data
        setappdata(materials_gui_handle, 'rheology', rheology);
        
        % - Table update
        materials('update_table')
        
        
    case 'move_up'
        %% MOVE UP
        
        % Get data
        rheology = getappdata(materials_gui_handle, 'rheology'); 
        
        data = rheology.data;
        line = rheology.line;
        
        if line<=size(data,1)
            
            temp = 1:size(data,1);
            temp(line) = line-1.5;
            [temp, order] = sort(temp);
            
            reordered_data = data;
            for i = 1:size(data,1);
                reordered_data(i,2:end) = data(order(i),2:end);
            end
            
            rheology.data = reordered_data;
        end
        
        rheology.line = line-1;
        
        % - Update data
        setappdata(materials_gui_handle, 'rheology', rheology);
        
        % - Table update
        materials('update_table')
        
    case 'move_down'
        %% MOVE DOWN
        
         % Get data
        rheology = getappdata(materials_gui_handle, 'rheology'); 
        
        data = rheology.data;
        line = rheology.line;
        
        if line<=size(data,1)-1
            
            temp = 1:size(data,1);
            temp(line) = line+1.5;
            [temp, order] = sort(temp);
            
            reordered_data = data;
            for i = 1:size(data,1);
                reordered_data(i,2:end) = data(order(i),2:end);
            end
            
            rheology.data = reordered_data;
        end
        
        rheology.line = line+1;
        
        % - Update data
        setappdata(materials_gui_handle, 'rheology', rheology);
        
        % - Table update
        materials('update_table')
        
    case 'materials_load'
        %% LOAD
        
        % Get data
        rheology = getappdata(materials_gui_handle, 'rheology'); 
        
        %  Load in files
        [filename, pathname] = uigetfile([rheology.path,'rheology',filesep,'*.mat'],'Pick a file');
        
        if length(filename)==1 && filename==0
            return;
        end
  
        try
            Input_data  = load([pathname,filename]);
            data        = Input_data.data;
            
        catch err
            errordlg(err.message, 'Material Load Error');
            return;
        end
        
        rheology.data = data;
        rheology.line = 0;
        
        % - Update data
        setappdata(materials_gui_handle, 'rheology', rheology);
        
        % - Table update
        materials('update_table')
        
    case 'materials_restore'
        %% RESTORE DEFAULT
        
        Input_data = load('restore_rheology_data.mat');
        data        = Input_data.data;
        
        rheology.data       = data;
        rheology.line       = 0;
        
        % Find main gui
        folder_gui_handle   = findobj(0, 'tag', 'folder_gui_handle',        'type', 'figure');
        fold                = getappdata(folder_gui_handle, 'fold');
        rheology.path       = fold.folder_path;
        
        % - Update data
        setappdata(materials_gui_handle, 'rheology', rheology);
        
        % - Table update
        materials('update_table')
        
        
    case 'materials_save'
        %% SAVE AS
        
        % Get data
        rheology = getappdata(materials_gui_handle, 'rheology');  
        data     = rheology.data;
        
        if isempty(data)
            warndlg('No data to save!', 'Rheology Table');
            return;
        end
        
        [Filename, Pathname] = uiputfile(...
            {'*.mat'},...
            'Save rheology table as',[rheology.path,'rheology',filesep,'material_parameter_table.mat']);
        
        if ~(length(Filename)==1 && Filename==0)
            save([Pathname, Filename], 'data');
        end
                
end

%% fun selection
    function selection(obj, event_obj)
        
        % Get data
        rheology = getappdata(materials_gui_handle, 'rheology');  
        
        if ~isempty(event_obj.Indices)
            rheology.line = event_obj.Indices(1);
        end
        
        if ~isempty(event_obj.Indices)
            if event_obj.Indices(2)==9
                
                col = uisetcolor;
                
                if size(col,2)>1
                    rheology.data(rheology.line,9) = {col};
                end
            end
        end
        
        % - Update data
        setappdata(materials_gui_handle, 'rheology', rheology);
        
        % - Update table
        materials('update_table')
        
        % - Enable buttons
        materials('buttons_enable')
    end
end
