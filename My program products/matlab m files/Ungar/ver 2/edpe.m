function err = edpe()
%EDPE Construct the Electrical Density Profile(EDP) from exp. diff. data.
% Calling sequence:
%    err=edpe
%
% OUT variables:
%   X_EDP       -- x values of EDP
%   Y_EXP       -- y values of EDP
%
% Record of revisions:
%     Date             Programmer          Description of change
%     ====             ==========          =====================
%   3/7/2006           Yi Xin Liu          Original code
global X_EDP
global Y_EXP
global N
global L
global V
global I_EXP
[p,q]=size(X_EDP);
Y_EXP=zeros(p,q);
for k=1:N
    Y_EXP=Y_EXP+sqrt(I_EXP(k))*cos(2*pi*k*X_EDP/L+V(k));
end
err=0;