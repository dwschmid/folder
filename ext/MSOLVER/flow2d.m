function [Vel, p] = flow2d(MESH, BC, Mu, nip, rhs)  

%% model info
[nnodel, nel]  = size(MESH.ELEMS);
[ndim, nnod] = size(MESH.NODES);
%nnod = MESH.info.nnod;
ndof = ndim*nnod;
nedof = nnodel*ndim;
np = 3;
ar = polyarea(reshape(MESH.NODES(1,MESH.ELEMS(1:3,:)),3,nel),...
              reshape(MESH.NODES(2,MESH.ELEMS(1:3,:)),3,nel));
%% rhs
if nargin<5
    rhs = zeros(ndof,1);
end

%% matrix computation
pf=1e1;%1e2;%1e4;

[A_all, Q_all, M] = mechanical_matrix_opt(MESH, Mu, pf, nip);

%% matrix assembly
% A matrix
if exist(['sparse_create.' mexext], 'file') == 3
    opts_sparse.symmetric = 1;
    opts_sparse.n_node_dof = 2;
    A = sparse_create(MESH.ELEMS, A_all, opts_sparse);
else
   %sparse2 or sparse
end
% Q matrix
ELEM_DOF = zeros(nedof, nel,'int32');
ELEM_DOF(1:ndim:end,:) = ndim*(MESH.ELEMS-1)+1;
ELEM_DOF(2:ndim:end,:) = ndim*(MESH.ELEMS-1)+2;

Q_i = repmat(int32(1:nel*np),nedof,1);
Q_j = repmat(ELEM_DOF,np,1);

if exist(['sparse2.' mexext], 'file') == 3
    Q = sparse2(Q_i(:), Q_j(:), Q_all(:));
else
    Q = sparse(double(Q_i(:)), double(Q_j(:)), Q_all(:));
end


%% boundary conditions
bc_indx = BC.index;
bc_val = BC.val;
Free = 1:ndof;
Free(bc_indx) = [];
Vel = zeros(ndof,1);
Vel(bc_indx) = bc_val;
% rhs
f = rhs-A*Vel-A'*Vel;
f = f(Free);
% A matrix
A = A(Free,Free);
% Q matrix
g = -Q*Vel;
Q(:,bc_indx) = [];

%% factorize A
%L = lchol(A);
L = chol(A,'lower');

%% pressure iterations (CG)
% if exist(['cs_lsolve' mexext], 'file') == 3    
%     bfsubst = @(x) cs_ltsolve(L,cs_lsolve(L,x));    
% else
%     Lt = L';
%     bfsubst = @(x)Lt\(L\x);    
% end
% 
% D = spdiags(sqrt(spdiags(A,0)), 0,size(A,1),size(A,1)); 
% invD = spdiags(1./sqrt(spdiags(A,0)), 0,size(A,1),size(A,1));
% % 
% D = spdiags(ones(size((spdiags(A,0)))), 0,size(A,1),size(A,1)); 
% invD = D;
% 
A2 = A + tril(A,-1)';
% A3 = invD*A2*invD;
% L = chol(A3,'lower');
% bfsubst = @(x) A2\x;
b = Q*bfsubst(f)-g;
b = b-mean(b); %only if no traction bc

%Mu_max = max(max(Mu,[],3),[],2);%visc averaging for p iterations
%Mu_max = max(mean(Mu(:,1,:),3),[],2);
%Mu_max = mean(Mu(:,1,:),3);
if size(Mu,2)==nip
    Mu_char = sqrt( Mu(:,1,:).^2 + 2*Mu(:,2,:).^2 + 2*Mu(:,3,:).^2 + ...
                                     Mu(:,4,:).^2+ 2*Mu(:,5,:).^2 + ...
                                                      Mu(:,6,:).^2 );
    Mu_char = squeeze(Mu_char);
else
    Mu_char = squeeze(Mu(:,1,:));
end

Mu_char = mean(Mu_char,2);

% display(['max: ', num2str(max(mean(Mu(:,1,:),3)./Mu(:,1)))])
% display(['min: ', num2str(min(mean(Mu(:,1,:),3)./Mu(:,1)))])

%Mu_max = Mu(:,1);
%max(Mu_max)
%min(Mu_max)
pre = repmat(ar(:)'./Mu_char(:)',3,1);
pre = pre(:);
invM = inv(M);

[p, ~, relres, it, resvec] = pcg(@(x)Q*bfsubst(Q'*x), b , 1e-13, 100, ...
                        @(x)(reshape(invM*reshape(x,np,nel),np*nel,1))./pre);
 
%it
%relres
Vel(Free) = bfsubst(f-Q'*p);

function x=bfsubst(b)
x = 0*b;
for i=1
%res = invD*b-A3*x;    
%res = b-A3*x;    
res = b-A2*x;    
x=x+cs_ltsolve(L,cs_lsolve(L,res));
end
%x = invD*x;


%norm(res)
%x = x1;
%x2=cs_ltsolve(L,cs_lsolve(L,res));
%x = x1 + x2;
%res = b-A2*x;
%norm(res)
end
end

%% fgmres - outer solver
%scaling A & Q

%% refinement
%A2 no penalty
% VelFree = bfsubst(f-Q'*p);
% A = [A2 Q';Q sparse(size(Q,1), size(Q,1))];
% sol = [VelFree;p];
% res = [f;g]-A*sol;
% ref = minres(A,res,1e-3,100);
% sol = sol+ref;


