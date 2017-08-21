function ER_ALL = extract_strain_2d(GCOORD, ELEM2NODE, VEL, STRAIN_X, nelblo)

nel = size(ELEM2NODE,2);
curr_nnodel = size(ELEM2NODE,1);

nstrain = size(STRAIN_X,1);
ndim = 2;
nnodel = 7;
ntensor = 3;
nnod        = size(GCOORD,2);

%==========================================================================
% BLOCKING PARAMETERS (nelblo must be < nel)
%==========================================================================
nelblo      = min(nel, nelblo);
nblo        = ceil(nel/nelblo);
il          = 1;
iu          = nelblo;

%==========================================================================
% ADD 7th NODE
%==========================================================================

if (nnodel==7 & curr_nnodel~=7)
    tic; fprintf(1, ' 6 TO 7:              ');
    ELEM2NODE(7,:)  = nnod+1:nnod+nel;
    GCOORD          = [GCOORD, [...
        mean(reshape(GCOORD(1, ELEM2NODE(1:3,:)), 3, nel));...
        mean(reshape(GCOORD(2, ELEM2NODE(1:3,:)), 3, nel))]];
    fprintf(1, [num2str(toc),'\n']);
end


%==========================================================================
% PREPARE INTEGRATION POINTS & DERIVATIVES wrt LOCAL COORDINATES
%==========================================================================

[N dNdu]      = shp_deriv_triangle(STRAIN_X, nnodel);   


%EVALUATE STRAIN RATES
%tic; 
%fprintf(1, 'CALC STRAIN RATE, STRESS, AVERAGE PROPERTIES:    ');
ER_ALL  = zeros(ntensor, nel*nstrain);


for ib = 1:nblo
    %======================================================================
    % ii) FETCH DATA OF ELEMENTS IN BLOCK
    %======================================================================
    ECOORD_x = reshape( GCOORD(1,ELEM2NODE(:,il:iu)), nnodel, nelblo);
    ECOORD_y = reshape( GCOORD(2,ELEM2NODE(:,il:iu)), nnodel, nelblo);
    
    V_x = reshape( VEL(ndim*(ELEM2NODE(:,il:iu)-1)+1), nnodel,nelblo);
    V_y = reshape( VEL(ndim*(ELEM2NODE(:,il:iu)-1)+2), nnodel,nelblo);
   
    
    
    %======================================================================
    % INTEGRATION LOOP
    %======================================================================
    for ip=1:nstrain
        %==================================================================
        % iii) LOAD SHAPE FUNCTIONS DERIVATIVES FOR INTEGRATION POINT
        %==================================================================
        dNdui       = dNdu{ip};

        Jx          = ECOORD_x'*dNdui;                                 
        Jy          = ECOORD_y'*dNdui;                                 
        detJ        = Jx(:,1).*Jy(:,2) - Jx(:,2).*Jy(:,1);

        invdetJ     = 1.0./detJ;
        invJx(:,1)  = +Jy(:,2).*invdetJ;
        invJx(:,2)  = -Jy(:,1).*invdetJ;
        invJy(:,1)  = -Jx(:,2).*invdetJ;
        invJy(:,2)  = +Jx(:,1).*invdetJ;

        %==================================================================
        % v) DERIVATIVES wrt GLOBAL COORDINATES
        %==================================================================
        dNdx        = invJx*dNdui';
        dNdy        = invJy*dNdui';
              
        %CALCULATE STRAIN
        dVxdx = sum(dNdx'.*V_x);
        dVydy = sum(dNdy'.*V_y);
         ER_BLOCK = [2/3*dVxdx - 1/3*dVydy;...   
                     2/3*dVydy - 1/3*dVxdx;...
                     0.5*(sum(dNdy'.*V_x)+sum(dNdx'.*V_y))];
         
         ER_ALL(:,(ip-1)*nel+(il:iu)) = ER_BLOCK;       
        
%         ER_ALL(1,(ip-1)*nel+[il:iu]) = 2/3*dVxdx - 1/3*dVydy;
%          ER_ALL(2,(ip-1)*nel+[il:iu]) = 2/3*dVydy - 1/3*dVxdx;                
%          ER_ALL(3,(ip-1)*nel+[il:iu]) = 0.5*(sum(dNdy.*V_x',2)+sum(dNdx.*V_y',2));
%         
    end
    
    
    
    il  = il+nelblo;
    if(ib==nblo-1)
        nelblo 	= nel-iu;
        invJx   = zeros(nelblo, ndim);
        invJy   = zeros(nelblo, ndim);
    end
    iu  = iu+nelblo;
end

%fprintf(1, [num2str(toc),'\n']);

end