function [u1] = plot2d1c(u,idx,idy,idz,n)
% u   - Nx x Ny x Nz 3D array
% idx - index for cut normal to x direction
% idy - index for cut normal to y direction
% idz - index for cut normal to z direction
% n   - number of contour levels
 
[Nx, Ny, Nz] = size(u);


u2x=zeros(Ny,Nz);
for j=1:Ny
    for k=1:Nz
        u2x(j,k)=u(idx,j,k);
    end
end

u2y=zeros(Nx,Nz);
for i=1:Nx
    for k=1:Nz
        u2y(i,k)=u(i,idy,k);
    end
end

u2z=zeros(Nx,Ny);
for i=1:Nx
    for j=1:Ny
        u2z(i,j)=u(i,j,idz);
    end
end


figure;
contourf(u2x,n);
colorbar;
shading flat;
%phi_img=cat(3,u2,phi0,phi0);
%imshow(phi_img,'Border','tight');
set(gca,'DataAspectRatio',[1.0 1.0 1.0]);
saveas(gcf, 'x-cut.png')
axis off

figure;
contourf(u2y,n);
colorbar;
shading flat;
set(gca,'DataAspectRatio',[1.0 1.0 1.0]);
saveas(gcf, 'y-cut.png')
axis off

figure;
contourf(u2z,n);
colorbar;
shading flat;
set(gca,'DataAspectRatio',[1.0 1.0 1.0]);
saveas(gcf, 'z-cut.png')
axis off

u1 = zeros(Nz+1, 1);
for k=1:Nz
    for i=1:Nx
        for j=1:Ny
            u1(k) = u1(k) + u(i,j,k);
        end
    end
end
u1(Nz+1) = u1(1);
u1 = u1 / (Nx*Ny);

% figure;
% plot(u1,'-o');

end