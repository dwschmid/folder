function [dVxdx, dVxdy, dVydx, dVydy, IP_pts, map_pm] = dVdx_grid(X,Y,Vx,Vy,MESH)

grid = [X(:)';Y(:)'];
V    = [Vx(:)'; Vy(:)'];

nnodel = 7;
npts   = length(X);

% Mapping
WS.xmin   = min(MESH.NODES(1,:));
WS.xmax   = max(MESH.NODES(1,:));
WS.ymin   = min(MESH.NODES(2,:));
WS.ymax   = max(MESH.NODES(2,:));
opts.nthreads = 1;

warning('off','MATLAB:triangulation:PtsNotInTriWarnId');
map_pm     = tsearch2(MESH.NODES, MESH.ELEMS(1:3,:), grid, WS);
[~,IP_pts] = einterp(MESH, V, grid, map_pm, opts);

% Calculate derivatives
[DERIV_u, DERIV_v]   = deriv_triangle7(IP_pts);

% Fetch data of elements
ECOORD_X = reshape( MESH.NODES(1,MESH.ELEMS(:,map_pm)), nnodel, npts);
ECOORD_Y = reshape( MESH.NODES(2,MESH.ELEMS(:,map_pm)), nnodel, npts);

V_x  = Vx(MESH.ELEMS(:,map_pm));
V_y  = Vy(MESH.ELEMS(:,map_pm));

% Calculate jacobian and its inverse
Jx_u    = sum(ECOORD_X.*DERIV_u,1);
Jx_v    = sum(ECOORD_X.*DERIV_v,1);
Jy_u    = sum(ECOORD_Y.*DERIV_u,1);
Jy_v    = sum(ECOORD_Y.*DERIV_v,1);
detJ   	= Jx_u.*Jy_v - Jx_v.*Jy_u;
invdetJ	= 1./detJ;
invJx1  = +Jy_v.*invdetJ;
invJx2  = -Jy_u.*invdetJ;
invJy1  = -Jx_v.*invdetJ;
invJy2  = +Jx_u.*invdetJ;

% Calculate derivatives in the grid points
dNdx   = repmat(invJx1,7,1).*DERIV_u+repmat(invJx2,7,1).*DERIV_v;
dNdy   = repmat(invJy1,7,1).*DERIV_u+repmat(invJy2,7,1).*DERIV_v;

% Calculate strain
dVxdx = sum(dNdx.*V_x,1);
dVxdy = sum(dNdy.*V_x,1);
dVydx = sum(dNdx.*V_y,1);
dVydy = sum(dNdy.*V_y,1);
