function growth_num_setting(Action)

% Original author:    Marta Adamuszek
% Last committed:     $Revision: 72 $
% Last changed by:    $Author: fgt_marta $
% Last changed date:  $Date: 2015-09-11 10:54:35 +0200 (Pt, 11 wrz 2015) $
%--------------------------------------------------------------------------

%% input check
if nargin==0
    Action = 'initialize';
end

%% find gui
growth_num_gui_handle = findobj(0, 'tag', 'growth_num_gui_handle', 'type', 'figure');

switch lower(Action)
    case 'initialize'
        
        %  Delete figure if it already exists
        if ~isempty(growth_num_gui_handle)
            delete(growth_num_gui_handle);
        end
        
        %% Initialize
        % Find default character size
        try
            growth_gui_handle = findobj(0, 'tag', 'growth_gui_handle', 'type', 'figure');
            b_width  = getappdata(growth_gui_handle, 'b_width');
            b_height = getappdata(growth_gui_handle, 'b_height');
            gap      = getappdata(growth_gui_handle, 'gap');
        catch
            warndlg('You should start to run the main Growth Rate function first.', 'Error');
            return;
        end
        
        Screensize      = get(0, 'ScreenSize');
        text_width      = 2*b_width;
        field_width     = 2*b_width+gap;
        
        fig_width       = text_width+field_width+3*gap;
        fig_height      = 8*(b_height+gap)+2*gap;
        
        % Create dialog window
        growth_num_gui_handle = figure( ...
            'Name' ,'Numerics Settings', 'Units','pixels', 'tag','growth_num_gui_handle',...
            'NumberTitle', 'off', 'DockControls', 'off', 'MenuBar', 'none', 'ToolBar', 'none',...
            'Resize','off',...
            'pos', [Screensize(3)/5, (Screensize(4)-fig_height)/2, fig_width, fig_height], 'Color',get(0, 'DefaultUipanelBackgroundColor'));%,...
            %'WindowStyle', 'modal');
                
        growth_num_upanel           = uiextras.VBox('Parent', growth_num_gui_handle);
        growth_num_upanel_general   = uipanel('Parent', growth_num_upanel, 'Tag','growth_num_upanel_general');
        growth_num_upanel_apply     = uipanel('Parent', growth_num_upanel, 'Tag','growth_num_upanel_apply');
        general_height              = 7*(b_height+gap)+gap;
        apply_height                = 1*(b_height+gap)+gap;
        set(growth_num_upanel, 'Sizes', [general_height apply_height]);
               
        %% - General
        % mu0
        uicontrol('Parent', growth_num_upanel_general, 'style', 'text', 'String', 'm_0/m', 'HorizontalAlignment', 'left',...
            'position', [gap, 6*(b_height+gap)+gap, text_width, b_height],...
            'tooltipstring','Normalized viscosity at zero shear rate.');
        % Field
        obj.growth_num_vis0 = uicontrol('Parent', growth_num_upanel_general, 'style', 'edit', 'String', '', 'BackgroundColor','w',...
            'callback',  @(a,b)  growth_num_setting('uicontrol_callback'),...
            'tag', 'growth_num_vis0', ...
            'position', [gap+text_width+gap, 6*(b_height+gap)+gap, field_width, b_height]);
        
        % muInf
        uicontrol('Parent', growth_num_upanel_general, 'style', 'text', 'String', 'm_inf/m', 'HorizontalAlignment', 'left',...
            'position', [gap, 5*(b_height+gap)+gap, text_width, b_height],...
            'tooltipstring','Normalized viscosity at infinite shear rate.');
        % Field
        obj.growth_num_visInf = uicontrol('Parent', growth_num_upanel_general, 'style', 'edit', 'String', '', 'BackgroundColor','w',...
            'callback',  @(a,b)  growth_num_setting('uicontrol_callback'),...
            'tag', 'growth_num_visInf', ...
            'position', [gap+text_width+gap, 5*(b_height+gap)+gap, field_width, b_height]);
        
        % dx
        uicontrol('Parent', growth_num_upanel_general, 'style', 'text', 'String', 'dx', 'HorizontalAlignment', 'left',...
            'position', [gap, 4*(b_height+gap)+gap, text_width, b_height],...
            'tooltipstring','Defines the resoltuion of points on the layer interface.');
        % Field
        obj.growth_num_dx = uicontrol('Parent', growth_num_upanel_general, 'style', 'edit', 'String', '', 'BackgroundColor','w',...
            'callback',  @(a,b)  growth_num_setting('uicontrol_callback'),...
            'tag', 'growth_num_dx', ...
            'position', [gap+text_width+gap, 4*(b_height+gap)+gap, field_width, b_height]);
        
        % Triangle area
        uicontrol('Parent', growth_num_upanel_general, 'style', 'text', 'String', 'Triangle Area','HorizontalAlignment', 'left', ...
            'position', [gap, 3*(b_height+gap)+gap, text_width, b_height],...
            'tooltipstring','Maximum area of the triangle mesh.');
        % Field
        obj.growth_num_area = uicontrol('Parent', growth_num_upanel_general, 'style', 'edit', 'String', '', 'BackgroundColor','w',...
            'callback',  @(a,b)  growth_num_setting('uicontrol_callback'),...
            'tag', 'growth_num_area', ...
            'position', [gap+text_width+gap, 3*(b_height+gap)+gap, field_width, b_height]);
        
        % Max iter Picard
        uicontrol('Parent', growth_num_upanel_general, 'style', 'text', 'String', 'Picard Iterations','HorizontalAlignment', 'left', ...
            'position', [gap, 2*(b_height+gap)+gap, text_width, b_height],...
            'tooltipstring','Maximum number of Picard iterations.');
        % Field
        obj.growth_num_pic_iter = uicontrol('Parent', growth_num_upanel_general, 'style', 'edit', 'String', '', 'BackgroundColor','w',...
            'callback',  @(a,b)  growth_num_setting('uicontrol_callback'),...
            'tag', 'growth_num_pic_iter', ...
            'position', [gap+text_width+gap, 2*(b_height+gap)+gap, field_width, b_height]);
        
        % Newton-Raphson Iterations
        uicontrol('Parent', growth_num_upanel_general, 'style', 'text', 'String', 'Newton-Raphson Iterations','HorizontalAlignment', 'left', ...
            'position', [gap, 1*(b_height+gap)+gap, text_width, b_height],...
            'tooltipstring','Maximum number of Newton-Raphson iterations.');
        % Field
        obj.growth_num_nr_iter = uicontrol('Parent', growth_num_upanel_general, 'style', 'edit', 'String', '', 'BackgroundColor','w',...
            'callback',  @(a,b)  growth_num_setting('uicontrol_callback'),...
            'tag', 'growth_num_nr_iter', ...
            'position', [gap+text_width+gap, 1*(b_height+gap)+gap, field_width, b_height]);
        
        % Relative Residual
        uicontrol('Parent', growth_num_upanel_general, 'style', 'text', 'String', 'Relative Residual','HorizontalAlignment', 'left', ...
            'position', [gap, 0*(b_height+gap)+gap, text_width, b_height],...
            'tooltipstring','Maximum relative residual.');
        % Field
        obj.growth_num_rel_res = uicontrol('Parent', growth_num_upanel_general, 'style', 'edit', 'String', '', 'BackgroundColor','w',...
            'callback',  @(a,b)  growth_num_setting('uicontrol_callback'),...
            'tag', 'growth_num_rel_res', ...
            'position', [gap+text_width+gap, 0*(b_height+gap)+gap, field_width, b_height]);
        

        %% - Apply & Cancel
        % Apply Button
        obj.growth_num_done = uicontrol('Parent', growth_num_upanel_apply, 'style', 'pushbutton', 'String', 'Apply',...
            'tag', 'growth_num_apply', ...
            'callback',  @(a,b)  growth_num_setting('growth_num_apply'),...
            'position', [fig_width-3*(b_width+gap), gap, b_width, b_height]);
        
        % Done Button
        obj.growth_num_done = uicontrol('Parent', growth_num_upanel_apply, 'style', 'pushbutton', 'String', 'Done',...
            'tag', 'growth_num_done', ...
            'callback',  @(a,b)  growth_num_setting('growth_num_done'),...
            'position', [fig_width-2*(b_width+gap), gap, b_width, b_height]);
        
        % Cancel Button
        uicontrol('Parent', growth_num_upanel_apply, 'style', 'pushbutton', 'String', 'Cancel',...
            'tag', 'growth_num_cancel', ...
            'callback',  @(a,b) close(gcf),...
            'position', [fig_width-(b_width+gap), gap, b_width, b_height]);
        
        % Store in Figure Appdata
        setappdata(growth_num_gui_handle, 'obj', obj);
        
        % - Folder Default Values
        growth_num_setting('default_values');
        
        % - Update Uicontrols
        growth_num_setting('uicontrol_update');
        
        
    case 'default_values'
        %% Default values
        
        growth_gui_handle = findobj(0, 'tag', 'growth_gui_handle',        'type', 'figure');
        growth    = getappdata(growth_gui_handle, 'growth');
        
        growth_num.vis0         = growth.num_vis0;
        growth_num.visInf       = growth.num_visInf;
        growth_num.dx           = growth.num_dx;
        growth_num.area         = growth.num_area;
        growth_num.pic_iter     = growth.num_pic_iter;
        growth_num.nr_iter      = growth.num_nr_iter;
        growth_num.rel_res      = growth.num_rel_res;
        
        setappdata(growth_num_gui_handle, 'growth_num', growth_num);
        
    case 'uicontrol_update'
        %% Update Uicontrols
        
        % Get data
        obj     = getappdata(growth_num_gui_handle, 'obj');
        growth_num = getappdata(growth_num_gui_handle, 'growth_num');
        
        % General
        set(obj.growth_num_vis0,        'string', num2str(growth_num.vis0));
        set(obj.growth_num_visInf,      'string', num2str(growth_num.visInf));
        set(obj.growth_num_dx,          'string', num2str(growth_num.dx));
        set(obj.growth_num_area,        'string', num2str(growth_num.area));
        set(obj.growth_num_pic_iter,    'string', num2str(growth_num.pic_iter));
        set(obj.growth_num_nr_iter,     'string', num2str(growth_num.nr_iter));
        set(obj.growth_num_rel_res,     'string', num2str(growth_num.rel_res));
    
        
    case 'uicontrol_callback'
        %% Uicontrol callback
        
        % Who is calling
        wcbo            = gcbo;
        Whoiscalling    = get(wcbo, 'tag');
        
        % Get data
        growth_num = getappdata(growth_num_gui_handle, 'growth_num');
            
        
        switch Whoiscalling
            
            case 'growth_num_vis0'
                if str2double(get(wcbo,'string')) >= 1
                    growth_num.vis0   = str2double(get(wcbo,  'string'));
                else
                    errordlg('The value cannot be smaller than 1.');
                end
                
            case 'growth_num_visInf'
                if (str2double(get(wcbo,'string')) <= 1 || str2double(get(wcbo,'string')) >= 0)
                    growth_num.visInf   = str2double(get(wcbo,  'string'));
                else
                    errordlg('The value must be between 0 and 1.');
                end
            
            case 'growth_num_dx'
                if (str2double(get(wcbo,'string')) < 1 || str2double(get(wcbo,'string')) > 0)
                    growth_num.dx   = str2double(get(wcbo,  'string'));
                else
                    errordlg('The value must be between 0 and 1.');
                end
                
            case 'growth_num_area'
                if str2double(get(wcbo,'string')) > 0
                    growth_num.area   = str2double(get(wcbo,  'string'));
                else
                    errordlg('The value must be larger than 0.');
                end
                
            case 'growth_num_pic_iter'
                if str2double(get(wcbo,'string')) < 0
                    errordlg('The value cannot be smaller than 0.');
                else
                    if mod(str2double(get(wcbo,  'string')),1)==0
                        growth_num.pic_iter   = str2double(get(wcbo,  'string'));
                    else
                        errordlg('The value must be an integer.');
                    end
                end
                
            case 'growth_num_nr_iter'
                if str2double(get(wcbo,'string')) < 0
                    errordlg('The value cannot be smaller than 0.');
                else
                    if mod(str2double(get(wcbo,  'string')),1)==0
                        growth_num.nr_iter   = str2double(get(wcbo,  'string'));
                    else
                        errordlg('The value must be an integer.');
                    end
                end
                
            case 'growth_num_rel_res'
                if (str2double(get(wcbo,'string')) < 1 || str2double(get(wcbo,'string')) > 1e-15)
                    growth_num.rel_res   = str2double(get(wcbo,  'string'));
                else
                    errordlg('The value must be between 1e-15 and 1.');
                end
                  
        end
        
        % - Update data
        setappdata(growth_num_gui_handle, 'growth_num', growth_num);
        
        % - Update Uicontrols
        growth_num_setting('uicontrol_update');
        
    case 'growth_num_apply'
        %% Apply 
        
        % Get data
        growth_num = getappdata(growth_num_gui_handle, 'growth_num');
        
        % Check if the main figure exist
        growth_gui_handle = findobj(0, 'tag', 'growth_gui_handle',        'type', 'figure');
        
        
        % Update the FOLDER GUI
%         try
            %  Get fold data
            growth        = getappdata(growth_gui_handle, 'growth');
            
            % Overwrite data
            growth.num_vis0         = growth_num.vis0;
            growth.num_visInf       = growth_num.visInf;
            growth.num_dx           = growth_num.dx;
            growth.num_area         = growth_num.area;
            growth.num_pic_iter     = growth_num.pic_iter;
            growth.num_nr_iter      = growth_num.nr_iter;
            growth.num_rel_res      = growth_num.rel_res;
            
            % Update fold data
            setappdata(growth_gui_handle, 'growth', growth);
            
            % Update Main Plot
            growth_rate('uicontrol_callback');
            
%         catch
%           errordlg('Main figure gone.');
%         end
        
    case 'growth_num_done'
        %% Done
        
        % Apply changes
        growth_num_setting('growth_num_apply');
        
        % Close figure
        close(growth_num_gui_handle);
        
end
end


