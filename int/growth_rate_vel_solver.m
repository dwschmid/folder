function Vel = growth_rate_vel_solver(L,H,A,nx,max_area,Mu,Mus_0,Mus_inf,PL_n,strain_mode,max_it_picard,max_it_nr,relres)

% Original author:    Marcin Dabrowski
% Last committed:     $Revision: 72 $
% Last changed by:    $Author: fgt_marta $
% Last changed date:  $Date: 2015-09-11 10:54:35 +0200 (Pt, 11 wrz 2015) $
%--------------------------------------------------------------------------

%% TRIANGLE
% NODES
NODES = zeros(2,2*nx+4);
% Bottom boundary
NODES(:,1:2) = [0, L/2;-H, -H];
% Layer interafce
X = linspace(0,L/2,nx);
Y = A*cos(2*pi*1/L*X);

if strain_mode == 1
    % Shortenint
    NODES(:,3:end-2) = [X X; Y-0.5 Y+0.5];
else
    % Extension
    NODES(:,3:end-2) = [X X; -Y-0.5 Y+0.5];
end

% Top boundary
NODES(:,end-1:end) = [0 L/2; H H];

S       = [1 2 2*nx+4 2*nx+3];
SEGM    = [S;S([2:end 1])];
S       = [3:nx+2 (2*nx+2):-1:(nx+3)];
SEGM    = [SEGM [S;S([2:end 1])]];

% PHASE POINTS
PHASE_PTS  = [ 0+1e-2    0+1e-2     0+1e-2;...
              -H+1e-2    Y(1)       H-1e-2;...
               1          2         3;...
               max_area   max_area  max_area];
              

% Create triangle input structure
tristr.points  	= NODES;
tristr.segments	= uint32(SEGM);
tristr.regions	= PHASE_PTS;

% Generate the mesh using triangle
opts = [];
opts.element_type     = 'tri7';   % element type
opts.gen_neighbors    = 1;        % generate element neighbors
opts.gen_elmarkers    = 1;        % generate element markers
opts.triangulate_poly = 1;
opts.min_angle        = 32;
opts.other_options    = 'aA';

MESH            = mtriangle(opts, tristr);
%trisurf(MESH.ELEMS(1:3,:)',MESH.NODES(1,:)',MESH.NODES(2,:)',0*MESH.NODES(2,:)'); view(2); axis equal;

if MESH.NODES>5*1e5
    uiwait('The size of the numerical model is too big and cannot be calculated.', 'modal');
    return;
end

% - reorder mesh
[MESH,~,iperm]  = mesh_reorder_amd(MESH);

% - find interface nodes
nnode           = size(NODES,2);
interface_nodes = iperm(1:nnode);

% - mesh info
[nnodel, nel]   = size(MESH.ELEMS);
[ndim, nnod]    = size(MESH.NODES);
nedof           = nnodel*ndim;
np              = 3;

%% MATERIAL PROPERTIES IN ELEMENTS
el_Mu     = Mu(MESH.elem_markers(:));
el_PL_n   = PL_n(MESH.elem_markers(:));
el_Mu_0   = Mus_0(MESH.elem_markers(:));
el_Mu_inf = Mus_inf(MESH.elem_markers(:));

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

if strain_mode==1
    BC.val = [-MESH.NODES(1,Left) -MESH.NODES(1,Right) MESH.NODES(2,Bottom) MESH.NODES(2,Top)];
else
    BC.val = [MESH.NODES(1,Left) MESH.NODES(1,Right) -MESH.NODES(2,Bottom) -MESH.NODES(2,Top)];
end

%% Numerical inputs
nip         = 6;
[IP_X,IP_W] = ip_triangle(nip);
nelblo      = 1e3;

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

%% INITIAL RESIDUAL & REL_RES
res             = powerlaw_residual(MESH, BC, el_Mu, el_PL_n, el_Mu_0, el_Mu_inf, Q, Vel,p, nip);
res(BC.index)   = [];
res_init        = norm(res);

rel_res       	= NaN(1, max_it_picard+max_it_nr+1);
rel_res(1)    	= 1;

% Accuracy
rel_res_tol= relres;


if any(PL_n>1)
    
    %% PICARD ITERATIONS
    iter            = 1;
    
    if max_it_picard > 0
        while(1)
                     
            % Viscosity computation
            %el_Mu_PL = powerlaw_viscosity(MESH, el_Mu, el_PL_n, Vel, IP_X);
            el_Mu_PL = carreau_viscosity(MESH,el_Mu, el_PL_n, el_Mu_0, el_Mu_inf, Vel, IP_X);
            
            % SOLVE
            [Vel, p] = flow2d(MESH, BC, el_Mu_PL, nip);
            
            % Relative residual
            res             = powerlaw_residual(MESH, BC, el_Mu, el_PL_n, el_Mu_0, el_Mu_inf, Q, Vel, p, nip);
            res(BC.index)   = 0;
            rel_res(iter+1) = norm(res)/res_init;
            
            display(['Iteration Picard        : ' num2str(iter,'%.2d') ' relres: ' num2str(rel_res(iter+1),'%.12f') ]);
                        
            if(rel_res(iter+1)<rel_res_tol || iter>=max_it_picard)
                break
            end
            
            iter = iter + 1;
            
        end
    end
    
    %% NEWTON-RAPHSON
    iter = iter + 1;
    
    if max_it_nr > 0
        while(1)
            
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
            
            D = bsxfun(@times, (1./n-1).*(invar.^(1./n-2))./(2*invar), Ec) + bsxfun(@times,invar.^(1./n-1), DEV);
            D = 2*bsxfun(@times, D, el_Mu(:));
                  
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
                         
            if(rel_res(iter+1)<rel_res_tol || iter>max_it_nr)
                break
            end
            
            iter = iter + 1;
        end
    end
    
end

Vel         = reshape(Vel,2,nnod);
Vel         = Vel(:);

Vx  = Vel(1:2:end);
Vy  = Vel(2:2:end);
V_nodes = [Vx(interface_nodes)';Vy(interface_nodes)'];
V_nodes = V_nodes(:);

Vel = V_nodes;