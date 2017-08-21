function q = growth_rate_SAS_boundary(Lam0,R,Nl,Nm,h,H)

% Calculates growth rate of the single layer amplitude growth. The layer is
% embedded in the box.
% Input:    Lam - perturbation wavelength
%           R   - viscosity ratio between the layer and matrix
%           Nl  - stress exponent of the layer
%           Nm  - stress exponent of the matrix
%           h   - layer thickness
%           H   - half of the bounding box heigth

muL = R;
muM = 1;
k   = 2*pi/Lam0;

%% coef
alphaL = 1/sqrt(Nl);
betaL  = sqrt(1-1/Nl);
alphaM = 1/sqrt(Nm);
betaM  = sqrt(1-1/Nm);

%% matrix and rhs
A = zeros(12);
b = zeros(12,1);

% vz top boundary
% A(1,1)   = sin( betaM*k*H)*exp( alphaM*k*H);
% A(1,2)   = cos( betaM*k*H)*exp( alphaM*k*H);
% A(1,3)   = sin( betaM*k*H)*exp(-alphaM*k*H);
% A(1,4)   = cos( betaM*k*H)*exp(-alphaM*k*H);

A(1,1)   = sin( betaM*k*H);%*exp( alphaM*k*H);
A(1,2)   = cos( betaM*k*H);%*exp( alphaM*k*H);
A(1,3)   = sin( betaM*k*H)*exp(-2*alphaM*k*H);
A(1,4)   = cos( betaM*k*H)*exp(-2*alphaM*k*H);

% vz bottom boundary
%A(12, 9) = sin(-betaM*k*H)*exp(-alphaM*k*H);
%A(12,10) = cos(-betaM*k*H)*exp(-alphaM*k*H);
%A(12,11) = sin(-betaM*k*H)*exp( alphaM*k*H);
%A(12,12) = cos(-betaM*k*H)*exp( alphaM*k*H);

A(12, 9) = sin(-betaM*k*H)*exp(-2*alphaM*k*H);
A(12,10) = cos(-betaM*k*H)*exp(-2*alphaM*k*H);
A(12,11) = sin(-betaM*k*H);%*exp( alphaM*k*H);
A(12,12) = cos(-betaM*k*H);%*exp( alphaM*k*H);


% % vx top boundary
% A(2,1)   = ( betaM*cos( betaM*k*H) + alphaM*sin( betaM*k*H) )*exp( alphaM*k*H);
% A(2,2)   = (-betaM*sin( betaM*k*H) + alphaM*cos( betaM*k*H) )*exp( alphaM*k*H);
% A(2,3)   = ( betaM*cos( betaM*k*H) - alphaM*sin( betaM*k*H) )*exp(-alphaM*k*H);
% A(2,4)   = (-betaM*sin( betaM*k*H) - alphaM*cos( betaM*k*H) )*exp(-alphaM*k*H);
% % vx bottom boundary
% A(11,9)  = ( betaM*cos(-betaM*k*H) + alphaM*sin(-betaM*k*H) )*exp(-alphaM*k*H);
% A(11,10) = (-betaM*sin(-betaM*k*H) + alphaM*cos(-betaM*k*H) )*exp(-alphaM*k*H);
% A(11,11) = ( betaM*cos(-betaM*k*H) - alphaM*sin(-betaM*k*H) )*exp( alphaM*k*H);
% A(11,12) = (-betaM*sin(-betaM*k*H) - alphaM*cos(-betaM*k*H) )*exp( alphaM*k*H);

% Sns top boundary
% A(2,1)   =  ( (betaM^2-alphaM^2-1)*sin( betaM*k*H) - 2*alphaM*betaM*cos( betaM*k*H) )*exp( alphaM*k*H);
% A(2,2)   =  ( (betaM^2-alphaM^2-1)*cos( betaM*k*H) + 2*alphaM*betaM*sin( betaM*k*H) )*exp( alphaM*k*H);
% A(2,3)   =  ( (betaM^2-alphaM^2-1)*sin( betaM*k*H) + 2*alphaM*betaM*cos( betaM*k*H) )*exp(-alphaM*k*H);
% A(2,4)   =  ( (betaM^2-alphaM^2-1)*cos( betaM*k*H) - 2*alphaM*betaM*sin( betaM*k*H) )*exp(-alphaM*k*H);

A(2,1)   =  ( (betaM^2-alphaM^2-1)*sin( betaM*k*H) - 2*alphaM*betaM*cos( betaM*k*H) );%*exp( alphaM*k*H);
A(2,2)   =  ( (betaM^2-alphaM^2-1)*cos( betaM*k*H) + 2*alphaM*betaM*sin( betaM*k*H) );%*exp( alphaM*k*H);
A(2,3)   =  ( (betaM^2-alphaM^2-1)*sin( betaM*k*H) + 2*alphaM*betaM*cos( betaM*k*H) )*exp(-2*alphaM*k*H);
A(2,4)   =  ( (betaM^2-alphaM^2-1)*cos( betaM*k*H) - 2*alphaM*betaM*sin( betaM*k*H) )*exp(-2*alphaM*k*H);

% Sns bottom boundary
% A(11,9)  =  ( (betaM^2-alphaM^2-1)*sin(-betaM*k*H) - 2*alphaM*betaM*cos(-betaM*k*H) )*exp(-alphaM*k*H);
% A(11,10) =  ( (betaM^2-alphaM^2-1)*cos(-betaM*k*H) + 2*alphaM*betaM*sin(-betaM*k*H) )*exp(-alphaM*k*H);
% A(11,11) =  ( (betaM^2-alphaM^2-1)*sin(-betaM*k*H) + 2*alphaM*betaM*cos(-betaM*k*H) )*exp( alphaM*k*H);
% A(11,12) =  ( (betaM^2-alphaM^2-1)*cos(-betaM*k*H) - 2*alphaM*betaM*sin(-betaM*k*H) )*exp( alphaM*k*H);

A(11,9)  =  ( (betaM^2-alphaM^2-1)*sin(-betaM*k*H) - 2*alphaM*betaM*cos(-betaM*k*H) )*exp(-2*alphaM*k*H);
A(11,10) =  ( (betaM^2-alphaM^2-1)*cos(-betaM*k*H) + 2*alphaM*betaM*sin(-betaM*k*H) )*exp(-2*alphaM*k*H);
A(11,11) =  ( (betaM^2-alphaM^2-1)*sin(-betaM*k*H) + 2*alphaM*betaM*cos(-betaM*k*H) );%*exp( alphaM*k*H);
A(11,12) =  ( (betaM^2-alphaM^2-1)*cos(-betaM*k*H) - 2*alphaM*betaM*sin(-betaM*k*H) );%*exp( alphaM*k*H);

% vz top interface z = +h/2
A(3,1)   =  sin( betaM*k*h/2)*exp( alphaM*k*h/2);
A(3,2)   =  cos( betaM*k*h/2)*exp( alphaM*k*h/2);
A(3,3)   =  sin( betaM*k*h/2)*exp(-alphaM*k*h/2);
A(3,4)   =  cos( betaM*k*h/2)*exp(-alphaM*k*h/2);
A(3,5)   = -sin( betaL*k*h/2)*exp( alphaL*k*h/2);
A(3,6)   = -cos( betaL*k*h/2)*exp( alphaL*k*h/2);
A(3,7)   = -sin( betaL*k*h/2)*exp(-alphaL*k*h/2);
A(3,8)   = -cos( betaL*k*h/2)*exp(-alphaL*k*h/2);
% vz bottom interface z = -h/2
A(10,5)  =  sin(-betaL*k*h/2)*exp(-alphaL*k*h/2);
A(10,6)  =  cos(-betaL*k*h/2)*exp(-alphaL*k*h/2);
A(10,7)  =  sin(-betaL*k*h/2)*exp( alphaL*k*h/2);
A(10,8)  =  cos(-betaL*k*h/2)*exp( alphaL*k*h/2);
A(10,9)  = -sin(-betaM*k*h/2)*exp(-alphaM*k*h/2);
A(10,10) = -cos(-betaM*k*h/2)*exp(-alphaM*k*h/2);
A(10,11) = -sin(-betaM*k*h/2)*exp( alphaM*k*h/2);
A(10,12) = -cos(-betaM*k*h/2)*exp( alphaM*k*h/2);

% vx top interface z = +h/2
A(4,1)  =  ( betaM*cos( betaM*k*h/2) + alphaM*sin( betaM*k*h/2) )*exp( alphaM*k*h/2);
A(4,2)  =  (-betaM*sin( betaM*k*h/2) + alphaM*cos( betaM*k*h/2) )*exp( alphaM*k*h/2);
A(4,3)  =  ( betaM*cos( betaM*k*h/2) - alphaM*sin( betaM*k*h/2) )*exp(-alphaM*k*h/2);
A(4,4)  =  (-betaM*sin( betaM*k*h/2) - alphaM*cos( betaM*k*h/2) )*exp(-alphaM*k*h/2);
A(4,5)  = -( betaL*cos( betaL*k*h/2) + alphaL*sin( betaL*k*h/2) )*exp( alphaL*k*h/2);
A(4,6)  = -(-betaL*sin( betaL*k*h/2) + alphaL*cos( betaL*k*h/2) )*exp( alphaL*k*h/2);
A(4,7)  = -( betaL*cos( betaL*k*h/2) - alphaL*sin( betaL*k*h/2) )*exp(-alphaL*k*h/2);
A(4,8)  = -(-betaL*sin( betaL*k*h/2) - alphaL*cos( betaL*k*h/2) )*exp(-alphaL*k*h/2);
% vx bottom interface z = -h/2
A(9,5)  =  ( betaL*cos(-betaL*k*h/2) + alphaL*sin(-betaL*k*h/2) )*exp(-alphaL*k*h/2);
A(9,6)  =  (-betaL*sin(-betaL*k*h/2) + alphaL*cos(-betaL*k*h/2) )*exp(-alphaL*k*h/2);
A(9,7)  =  ( betaL*cos(-betaL*k*h/2) - alphaL*sin(-betaL*k*h/2) )*exp( alphaL*k*h/2);
A(9,8)  =  (-betaL*sin(-betaL*k*h/2) - alphaL*cos(-betaL*k*h/2) )*exp( alphaL*k*h/2);
A(9,9)  = -( betaM*cos(-betaM*k*h/2) + alphaM*sin(-betaM*k*h/2) )*exp(-alphaM*k*h/2);
A(9,10) = -(-betaM*sin(-betaM*k*h/2) + alphaM*cos(-betaM*k*h/2) )*exp(-alphaM*k*h/2);
A(9,11) = -( betaM*cos(-betaM*k*h/2) - alphaM*sin(-betaM*k*h/2) )*exp( alphaM*k*h/2);
A(9,12) = -(-betaM*sin(-betaM*k*h/2) - alphaM*cos(-betaM*k*h/2) )*exp( alphaM*k*h/2);

% Sns top interface
A(5,1)  =  muM*( (betaM^2-alphaM^2-1)*sin( betaM*k*h/2) - 2*alphaM*betaM*cos( betaM*k*h/2) )*exp( alphaM*k*h/2);
A(5,2)  =  muM*( (betaM^2-alphaM^2-1)*cos( betaM*k*h/2) + 2*alphaM*betaM*sin( betaM*k*h/2) )*exp( alphaM*k*h/2);
A(5,3)  =  muM*( (betaM^2-alphaM^2-1)*sin( betaM*k*h/2) + 2*alphaM*betaM*cos( betaM*k*h/2) )*exp(-alphaM*k*h/2);
A(5,4)  =  muM*( (betaM^2-alphaM^2-1)*cos( betaM*k*h/2) - 2*alphaM*betaM*sin( betaM*k*h/2) )*exp(-alphaM*k*h/2);
A(5,5)  = -muL*( (betaL^2-alphaL^2-1)*sin( betaL*k*h/2) - 2*alphaL*betaL*cos( betaL*k*h/2) )*exp( alphaL*k*h/2);
A(5,6)  = -muL*( (betaL^2-alphaL^2-1)*cos( betaL*k*h/2) + 2*alphaL*betaL*sin( betaL*k*h/2) )*exp( alphaL*k*h/2);
A(5,7)  = -muL*( (betaL^2-alphaL^2-1)*sin( betaL*k*h/2) + 2*alphaL*betaL*cos( betaL*k*h/2) )*exp(-alphaL*k*h/2);
A(5,8)  = -muL*( (betaL^2-alphaL^2-1)*cos( betaL*k*h/2) - 2*alphaL*betaL*sin( betaL*k*h/2) )*exp(-alphaL*k*h/2);
b(5)    = 4*(muM-muL);
% Sns bottom interface
A(8,5)  =  muL*( (betaL^2-alphaL^2-1)*sin(-betaL*k*h/2) - 2*alphaL*betaL*cos(-betaL*k*h/2) )*exp(-alphaL*k*h/2);
A(8,6)  =  muL*( (betaL^2-alphaL^2-1)*cos(-betaL*k*h/2) + 2*alphaL*betaL*sin(-betaL*k*h/2) )*exp(-alphaL*k*h/2);
A(8,7)  =  muL*( (betaL^2-alphaL^2-1)*sin(-betaL*k*h/2) + 2*alphaL*betaL*cos(-betaL*k*h/2) )*exp( alphaL*k*h/2);
A(8,8)  =  muL*( (betaL^2-alphaL^2-1)*cos(-betaL*k*h/2) - 2*alphaL*betaL*sin(-betaL*k*h/2) )*exp( alphaL*k*h/2);
A(8,9)  = -muM*( (betaM^2-alphaM^2-1)*sin(-betaM*k*h/2) - 2*alphaM*betaM*cos(-betaM*k*h/2) )*exp(-alphaM*k*h/2);
A(8,10) = -muM*( (betaM^2-alphaM^2-1)*cos(-betaM*k*h/2) + 2*alphaM*betaM*sin(-betaM*k*h/2) )*exp(-alphaM*k*h/2);
A(8,11) = -muM*( (betaM^2-alphaM^2-1)*sin(-betaM*k*h/2) + 2*alphaM*betaM*cos(-betaM*k*h/2) )*exp( alphaM*k*h/2);
A(8,12) = -muM*( (betaM^2-alphaM^2-1)*cos(-betaM*k*h/2) - 2*alphaM*betaM*sin(-betaM*k*h/2) )*exp( alphaM*k*h/2);
b(8)    = 4*(muL-muM);

% Snn top interface
C1 = -(k*exp( alphaM*k*h/2)*( betaM*cos(betaM*k*h/2) - alphaM*sin(betaM*k*h/2)))/(alphaM^2*k^2 + betaM^2*k^2); %int(exp( alphaM*k*z)*sin(betaM*k*z),z) for z=h/2
C2 =  (k*exp( alphaM*k*h/2)*(alphaM*cos(betaM*k*h/2) +  betaM*sin(betaM*k*h/2)))/(alphaM^2*k^2 + betaM^2*k^2); %int(exp( alphaM*k*z)*cos(betaM*k*z),z) for z=h/2
C3 = -(k*exp(-alphaM*k*h/2)*( betaM*cos(betaM*k*h/2) + alphaM*sin(betaM*k*h/2)))/(alphaM^2*k^2 + betaM^2*k^2); %int(exp(-alphaM*k*z)*sin(betaM*k*z),z) for z=h/2
C4 = -(k*exp(-alphaM*k*h/2)*(alphaM*cos(betaM*k*h/2) -  betaM*sin(betaM*k*h/2)))/(alphaM^2*k^2 + betaM^2*k^2); %int(exp(-alphaM*k*z)*cos(betaM*k*z),z) for z=h/2

C5 = -(k*exp( alphaL*k*h/2)*( betaL*cos(betaL*k*h/2) - alphaL*sin(betaL*k*h/2)))/(alphaL^2*k^2 + betaL^2*k^2); %int(exp( alphaL*k*z)*sin(betaL*k*z),z) for z=h/2
C6 =  (k*exp( alphaL*k*h/2)*(alphaL*cos(betaL*k*h/2) +  betaL*sin(betaL*k*h/2)))/(alphaL^2*k^2 + betaL^2*k^2); %int(exp( alphaL*k*z)*cos(betaL*k*z),z) for z=h/2
C7 = -(k*exp(-alphaL*k*h/2)*( betaL*cos(betaL*k*h/2) + alphaL*sin(betaL*k*h/2)))/(alphaL^2*k^2 + betaL^2*k^2); %int(exp(-alphaL*k*z)*sin(betaL*k*z),z) for z=h/2
C8 = -(k*exp(-alphaL*k*h/2)*(alphaL*cos(betaL*k*h/2) -  betaL*sin(betaL*k*h/2)))/(alphaL^2*k^2 + betaL^2*k^2); %int(exp(-alphaL*k*z)*cos(betaL*k*z),z) for z=h/2

A(6,1) =  muM*( (alphaM^2-betaM^2+1)*C1 + 2*alphaM*betaM*C2 );
A(6,2) =  muM*( (alphaM^2-betaM^2+1)*C2 - 2*alphaM*betaM*C1 );
A(6,3) =  muM*( (alphaM^2-betaM^2+1)*C3 - 2*alphaM*betaM*C4 );
A(6,4) =  muM*( (alphaM^2-betaM^2+1)*C4 + 2*alphaM*betaM*C3 );
A(6,5) = -muL*( (alphaL^2-betaL^2+1)*C5 + 2*alphaL*betaL*C6 );
A(6,6) = -muL*( (alphaL^2-betaL^2+1)*C6 - 2*alphaL*betaL*C5 );
A(6,7) = -muL*( (alphaL^2-betaL^2+1)*C7 - 2*alphaL*betaL*C8 );
A(6,8) = -muL*( (alphaL^2-betaL^2+1)*C8 + 2*alphaL*betaL*C7 );

% Snn bottom interface
C1 = -(k*exp(-alphaL*k*h/2)*( betaL*cos(-betaL*k*h/2) - alphaL*sin(-betaL*k*h/2)))/(alphaL^2*k^2 + betaL^2*k^2); %int(exp( alphaL*k*z)*sin(betaL*k*z),z) for z=-h/2
C2 =  (k*exp(-alphaL*k*h/2)*(alphaL*cos(-betaL*k*h/2) +  betaL*sin(-betaL*k*h/2)))/(alphaL^2*k^2 + betaL^2*k^2); %int(exp( alphaL*k*z)*cos(betaL*k*z),z) for z=-h/2
C3 = -(k*exp( alphaL*k*h/2)*( betaL*cos(-betaL*k*h/2) + alphaL*sin(-betaL*k*h/2)))/(alphaL^2*k^2 + betaL^2*k^2); %int(exp(-alphaL*k*z)*sin(betaL*k*z),z) for z=-h/2
C4 = -(k*exp( alphaL*k*h/2)*(alphaL*cos(-betaL*k*h/2) -  betaL*sin(-betaL*k*h/2)))/(alphaL^2*k^2 + betaL^2*k^2); %int(exp(-alphaL*k*z)*cos(betaL*k*z),z) for z=-h/2

C5 = -(k*exp(-alphaM*k*h/2)*( betaM*cos(-betaM*k*h/2) - alphaM*sin(-betaM*k*h/2)))/(alphaM^2*k^2 + betaM^2*k^2); %int(exp( alphaM*k*z)*sin(betaM*k*z),z) for z=-h/2
C6 =  (k*exp(-alphaM*k*h/2)*(alphaM*cos(-betaM*k*h/2) +  betaM*sin(-betaM*k*h/2)))/(alphaM^2*k^2 + betaM^2*k^2); %int(exp( alphaM*k*z)*cos(betaM*k*z),z) for z=-h/2
C7 = -(k*exp( alphaM*k*h/2)*( betaM*cos(-betaM*k*h/2) + alphaM*sin(-betaM*k*h/2)))/(alphaM^2*k^2 + betaM^2*k^2); %int(exp(-alphaM*k*z)*sin(betaM*k*z),z) for z=-h/2
C8 = -(k*exp( alphaM*k*h/2)*(alphaM*cos(-betaM*k*h/2) -  betaM*sin(-betaM*k*h/2)))/(alphaM^2*k^2 + betaM^2*k^2); %int(exp(-alphaM*k*z)*cos(betaM*k*z),z) for z=-h/2

A(7,5)  =  muL*( (alphaL^2-betaL^2+1)*C1 + 2*alphaL*betaL*C2 );
A(7,6)  =  muL*( (alphaL^2-betaL^2+1)*C2 - 2*alphaL*betaL*C1 );
A(7,7)  =  muL*( (alphaL^2-betaL^2+1)*C3 - 2*alphaL*betaL*C4 );
A(7,8)  =  muL*( (alphaL^2-betaL^2+1)*C4 + 2*alphaL*betaL*C3 );
A(7,9)  = -muM*( (alphaM^2-betaM^2+1)*C5 + 2*alphaM*betaM*C6 );
A(7,10) = -muM*( (alphaM^2-betaM^2+1)*C6 - 2*alphaM*betaM*C5 );
A(7,11) = -muM*( (alphaM^2-betaM^2+1)*C7 - 2*alphaM*betaM*C8 );
A(7,12) = -muM*( (alphaM^2-betaM^2+1)*C8 + 2*alphaM*betaM*C7 );

sol = A\b;

q = A(3,1:4)*sol(1:4);