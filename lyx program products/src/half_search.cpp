#include <iostream.h>
#include <stdio.h>
#include<string.h>
//half searching
void main()
{
	static int a[17]={0,-9,-1,2,3,4,5,6,7,8,9,10,11,12,23,24,145};
	int f=4;
	int l=1,u=17,i;
	i=(l+u)/2;
	while(a[i]!=f)
	{
		if(a[i]<f) l=i;
		else u=i;
		i=(l+u)/2;
	}
	cout<<i<<endl;
}
