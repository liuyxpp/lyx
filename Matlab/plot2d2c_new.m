%Revision: 2010.8.27, using imshow() instad of contourf
%Revision: 2010.8.31, show phie using imshow().
%Revision: 2010.9.1, correct phie<0 case.
%Revision: 2010.10.17, separate plot of A+B and S.
%Revision: 2011.3.25, add distribution of counterions
%Revision: 2012.4.17, dimension index has changed due to blitz

%!!!!Note: salt has not been considered in current version.

repeatx=3;
repeaty=3;
isPlotPolymerDensity=1;
isPlotPolymerDensityReplica=0;
isPlotSolventDensity=1;
isPlotSolventDensityReplica=0;
isPlotChargeDensity=1;
isPlotChargeDensityReplica=0;
isPlotCounterion=1;
isPlotCounterionReplica=0;

phi_a=phiA;
phi_b=phiB;
phi_s=phiS;
phi_p=phiP;
phi_n=phiN;
phi0=zeros(size(phiA));

phiab=phi_a-phi_b;
phipn=phi_p-phi_n;
phie=alphaA*upsA*phi_a+alphaB*upsB*phi_b+upsP*phi_p+upsN*phi_n; %net charge
phici=upsP*phi_p; %counterions, only for nA0B

% density plot
% A+B
if(isPlotPolymerDensity)
phi_img=cat(3,phi_a,phi0,phi_b);
figure;imshow(phi_img,'Border','tight');
set(gca,'DataAspectRatio',[lx/Lx ly/Ly 1.0]);
axis off
end
% Solvent
smin=min(min(phi_s));
smax=max(max(phi_s));
phi_s_r=(phi_s-smin)/(smax-smin); %rescaled phi_s
if(isPlotSolventDensity)
phi_img=cat(3,phi0,phi_s_r,phi0);
figure;imshow(phi_img,'Border','tight');
set(gca,'DataAspectRatio',[lx/Lx ly/Ly 1.0]);
axis off
end
% replica A+B
if(isPlotPolymerDensityReplica)
phi_img=cat(3,repmat(phi_a,repeatx,repeaty),repmat(phi0,repeatx,repeaty),repmat(phi_b,repeatx,repeaty));
figure;imshow(phi_img,'Border','tight');
set(gca,'DataAspectRatio',[lx/Lx ly/Ly 1.0]);
axis off
end
% replica solvent
if(isPlotSolventDensityReplica)
phi_img=cat(3,repmat(phi0,repeatx,repeaty),repmat(phi_s_r,repeatx,repeaty),repmat(phi0,repeatx,repeaty));
figure;imshow(phi_img,'Border','tight');
set(gca,'DataAspectRatio',[lx/Lx ly/Ly 1.0]);
axis off
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% net charge density plot
%mine=min(min(phie));
%maxe=max(max(phie));
mine=upsA*alphaA*fA*phiC/upsP; % Only for nA0B
maxe=-mine; %only for nA0B
r=zeros(size(phie));
g=zeros(size(phie));
b=zeros(size(phie));
% negtive charged region - red
% positive charged region - green
% neutral region - black
for i=1:Lx
    for j=1:Ly
        if phie(i,j)>0
            g(i,j)=(phie(i,j)-0)/(maxe-0);
        end
        if phie(i,j)<0
            r(i,j)=(0-phie(i,j))/(0-mine);
        end
    end
end
if(isPlotChargeDensity)
phie_img=cat(3,r,g,b);
figure;imshow(phie_img,'Border','tight');
set(gca,'DataAspectRatio',[lx/Lx ly/Ly 1.0]);
axis off
end
% Replica net charge
if(isPlotChargeDensityReplica)
phie_img=cat(3,repmat(r,repeatx,repeaty),repmat(g,repeatx,repeaty),repmat(b,repeatx,repeaty));
figure;imshow(phie_img,'Border','tight');
set(gca,'DataAspectRatio',[lx/Lx ly/Ly 1.0]);
axis off
end
%%% counterion charge density plot
phici_n=phici/(-upsA*alphaA*fA*phiC); %normalized phici
minci=0; %min(min(phici)); 
maxci=max(max(phici));
phici_n_r=(phici-minci)/(maxci-minci); %rescaled phici_n
if(isPlotCounterion)
phici_img=cat(3,phi0,phici_n_r,phi0);
figure;imshow(phici_img,'Border','tight');
set(gca,'DataAspectRatio',[lx/Lx ly/Ly 1.0]);
axis off
end
% Replica counterion
if(isPlotCounterionReplica)
phici_img=cat(3,repmat(phi0,repeatx,repeaty),repmat(phici_n_r,repeatx,repeaty),repmat(phi0,repeatx,repeaty));
figure;imshow(phici_img,'Border','tight');
set(gca,'DataAspectRatio',[lx/Lx ly/Ly 1.0]);
axis off
end

clear r g b i j L
clear phi_img phie_img phici_img
clear isPlotPolymerDensity isPlotPolymerDensityReplica
clear isPlotSolventDensity isPlotChargeDensity isPlotChargeDensityReplica
clear isPlotCounterion isPlotCounterionReplica
clear maxe mine smin smax maxci minci