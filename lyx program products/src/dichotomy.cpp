#include <iostream.h>
#include <stdio.h>
#include <math.h>

void main()
{
	double x1,x2,x,fx1,fx2,fx;
	x1=-10;
	x2=10;
	do{
		x=(x1+x2)/2;
		fx1=2*x1*x1*x1-4*x1*x1+3*x1-6;
		fx2=2*x2*x2*x2-4*x2*x2+3*x2-6;
		fx=2*x*x*x-4*x*x+3*x-6;
		if(fx1*fx<0) x2=x;
		else x1=x;
	}while(fabs(x2-x1)>=1e-6);
	cout<<x2<<endl;
}
