function []=plot31(data3d)
L=max(size(data3d));
data1dx=zeros(L,1);
data1dy=zeros(L,1);
data1dz=zeros(L,1);
for i=1:L
    data1dx(i)=data3d(i,L/2,L/2);
    data1dy(i)=data3d(L/2,i,L/2);
    data1dz(i)=data3d(L/2,L/2,i);
end
figure
plot(0:L-1,data1dx);
figure
plot(0:L-1,data1dy);
figure
plot(0:L-1,data1dz);
end 
