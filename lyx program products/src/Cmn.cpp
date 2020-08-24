#include <iostream.h>
#include <stdio.h>
#include <math.h>
//print Yan's triangle
//[Cmn]=[Cm(n-1)]*(m-n+1)/n
void main()
{
	int m,n,c;
	for(m=0;m<=10;m++)
	{
		c=1;
		cout<<c;
		for(n=1;n<=m;n++) {c=c*(m-n+1)/n;cout<<"  "<<c;}
		cout<<endl;
	}
}