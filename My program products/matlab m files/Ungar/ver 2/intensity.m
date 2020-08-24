function [ii,err] = intensity()
%EDPINI Construct intensity profile from all Lc 
% Calling sequence:
%    [ii,err]=intensity
%
% define variables:
%   ii         -- array of intensity ii(L/5,N)
%   err        -- error message 
%
% Record of revisions:
%     Date             Programmer          Description of change
%     ====             ==========          =====================
%   3/16/2006           Yi Xin Liu          Original code
global N
global L
global E0_INI
N
L
E0_INI=10;
ii=zeros(L/5,N);
Am=zeros(1,N);
for lc=5:5:L
    for k=1:N
       Am(k)=2*E0_INI*sin(k*pi*lc/L)/k/pi;
    end
    ii(lc/5,:)=Am.*Am;
end