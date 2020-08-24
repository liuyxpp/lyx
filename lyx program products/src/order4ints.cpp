#include <iostream.h>
#include <stdio.h>
#define MAX_IN 10
void main()
{
	int a,b,c,d;
	int t;
	scanf("%d %d %d %d",&a,&b,&c,&d);
	if(a<b) {t=a;a=b;b=t;}
	if(a<c) {t=a;a=c;c=t;}
	if(b<c) {t=b;b=c;c=t;}
	if(d>=a) 
	{cout<<d<<a<<b<<c<<endl;}
	else if(d>=b)
	{cout<<a<<d<<b<<c<<endl;}
	else if(d>=c)
	{cout<<a<<b<<d<<c<<endl;}
	else 
	{cout<<a<<b<<c<<d<<endl;}
}
