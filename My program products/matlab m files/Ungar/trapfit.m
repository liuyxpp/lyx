% trapfit.m
% Fitting the exp. diff. data with Ungar's Model II (tarpezoidal).
% INPUT var
% N    ------ highest order
% L    ------ long period obtained from first order peak position of exp. data
% x03  ------ initial guessed value of e0, lc, and ls.
% vi   ------ a vector, containing phase angle of each order diff.
% END INPUT var
% % % % % % % % % % % % % %
% OUT var
% x           ------ x(1): optimized e0 
%                    x(2): optimized lc.
%                    x(3): optimized ls.
% resnorm     ------ square residual
% Im    ------ square of Am_fit, i.e. intensity of n order diff.
% END OUT var

function trapfit()
global N;
global L;
global Ie;
global x03;
global e0;
global lc;
global ls;
x03=[e0 lc ls];
[x,resnorm]=lsqnonlin(@myfun,x03);
Am_fit=zeros(1,N);
sum=0;
for k=1:N
    Am_fit(k)=2*x(1)*sin(k*pi*x(2)/L)/k/pi;
    sum=sum+Ie(k);
end
Ie
Im=Am_fit.*Am_fit
resnorm=sqrt(resnorm/sum)
e0=x(1)
lc=x(2)
ls=x(3)

function F=myfun(x)
global N;
global L;
global Ie;
global vi;
F=zeros(1,N);
for n=1:N
    F(n)=2*x(1)*L*sin(n*pi*x(2)/L)*sin(n*pi*x(3)/L)/n/pi/n/pi/x(3)-sqrt(Ie(n))*cos(vi(n));
end