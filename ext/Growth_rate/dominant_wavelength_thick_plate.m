function lam = dominant_wavelength_thick_plate(R, mode)

% Original author:    Marta Adamuszek
% Last committed:     $Revision: 66 $
% Last changed by:    $Author: fgt_marta $
% Last changed date:  $Date: 2015-05-09 15:14:37 +0200 (So, 09 maj 2015) $
%--------------------------------------------------------------------------

% Thin plate
lam0 = 2*pi*(R/6)^(1/3);

% Define wavelength span
Lam2h = linspace(max([0.1*lam0 1]),10*lam0,10000);

% Wavenumber
k   = 2*pi./Lam2h;

if strcmp(mode,'folding')
    % Folding - thick plate solution
    q = 4*k*(1-R)*R./(2*k*(R^2-1)-(R+1)^2*exp(k)+(R-1)^2*exp(-k));
    
    % Find maximum
    [~,idx] = max(q);
    
elseif strcmp(mode,'boudinage')
    % Boudinage - thick plate solution
    q = 4*k*(1-R)*R./(2*k*(R^2-1)+(R+1)^2*exp(k)-(R-1)^2*exp(-k));
    
    % Find minimum
    [~,idx] = min(q);
end

lam = 2*pi./k(idx);