IP_X_visu = [0 0; 1 0; 0 1];
X = reshape(MESH.NODES(1,MESH.ELEMS(1:3,:)),3,[]);
Y = reshape(MESH.NODES(2,MESH.ELEMS(1:3,:)),3,[]);

ER_ALL = extract_strain_2d(MESH.NODES, MESH.ELEMS, Vel, IP_X_visu, nelblo);
%ER_ALL_II	= sqrt((ER_ALL(1,:)-ER_ALL(2,:)).^2./4+ER_ALL(3,:).^2)';
%ER_ALL_II = sqrt((ER_ALL(1,:).^2+ER_ALL(2,:).^2)/2+ER_ALL(3,:).^2)';
EZZ = -(ER_ALL(1,:)+ER_ALL(2,:));
ER_ALL_II = sqrt((ER_ALL(1,:).^2+ER_ALL(2,:).^2+EZZ.^2)/2+ER_ALL(3,:).^2)';
ER_ALL_II = reshape(ER_ALL_II, nel, 3)';

figure(1)
clf
hold on
patch(X,Y,ER_ALL_II)
plot(POINTS(1,:),POINTS(2,:),'k')
axis([-Box.width/2 Box.width/2 -Box.height/2 Box.height/2])
axis equal, axis off
shading interp
drawnow