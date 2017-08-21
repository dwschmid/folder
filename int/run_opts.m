function run_opts(Action)

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
ropts_gui_handle = findobj(0, 'tag', 'ropts_gui_handle', 'type', 'figure');

switch lower(Action)
    case 'initialize'
        
        %  Delete figure if it already exists
        if ~isempty(ropts_gui_handle)
            delete(ropts_gui_handle);
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
        field_width     = 2*b_width;
        
        solver_height 	= 2*(b_height+gap)+3*gap;
        model_height 	= 2*(b_height+gap)+3*gap;
        iter_height 	= 3*(b_height+gap)+3*gap;
        controls_height = 1*(b_height+gap)+gap;
        
        fig_width       = text_width+field_width+3*gap;
        fig_height      = solver_height+model_height+iter_height+controls_height+4*gap;
        
        % Create dialog window
        ropts_gui_handle = figure( ...
            'Name' ,'Run Options', 'Units','pixels', 'tag','ropts_gui_handle',...
            'NumberTitle', 'off', 'DockControls', 'off', 'MenuBar', 'none', 'ToolBar', 'none',...
            'Resize','off',...
            'pos', [Screensize(3)/5, Screensize(4)/2, fig_width, fig_height], 'Color',get(0, 'DefaultUipanelBackgroundColor'));
        
        b1                      = uiextras.VBox('Parent', ropts_gui_handle);
        ropts_upanel_solver   	= uipanel('Parent', b1, 'Tag','ropts_upanel_solver','title','Solver');
        ropts_upanel_model   	= uipanel('Parent', b1, 'Tag','ropts_upanel_solver','title','Deformation-dependent Parameters');
        ropts_upanel_iter   	= uipanel('Parent', b1, 'Tag','ropts_upanel_iter','title','Iterations for Non-linear Materials');
        ropts_upanel_contols    = uipanel('Parent', b1, 'Tag','ropts_upanel_controls');
        set( b1, 'Sizes', [-solver_height -model_height -iter_height -controls_height]);
        
        %% Parameters panel
        % SOLVER
        % - Text
        uicontrol('Parent', ropts_upanel_solver, 'style', 'text', 'String', 'Solver','HorizontalAlignment', 'left',...
            'position', [gap, 1*(b_height+gap)+gap, text_width, b_height],...
            'tooltipstring','Numerical solver.');
        % - Field
        obj.ropts_solver = uicontrol('Parent', ropts_upanel_solver, 'style', 'popupmenu',...
            'String', {'Euler';'Improved Euler';'Runge-Kutta 2';'Runge-Kutta 3';'Runge-Kutta 4';...
            'Adams-Bashforth 2';'Adams-Bashforth 3';'Adams-Bashforth 4'},'value', 1,...
            'callback',  @(a,b)  run_opts('uicontrol_callback'),'BackgroundColor','w',...
            'tag', 'ropts_solver', ...
            'position', [gap+text_width+gap, 1*(b_height+gap)+gap, text_width, b_height]);
        
        % TIMESTEP
        % - Text
        uicontrol('Parent', ropts_upanel_solver, 'style', 'text', 'String', 'Number of Time Steps','HorizontalAlignment', 'left',...
            'position', [gap, 0*(b_height+gap)+gap, text_width, b_height],...
            'tooltipstring','Number of time steps.');
        % - Field
        obj.ropts_time = uicontrol('Parent', ropts_upanel_solver, 'style', 'edit', 'String', '', 'BackgroundColor','w',...
            'callback',  @(a,b)  run_opts('uicontrol_callback'),...
            'tag', 'ropts_time',...
            'position', [gap+text_width+gap, 0*(b_height+gap)+gap, text_width, b_height]);
        
        
        % MODEL SETUP FOR NON-LINEAR MATERIAL
        uicontrol('Parent',ropts_upanel_model,'style', 'text', 'String', 'Temperature (K)','HorizontalAlignment', 'left',...
            'position', [gap, 1*(b_height+gap)+gap, text_width, b_height]);
        % - Field
        obj.ropts_temperature = uicontrol('Parent', ropts_upanel_model, 'style', 'edit', 'String', '', 'BackgroundColor','w',...
            'callback',  @(a,b)  run_opts('uicontrol_callback'),...
            'tag', 'ropts_temperature',...
            'position', [gap+text_width+gap, 1*(b_height+gap)+gap, text_width, b_height]);
        
        % STRAIN RATE
        uicontrol('Parent',ropts_upanel_model,'style', 'text', 'String', 'Rate of Deformation','HorizontalAlignment', 'left',...
            'position', [gap, 0*(b_height+gap)+gap, text_width, b_height]);
        % - Field
        obj.ropts_strain_rate = uicontrol('Parent', ropts_upanel_model, 'style', 'edit', 'String', '', 'BackgroundColor','w',...
            'callback',  @(a,b)  run_opts('uicontrol_callback'),...
            'tag', 'ropts_strain_rate',...
            'position', [gap+text_width+gap, 0*(b_height+gap)+gap, text_width, b_height]);
        
        % PICARD ITERATIONS
        % - Text
        uicontrol('Parent', ropts_upanel_iter, 'style', 'text', 'String', 'Picard Iterations','HorizontalAlignment', 'left',...
            'position', [gap, 2*(b_height+gap)+gap, text_width, b_height],...
            'tooltipstring','Max. number of Picard iterations.');
        % - Field
        obj.ropts_picards = uicontrol('Parent', ropts_upanel_iter, 'style', 'edit', 'String', '', 'BackgroundColor','w',...
            'callback',  @(a,b)  run_opts('uicontrol_callback'),...
            'tag', 'ropts_picards', ...
            'position', [gap+text_width+gap, 2*(b_height+gap)+gap, text_width, b_height]);
        
        % NUMBER OF ITERATIONS
        % - Text
        uicontrol('Parent', ropts_upanel_iter, 'style', 'text', 'String', 'Newton-Raphson Iterations','HorizontalAlignment', 'left',...
            'position', [gap, 1*(b_height+gap)+gap, text_width, b_height],...
            'tooltipstring','Max. number of Newton-Raphson iterations.');
        % - Field
        obj.ropts_newtons = uicontrol('Parent', ropts_upanel_iter, 'style', 'edit', 'String', '', 'BackgroundColor','w',...
            'callback',  @(a,b)  run_opts('uicontrol_callback'),...
            'tag', 'ropts_newtons',...
            'position', [gap+text_width+gap, 1*(b_height+gap)+gap, text_width, b_height]);
        
        % RELATIVE RESIDUUM
        % - Text
        uicontrol('Parent', ropts_upanel_iter, 'style', 'text', 'String', 'Relative Residuum','HorizontalAlignment', 'left',...
            'position', [gap, 0*(b_height+gap)+gap, text_width, b_height]);
        % - Field
        obj.ropts_relres = uicontrol('Parent', ropts_upanel_iter, 'style', 'edit', 'String', '', 'BackgroundColor','w',...
            'callback',  @(a,b)  run_opts('uicontrol_callback'),...
            'tag', 'ropts_relres',...
            'position', [gap+text_width+gap, 0*(b_height+gap)+gap, text_width, b_height]);
        
        %% - Done panel
        % Apply Button
        obj.ropts_apply = uicontrol('Parent', ropts_upanel_contols, 'style', 'pushbutton', 'String', 'Apply',...
            'tag', 'ropts_apply', ...
            'callback',  @(a,b)  run_opts('opts_apply'),...
            'position', [fig_width-3*(gap+b_width), gap, b_width, b_height]);
        % Done Button
        obj.ropts_done = uicontrol('Parent', ropts_upanel_contols, 'style', 'pushbutton', 'String', 'Done',...
            'tag', 'ropts_done', ...
            'callback',  @(a,b)  run_opts('opts_done'),...
            'position', [fig_width-2*(gap+b_width), gap, b_width, b_height]);
        % Close Button
        uicontrol('Parent', ropts_upanel_contols, 'style', 'pushbutton', 'String', 'Close',...
            'callback',  @(a,b)  close(gcf),...
            'position', [fig_width-1*(gap+b_width), gap, b_width, b_height]);
        
        % Store in Figure Appdata
        setappdata(ropts_gui_handle, 'obj', obj);
        
        % - Folder Default Values
        run_opts('default_values');
        
        % - Update Uicontrols
        run_opts('uicontrol_update');
        
        % - Enable buttons
        run_opts('buttons_enable');
        
        
    case 'default_values'
        %% Default values
        
        folder_gui_handle = findobj(0, 'tag', 'folder_gui_handle', 'type', 'figure');
        
        if ~isempty(folder_gui_handle)
            
            %  Get fold data
            fold        = getappdata(folder_gui_handle, 'fold');
            
            ropts.solver        = fold.num.solver;
            ropts.nt            = fold.num.nt;
            ropts.temperature   = fold.num.temperature;
            ropts.strain_rate   = fold.num.strain_rate;
            ropts.picards     	= fold.num.picards;
            ropts.newtons     	= fold.num.newtons;
            ropts.relres     	= fold.num.relres;
        end
        
        setappdata(ropts_gui_handle, 'ropts', ropts);
        
    case 'uicontrol_update'
        %% Update Uicontrols
        
        % Get data
        obj   = getappdata(ropts_gui_handle, 'obj');
        ropts = getappdata(ropts_gui_handle, 'ropts');
        
        set(obj.ropts_solver,               'value',  ropts.solver);
        set(obj.ropts_time,                 'string', num2str(ropts.nt));
        set(obj.ropts_temperature,          'string', num2str(ropts.temperature));
        set(obj.ropts_strain_rate,          'string', num2str(ropts.strain_rate));
        set(obj.ropts_picards,              'string', num2str(ropts.picards));
        set(obj.ropts_newtons,           	'string', num2str(ropts.newtons));
        set(obj.ropts_relres,           	'string', num2str(ropts.relres));
        
        
    case 'uicontrol_callback'
        %% Uicontrol callback
        
        % Who is calling
        wcbo            = gcbo;
        Whoiscalling    = get(wcbo, 'tag');
        
        % Get data
        ropts = getappdata(ropts_gui_handle, 'ropts');
            
        
        switch Whoiscalling
            
            case 'ropts_solver'
                ropts.solver      = get(wcbo,  'value');

            case 'ropts_time'
                
                % Value must be an integer
                if isinteger(int8(str2double(get(wcbo,  'string'))))
                    
                    % ...and must be larger than 2
                    if str2double(get(wcbo,  'string')) > 2
                        ropts.nt         = str2double(get(wcbo,  'string'));
                    else
                        warndlg('Number of time steps must be larger than 2.', 'Error!', 'modal');
                        return;
                    end
                else
                    warndlg('Number must be an integer.', 'Error!', 'modal');
                end
             
            case 'ropts_temperature'
                
                % Temperature must be a positive value
                if str2double(get(wcbo,  'string')) > 0
                    ropts.temperature         = str2double(get(wcbo,  'string'));
                else
                    warndlg('Temperature must be a positive value.', 'Error!', 'modal');
                end
                
            case 'ropts_strain_rate'
                
                % Temperature must be a positive value
                if str2double(get(wcbo,  'string')) > 0
                    ropts.strain_rate         = str2double(get(wcbo,  'string'));
                else
                    warndlg('Rate of deformation must be a positive value.', 'Error!', 'modal');
                end
                
            case 'ropts_picards'
                % Value must be an integer
                if isinteger(int8(str2double(get(wcbo,  'string'))))
                    
                    % ...and must be at least 1 picard
                    if str2double(get(wcbo,  'string')) >= 0
                        ropts.picards  = str2double(get(wcbo,  'string'));
                    else
                        warndlg('Number of iterations must be larger than 0.', 'Error!', 'modal');
                    end
                else
                    warndlg('Number must be an integer.', 'Error!', 'modal');
                end
                
            case 'ropts_newtons'
                 % Value must be an integer
                if isinteger(int8(str2double(get(wcbo,  'string'))))
                    % ...and it cannot be negative
                    if str2double(get(wcbo,  'string')) >= 0
                        ropts.newtons      = str2double(get(wcbo,  'string'));
                    else
                        warndlg('Number of iteration cannot be negative.', 'Error!', 'modal');
                    end
                else
                    warndlg('Number must be an integer.', 'Error!', 'modal');
                end
                
            case 'ropts_relres'
                
                % Relative residuum must be a positive value
                if str2double(get(wcbo,  'string')) > 0
                    ropts.relres         = str2double(get(wcbo,  'string'));
                else
                    warndlg('Relative residuum must be a positive value.', 'Error!', 'modal');
                end
                
        end
        
        % - Update data
        setappdata(ropts_gui_handle, 'ropts', ropts);
        
        % - Update Uicontrols
        run_opts('uicontrol_update');
        
        
        
    case 'opts_apply'
        %% Apply 
        
        % Check if the main figure exist
        folder_gui_handle = findobj(0, 'tag', 'folder_gui_handle',        'type', 'figure');
        
        % Update the FOLDER GUI
        try
            %  Get fold data
            fold        = getappdata(folder_gui_handle, 'fold');
            
            % Update Data
            folder('uicontrol_callback');
            
        catch
            errordlg('Main figure gone.');
        end
        
    case 'opts_done'
        %% Done
        
        % Apply changes
        run_opts('opts_apply');
        
        % Close figure
        close(ropts_gui_handle);
        
end
end