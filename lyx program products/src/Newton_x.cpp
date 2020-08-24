#include <iostream.h>
#include <stdio.h>
#include <math.h>

void main()
{
	double x,y=1.5,f,fd;
	do{
		x=y;
		f=2*x*x*x-4*x*x+3*x-6;
		fd=6*x*x-8*x+3;
		y=x-f/fd;
	}while(fabs(y-x)>=1e-6);
	cout<<y<<endl;
}
