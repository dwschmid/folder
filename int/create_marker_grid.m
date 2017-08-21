function MARKERS = create_marker_grid(Xbot, Ybot, Xtop, Ytop, type, ncell, resol)

% Original author:    Marta Adamuszek
% Last committed:     $Revision: 91 $
% Last changed by:    $Author: schmid $
% Last changed date:  $Date: 2017-08-21 16:17:19 +0200 (Mon, 21 Aug 2017) $
%--------------------------------------------------------------------------

ncell = ncell+1;
resol = resol+1;

% Reduce the size of the bounding region
% epsi = 1e1;
% Xbot(Xbot==min(Xbot)) = Xbot(Xbot==min(Xbot))+epsi;
% Xbot(Xbot==max(Xbot)) = Xbot(Xbot==max(Xbot))-epsi;
% Ybot(Ybot==min(Ybot)) = Ybot(Ybot==min(Ybot))+epsi;
% Xtop(Xtop==min(Xtop)) = Xtop(Xtop==min(Xtop))+epsi;
% Xtop(Xtop==max(Xtop)) = Xtop(Xtop==max(Xtop))-epsi;
% Ytop(Ytop==max(Ytop)) = Ytop(Ytop==max(Ytop))-epsi;

% Find bounding region
xfield = [Xbot fliplr(Xtop) Xbot(1)]';
yfield = [Ybot fliplr(Ytop) Ybot(1)]';

xfield([1 4 5]) = xfield([1 4 5])+1e-4;
xfield([2 3])   = xfield([2 3])-1e-4;
yfield([1 2 5]) = yfield([1 2 5])+1e-4;
yfield([3 4])   = yfield([3 4])-1e-4;  

switch type
    case 1 % layers
        
        %% Horizontal lines
        % Define X and Y coordinates
        x  = [linspace(min(Xtop),max(Xtop),resol*ncell) NaN];
        y  =  linspace(min(Ybot),max(Ytop),ncell);
        [XX, YY] = ndgrid(x,y);
        YY(end,:) = NaN;
        XX = XX(:)';
        YY = YY(:)';
        
        % Check if the markers are inside the region
        p    = [XX' YY'];
        node = [xfield yfield];
        edge = [1:length(xfield); 2:length(xfield) 1]';
        [in,on]  = inpoly(p,node,edge,1e-12);
        in(on==1) = 0;
        
        % Set markers outside the region to NaN
        XX((in)==0) = NaN;
        YY((in)==0) = NaN;
        
        MARKERS = [XX;YY];
        
    case 2 % bars
        
        %% Vertical lines
        % Define X and Y coordinates
        x  = linspace(min(Xbot),max(Xbot),ncell);
        y  = [linspace(min(Ybot),max(Ytop),ncell*resol) NaN];
        [XX, YY] = meshgrid(x,y);
        XX(end,:) = NaN;
        XX = XX(:)';
        YY = YY(:)';
        
        % Check if the markers are inside the region
        p    = [XX' YY'];
        node = [xfield yfield];
        edge = [1:length(xfield); 2:length(xfield) 1]';
        [in,on]  = inpoly(p,node,edge,1e-12);
        in(on==1) = 0;
        
        % Set markers outside the region to NaN
        XX((in)==0) = NaN;
        YY((in)==0) = NaN;
        
        MARKERS = [XX;YY];
        
    case 3 % grid
        
        %% Vertical lines
        % Define X and Y coordinates
        xv  = linspace(min(Xbot),max(Xbot),ncell);
        grid_size = xv(2)-xv(1);
        ncell2    = ceil(( max(Ytop)-min(Ybot) )/(grid_size));
        yv  = [linspace(min(Ybot),max(Ytop),ncell2*resol) NaN];
        [XXv, YYv] = meshgrid(xv,yv);
        XXv(end,:) = NaN;
        XXv = XXv(:)';
        YYv = YYv(:)';
        
        % Check if the markers are inside the region
        p    = [XXv' YYv'];
        node = [xfield yfield];
        edge = [1:length(xfield); 2:length(xfield) 1]';
        [in,on]  = inpoly(p,node,edge,1e-10);
        in(on==1) = 0;
        
        % Set markers outside the region to NaN
        XXv((in)==0) = NaN;
        YYv((in)==0) = NaN;
        
        %% Horizontal lines
        % Calculate number of cells in horizontal direction and the shift
        sy        = ((max(Ytop)-min(Ybot))-(ncell2+1)*grid_size)/2;
        
        % Define X and Y coordinates
        xh  = [linspace(min(Xtop),max(Xtop),ncell*resol) NaN];
        yh  = (min(Ybot)+sy):grid_size:(min(Ybot)+sy+(ncell2+1)*grid_size);
        [XXh, YYh] = ndgrid(xh,yh);
        YYh(end,:) = NaN;
        XXh = XXh(:)';
        YYh = YYh(:)';
        
        % Check if the markers are inside the region
        p    = [XXh' YYh'];
        node = [xfield yfield];
        edge = [1:length(xfield); 2:length(xfield) 1]';
        [in,on]  = inpoly(p,node,edge,1e-12);
        in(on==1) = 0;
        
        % Set markers outside the region to NaN
        XXh((in)==0) = NaN;
        YYh((in)==0) = NaN;
        
        MARKERS = [XXh NaN XXv;...
                   YYh NaN YYv];
        
    case 4 % ellipses
        
        x      = linspace(min(Xbot),max(Xbot),ncell);
        grid_size = x(2)-x(1);
        x      = x(1:end-1)+grid_size/2;
        y      = (min(Ybot)+grid_size/2):grid_size:(max(Ytop)-grid_size/2);
        sy     = ((max(Ytop)-min(Ybot)-grid_size)-(length(y)-1)*grid_size)/2;
        y      = y + sy; % shift points to the center
        
        [xx, yy] = ndgrid(x,y);
        xx = xx(:);
        yy = yy(:);
        
        % Define references ellipse
        theta = linspace(0,2*pi,resol);
        r     = 0.4*grid_size;
        xc    = [r*cos(theta) NaN];
        yc    = [r*sin(theta) NaN];
        
        % Duplicate ellipses and set them in proper cell
        XX = bsxfun(@plus, xx, xc)';
        XX = XX(:)';
        YY = bsxfun(@plus, yy, yc)';
        YY = YY(:)';
        
        % Check if the markers are inside the region
        p    = [XX' YY'];
        node = [xfield yfield];
        edge = [1:length(xfield); 2:length(xfield) 1]';
        [in,on]  = inpoly(p,node,edge,1e-10);
        in(on==1) = 0;
        
        % Set markers outside the region to NaN
        XX((in)==0) = NaN;
        YY((in)==0) = NaN;
        
        MARKERS = [XX;YY];
        
    case 5 % polygrain
        
        xv  = linspace(min(Xbot),max(Xbot),ncell);
        grid_size = xv(2)-xv(1);
        
        xmin = min(Xbot);
        xmax = max(Xtop);
        ymin = min(Ybot);
        ymax = max(Ytop);
        
        % Size of the box
        width  = xmax-xmin;
        height = ymax-ymin;
        
        % Aligned centers
        nx = ceil(( xmax-xmin )/(grid_size));
        ny = ceil(( ymax-ymin )/(grid_size));
        dx     = width/(nx-1);
        dy     = height/(ny-1);
        x_out  = linspace(xmin-2*dx,xmax+2*dx,nx+4);
        y_out  = linspace(ymin-2*dy,ymax+2*dy,ny+4);
        [x_out, y_out] = meshgrid(x_out, y_out);
        
        % Shift every other node
        t = zeros(ny+4,1);
        t(1:2:end) = dx/2;
        t = repmat(t,1,nx+4);
        x_out = x_out + t;
        x_out(2:2:end,1)   = NaN;
        x_out(:,end) = NaN;
        
        % Identify inner and outer points
        x_out = x_out(:);
        y_out = y_out(:);
        Outer = find(isnan(x_out));
        x_out(Outer) = [];
        y_out(Outer) = [];
        
        Left   = find( (x_out-xmin)<=0);
        Right  = find( (x_out-xmax)>=0);
        Bottom = find( (y_out-ymin)<=0);
        Top    = find( (y_out-ymax)>=0);
        Bdry   = unique(sort([Left; Right; Bottom; Top]));
        Inner  = 1:length(x_out);
        Inner(Bdry) = [];
        
        % Perturbed hexagonal centers
        pertx = (-1 + 2*rand(length(Inner),1))*dx/4;
        perty = (-1 + 2*rand(length(Inner),1))*dy/4;
        x_out(Inner) = x_out(Inner) + pertx;
        y_out(Inner) = y_out(Inner) + perty;
        
        % Create triangle input
        tristr.points         = [x_out y_out]';
        opts                  = [];
        opts.element_type     = 'tri3';
        opts.triangulate_poly = 0;
        opts.other_options    = 'v';
        
        % Generate the mesh using triangle
        [~, VORO]        = mtriangle(opts, tristr);
        
        % Remove unnecessary segments
        VORO.EDGES(:,VORO.EDGES(2,:)==0) = [];
        
        X = reshape(VORO.NODES(1,VORO.EDGES),2,size(VORO.EDGES,2));
        Y = reshape(VORO.NODES(2,VORO.EDGES),2,size(VORO.EDGES,2));
        
        % Add additional points on each wall
        x  = bsxfun(@times,[ones(resol+1,1);NaN],X(1,:));
        dx = bsxfun(@times,[0:1:resol NaN]',diff(X,1,1)/resol);
        y  = bsxfun(@times,[ones(resol+1,1);NaN],Y(1,:));
        dy = bsxfun(@times,[0:1:resol NaN]',diff(Y,1,1)/resol);
        
        XX = x+dx;
        YY = y+dy;
        XX = XX(:)';
        YY = YY(:)';
        
        % Check if the markers are inside the region
        p    = [XX' YY'];
        node = [xfield yfield];
        edge = [1:length(xfield); 2:length(xfield) 1]';
        [in,on]   = inpoly(p,node,edge,1e-10);
        in(on==1) = 0;
        
        % Set markers outside the region to NaN
        XX(in==0) = NaN;
        YY(in==0) = NaN;
        
        MARKERS = [XX;YY];
        
end
end




