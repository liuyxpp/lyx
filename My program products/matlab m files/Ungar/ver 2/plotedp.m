function [err, hini, hfit] = plotedp(pexp,pini,pfit)
%PLOTEDP Plot three EDP profiles, experimental,initial and non-linear
% Calling sequence:
%    [err,hini,hfit]=plotedp(pexp,pini,p)
%
% Define variables:
%   pexp     -- ploting parameters of exp EDP
%   pini     -- ploting parameters of initial guesing model EDP
%   pfit     -- ploting parameters of fitted model EDP
%   err      -- error message if any
%   hini     -- figure handle for initial EDP
%   hfit     -- figure handle for fitted EDP
%
% Record of revisions:
%     Date             Programmer          Description of change
%     ====             ==========          =====================
%   3/7/2006           Yi Xin Liu          Original code
global X_EDP
global Y_EXP
global Y_INI
global Y_FIT
if nargin<3
    pexp='k';
    pini='r';
    pfit='b';
end
subplot(1,2,1);
hini=plot(X_EDP,Y_EXP,pexp,X_EDP,Y_INI,pini);
subplot(1,2,2);
hfit=plot(X_EDP,Y_EXP,pexp,X_EDP,Y_FIT,pfit);
err=0;
