function res = powerlaw_residual(MESH, BC, el_Mu, el_PL_n, el_Mu_0, el_Mu_inf, Q,Vel, p, nip)

IP_X = ip_triangle(nip);
%el_Mu_PL = powerlaw_viscosity(MESH,el_Mu, el_PL_n, Vel,IP_X);
el_Mu_PL = carreau_viscosity(MESH,el_Mu, el_PL_n, el_Mu_0, el_Mu_inf, Vel,IP_X);
A_all = mechanical_matrix_opt(MESH, el_Mu_PL,0, nip);

if exist(['sparse_create.' mexext], 'file') == 3
    opts_sparse.symmetric = 1;
    opts_sparse.n_node_dof = 2;
    A = sparse_create(MESH.ELEMS, A_all, opts_sparse);
else
   %sparse2 or sparse
end

if exist(['spmv.' mexext], 'file') == 3
     opts.symmetric  = 1;
     % mutils was not everywhere compiled with OpenMP support. Try
     % multi-threading, if it fails, then use single thread.
     try
         opts.nthreads = 4;
         Ac = sparse_convert(A, opts);
     catch
         opts.nthreads = 1;
         Ac = sparse_convert(A, opts);
     end
     res = spmv(Ac, Vel(:))+Q'*p;
else
    A = A+tril(A,-1)';
    res = A*Vel(:)+Q'*p;
end

res(BC.index)=0;
