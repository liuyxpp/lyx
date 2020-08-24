L=max(size(phiA));
phi_a=zeros(L,1);
phi_b=zeros(L,1);
phi=zeros(L,1);
phie=zeros(L,1);
phi_p=zeros(L,1);
phi_n=zeros(L,1);
for i=1:L
    phi_a(i)=phiA(1,1,i);
    phi_b(i)=phiB(1,1,i);
    phi(i)=phiB(1,1,i)-phiA(1,1,i);
    phi_p(i)=phiP(1,1,i);
    phi_n(i)=phiN(1,1,i);
    phie(i)=-phi_n(i)+phi_p(i)-alphaA*phi_a(i)+alphaB*phi_b(i);
end
figure
plot(1:L,phi_a,'r')
hold on
plot(1:L,phi_b,'g');
figure
plot(1:L,phi);
figure
plot(1:L,phi_p,'k');
hold on
plot(1:L,-alphaA*phi_a,'r');
plot(1:L,phi_p-alphaA*phi_a,'b');

