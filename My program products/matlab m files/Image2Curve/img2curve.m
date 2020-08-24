function [ xy ] = img2curve( g,w)
% INPUT: binary image raw matrix
% OUTPUT: array with x and y values stored
%     xy(:,1) -> x
%     xy(:,2) -> y
%     figure of xy
% IN VAR: 
%     g - image raw matrix
%     w - line width of figure xy
% OUT VAR:
%     xy - array with x and y values

[m,n]=size(g);
xy=zeros(n,2);
for i=1:1:n
    for j=1:1:m
        if g(j,i)==0 
            xy(i,1)=i;
            xy(i,2)=m-j;
            break;
        end
    end
end
plot(xy(:,1),xy(:,2),'k','linewidth',w);
axis([0,n,0,m]);