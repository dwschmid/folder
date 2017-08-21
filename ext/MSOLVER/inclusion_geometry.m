function [POINTS, SEGMENTS, REGIONS] = inclusion_geometry(box,incl)

xmax    = box.width/2;
xmin    = -xmax;
ymax    = box.height/2;
ymin    = -ymax;

box_points = [xmin xmax xmax xmin;ymin ymin ymax ymax];
box_segments = [1 2 3 4; 2 3 4 1];

POINTS     	= box_points;
SEGMENTS 	= uint32(box_segments);
REGIONS     = [xmin+1e-2;...
               ymin+1e-2;...
                1;...
               -1];
% inclusions
for i = 1:length(incl.radius_a)
    
    incl_a      = incl.radius_a(i);
    incl_b      = incl.radius_b(i);
    incl_phi    = incl.radius_phi(i);
    npts        = incl.nx(i);
    
    th          = linspace(0,2*pi,npts+1);
    th(end)     = [];
    incl_points = [sin(th); cos(th)];
    S           = diag([incl_a incl_b]);
    R           = [cos(incl_phi) sin(incl_phi); -sin(incl_phi) cos(incl_phi)];
    
    incl_points     = R*S*incl_points+[incl.x(i)*ones(1,npts);incl.y(i)*ones(1,npts)];
    incl_segments   = [1:npts;2:npts+1];
    incl_segments(end) = 1;
    incl_segments   = incl_segments+size(SEGMENTS,2);
    
    POINTS      	= [POINTS incl_points];
    SEGMENTS        = uint32([SEGMENTS incl_segments]);
    REGIONS         = [REGIONS [incl.x(i); incl.y(i); 2; -1]];
end

                      
