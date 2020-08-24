% rectfit.m
% Fitting the exp. diff. data with Ungar's Model I (rectangle).
% INPUT var
% N    ------ highest order
% L    ------ long period obtained from first order peak position of exp. data
% x02  ------ initial guessed value of e0 and lc.
% vi   ------ a vector, containing phase angle of each order diff.
% END INPUT var
% % % % % % % % % % % % % %
% OUT var
% x           ------ x(1): optimized e0; 
%                    x(2): optimized lc.
% resnorm     ------ square residual
% Im    ------ square of Am_fit, i.e. intensity of n order diff.
% END OUT var

function rectfit()
global N;
global L;
global Ie;
global x02;
global e0;
global lc;
x02=[e0 lc];
[x,resnorm]=lsqnonlin(@myfun,x02);
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

function F=myfun(x)
global N;
global L;
global Ie;
global vi;
F=zeros(1,N);
for n=1:N
    F(n)=2*x(1)*sin(n*pi*x(2)/L)/n/pi-sqrt(Ie(n))*cos(vi(n));
end