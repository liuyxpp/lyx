function [  ] = visual3d_scatter(x,y,z,data1,data2,data3,isoval,alp,repeat)
% Visualizing concentration distributions in three-dimensional (3D) space
% in cubic cell.
%   since 2010.4.14
%   coded by Yixin Liu @ Fudan
%   contact: liuyxpp@gmail.com
%   %usage:
%       visual3d_scatter()
%       input var
%           x,y,z: coordinates
%           data1,data2,data3: 3D concentration
%           isoval: iso surface threshold
%           alp: degree of alpha
%           repeat: reptition times
%       output var
%           none
%       output
%           3D visualization figure for scatered coordinates.
%   %example:
% $ Revision: 2012.5.8 $

switch nargin
    case 6
        isoval = [0.2,0.4,0.4];
        alp = [0.6,0.6,0.6];
        repeat = [2,2,2];
    case 7
        alp = [0.6,0.6,0.6];
        repeat = [2,2,2];
    case 8
        repeat = [2,2,2];
end

% new figure
figure;
% Smooth data before visualization
%data1=smooth3(data1,'box',5);
%data2=smooth3(data2,'box',5);
%data3=smooth3(data3,'box',5);

% repetition
data1 = repmat(data1,repeat);
data2 = repmat(data2,repeat);
data3 = repmat(data3,repeat);
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
ha=patch(isosurface(x,y,z,data1,isoval(1)),...
        'FaceColor','red',...
        'EdgeColor','none',...
        'AmbientStrength',0.2,...
        'SpecularStrength',0.7,...
        'DiffuseStrength',0.4);
%isonormals(x,y,z,data1,ha)
alpha(alp(1))
% Create the isocaps and set Properties
patch(isocaps(x,y,z,data1,isoval(1)),...
        'FaceColor','red',...
        'EdgeColor','none');
% Set transparency of caps
alpha(alp(1))

hb=patch(isosurface(x,y,z,data2,isoval(2)),...
        'FaceColor','green',...
        'EdgeColor','none',...
        'AmbientStrength',0.2,...
        'SpecularStrength',0.7,...
        'DiffuseStrength',0.4);
%isonormals(x,y,z,data2,hb)
alpha(alp(2))
% Create the isocaps and set Properties
patch(isocaps(x,y,z,data2,isoval(2)),...
        'FaceColor','green',...
        'EdgeColor','none');
% Set transparency of caps
alpha(alp(2))

hc=patch(isosurface(x,y,z,data3,isoval(3)),...
        'FaceColor','blue',...
        'EdgeColor','none',...
        'AmbientStrength',0.2,...
        'SpecularStrength',0.7,...
        'DiffuseStrength',0.4);
%isonormals(x,y,z,data3,hc)
alpha(alp(3))
% Create the isocaps and set Properties
patch(isocaps(x,y,z,data3,isoval(3)),...
        'FaceColor','blue',...
        'EdgeColor','none');
% Set transparency of caps
alpha(alp(3))

set(gca,'position',[0,0,1,1]);
axis equal
axis tight
axis off

%colormap hsv
% Define the View
daspect([1,1,1])
%axis tight

%grid on
view(3)
% Add lighting
camlight right
camlight left
%set(gcf,'Renderer','zbuffer');
lighting phong

%%%% Prettify figure export
axis off
ti = get(gca, 'TightInset');
set(gca, 'Position', [ti(1) ti(2) 1-ti(3)-ti(1) 1-ti(4)-ti(2)]);
set(gca,'Units','Inches');
pos = get(gca, 'Position');
ti = get(gca, 'TightInset');
w = pos(3)+ti(1)+ti(3);
h = pos(4)+ti(2)+ti(4);
set(gcf, 'PaperUnits', 'Inches');
set(gcf, 'PaperSize', [w h]);
set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperPosition', [0 0 w h]);
%saveas(gcf, 'phiAB_mat.png');
print('phiAB','-dpng','-r300');
end

