function [Exx, Eyy, Exy] = strain_rate(VEL, MESH, nelblo)

% Original author:    Marcin Dabrowski
% Last committed:     $Revision: 91 $
% Last changed by:    $Author: schmid $
% Last changed date:  $Date: 2017-08-21 16:17:19 +0200 (Mon, 21 Aug 2017) $
%--------------------------------------------------------------------------

% Computes strain-rate 

nel = size(MESH.ELEMS,2);
ndim = 2;
nnodel = 7;

% BLOCKING PARAMETERS 
nelblo      = min(nel, nelblo);
nblo        = ceil(nel/nelblo);
il          = 1;
iu          = nelblo;

% PREPARE INTEGRATION POINTS & DERIVATIVES wrt LOCAL COORDINATES
IP_X = [0 0; 1 0; 0 1; 1/2 1/2; 0 1/2; 1/2 0; 1/3 1/3];
npts = size(IP_X,1);

[~, dNdu]   = shp_deriv_triangle(IP_X, nnodel);   

% ALLOCATE MEMORY
Exx         = zeros(3, nel);
Eyy         = zeros(3, nel);
Exy         = zeros(3, nel);

for ib = 1:nblo
    % FETCH DATA OF ELEMENTS IN BLOCK
    ECOORD_x = reshape( MESH.NODES(1,MESH.ELEMS(:,il:iu)), nnodel, nelblo);
    ECOORD_y = reshape( MESH.NODES(2,MESH.ELEMS(:,il:iu)), nnodel, nelblo);
    
    V_x = reshape( VEL(ndim*(MESH.ELEMS(:,il:iu)-1)+1), nnodel,nelblo);
    V_y = reshape( VEL(ndim*(MESH.ELEMS(:,il:iu)-1)+2), nnodel,nelblo);
   

    % INTEGRATION LOOP OVER CORNER POINTS
    for ip=1:npts
        
        % LOAD SHAPE FUNCTIONS DERIVATIVES FOR INTEGRATION POINT
        dNdui       = dNdu{ip};

        Jx          = ECOORD_x'*dNdui;                                 
        Jy          = ECOORD_y'*dNdui;                                 
        detJ        = Jx(:,1).*Jy(:,2) - Jx(:,2).*Jy(:,1);

        invdetJ     = 1.0./detJ;
        invJx(:,1)  = +Jy(:,2).*invdetJ;
        invJx(:,2)  = -Jy(:,1).*invdetJ;
        invJy(:,1)  = -Jx(:,2).*invdetJ;
        invJy(:,2)  = +Jx(:,1).*invdetJ;

        % DERIVATIVES wrt GLOBAL COORDINATES
        dNdx        = invJx*dNdui';
        dNdy        = invJy*dNdui';

        %CALCULATE STRAIN AT EACH TRIANGLE CORNER
        Exx(ip,il:iu)  = 2/3*sum(dNdx.*V_x',2) - 1/3*sum(dNdy.*V_y',2);
        Eyy(ip,il:iu)  = 2/3*sum(dNdy.*V_y',2) - 1/3*sum(dNdx.*V_x',2);   
        Exy(ip,il:iu)  = 0.5*(sum(dNdy.*V_x',2)+sum(dNdx.*V_y',2));

    end
    
    il  = il+nelblo;
    if(ib==nblo-1)
        nelblo 	= nel-iu;
        invJx   = zeros(nelblo, ndim);
        invJy   = zeros(nelblo, ndim);
    end
    iu  = iu+nelblo;
end

end