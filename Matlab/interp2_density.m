function [xq,yq,Vq] = interp2_density(x, y, V, Nxq, Nyq)
%   
%   %usage:
%       [xp,yp,phip] = density_interp(x,y,V,Nxp,Nyp);
%
%       input var
%           x,y: coordinates (ndgrid form) or vectors or the length in
%           that dimension.
%           V: 2D density input, with periodic boundary for each dimension
%           Nxq, Nyq: number of grid points to be interpolated.
%
%       output var
%           Vq: Interpolated density
%
% History:
%   2015.12.06: Created.
%
% Copyright(c) 2015, Yi-Xin Liu
%%

[Nx, Ny] = size(V);
if isscalar(x)
    xmax = x;  
else
    xmax = max(x(:)) * Nx / (Nx - 1);
end
if isscalar(y)
    ymax = y;
else
    ymax = max(y(:)) * Ny / (Ny - 1);
end

% Extend data utilizing Periodic boundary
% The original data is in the range of 0:xmax/Nx:xmax-xmax/Nx in x
% dimension, and y dimension are the same.
% Below we extend it to 0:xmax/Nx:xmax, and the end point data are copied
% from the first data.
vx = 0:xmax/Nx:xmax;
vy = 0:ymax/Ny:ymax;
[xf,yf] = ndgrid(vx,vy);
Vf = zeros(Nx+1, Ny+1);
Vf(1:Nx,1:Ny) = V;
Vf(Nx+1,1:Ny) = V(1,1:Ny);
Vf(1:Nx,Ny+1) = V(1:Nx,1);

% Construct interpolation coordinates
% xmax-xmax/Nxq may > xmax-xmax/Nx when Nxq > Nx.
% Therefore V must be extended to [0, xmax] instead of its original range
% [0, xmax-xmax/Nx].
vx = 0:xmax/Nxq:xmax-xmax/Nxq;
vy = 0:ymax/Nyq:ymax-ymax/Nyq;
[xq,yq] = ndgrid(vx,vy);
Vq = interpn(xf,yf,Vf,xq,yq);
end

function [] = gen_init_field_AB(x, y, Nxq, Nyq)
[xp,yp,wA] = interp2_density(wA,Nxq,Nyq);
[xp,yp,wB] = interp2_density(wB,Nxq,Nyq);
[xp,yp,yita] = interp2_density(x,y,yita,Nxq,Nyq);
[xp,yp,phiA] = interp2_density(x,y,phiA,Nxq,Nyq);
[xp,yp,phiB] = interp2_density(x,y,phiB,Nxq,Nyq);
x=xp;y=yp;
end
