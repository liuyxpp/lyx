% edpr.m
% Reconstructing the Electrical Density Profile(EDP) from guessed E0 and
% Am of Ungar's Model I (rectangle).
% INPUT var
% N    ------ highest order
% L    ------ long period obtained from first order peak position of exp. data
% lc   ------ crystalline length, a guessed value
% e0   ------ absolute denstity, a guessed value
% x    ------ the distance between current postion to zero position.
% END INPUT var
% % % % % % % % % % % % % %
% OUT var
% ym   ------ the density at position x.
% Am   ------ guessed altitude.
% Im   ------ square of guessed altitude.
% END OUT var

vi=zeros(1,N);
Am=zeros(1,N);
for n=1:N
    Am(n)=2*e0*sin(n*pi*lc/L)/n/pi;
    if Am(n)<0
        vi(n)=pi;
    else
        vi(n)=0;
    end
end
Im=Am.*Am
ym=0;
for k=1:N
    ym=ym+Am(k)*cos(2*pi*k*x/L);
end