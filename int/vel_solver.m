function Vel = vel_solver(t, x, fold)

% Original author:    Marcin Dabrowski
% Last committed:     $Revision: 91 $
% Last changed by:    $Author: schmid $
% Last changed date:  $Date: 2017-08-21 16:17:19 +0200 (Mon, 21 Aug 2017) $
%--------------------------------------------------------------------------

t

nnode      = size(fold.NODES,2);
nmarkers   = fold.nmarkers;
nstrain    = fold.nfstrain;

% Nodes and phases
NODES      = reshape(x(1:2*nnode),2,nnode);
MARKERS    = reshape(x(2*nnode+1:2*nnode+2*nmarkers),2,nmarkers);
FS_GRID    = reshape(x(2*nnode+2*nmarkers+1:2*nnode+2*nmarkers+2*nstrain),2,nstrain);
FSTRAIN    = reshape(x(2*nnode+2*nmarkers+2*nstrain+1:2*nnode+2*nmarkers+2*nstrain+4*nstrain),4,nstrain);

% Rheology
Mu         = zeros(1,length(fold.region))';
N          = zeros(1,length(fold.region))';
Mu_0       = zeros(1,length(fold.region))';
Mu_inf     = zeros(1,length(fold.region))';
T          = fold.num.temperature;
Dxx        = fold.num.strain_rate;
R          = 8.3144621;

% Accuracy
rel_res_tol= fold.num.relres;

for ii = 1:length(fold.region)
    if isempty(fold.material_data{fold.region(ii).material,7})
        % Mu & n
        N(ii)   = str2double(fold.material_data{fold.region(ii).material,6});
        Mu(ii)  = str2double(fold.material_data{fold.region(ii).material,3});
    else
        N(ii)   = str2double(fold.material_data{fold.region(ii).material,6});
        Q       = str2double(fold.material_data{fold.region(ii).material,7});
        A       = str2double(fold.material_data{fold.region(ii).material,8});
        
        %Mu(ii)  = A^(1/N(ii))*exp(Q/(N(ii)*R*T))*Dxx_ref^(1/N(ii)-1);
        Mu(ii)  = (10^(A))^(1./N(ii)).*exp(Q./(N(ii)*R.*T))*1e6*Dxx^(1./N(ii)-1);
    end
    
    % Cutoffs for Carreau Fluids
    if N(ii)==1
        % Linear viscous materials
        Mu_0(ii)   = Mu(ii);
        Mu_inf(ii) = Mu(ii);
    else
        % Non-linear viscous materials
        Mu_0(ii)   = str2double(fold.material_data{fold.region(ii).material,4})*Mu(ii);
        Mu_inf(ii) = str2double(fold.material_data{fold.region(ii).material,5})*Mu(ii);
    end
end
PL_n    = N;

%% Numerical inputs
nip         = 6;
[IP_X,IP_W] = ip_triangle(nip);
IP_PTS      = [0 0; 1 0; 0 1; 1/2 1/2; 0 1/2; 1/2 0; 1/3 1/3];
nelblo      = 1e3;

pl_cutoff   = 1e-7;

%% TRIANGLE
% Phase points
PHASE_PTS  = zeros(4,length(fold.PHASE_idx));
for ii = 1:length(fold.PHASE_idx)
    PHASE_PTS(:,ii) = [(NODES(1,fold.REGIONS{ii}(1))+NODES(1,fold.REGIONS{ii}(end)))/2+1e-4 ...
                       (NODES(2,fold.REGIONS{ii}(1))+NODES(2,fold.REGIONS{ii}(end)))/2+1e-4 ...
                       ii...
                       fold.region(ii).area]';
end

% Create triangle input structure
tristr.points  	= NODES;
tristr.segments	= uint32(fold.SEGM);
tristr.regions	= PHASE_PTS;

% Generate the mesh using triangle
opts            = fold.MESH_opts;
MESH            = mtriangle(opts, tristr);
display(['MESH NODES        : ' num2str(size(MESH.NODES,2))]);
display(['MESH TRIANGLES    : ' num2str(size(MESH.ELEMS,2))]);

% - reorder mesh
[MESH,~,iperm]  = mesh_reorder_amd(MESH);

% - find interface nodes
interface_nodes = iperm(1:nnode);

% - mesh info
[nnodel, nel]   = size(MESH.ELEMS);
[ndim, nnod]    = size(MESH.NODES);
nedof           = nnodel*ndim;
np              = 3;

%% MATERIAL PROPERTIES IN ELEMENTS
el_Mu       = Mu(     MESH.elem_markers(:));
el_PL_n     = PL_n(   MESH.elem_markers(:));
el_Mu_0     = Mu_0(   MESH.elem_markers(:));
el_Mu_inf   = Mu_inf( MESH.elem_markers(:));

%% BOUNDARY
xmin = min(MESH.NODES(1,:));
xmax = max(MESH.NODES(1,:));
ymin = min(MESH.NODES(2,:));
ymax = max(MESH.NODES(2,:));

tol    = 1e-9;
Left   = find( abs(MESH.NODES(1,:)-xmin)<tol);
Right  = find( abs(MESH.NODES(1,:)-xmax)<tol);
Bottom = find( abs(MESH.NODES(2,:)-ymin)<tol);
Top    = find( abs(MESH.NODES(2,:)-ymax)<tol);
BC.index = [       2*Left-1        2*Right-1         2*Bottom         2*Top];

if fold.num.strain_mode==1
    BC.val = [-MESH.NODES(1,Left) -MESH.NODES(1,Right) MESH.NODES(2,Bottom) MESH.NODES(2,Top)];
elseif fold.num.strain_mode==-1
    BC.val = [MESH.NODES(1,Left) MESH.NODES(1,Right) -MESH.NODES(2,Bottom) -MESH.NODES(2,Top)];
end

%% MILAMIN SOLVER
[Vel,p]   = flow2d(MESH, BC, el_Mu, nip);
[~,Q_all] = mechanical_matrix_opt(MESH, el_Mu, 1, nip);

%% Q MATRIX
ELEM_DOF = zeros(nedof, nel,'int32');
ELEM_DOF(1:ndim:end,:) = ndim*(MESH.ELEMS-1)+1;
ELEM_DOF(2:ndim:end,:) = ndim*(MESH.ELEMS-1)+2;

Q_i = repmat(int32(1:nel*np),nedof,1);
Q_j = repmat(ELEM_DOF,np,1);
if exist(['sparse2.' mexext], 'file') == 3
    Q = sparse2(Q_i(:), Q_j(:), Q_all(:));
else
    Q = sparse(double(Q_i(:)), double(Q_j(:)), Q_all(:));
end

%% NON-LINEAR ITERATIONS
max_it_picard   = fold.num.picards;
max_it_nr       = fold.num.newtons;

%% INITIAL RESIDUAL & REL_RES
res             = powerlaw_residual(MESH, BC, el_Mu, el_PL_n,el_Mu_0, el_Mu_inf, Q, Vel,p, nip);
res(BC.index)   = [];
res_init        = norm(res);

rel_res       	= NaN(1, max_it_picard+max_it_nr+1);
rel_res(1)    	= 1;

if any(PL_n>1)
    
    %% PICARD ITERATIONS
    iter            = 1;
    
    picard_total = tic;
    
    if max_it_picard > 0
        while(1)
            
            picard_part = tic;
            
            % Viscosity computation
            %el_Mu_PL = powerlaw_viscosity(MESH, el_Mu, el_PL_n, Vel, IP_X);
            el_Mu_PL = carreau_viscosity(MESH,el_Mu, el_PL_n, el_Mu_0, el_Mu_inf, Vel,IP_X);
            
            %[iter min(el_Mu_PL(:)) max(el_Mu_PL(:))]
            % SOLVE
            [Vel, p] = flow2d(MESH, BC, el_Mu_PL, nip);
            
            % Relative residual
            res             = powerlaw_residual(MESH, BC, el_Mu, el_PL_n, el_Mu_0, el_Mu_inf, Q, Vel, p, nip);
            res(BC.index)   = 0;
            rel_res(iter+1) = norm(res)/res_init;
            
            display(['Iteration Picard        : ' num2str(iter,'%.2d') ' relres: ' num2str(rel_res(iter+1),'%.12f') ]);
             
            picard_time_part(iter) = toc(picard_part);
            
            if(rel_res(iter+1)<rel_res_tol || iter>=max_it_picard)
                break
            end
            
            iter = iter + 1;
            
        end
    end
    
    picard_time = toc(picard_total);
    
    %% NEWTON-RAPHSON
    iter = iter + 1;
    
    newton_total = tic;
    
    if max_it_nr > 0
        while(1)
            
            newton_part = tic;
            
            % Computer rhs (residual)
            res = powerlaw_residual(MESH, BC, el_Mu, el_PL_n, el_Mu_0, el_Mu_inf, Q, Vel, p, nip);
       
            % compute anisotropic D for the tangent matrix
            ER_ALL    = extract_strain_2d(MESH.NODES, MESH.ELEMS, Vel, IP_X, nelblo);
            EZZ       = -(ER_ALL(1,:)+ER_ALL(2,:));
            ER_ALL_II = sqrt((ER_ALL(1,:).^2+ER_ALL(2,:).^2+EZZ.^2)/2+ER_ALL(3,:).^2)';
            ER_ALL_II = reshape(ER_ALL_II,nel,nip);
            invar     = reshape(ER_ALL_II,nel,1,nip);
            n         = PL_n(MESH.elem_markers);
            n         = repmat(n,[1,1,nip]);
            
            ER_ALL = reshape(ER_ALL,3,nel,1,nip);
            ER_ALL = permute(ER_ALL,[2,3,4,1]);
            Ec = [ER_ALL(:,1,:,1).*ER_ALL(:,1,:,1) ER_ALL(:,1,:,1).*ER_ALL(:,1,:,2) ER_ALL(:,1,:,1).*ER_ALL(:,1,:,3)...
                ER_ALL(:,1,:,2).*ER_ALL(:,1,:,2) ER_ALL(:,1,:,2).*ER_ALL(:,1,:,3)...
                ER_ALL(:,1,:,3).*ER_ALL(:,1,:,3)];
            
            DEV = [2/3 -1/3 0 2/3 0 1/2];
            
            %D = bsxfun(@times, (1./n-1).*(invar.^(1./n-2))./(2*invar), Ec) + bsxfun(@times,invar.^(1./n-1), DEV);
            %D = 2*bsxfun(@times, D, el_Mu(:));
       
            
            el_Lambda = (el_Mu./(el_Mu_0-el_Mu_inf)).^(1./(1./el_PL_n-1));
            tmp = 1+bsxfun(@times, invar, el_Lambda).^2;
            el_Mu_Ca = bsxfun(@plus, el_Mu_inf, bsxfun(@times, el_Mu_0-el_Mu_inf, bsxfun(@power, tmp, (1./el_PL_n-1)/2)));            
            el_Mu_Ca = reshape(el_Mu_Ca,nel,1,nip);
            D =  bsxfun(@times,el_Mu_Ca, DEV);
            
            el_Lambda(el_PL_n==1) = 0;
            tmp2 =  bsxfun(@times, 2*el_Lambda.^2.*(el_Mu_0-el_Mu_inf).*(1./el_PL_n-1)/2, bsxfun(@power, tmp, (1./el_PL_n-1)/2-1));       
            tmp3 =  bsxfun(@times, tmp2.*invar./(2*invar), Ec);    
            D = D + tmp3;
            D = 2*D;
            
            
            
            
            % Solve using the tangent matrix
       
            BC2         = BC;
            BC2.val     = 0*BC2.val;
            [dVel,dp]   = flow2d(MESH, BC2, D, nip, res);
       
            % Line search
            f = @(s) norm(powerlaw_residual(MESH, BC, el_Mu, el_PL_n, el_Mu_0, el_Mu_inf, Q, Vel-s*dVel, p-s*dp, nip));
            alpha = poly_search(f,norm(res));
       
            % Update velocity & pressure
            Vel = Vel - alpha*dVel;
            p   = p   - alpha*dp;
            
            % Relative residual
            res = powerlaw_residual(MESH, BC, el_Mu, el_PL_n, el_Mu_0, el_Mu_inf, Q, Vel, p, nip);
            
            res(BC.index)   = 0;
            
            rel_res(iter+1) = norm(res)/res_init;
            
            display(['Iteration Newton-Raphson: ' num2str(iter,'%.2d') ' relres: ' num2str(rel_res(iter+1),'%.12f') ]);
             
            newton_time_part(iter) = toc(newton_part); 
            
            if(rel_res(iter+1)<rel_res_tol || iter>max_it_nr)
                break
            end
            
            iter = iter + 1;
        end
    end
    newton_time = toc(newton_total);
    
else
    picard_time = 0;
    newton_time = 0;
    picard_time_part = 0;
    newton_time_part = 0;
end

Vel         = reshape(Vel,2,nnod);
Vel         = Vel(:);
Pressure    = reshape(p,np, nel);

%% APPARENT VISCOSITY
Mu_app          = carreau_viscosity(MESH,el_Mu, el_PL_n, el_Mu_0, el_Mu_inf, Vel, IP_PTS);
Mu_app          = squeeze(Mu_app)';

%% STRAIN RATE AND STRESS
% [Exx, Eyy, Exy]  = strain_rate(Vel, MESH, nelblo);
% Sxx              = 2*repmat(Mu_app,3,1).*Exx;
% Syy              = 2*repmat(Mu_app,3,1).*Eyy;
% Sxy              = 2*repmat(Mu_app,3,1).*Exy;

Vx  = Vel(1:2:end);
Vy  = Vel(2:2:end);
V   = [Vx(:)'; Vy(:)'];
V_nodes = [Vx(interface_nodes)';Vy(interface_nodes)'];
V_nodes = V_nodes(:);

WS.xmin   = xmin;
WS.xmax   = xmax;
WS.ymin   = ymin;
WS.ymax   = ymax;

%% INTERPOLATE MARKER POSITION AND THEIR VELOCITIES
if ~isempty(MARKERS)
    warning('off','MATLAB:triangulation:PtsNotInTriWarnId');
    map_markers  = tsearch2(MESH.NODES, MESH.ELEMS(1:3,:), MARKERS, WS);
    vel_markers  = einterp(MESH, V, MARKERS, map_markers, opts);
else
    vel_markers  = [];
end

%% FINITE STRAIN
% Interpolate position of finite strain grid marker grid postion and their velocities
if ~isempty(FS_GRID)
    warning('off','MATLAB:triangulation:PtsNotInTriWarnId');
    map_strain_grid  = tsearch2(MESH.NODES, MESH.ELEMS(1:3,:), FS_GRID, WS);
    vel_strain_grid  = einterp(MESH, V, FS_GRID, map_strain_grid, opts);
else
    vel_strain_grid  = [];
end

if ~isempty(FS_GRID)
    % Calculates velocity derivatives in the grid points
    [dVxdx, dVxdy, dVydx, dVydy] = dVdx_grid(FS_GRID(1,:),FS_GRID(2,:),Vx,Vy,MESH);
    dVdx = [dVxdx; dVydx; dVxdy; dVydy];
    
    % Calculates velocity gradient
    dVdX = [dVdx(1,:).*FSTRAIN(1,:) + dVdx(3,:).*FSTRAIN(2,:);
            dVdx(2,:).*FSTRAIN(1,:) + dVdx(4,:).*FSTRAIN(2,:);
            dVdx(1,:).*FSTRAIN(3,:) + dVdx(3,:).*FSTRAIN(4,:);
            dVdx(2,:).*FSTRAIN(3,:) + dVdx(4,:).*FSTRAIN(4,:)];
else
    dVdX = [];
end

%% SAVE
% Save results
if ~isempty(find(t==fold.num.tspan))
    save([fold.run_output,'run_output',filesep,'run_',num2str(find(t==fold.num.tspan),'%.4d')],...
        'MESH','Vel','Pressure','interface_nodes','Mu_app')
        %'MESH','Vel','Pressure','Exx','Eyy','Exy','Sxx','Syy','Sxy','Mu_app','interface_nodes')
end

% Save info about the run
if exist([fold.run_output,'run_output',filesep,'numerics.mat'],'file')
    load([fold.run_output,'run_output',filesep,'numerics.mat'],'data');
    count = size(data,2)+1;
else
    count = 1;
end
data(count).rel_res         = rel_res;
if max_it_picard > 0
    data(count).picard_time     = picard_time;
    data(count).picard_time_part= picard_time_part;
else
    data(count).picard_time     = 0;
    data(count).picard_time_part= 0;
end
if max_it_nr > 0;
    data(count).newton_time     = newton_time;
    data(count).newton_time_part= newton_time_part;
else
    data(count).newton_time     = 0;
    data(count).newton_time_part= 0;
end
data(count).nnodes      	= nnod;
data(count).nel             = nel;
    
save([fold.run_output,'run_output',filesep,'numerics.mat'],'data')

%% OUTPUT
Vel = [V_nodes; vel_markers(:); vel_strain_grid(:); dVdX(:)];