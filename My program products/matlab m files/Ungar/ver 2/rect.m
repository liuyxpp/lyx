function err = rect(lc,e0,xedp)
%RECT 
% Calling sequence:
%    err=rect(lc,e0=10,xedp=-180:0.1:180)
%
% define variables:
%   err        -- error message
%   lc         -- initial Lc
%   e0         -- initial E0,optioanl,default=10
%   xedp       -- specify edp's x scale range,default=-180:0.1:180
%
% Record of revisions:
%     Date             Programmer          Description of change
%     ====             ==========          =====================
%   3/8/2006           Yi Xin Liu          Original code
global Lc_INI
global E0_INI
global X_EDP
global N
global L
global V
global Lc_FIT
global E0_FIT
global I_FIT
global RN
global I_EXP
global I_INI
if nargin<1
    err='You must at least enter a value for lc'
end
Lc_INI=lc;
E0_INI=10;
X_EDP=-180:0.1:180;
if nargin==2
    E0_INI=e0;
end
if nargin==3
    E0_INI=e0;
    X_EDP=xedp;
end
edprini;
edpe;
rectfit;
edprfit;
[err,hini,hfit]=plotedp;
