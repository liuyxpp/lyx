function [  ] = viscylind(x,y,z,phi_a,phi_b,isoval,aa,repeat)
% Visualizing concentration distributions in three-dimensional (3D) space
% in cylinder generated by scftpy/CylinderAB.
%   since 2013.9.10
%   coded by Yixin Liu @ Fudan University
%   contact: lyx@fudan.edu.cn
%   %usage:
%       viscylind(x,y,z,phiA,phiB)
%       input var
%           phi_a: concentration of component A
%           phi_b: concentration of component B
%           isoval: iso-value
%           aa: alpha-value
%           repeat: a vector with length 3 for repmat use
%       output var
%           none
%       output
%           3D visualization figure
%   %example:
% $ Revision: 2013.9.10 $

switch nargin
    case 5
        isoval = [0.5, 0.5];
        aa = [0.6,0.6];
        repeat = [1 1 1];
    case 6
        aa = [0.6,0.6];
        repeat = [1 1 1];
    case 7
        repeat = [1 1 1];
end

%figure;
% Smooth data before visualization
phi_a=smooth3(phi_a,'box',5);
phi_b=smooth3(phi_b,'box',5);

% Repeat data in each dimension
phi_a = repmat(phi_a,repeat);
phi_b = repmat(phi_b,repeat);
% To implement above repetition, x, y, z should also be repeated.
% Note that here the equal spaced grid is assumed.
[Lx,Ly,Lz] = size(x);
xa = x(1,1,1);
dx1 = x(2,1,1) - xa;
dx2 = x(1,2,1) - xa;
dx3 = x(1,1,2) - xa;
yc = y(1,1,1);
dy1 = y(2,1,1) - yc;
dy2 = y(1,2,1) - yc;
dy3 = y(1,1,2) - yc;
ze = z(1,1,1);
dz1 = z(2,1,1) - ze;
dz2 = z(1,2,1) - ze;
dz3 = z(1,1,2) - ze;
repx = repeat(1);
repy = repeat(2);
repz = repeat(3);

x = zeros(Lx*repx,Ly*repy,Lz*repz);
y = zeros(Lx*repx,Ly*repy,Lz*repz);
z = zeros(Lx*repx,Ly*repy,Lz*repz);
for i=1:Lx*repx
    for j=1:Ly*repy
        for k=1:Lz*repz
            x(i,j,k) = (i-1)*dx1 + (j-1)*dx2 + (k-1)*dx3;
            y(i,j,k) = (i-1)*dy1 + (j-1)*dy2 + (k-1)*dy3;
            z(i,j,k) = (i-1)*dz1 + (j-1)*dz2 + (k-1)*dz3;
        end
    end
end

% Create the isosurface and set properties
%isoval=0.33;
ha=patch(isosurface(x,y,z,phi_a,isoval(1)),...
        'FaceColor','red',...
        'EdgeColor','none',...
        'AmbientStrength',0.2,...
        'SpecularStrength',0.7,...
        'DiffuseStrength',0.4);
%isonormals(x,y,z,phi_a,ha)
alpha(aa(1))
% Create the isocaps and set Properties
patch(isocaps(x,y,z,phi_a,isoval(1)),...
        'FaceColor','red',...
        'EdgeColor','none');
% Set transparency of caps
alpha(aa(1))

hb=patch(isosurface(x,y,z,phi_b,isoval(2)),...
        'FaceColor','green',...
        'EdgeColor','none',...
        'AmbientStrength',0.2,...
        'SpecularStrength',0.7,...
        'DiffuseStrength',0.4);
%isonormals(x,y,z,phi_b,hb)
alpha(aa(2))
patch(isocaps(x,y,z,phi_b,isoval(2)),...
        'FaceColor','green',...
        'EdgeColor','none')
alpha(aa(2))

%colormap hsv
% Define the View
daspect([1,1,1])
axis equal
%grid on
view(3)
% Add lighting
camlight right
camlight left
%set(gcf,'Renderer','zbuffer');
lighting phong

%%%% Prettify figure export
axis tight
axis off
op = get(gca, 'OuterPosition')
pi = get(gca, 'Position')
ti = get(gca, 'TightInset')
%set(gca, 'Position', op)
%set(gca, 'Position', [ti(1) ti(2) 1-ti(3)-ti(1) 1-ti(4)-ti(2)]);
%set(gca,'Units','Inches');
%pos = get(gca, 'Position');
%ti = get(gca, 'TightInset');
%w = pos(3)+ti(1)+ti(3);
%h = pos(4)+ti(2)+ti(4);
%set(gcf, 'PaperUnits', 'Inches');
%set(gcf, 'PaperSize', [w h]);
%set(gcf, 'PaperPositionMode', 'manual');
%set(gcf, 'PaperPosition', [0 0 w h]);
%saveas(gcf, 'phiAB_mat.png');
%print('phiAB_mat','-dpng','-r300');
%print('phiAB_mat','-depsc2','-r300');
end

