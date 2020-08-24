function err = rectfit()
%RECTFIT Use Model I (rectangular) to fit the experimental data.
% Calling sequence:
%    err=rectfit
%
% define variables:
%   err        -- error message 
%
% Record of revisions:
%     Date             Programmer          Description of change
%     ====             ==========          =====================
%   3/8/2006           Yi Xin Liu          Original code
global E0_INI
global Lc_INI
global E0_FIT
global Lc_FIT
global I_EXP
global RN
x02=[E0_INI Lc_INI];
[x,RN]=lsqnonlin(@myfun,x02);
E0_FIT=x(1)
Lc_FIT=x(2)
RN=sqrt(RN/sum(I_EXP));
err=0;

function F=myfun(x)
global N
global L
global I_EXP
global V
F=zeros(1,N);
for k=1:N
    F(k)=2*x(1)*sin(k*pi*x(2)/L)/k/pi-sqrt(I_EXP(k))*cos(V(k));
end
