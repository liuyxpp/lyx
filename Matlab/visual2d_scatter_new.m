function [xx,yy,data] = visual2d_scatter_new(x,y,s)
%VISUAL2D_SCATTER Plot 2D array with scattered position
%   x,y - the 2D array for coordinates x and y
%   s   - the data, 2D array

[Lx,Ly]=size(x);
xx = zeros(Lx,Ly);
yy = zeros(Lx,Ly);
data = zeros(Lx,Ly);
for i=1:Lx
    for j=1:Ly
        xx(i,j)=x(i,j);
        yy(i,j)=y(i,j);
        data(i,j)=s(i,j);
    end
end

dx = max(max(xx))-min(min(xx));
dy = max(max(yy))-min(min(yy));
[C, hc] = contourf(xx,yy,data,256,'LineColor','none');
%set(gca,'DataAspectRatio',[dx,dy,1])
w = 8.0;
h = 8.0 * dy / dx;
set(gcf,'PaperUnits','centimeters');
set(gcf,'PaperPosition',[0,0,w,h]);
set(gcf,'Position',[800,400,w*60,h*60]);
set(gca,'position',[0,0,1,1]);
map = zeros(256,3);
for i=1:256
    map(i,1) = (i-1.0)/255.0;
end
colormap(map)

end

