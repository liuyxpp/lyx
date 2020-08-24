#include <iostream.h>
#include <stdio.h>
#define MAX_IN 10
void main()
{
	int in,i,j,out,div=1,n=1;
	int o[MAX_IN];
	scanf("%10d",&in);
	for(i=MAX_IN-1;i>=1;i--)
	{
		for(j=1;j<=i;j++)
			div=div*10;
		out=in/div;
		if (out) 
		{
			n+=1;
			o[i]=out;
			cout<<out;
			in=in-out*div;
		}
		div=1;
	}
	cout<<in;
	o[i]=in;
	cout<<endl;
	for(i=0;i<n;i++)
		cout<<o[i];
	cout<<endl;
	cout<<"Î»Êý:"<<n<<endl;
}
