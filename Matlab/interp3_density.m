function [xq,yq,zq,Vq] = interp3_density(x, y, z, V, Nxq, Nyq, Nzq)
%   
%   %usage:
%       [xp,yp,zp,phip] = density_interp(x,y,z,V,Nxp,Nyp,Nzp);
%
%       input var
%           x,y,z: coordinates (ndgrid form) or vectors or the length in
%           that dimension.
%           V: 3D density input, with periodic boundary for each dimension
%           Nxq, Nyq, Nzq: number of grid points to be interpolated.
%
%       output var
%           Vq: Interpolated density
%
% History:
%   2014.09.24: Created.
%
% Copyright(c) 2014, Yi-Xin Liu
%%

[Nx, Ny, Nz] = size(V);
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
if isscalar(z)
    zmax = z;
else
    zmax = max(z(:)) * Nz / (Nz - 1);
end

% Extend data utilizing Periodic boundary
% The original data is in the range of 0:xmax/Nx:xmax-xmax/Nx in x
% dimension, y and z dimensions are the same.
% Below we extend it to 0:xmax/Nx:xmax, and the end point data are copied
% from the first data.
vx = 0:xmax/Nx:xmax;
vy = 0:ymax/Ny:ymax;
vz = 0:zmax/Nz:zmax;
[xf,yf,zf] = ndgrid(vx,vy,vz);
Vf = zeros(Nx+1, Ny+1, Nz+1);
Vf(1:Nx,1:Ny,1:Nz) = V;
Vf(Nx+1,1:Ny,1:Nz) = V(1,1:Ny,1:Nz);
Vf(1:Nx,Ny+1,1:Nz) = V(1:Nx,1,1:Nz);
Vf(1:Nx,1:Ny,Nz+1) = V(1:Nx,1:Ny,1);

% Construct interpolation coordinates
% xmax-xmax/Nxq may > xmax-xmax/Nx when Nxq > Nx.
% Therefore V must be extended to [0, xmax] instead of its original range
% [0, xmax-xmax/Nx].
vx = 0:xmax/Nxq:xmax-xmax/Nxq;
vy = 0:ymax/Nyq:ymax-ymax/Nyq;
vz = 0:zmax/Nzq:zmax-zmax/Nzq;
[xq,yq,zq] = ndgrid(vx,vy,vz);
Vq = interpn(xf,yf,zf,Vf,xq,yq,zq);
end

function [x,y,z,wA,wB,yita,phiA,phiB] = gen_init_field_AB(x, y, z, wA, wB, yita, phiA, phiB)
[xp,yp,zp,wA] = interp3_density(x,y,z,wA,20,20,20);
[xp,yp,zp,wB] = interp3_density(x,y,z,wB,20,20,20);
[xp,yp,zp,yita] = interp3_density(x,y,z,yita,20,20,20);
[xp,yp,zp,phiA] = interp3_density(x,y,z,phiA,20,20,20);
[xp,yp,zp,phiB] = interp3_density(x,y,z,phiB,20,20,20);
x=xp;y=yp;z=zp;
end
