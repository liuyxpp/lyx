function [xx,yy,data] = visual2d_scatter(x,y,s,color,repeat)
%VISUAL2D_SCATTER Plot 2D array with scattered position
%   x,y - the 2D array for coordinates x and y
%   s   - the data, 2D array

switch nargin
    case 3
        color = 1;
        repeat = [2,2];
    case 4
        repeat = [2,2];
end

% repetition
data = repmat(s,repeat);

[Lx,Ly] = size(x);
xa = x(1,1);
dx1 = x(2,1) - xa;
dx2 = x(1,2) - xa;

yc = y(1,1);
dy1 = y(2,1) - yc;
dy2 = y(1,2) - yc;

repx = repeat(1);
repy = repeat(2);

xx = zeros(Lx*repx,Ly*repy);
yy = zeros(Lx*repx,Ly*repy);
for i=1:Lx*repx
    for j=1:Ly*repy
        xx(i,j) = (i-1)*dx1 + (j-1)*dx2;
        yy(i,j) = (i-1)*dy1 + (j-1)*dy2;
    end
end

dx = max(xx(:))-min(xx(:));
dy = max(yy(:))-min(yy(:));
contourf(xx,yy,data,256,'LineColor','none')
w = 8.0;
h = 8.0 * dy / dx;
set(gcf,'PaperUnits','centimeters');
set(gcf,'PaperPosition',[0,0,w,h]);
set(gcf,'Position',[800,400,w*60,h*60]);
set(gca,'position',[0,0,1,1]);
axis off

map = zeros(256,3);
for i=1:256
    map(i,color) = (i-1.0)/255.0;
end
colormap(map)

%%%% Trial for the possibility to plot more than 2 components in a single
%%%% figure by utilizing visual3d_scatter()
%zz = zeros(Lx*repx,Ly*repy,2);
%zz(:,:,2) = 1; 
%phi0 = zeros(Lx*repx,Ly*repy,2);
%visual3d_scatter(cat(3,xx,xx),cat(3,yy,yy),zz,cat(3,data,data),phi0,phi0);

end

