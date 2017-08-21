function [POINTS, SEGMENTS, REGIONS] = layer_geometry(box,layer)

% - Box
xmax    = box.width/2;
xmin    = -xmax;
ymax    = box.height/2;
ymin    = -ymax;

POINTS          = [xmin xmax xmax xmin;ymin ymin ymax ymax];
SEGMENTS        = [1 2 3 4; 2 3 4 1];
REGIONS         = [xmin+1e-2; ymin+1e-2; 1; -1];

% - Layer
if ~isfield(layer,'nlayers')
    layer.nlayers = 1;
end

X    = [linspace(xmin,xmax,layer.nx)     linspace(xmax,xmin,layer.nx)];

if layer.pert == 1
    % Sinusoidal perturbation
    pert = layer.ampl*cos(2*pi*1/box.width*linspace(xmin,xmax,layer.nx));
elseif layer.pert == 2
    % Red noise
    x       = linspace(xmin,xmax,layer.nx);
    phi     = 2*pi*rand(1,floor(layer.nx/2));
    pert    = zeros(1,layer.nx);
    for it = 1:floor(layer.nx/2)
        pert  = pert + 1/it*cos(2*pi*it*x./box.width+phi(it));
    end
    pert = 2*layer.ampl/(max(pert)-min(pert))*pert;
    pert = pert - (max(pert)-abs(layer.ampl));
end

nl   = 2*layer.nlayers-1;
yy   = -nl*layer.thick/2:layer.thick:nl*layer.thick/2;

for il = 1:layer.nlayers
    POINTS   = [POINTS [X;pert+yy(2*il-1) pert+yy(2*il)]];
    SEGMENTS = [SEGMENTS [1:2*layer.nx; 2:2*layer.nx 1]+size(SEGMENTS,2)];
    REGIONS  = [REGIONS [xmin+1e-2; pert(1)+yy(2*il-1)+1e-2; 2; -1]];
    REGIONS  = [REGIONS [xmin+1e-2; pert(1)+yy(2*il  )+1e-2; 1; -1]];
end
