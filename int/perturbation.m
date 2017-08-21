function pert = perturbation(pert_type, wavelength, L, shift, width, nx, ampl)

% Original author:    Marta Adamuszek
% Last committed:     $Revision: 91 $
% Last changed by:    $Author: schmid $
% Last changed date:  $Date: 2017-08-21 16:17:19 +0200 (Mon, 21 Aug 2017) $
%--------------------------------------------------------------------------

% Input parameters:
% - pert_type   - type of perturbation from the list:
%       1 - sine, 2 -  red noise, 3 - white noise, 4 - Gaussian noise
%       5 - step function, 6 - triangle shape, 7 - bell shape
% - wavelength  - wavelength (for the periodic functions)
% - L           - domain width
% - shift       - phase shift (for the periodic functions)
% - width       - bell width (for the bell shape function) 
%                 or Hurst exponent (for the Gaussian noise)
% - nx          - number of points
% - ampl        - perturbation amplitude

x     = linspace(-L/2,L/2,nx);

switch pert_type
    
    case 1 
        %% SINE
        
        pert    = cos(2*pi*1/wavelength*(x-shift));
        
    case 2
        %% RED
        
        phi     = 2*pi*rand(1,floor(nx/2));
        pert    = zeros(1,nx);
        
        for it = 1:floor(nx/2)
            pert  = pert + 1/it*cos(2*pi*it*x/L+phi(it));
        end
        
    case 3
        %% WHITE
        
        phi     = 2*pi*rand(1,floor(nx/2));
        pert    = zeros(1,nx);
        
        for it = 1:floor(nx/2)
            pert  = pert + cos(2*pi*it*x/L+phi(it));
        end
        
    case 4
        %% GAUSSIAN
        
        sigma       = 1; % standard deviation fix to 1
        correlation = nx/L*wavelength; % correlation wavelength
        herst_exp   = width; % wykladnik hersta 0-1
        pert    = generate_crf_FT(nx, sigma, correlation, herst_exp);
        
    case 5
        %% STEP
        
        pert    = -ones(1,nx);
        idx     = find(x>shift);
        pert(idx) = 1;
        
    case 6
        %% TRIANGLE
       
        n_waves = round(L/wavelength);
        xx      = linspace(-n_waves*wavelength,n_waves*wavelength,4*n_waves+1)+shift;
        yy      = ones(1,4*n_waves+1);
        yy(2:2:end) = -1;
        pert    = interp1(xx,yy,x);
        
    case 7
        %% BELL

        bb          = 1;
        pert        = bb./(1+((x-shift)/width).^2);
        pert        = pert-(max(pert)-min(pert))/2;
        
end

% normalize the perturbation to get the proper amplitude
if max(pert)-min(pert)>0
    pert = 2*ampl/(max(pert)-min(pert))*pert;
    % shift the perturbation
    pert = pert - (max(pert)-abs(ampl));
end
    
