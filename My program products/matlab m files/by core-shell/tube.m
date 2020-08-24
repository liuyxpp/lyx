function [ I ] = tube( input_args )
%TUBE Summary of this function goes here
%  Detailed explanation goes here
r1=0.1;
r2=6.5;
r3=28.5;
r4=35;
p1=0;
p2=0.01;
p3=-0.05;
q=0.02:0.005:0.2;
I=p1*r1*2*besselj(1,q*r1)./q+p2*r2*2*besselj(1,q*r2)./q-p2*r1*2*besselj(1,q*r1)./q+p3*r3*2*besselj(1,q*r3)./q-p3*r2*2*besselj(1,q*r2)./q+p2*r4*2*besselj(1,q*r4)./q-p2*r3*2*besselj(1,q*r3)./q;
I=I.*I./q;
plot(q,I);