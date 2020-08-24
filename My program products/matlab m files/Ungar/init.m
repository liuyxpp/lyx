% init.m
% Initializing all global vars for Ungar's Model.

global L; % Polymer chain length in angstrom.
global N; % Highest order diffraction of experiment.
global e0; % Electron density of crystalline.
global Ie; % Diffraction intensity of each order diff.. An array Ie(N).
global vi; % Phase of each order diff. An array vi(N), Ae(n)=sqrt(Ie(n))*cos(vi(n)),n=1~N.
global lc; % Crystalline length.
global x; % x axis in Electron Density Profile (EDP), i.e. the position.
% For Model I
global x02; % Initial guessed values of e0 and lc. x02=[e0, lc].
% For Model II
global ls; % Transient part length.
global x03; % Initial guessed values of e0, lc, and ls. x03=[e0, lc, ls].
L=150;
N=6;
e0=10;
Ie=zeros(1,N);
vi=zeros(1,N);
lc=130;
x=-180:0.1:180;
x02=[e0 lc];
ls=10;
x03=[e0 lc ls];
