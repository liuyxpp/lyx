#include <iostream.h>
#define ROW 8
void main()
{
	int i,j,k;
	char sp[]="   ";
	char star[]="*  ";
	cout<<endl;
	cout<<endl;
	for(i=1;i<=ROW;i++)
	{
		cout<<sp<<sp;
		for(j=ROW-i;j>0;j--)
			cout<<sp;
		for(k=1;k<=2*i-1;k++)
			cout<<star;
		cout<<endl;
	}
	for(i=1;i<=ROW-1;i++)
	{
		cout<<sp<<sp;
		for(j=1;j<=i;j++)
			cout<<sp;
		for(k=1;k<=2*(ROW-i)-1;k++)
			cout<<star;
		cout<<endl;
	}
}

