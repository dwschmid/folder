function y = generate_crf_FT(nx, sigma, lc, H)

% Original author:    Marcin Dabrowski
% Last committed:     $Revision: 91 $
% Last changed by:    $Author: schmid $
% Last changed date:  $Date: 2017-08-21 16:17:19 +0200 (Mon, 21 Aug 2017) $
%--------------------------------------------------------------------------

% Correlated random fields

% Correlation function
u   =-(nx-1):(nx-1);
C   = sigma^2*exp(-(abs(u/lc)).^(2*H));
Cft = fft(C);

X   = randn(1,2*nx-1);
Xft = fft(X);
tmp = sqrt(Cft);
y   = real(ifft(tmp.*Xft));

y   = y(nx:end);
