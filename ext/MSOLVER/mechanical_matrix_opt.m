function [A_all, Q_all, M] = mechanical_matrix_opt(MESH, D, pf_sc, nip)

if nargin<3
    pf_sc=1e4;
end

%% MODEL INFO
[nnodel, nel] = size(MESH.ELEMS);
[ndim, nnod]  = size(MESH.NODES);
nedof = nnodel*ndim;
np    = 3;

%% CONSTANTS
%Mu_max = max(max(D,[],3),[],2);

%Mu_max = mean(D(:,1,:),3);
Mu = D;
if size(Mu,2)==nip
    Mu_char = sqrt( Mu(:,1,:).^2 + 2*Mu(:,2,:).^2 + 2*Mu(:,3,:).^2 + ...
                                     Mu(:,4,:).^2+ 2*Mu(:,5,:).^2 + ...
                                                      Mu(:,6,:).^2 );
    Mu_char = squeeze(Mu_char);
else
    Mu_char = squeeze(Mu(:,1,:));
end

Mu_char = mean(Mu_char,2);


PF = pf_sc*Mu_char;
C1 = 4/3;
C2 = 2/3;

%% BLOCKING PARAMETERS 
nelblo  = 1e4;
nelblo  = min(double(nel), nelblo); %(nelblo must be < nel)
nblo    = ceil(double(nel)/nelblo);
il = 1:nelblo:nblo*nelblo;
iu = nelblo:nelblo:nblo*nelblo;
iu(end) = nel;

%% INTEGRATION POINTS & DERIVATIVES wrt LOCAL COORDINATES
[ipx, ipw] = ip_triangle(nip);
[~,  dNdu] = shp_deriv_triangle(ipx,nnodel);
dNdu = reshape([dNdu{:}],nnodel,ndim,nip);
P = shp_deriv_triangle(ipx,np);
P = [P{:}];

%% VALIDATE MATERIAL PROPERTY ARRAY D 
[sD_1, sD_2, sD_3] = size(D);

%% DECLARE VARIABLES (ALLOCATE MEMORY)
A_all       = zeros(nedof*(nedof+1)/2,nel);
if nargout>1
    Q_all       = zeros(nedof*np, nel);
end
ENODES_block_x = zeros(nnodel,nelblo);
ENODES_block_y = zeros(nnodel,nelblo);
invJ_x = zeros(nelblo, ndim);
invJ_y = zeros(nelblo, ndim);

%% M matrix-------------------------
M = zeros(np);
for ip=1:nip
    M = M + ipw(ip)*P(:,ip)*P(:,ip)';
end
M = M/sum(ipw); %now all entries in M sum up to 1
invM = inv(M);
invM = invM(:)';

%% ELEMENT BLOCK LOOP - MATRIX COMPUTATION
for ib = 1:nblo  
    %% FETCH DATA OF ELEMENTS IN BLOCK
    EL_BLOCK = MESH.ELEMS(:,il(ib):iu(ib));
    ENODES_block_x(:) = MESH.NODES(1,EL_BLOCK);
    ENODES_block_y(:) = MESH.NODES(2,EL_BLOCK);
            
    if sD_1==1
        ED = D(1,:,:);
    else
        ED = D(il(ib):iu(ib),:,:);
    end

    %% INTEGRATION LOOP            
    A_block = zeros(nelblo, nedof*(nedof+1)/2);    
    Q_block     = zeros(nelblo, np*nedof);

    invMQ_block = zeros(nelblo, np*nedof);
    area = zeros(nelblo,1);    
    
    for ip=1:nip
        %% FETCH DATA OF INTEGRATION POINT
        IPD = ED(:,:,min(ip,sD_3));
        dNdui  = dNdu(:,:,ip);
        Pi     = P(:,ip);
        
        %% CALCULATE JACOBIAN AND ITS INVERSE AND DETERMINANT
        %JACOBIAN
        J_x = ENODES_block_x'*dNdui;
        J_y = ENODES_block_y'*dNdui;
        
        %ITS DETERMINANT
        detJ = J_x(:,1).*J_y(:,2) - J_x(:,2).*J_y(:,1);
        invdetJ = 1.0./detJ;
        
        %JACOBIAN'S INVERSE
        invJ_x(:,1) = +J_y(:,2).*invdetJ;
        invJ_x(:,2) = -J_y(:,1).*invdetJ;        
        invJ_y(:,1) = -J_x(:,2).*invdetJ;
        invJ_y(:,2) = +J_x(:,1).*invdetJ;
                
        %% DERIVATIVES wrt GLOBAL COORDINATES
        dNdx   = invJ_x*dNdui';
        dNdy   = invJ_y*dNdui';
                
        %% NUMERICAL INTEGRATION OF THE ELEMENT STIFFNESS MATRIX
        weight = ipw(ip)*detJ;   
        area = area + weight;
        
        % ------------------------Q matrix-------------------------
        if pf_sc~=0
            for i=1:np
                TMP1 = weight.*Pi(i);
                TMP2 = TMP1(:,ones(1,nnodel));
                Q_block(:,(i-1)*nedof + (1:2:nedof)) =  Q_block(:,(i-1)*nedof + (1:2:nedof)) - TMP2.*dNdx;
                Q_block(:,(i-1)*nedof + (2:2:nedof)) =  Q_block(:,(i-1)*nedof + (2:2:nedof)) - TMP2.*dNdy;
            end
        end
        if sD_2==1 %isotropic 
            
        weight     =    weight.*IPD;
        
        % ------------------------A matrix-------------------------
        indx  = 1;
        for i = 1:nnodel
            % x-velocity equation
            for j = i:nnodel
                A_block(:,indx) = A_block(:,indx) + ( C1.*dNdx(:,i).*dNdx(:,j) + dNdy(:,i).*dNdy(:,j)).*weight;
                indx = indx+1;
                A_block(:,indx) = A_block(:,indx) + (-C2.*dNdx(:,i).*dNdy(:,j) + dNdy(:,i).*dNdx(:,j)).*weight;
                indx = indx+1;
            end
            % y-velocity equation
            for j = i:nnodel
                if(j>i)
                    A_block(:,indx) = A_block(:,indx) + (-C2.*dNdy(:,i).*dNdx(:,j) + dNdx(:,i).*dNdy(:,j)).*weight;
                    indx = indx+1;
                end
                A_block(:,indx) = A_block(:,indx) + ( C1.*dNdy(:,i).*dNdy(:,j) + dNdx(:,i).*dNdx(:,j)).*weight;
                indx = indx+1;
            end
        end
        
        else %anisotropic
            
            d11 = IPD(:,1);
            d12 = IPD(:,2);
            d13 = IPD(:,3);
            d22 = IPD(:,4);
            d23 = IPD(:,5);
            d33 = IPD(:,6);
            
            indx  = 1;
            for i = 1:nnodel
                
                % X-VELOCITY EQUATION
                for j = i:nnodel
                    A_block(:,indx) = A_block(:,indx) + ( d11.*dNdx(:,i).*dNdx(:,j) + d33.*dNdy(:,i).*dNdy(:,j) + ...
                        d13.*dNdx(:,i).*dNdy(:,j) + d13.*dNdx(:,j).*dNdy(:,i)).*weight;
                    indx = indx+1;
                    A_block(:,indx) = A_block(:,indx) + (d12.*dNdx(:,i).*dNdy(:,j) + d33.*dNdy(:,i).*dNdx(:,j) + ...
                        d13.*dNdx(:,i).*dNdx(:,j) + d23.*dNdy(:,j).*dNdy(:,i)).*weight;
                    indx = indx+1;
                end
                
                
                %Y-VELOCITY EQUATION
                for j = i:nnodel
                    if(j>i)
                        A_block(:,indx) = A_block(:,indx) + (d12.*dNdy(:,i).*dNdx(:,j) + d33.*dNdx(:,i).*dNdy(:,j) + ...
                            d13.*dNdx(:,i).*dNdx(:,j) + d23.*dNdy(:,j).*dNdy(:,i)).*weight;
                        indx = indx+1;
                    end
                    A_block(:,indx) = A_block(:,indx) + ( d22.*dNdy(:,i).*dNdy(:,j) + d33.*dNdx(:,i).*dNdx(:,j) + ...
                        d23.*dNdx(:,i).*dNdy(:,j) + d23.*dNdx(:,j).*dNdy(:,i)).*weight;
                    indx = indx+1;
                end
            end
        end                                       
    end
    
    if pf_sc~=0
        %% AUGMENT
        invM_block = (1./area)*invM;
        
        % --------------------------invM*Q'----------------------------
        for i=1:np
            for j=1:nedof
                for k=1:np
                    invMQ_block(:,(i-1)*nedof+j) = invMQ_block(:,(i-1)*nedof+j) + invM_block(:,(i-1)*np+k).*Q_block(:,(k-1)*nedof+j);
                end
            end
        end
        
        %%-------------------A = A + PF*Q'*invM*Q'---------------------
        indx = 1;
        for i=1:nedof
            for j=i:nedof
                for k=1:np
                    A_block(:,indx) = A_block(:,indx) + PF(il(ib):iu(ib)).*Q_block(:,(k-1)*nedof+i).*invMQ_block(:,(k-1)*nedof+j);
                    % A_block(:,indx) = A_block(:,indx) + PF.*Q_block(:,(k-1)*nedof+i).*invMQ_block(:,(k-1)*nedof+j);
                end
                indx = indx + 1;
            end
        end
        
    end
    
    %% WRITE DATA INTO GLOBAL STORAGE    
    A_all(:,il(ib):iu(ib))      = A_block';
    if nargout>1
        Q_all(:,il(ib):iu(ib))      = Q_block';
    end

    % READJUST START, END AND SIZE OF BLOCK. REALLOCATE MEMORY
    if(ib==nblo-1)
        nelblo 	= nel-il(nblo)+1;
        ENODES_block_x = zeros(nnodel,nelblo);
        ENODES_block_y = zeros(nnodel,nelblo);
        invJ_x = zeros(nelblo, ndim);
        invJ_y = zeros(nelblo, ndim);
    end
        
end

end

