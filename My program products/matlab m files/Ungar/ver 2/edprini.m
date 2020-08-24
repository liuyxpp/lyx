function err = edprini()
%EDPINI Reconstruct EDP from initial Lc and E0 
% Calling sequence:
%    err=edprini
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
global E0_INI
global V
global Lc_INI
global X_EDP
global I_INI
global Y_INI
V=zeros(1,N);
Am=zeros(1,N);
for k=1:N
    Am(k)=2*E0_INI*sin(k*pi*Lc_INI/L)/k/pi;
    if Am(k)<0
        V(k)=pi;
    else
        V(k)=0;
    end
end
I_INI=Am.*Am;
[p,q]=size(X_EDP);
Y_INI=zeros(p,q);
for k=1:N
    Y_INI=Y_INI+Am(k)*cos(2*pi*k*X_EDP/L);
end
err=0;