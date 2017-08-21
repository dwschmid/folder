function ode_solvers(odefun, tspan, nodes, solver_type, run_output, markers, fstrain_grid, fstrain, waitbar_flag)

% Original author:    Marta Adamuszek
% Last committed:     $Revision: 91 $
% Last changed by:    $Author: schmid $
% Last changed date:  $Date: 2017-08-21 16:17:19 +0200 (Mon, 21 Aug 2017) $
%--------------------------------------------------------------------------

if nargin==5
    markers         = [];
    fstrain_grid    = [];
    fstrain         = [];
    waitbar_flag    = 0;
elseif nargin==6
    fstrain_grid    = [];
    fstrain         = [];
    waitbar_flag    = 0;
elseif nargin==7
    fstrain         = [];
    waitbar_flag    = 0;
elseif nargin==8
    waitbar_flag    = 0;
end


%%  Eliminate markers with nan values from the solver input
markers_all     = markers;
markers         = markers(:);
idx_marker      = ~isnan(markers);
markers         = markers(idx_marker);
markers         = reshape(markers,2,length(markers)/2);

%%  Number of points
nnodes          = size(nodes,2);
nmarkers        = size(markers,2);
nfstrain        = size(fstrain,2);

%%  Initialize
y0    = [nodes(:); markers(:); fstrain_grid(:); fstrain(:)];
f     = zeros(length(y0),4);

%% Save initial step
NODES_run = nodes;
save([run_output,'run_output',filesep,'nodes_',       num2str(1,'%.4d')],'NODES_run');
MARKERS_run = markers_all;
save([run_output,'run_output',filesep,'markers_',     num2str(1,'%.4d')],'MARKERS_run');
FSTRAIN_GRID_run = fstrain_grid;
save([run_output,'run_output',filesep,'fstrain_grid_',num2str(1,'%.4d')],'FSTRAIN_GRID_run');
FSTRAIN_run = fstrain;
save([run_output,'run_output',filesep,'fstrain_',     num2str(1,'%.4d')],'FSTRAIN_run');

dt = tspan(2)-tspan(1);

%%  Integrate
for it = 2:length(tspan)+1
    % Number of steps is +1 to evaluate parameters in the last step
    ti = tspan(it-1);
    
    % Calculate time for each time step
    tic;
    
    switch solver_type
        
        case 1
            %'Euler'
            
            F1 = odefun(ti,y0);
            
            y0 = y0 + dt*F1;
            
        case 2
            %'Improved Euler'
            % Heun's method
            
            F1 = odefun(ti,y0);
            F2 = odefun(ti+dt,y0+dt*F1);
            
            y0 = y0 + dt/2*(F1+F2);
            
        case 3
            %'Runge-Kutta 2'
            %(Mid-point/Modified Euler)
            
            F1 = odefun(ti,y0);
            F2 = odefun(ti+dt/2,y0+dt/2*F1);
            
            y0 = y0 + dt*F2;    
            
        case 4
            %'Runge-Kutta 3'
            
            F      = zeros(length(y0),3);
            F(:,1) = odefun(ti       ,y0                            );
            F(:,2) = odefun(ti+0.5*dt,y0+0.5*dt*F(:,1)              );
            F(:,3) = odefun(ti+    dt,y0-    dt*F(:,1) + dt*2*F(:,2));
            
            y0 = y0 + dt/6*(F(:,1)+4*F(:,2)+F(:,3));
            
            
        case 5
            %'Runge-Kutta 4'
            
            F      = zeros(length(y0),4);
            F(:,1) = odefun(ti             ,y0        );
            F(:,2) = odefun(ti+0.5*dt,y0+0.5*dt*F(:,1));
            F(:,3) = odefun(ti+0.5*dt,y0+0.5*dt*F(:,2));
            F(:,4) = odefun(ti+    dt,y0+    dt*F(:,3));
            
            y0 = y0 + dt/6*(F(:,1) + 2*F(:,2) + 2*F(:,3) + F(:,4));
            
        case 6
            %'Adams-Bashforth 2'
            
            if it < 3
%                 % Euler
%                 F1 = odefun(ti,y0);
%                 f(:,1) = F1;
%                 
%                 y0 = y0 + dt*F1;
%                 
            % Runge - Kutta 2
             
            F1 = odefun(ti,y0);
            F2 = odefun(ti+dt/2,y0+dt/2*F1);
            
            y0 = y0 + dt*F2;   
                
            else
                % Adams-Bashforth 2
                F1 = f(:,2);
                F2 = odefun(ti,y0);
                f(:,1) = F2;
                
                y0 = y0 + dt/2*( 3*F2 -  F1);
            end
         
        case 7
            %'Adams-Bashforth 3'
            
            if it < 4
                % Runge-Kutta 3
                F      = zeros(length(y0),3);
                F(:,1) = odefun(ti             ,y0                      );
                F(:,2) = odefun(ti+0.5*dt,y0+0.5*dt*F(:,1)              );
                F(:,3) = odefun(ti+    dt,y0-    dt*F(:,1) + dt*2*F(:,2));
                f(:,1) = F(:,1);
                
                y0 = y0 + dt/6*(F(:,1)+4*F(:,2)+F(:,3));
                
            else
                % Adams-Bashforth 3
                F1 = f(:,3);
                F2 = f(:,2);
                F3 = odefun(ti,y0);
                f(:,1) = F3;
                
                y0 = y0 + dt/12*(23*F3 - 16*F2 + 5*F1);
            end
            
        case 8
            %'Adams-Bashforth 4'
                

            if it<5
                
                % Runge-Kutta 4
                F      = zeros(length(y0),4);
                F(:,1) = odefun(ti             ,y0        );
                F(:,2) = odefun(ti+0.5*dt,y0+0.5*dt*F(:,1));
                F(:,3) = odefun(ti+0.5*dt,y0+0.5*dt*F(:,2));
                F(:,4) = odefun(ti+    dt,y0+    dt*F(:,3));
                f(:,1) = F(:,1);
                
                y0 = y0 + dt/6*(F(:,1) + 2*F(:,2) + 2*F(:,3) + F(:,4));
            
            else
                % Adams-Bashforth 4
                F1 = f(:,4);
                F2 = f(:,3);
                F3 = f(:,2);
                F4 = odefun(ti,y0);
                f(:,1) = F4;
                
                y0 = y0 + dt/24*(55*F4 - 59*F3 + 37*F2 - 9*F1);
            end
            
    end
    
    % Update previously saved data
    f(:,2:4) = f(:,1:3);
    
    it_run_time = toc;
    
    %% Update waitbar
    if(waitbar_flag)
        % find handle
        h = findobj(0,'tag','TMWWaitbar');
        % Check if waitbar was closed
        if ~isempty(h)
            % Modify progress bar
            waitbar((it-1)/length(tspan));
            % Modify progress bar title.
            timeleft = (length(tspan)-it)*it_run_time;
            if timeleft > 3600
                timeleft = ceil(timeleft/60);
                godziny  = floor(timeleft/60);
                minuty   = timeleft-godziny*60;
                set( get(findobj(h,'type','axes'),'title'), 'string', ['Calculating. Estimated completion time ca. ',num2str(godziny),' h', num2str(minuty),' min']); 
            elseif timeleft > 60
                timeleft = ceil(timeleft/60);
                set( get(findobj(h,'type','axes'),'title'), 'string', ['Calculating. Estimated completion time ca. ',num2str(timeleft),' min']); 
            else
                timeleft = ceil(timeleft);
                set( get(findobj(h,'type','axes'),'title'), 'string', ['Calculating. Estimated completion time ca. ',num2str(timeleft),' s']); 
            end
        end
        
        % Cancel button
        if getappdata(h,'canceling')
            break;
        end
    end
    
    
    %%  Save data
    
    % Nodes
    NODES_run = y0(1:2*nnodes);
    NODES_run = reshape(NODES_run,2,nnodes);
    
    save([run_output,'run_output',filesep,'nodes_',num2str(it,'%.4d')],'NODES_run');

    % Markers
    if nmarkers>0
        MARKERS_run                = NaN(2*size(markers_all,2),1);
        MARKERS_run(idx_marker,:)  = y0(2*nnodes+1:2*nnodes+2*nmarkers);
        MARKERS_run                = single(reshape(MARKERS_run,2,length(MARKERS_run)/2));
        
        save([run_output,'run_output',filesep,'markers_',num2str(it,'%.4d')],'MARKERS_run');
    end
    
    % Finite strain
    if nfstrain>0
        FSTRAIN_GRID_run  	= y0(2*nnodes+2*nmarkers+1:2*nnodes+2*nmarkers+2*nfstrain);
        FSTRAIN_GRID_run 	= single(reshape(FSTRAIN_GRID_run,2,nfstrain));
        
        save([run_output,'run_output',filesep,'fstrain_grid_',num2str(it,'%.4d')],'FSTRAIN_GRID_run');
        
        FSTRAIN_run       	= y0(2*nnodes+2*nmarkers+2*nfstrain+1:2*nnodes+2*nmarkers+2*nfstrain+4*nfstrain);
        FSTRAIN_run         = reshape(FSTRAIN_run,4,nfstrain);
        
        save([run_output,'run_output',filesep,'fstrain_',num2str(it,'%.4d')],'FSTRAIN_run'); 
    end
    
    % Run info
    load([run_output,'run_output',filesep,'numerics.mat'],'data');
    
    if it == 2
        data(1).step_time = zeros(1,length(tspan));
    end
    
    data(1).step_time(it-1)  = it_run_time;
    save([run_output,'run_output',filesep,'numerics.mat'],'data')
end