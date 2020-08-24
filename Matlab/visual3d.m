function [  ] = visual3d(data3d,isoval,alp)
% Visualizing concentration distributions in three-dimensional (3D) space
% in cubic cell.
%   since 2010.4.14
%   coded by Yixin Liu @ Fudan
%   contact: liuyxpp@gmail.com
%   %usage:
%       visual3d()
%       input var
%           data3d: 3D concentration
%       output var
%           none
%       output
%           3D visualization figure
%   %example:
% $ Revision: 2010.4.22 $

% new figure
figure;
% Smooth data before visualization
%data3d=smooth3(data3d,'box',5);
% Create the isosurface and set properties
h=patch(isosurface(data3d,isoval),...
        'FaceColor','green',...
        'EdgeColor','none',...
        'AmbientStrength',0.2,...
        'SpecularStrength',0.7,...
        'DiffuseStrength',0.4);
isonormals(data3d,h)
alpha(alp)
% Create the isocaps and set Properties
patch(isocaps(data3d,isoval),...
        'FaceColor','green',...
        'EdgeColor','none');
% Set transparency of caps
alpha(alp)

%colormap hsv
% Define the View
daspect([1,1,1])
axis tight
%grid on
view(3)
% Add lighting
camlight right
camlight left
%set(gcf,'Renderer','zbuffer');
lighting phong
end

