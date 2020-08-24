%2010.8.18
%Revision: 2010.8.20
%Revision: 2010.8.27, using imshow() instead of contourf() 
%Revision: 2010.10.26, separate plot of A+B and S

repeatx=3;
repeaty=3;
isPlotPolymerDensity=0;
isPlotPolymerDensityReplica=1;
isPlotSolventDensity=0;
isPlotSolventDensityReplica=0;

[Lx,Ly,Lz]=size(phiA);
phi_a=zeros(Lx,Ly);
phi_b=zeros(Lx,Ly);
phiba=zeros(Lx,Ly);
phi_s=zeros(Lx,Ly);
phi0=zeros(Lx,Ly);
for i=1:Lx
    for j=1:Ly
        phi_a(i,j)=phiA(i,j,1);
        phi_b(i,j)=phiB(i,j,1);
        %phi_s(i,j)=phiS(1,i,j);
    end
end
phiab=phi_a-phi_b;

% density plot
% A+B
if(isPlotPolymerDensity)
phi_img=cat(3,phi_a,phi0,phi_b);
figure;
imshow(phi_img,'Border','tight');
set(gca,'DataAspectRatio',[1.0 ly/lz 1.0]);
axis off
end
% Solvent
smin=min(min(phi_s));
smax=max(max(phi_s));
phi_s_r=(phi_s-smin)/(smax-smin); %rescaled phi_s
if(isPlotSolventDensity)
phi_img=cat(3,phi0,phi_s_r,phi0);
figure;imshow(phi_img,'Border','tight');
set(gca,'DataAspectRatio',[1.0 ly/lz 1.0]);
axis off
end
% replica A+B
if(isPlotPolymerDensityReplica)
phi_img=cat(3,repmat(phi_a,repeatx,repeaty),repmat(phi0,repeatx,repeaty),repmat(phi_b,repeatx,repeaty));
figure;imshow(phi_img,'Border','tight');
set(gca,'DataAspectRatio',[1.0 ly/lz 1.0]);
axis off
end
% replica solvent
if(isPlotSolventDensityReplica)
phi_img=cat(3,repmat(phi0,repeatx,repeaty),repmat(phi_s_r,repeatx,repeaty),repmat(phi0,repeatx,repeaty));
figure;imshow(phi_img,'Border','tight');
set(gca,'DataAspectRatio',[1.0 ly/lz 1.0]);
axis off
end

%print -depsc2 Fig.ps;
%print -depsc2 -tiff Fig.eps;
%print -dill Fig.ai;
%print -dmeta;
clear r g b i j L
clear repeatx repeaty isPlotPolymerDensity isPlotPolymerDensityReplica
clear isPlotSolventDensity isPlotSolventDensityReplica
clear maxe mine smin smax phi_img