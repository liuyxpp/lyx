function err=ungar(n,l,i)
%UNGAR Initialize the basic working environment for Ungar SAXS Model.
% Calling sequence:
%    err=ungar(n,l,i)
%
% Define variables:
%   n       -- N peaks
%   l       -- long period length
%   i       -- a row vector contains corresponding intensity of each peaks
%
% Record of revisions:
%     Date             Programmer          Description of change
%     ====             ==========          =====================
%   3/6/2006           Yi Xin Liu          Original code

global N;
global L;
global I_EXP;
if size(nargchk(3,3,nargin))~=0
    err='Too more or too less input argments';      
    return;
end
[p q]=size(i);
if p==1 & q==n 
    N=n;
    L=l;
    I_EXP=i;
    err=0;          
elseif p~=1
    err='Need a row vector';        
else 
    err='Size not match';        
end