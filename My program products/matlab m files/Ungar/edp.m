% edp.m
% Constructing the Electrical Density Profile(EDP) from exp. diff. data.
% INPUT var
% N    ------ highest order
% L    ------ long period obtained from first order peak position of exp. data
% vi   ------ a vector, containing phase angle of each order diff.
% x    ------ the distance between current postion to zero position.
% END INPUT var
% % % % % % % % % % % % % %
% OUT var
% ye   ------ the density at position x.
% END OUT var

ye=0;
for k=1:N
    ye=ye+sqrt(Ie(k))*cos(2*pi*k*x/L+vi(k));
end
Ie