function [ output_args ] = rod( input_args )
%ROD Summary of this function goes here
%  Detailed explanation goes here
r1=22;
r2=28.5;
p1=-0.05;
p2=0.01;
q=0.02:0.005:0.2;
I=p1*r1*pi*2*besselj(1,q*r1)./q+(p2-p1)*r2*pi*2*besselj(1,q*r2)./q;
%I=I.*I./q;
plot(q,I);