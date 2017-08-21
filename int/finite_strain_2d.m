function [FS_ab, FS_th, FS_V] = finite_strain_2d(FS_dxdX)

% Original author:    Marcin Dabrowski
% Last committed:     $Revision: 91 $
% Last changed by:    $Author: schmid $
% Last changed date:  $Date: 2017-08-21 16:17:19 +0200 (Mon, 21 Aug 2017) $
%--------------------------------------------------------------------------

%FS_dxdX = reshape(FS_dxdX_in,4,length(FS_dxdX_in)/4);
nfs   = size(FS_dxdX,2);
FS_ab = zeros(2,nfs);
FS_V  = zeros(2,nfs);
FS_th = zeros(1,nfs);

for k=1:nfs
    dxdX = reshape(FS_dxdX(:,k),2,2);
    dXdx = dxdX;
    
    [V,D] = eig(dXdx'*dXdx);
    ab  = sqrt(diag(D));
    str = V*sqrt(D)*V';
    rot = dXdx*inv(str);
    la = rot*V(:,2);
    th = atan2(la(2),la(1));

    FS_ab(:,k) = ab;
    FS_th(k) = th;
    FS_V(:,k) = la;
end

end