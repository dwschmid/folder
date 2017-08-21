function el_Mu_PL = powerlaw_viscosity(MESH,el_Mu, el_PL_n, Vel,IP_X)

nelblo = 1e4;
nip = size(IP_X,1);
nel = size(MESH.ELEMS,2);
ER_ALL    = extract_strain_2d(MESH.NODES, MESH.ELEMS, Vel, IP_X, nelblo);
%ER_ALL_II = sqrt((ER_ALL(1,:).^2+ER_ALL(2,:).^2)/2+ER_ALL(3,:).^2)';
EZZ = -(ER_ALL(1,:)+ER_ALL(2,:));
ER_ALL_II = sqrt((ER_ALL(1,:).^2+ER_ALL(2,:).^2+EZZ.^2)/2+ER_ALL(3,:).^2)';
ER_ALL_II = reshape(ER_ALL_II,nel,nip);
el_Mu_PL = bsxfun(@times, el_Mu, bsxfun(@power, ER_ALL_II, (1./el_PL_n-1)));
el_Mu_PL = reshape(el_Mu_PL,nel,1,nip);
