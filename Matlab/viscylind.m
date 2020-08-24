function [  ] = viscylind(x,y,z,phi_a,phi_b,isoval,aa,repeatz)
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
        repeatz = 2;
    case 6
        aa = [0.6,0.6];
        repeatz = 2;
    case 7
        repeatz = 2;
end

figure;
% Smooth data before visualization
%phi_a=smooth3(phi_a,'box',5);
%phi_b=smooth3(phi_b,'box',5);

% Repeat data in each dimension
%phi_a = repmat(phi_a,[1,1,repeatz]);
%phi_b = repmat(phi_b,[1,1,repeatz]);
% To implement above repetition, x, y, z should also be repeated,
% which is not realized yet.

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
axis tight
%grid on
view(3)
% Add lighting
camlight right
camlight left
%set(gcf,'Renderer','zbuffer');
lighting phong
end
