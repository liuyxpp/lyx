function err = edprfit()
%EDPFIT Summary of this function goes here
% Calling sequence:
%    err=edprfit
%
% define variables:
%   err        -- error message 
%
% Record of revisions:
%     Date             Programmer          Description of change
%     ====             ==========          =====================
%   3/8/2006           Yi Xin Liu          Original code
global N
global L
global E0_FIT
global V
global Lc_FIT
global X_EDP
global I_FIT
global Y_FIT
V=zeros(1,N);
Am=zeros(1,N);
for k=1:N
    Am(k)=2*E0_FIT*sin(k*pi*Lc_FIT/L)/k/pi;
    if Am(k)<0
        V(k)=pi;
    else
        V(k)=0;
    end
end
I_FIT=Am.*Am
[p,q]=size(X_EDP);
Y_FIT=zeros(p,q);
for k=1:N
    Y_FIT=Y_FIT+Am(k)*cos(2*pi*k*X_EDP/L);
end
err=0;