function [AKT,corr,Q] = LAF_sine_bounded(tspan,R,Len0,T0,Amp0,L)

% Original author:    Marta Adamuszek
% Last committed:     $Revision: 66 $
% Last changed by:    $Author: fgt_marta $
% Last changed date:  $Date: 2015-05-09 15:14:37 +0200 (So, 09 maj 2015) $
%--------------------------------------------------------------------------

% Input parameters
% tspan - time integration
% R     - viscosity ratio 
% Len0  - initital wavelength
% T0    - initital thickness
% Amp0  - initital amplitude
% Funtion that returns:
% AKT  - amplitude, wavenumber and thickness evolution wiht time
% Q    - growth rate evolution with time
% All the parameters are calculated according to LAF method for a single
% waveform.

options = odeset('RelTol',1e-8);
k0      = 2*pi/Len0;

[tmp, AKT] = ode45(@myfun, tspan, [Amp0; k0; T0], options);
[corr, Q]  = correction_factor(AKT);

    function dakt = myfun(Tspan,akt)
        
        A = akt(1); %amplitude
        k = akt(2); %wavenumber
        T = akt(3); %thickness
        
        % Growth rate
        kT = k*T;
        AA = exp(kT);
        BB = exp(kT*L);
        q  = -4*kT.*(R - 1).*( R*(1-AA.^2./BB.^4) - 2*AA./BB.^2.*(2*L - 1).*( kT.*(R-1)- sinh(kT) ) )./ ...
                    (+ (R-1)^2*(1+AA.^4./BB.^4).*AA.^-1 + ...
                     - (R+1)^2*AA.*(1+1./BB.^4 ) + ...
                     + 2*kT.*(R^2 - 1).*(1-AA.^2./BB.^4) +...
                     - 4*AA./BB.^2.*( kT.^2.*(2*L-1)*(R-1)^2+2*R - kT.*(2*L-1).*sinh(kT).*(R^2-1) ) );
        
        % Correction factor
        a       = A*k;   %scale amplitude
        [K, E]  = ellipke(a^2/(a^2+1));
        SS      = a^2/(a^2+1)+(E-K)/(E*(a^2+1));
        c       = (1-2*SS)/(1+q*SS);

        % Solve equations
        dA = A*(1+q*c);
        dk = k;
        dT = T*c;
        
        dakt = [dA; dk; dT];
        
    end

    function [c, Q] = correction_factor(AKT)
        
        n = length(AKT);
        A = AKT(:,1);   %amplitude
        k = AKT(:,2);   %wavenumber
        T = AKT(:,3);   %thickness
        c = zeros(1,n); %correction factor
        Q = zeros(1,n); %growth rate
       
        for it = 1:n %loop over time
            
            % growth rate
            kT = k(it)*T(it);
            AA = exp(kT);
            BB = exp(kT*L);
            q  = -4*kT.*(R - 1).*( R*(1-AA.^2./BB.^4) - 2*AA./BB.^2.*(2*L - 1).*( kT.*(R-1)- sinh(kT) ) )./ ...
                    (+ (R-1)^2*(1+AA.^4./BB.^4).*AA.^-1 + ...
                     - (R+1)^2*AA.*(1+1./BB.^4 ) + ...
                     + 2*kT.*(R^2 - 1).*(1-AA.^2./BB.^4) +...
                     - 4*AA./BB.^2.*( kT.^2.*(2*L-1)*(R-1)^2+2*R - kT.*(2*L-1).*sinh(kT).*(R^2-1) ) );
            
            % Correction factor
            a       = A(it)*k(it);   %scale amplitude
            [K, E]  = ellipke(a^2/(a^2+1));
            
            SS = a^2/(a^2+1)+(E-K)/(E*(a^2+1));
            c(it)  = (1-2*SS)/(1+q*SS);
            
            Q(it) = q*c(it);
        end
        
    end

end

