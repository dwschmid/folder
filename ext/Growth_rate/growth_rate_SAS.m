function q = growth_rate_SAS(Lam0,R,Nl,Nm)

% Original author:    Marta Adamuszek
% Last committed:     $Revision: 66 $
% Last changed by:    $Author: fgt_marta $
% Last changed date:  $Date: 2015-05-09 15:14:37 +0200 (So, 09 maj 2015) $
%--------------------------------------------------------------------------

k0 = 2*pi./Lam0;
R  = 1/R;

% Introduce coefficients used in q
alpha   = sqrt(1./Nl);
beta    = sqrt(1-1./Nl);
gamma   = sqrt(Nl-1);
Q       = sqrt(Nl/Nm)*R;

% Introduce  variable
temp1	= 2*Nl.*(1-R);
temp2   = (1-Q.^2);
temp3   = gamma.*(1+Q).^2;
temp4   = gamma.*(1-Q).^2;

% Introduce  variable dependent on k
temp5   = 2*sin(beta*k0);
temp6   = exp(alpha*k0)./temp5;
temp7   = exp(-alpha*k0)./temp5;

% growth rate 
q       = temp1 ./ ( -temp2 + temp3.*temp6 - temp4.*temp7 );