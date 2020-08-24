#include <iostream.h>
#include <stdio.h>

void main()
{
	int m=15,n=35;
	int t,i;
	if(m>n) {t=m;m=n;n=t;}
	for(i=m;i>=1;i--)
		if(n%i==0&&m%i==0) break;
	if(i<1) cout<<1;
	else cout<<i;
	cout<<endl;
	for(i=n;i<=n*m;i++)
		if(i%m==0&&i%n==0) break;
	if(i>n*m) cout<<n*m;
	else cout<<i;
	cout<<endl;
}
