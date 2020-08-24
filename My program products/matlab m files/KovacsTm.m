function KovacsTm(n,p)
% plot Tm(n,p) when vector n and p are not same in dimension
% Tm - melting temperature
% n  - number of folds per chain
% p  - degree of polymerization

a0=1570*4.18;
b0=0;
a=2150*4.18;
b=1380*4.18;
alpha=0.0129;
t0=61.2+273.15;
t8=68.9+273.15;
R=8.314;
H=2070*4.18;
rl=zeros(n,p);
tm=zeros(n,p);
for i=1:n
    sigma=a+(i-1)*b;
    if i==1 
        sigma=a0;
    end 
    for j=1:p
        rl(i,j)=i/((j+6)*0.2783);
        tm(i,j)=t8*(1-sigma*(1+alpha*t0)/(j+6)/H)/(1+log(j+6)*R*t8/(j+6)/H-t8*sigma*alpha/(j+6)/H)-273.15;
    end
end
hold on;
for i=1:n
    plot(rl(i,:),tm(i,:));
end
grid on;
%hold off;
% This is the end of this file