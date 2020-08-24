function fft2d()
% *******************************************************************
% (C) Copyright Yi-Xin Liu
%               Peking Univ., Beijing, China
% *******************************************************************
% Zhu XQ's 2D FFT of step density function
% ********************************************************************
% With Matlab FFT(x) assistance
% Constructing an input array which contains several period of the 
% 2D step density function Ex. Then perform a 2-dimensional DFT for Ex
% by using fft2(x).
% Plot the result intensity profile.
% ********************************************************************
% Calling sequence:
%    fft2d
% ********************************************************************
% Record of revisions:
%     Date             Programmer          Description of change
%     ====             ==========          =====================
%   9/2/2007           Yi Xin Liu          Original code
% *********************************************************************
%
%
% *****parameter set****************************************************
% ----- material parameters
L=256;  % long period, unit 0.1 angstrom, must be an even number 
m=126;  % mesogen, unit 0.1 angstrom
s=119;   % spacer, unit 0.1 angstrom
b=fix((L-m-s)/2); % backbone, main chain width, unit 0.1 angstrom
d=172;  % y direction period length, must be an even number
Em=4.0;  % the electron density of mesogen, unit arbitrary
Eb=1.0;  % the electron density of backbone, unit arbitrary
Es=3.3;   % the electron density of spacer, unit arbitrary
% ----- model parameters
nx=8; % the number of periods in x direction. For efficient case, 2^n is better.
ny=fix(L*nx/d); % the number of periods in y direction
%Nv=n*L2 % the vector length
xb=zeros(1,b)+Eb;
xm=zeros(1,m)+Em;
xs=zeros(1,s)+Es;
% *****parameter set************************************************
%
%
% *****Constructing density function********************************
Exu1=[xb xm xs xb]; % x direction unit for up part
Exd1=fliplr(Exu1);  % x direction unit for down part
Eyu1=repmat(Exu1,d/2,1);
Eyd1=repmat(Exd1,d/2,1);
Exy1=vertcat(Eyu1,Eyd1);
Exy_init=repmat(Exy1,ny,nx); % constructing density functin matrix
Q=min(d*ny,L*nx);
t=fix(log2(Q));
latticex=2^t;
latticey=latticex;
Exy=Exy_init(1:latticey,1:latticex);
[latticex latticey]
% *****Constructing density function********************************
% 
%
% *****Remove rectangular componet**********************************
average=sum(sum(Exy))/(latticex*latticey);
Exy=Exy-average;
% *****Remove rectangular componet**********************************
%
%
% *****DFT**********************************************************
f=fftn(Exy);
f2=fftshift(f);
% *****DFT**********************************************************
%
%
% *****Narrow to interested region**********************************
outsize=36;
fout=zeros(2*outsize);
xl=fix(latticex/2-outsize);
xr=fix(latticex/2+outsize);
yu=fix(latticey/2-outsize);
yd=fix(latticey/2+outsize);
[xl xr;yu yd]
fout=abs(f2(yu:yd,xl:xr));
% *****Narrow to interested region**********************************
%
%
% *****Spherical average(Liu YX)************************************
npoint=2*outsize*outsize+1;
rI=zeros(1,npoint);
numadd=zeros(1,npoint);
for i=2:2*outsize+1
    for j=2:2*outsize+1
        rr=(i-outsize-2)*(i-outsize-2)+(j-outsize-2)*(j-outsize-2)+1;
        rI(rr)=rI(rr)+fout(i,j);
        numadd(rr)=numadd(rr)+1;
    end 
end
raxis=zeros(1,npoint);
for i=1:npoint
    if numadd(i)>0
        rI(i)=rI(i)/real(numadd(i));
    else
        rI(i)=0.0;
    end
    raxis(i)=sqrt(i-1)/latticex;
end
% *****Spherical average(Liu YX)************************************
%
%
% *****Spherical average(Xu GQ)************************************
npoint=2500;
half=latticex/2;
rdata=0.0001;
rstep=1.0;
for ii=1:npoint
    sfactor(ii)=0.0;
    number(ii)=0;
end
for ii=1:latticex
    for jj=1:latticex
        aamc=(ii-half-1)*(ii-half-1)+(jj-half-1)*(jj-half-1);
        aamc=sqrt(real(aamc))/(latticex*rstep);
        nnnn=fix(aamc/rdata)+1;
        if nnnn<=npoint
            sfactor(nnnn)=sfactor(nnnn)+abs(f2(ii,jj));
            number(nnnn)=number(nnnn)+1;
        end
    end
end
for ii=1:npoint
    if number(ii)>0
        sfactor(ii)=sfactor(ii)/real(number(ii));
    else
        sfactor(ii)=0.0;
    end
end
% *****Spherical average(Xu GQ)*************************************
%
%
% *****Plot density function****************************************
figure('Name','Density function map');
imshow(Exy,[-6 6],'truesize');
% *****Plot density function****************************************
%
%
% *****Plot 2D Intensity***********************************************
%figure;
%[X,Y]=meshgrid(1-latticex/2:latticex/2,1-latticey/2:latticey/2);
%contour(X,Y,abs(f));
figure('Name','Diffraction patter');
[X Y]=meshgrid(-outsize/latticex:1/latticex:(outsize-2)/latticex,-outsize/latticey:1/latticey:(outsize-2)/latticey);
contour(X,Y,fout(2:2*outsize,2:2*outsize));
% *****Plot 2D Intensity***********************************************
%
%
% *****Plot 1D Intensity***********************************************
% --- Liu YX
figure('Name','Diffracion curve: mapping');
plot(raxis,rI);
% --- Xu GQ
figure('Name','Diffracton curve: step');
plot(rdata:rdata:rdata*npoint,sfactor);
% *****Plot 1D Intensity***********************************************
%
%
% *****output paramter set******************************************
fprintf('L=%d\nm=%d\ns=%d\nb=%d\nd=%d\n',L,m,s,b,d);
fprintf('Em=%d\nEb=%d\nEs=%d\n',Em,Eb,Es);
fprintf('lattice size: %d * %d',latticex,latticey)
% *****output paramter set******************************************
% end of program
