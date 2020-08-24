#include <iostream.h>
#include <stdio.h>
#include <math.h>
//sorting method:selection advanced
//select a max number in the array,put it in the front
void main()
{
	static int a[11]={123,5,-8,9,43,4,7,7,9,-87,-32};//initialization
	int i,j;//counter
	int t;//temporary var
	int k;//store the max suffix
	for(i=1;i<10;i++)
	{
		k=i;
		for(j=i+1;j<11;j++)
			if(a[k]<a[j]) k=j;
		if (k!=i) {t=a[i];a[i]=a[k];a[k]=t;}//if rest has number max,change it
	}
	for(i=1;i<11;i++)
		cout<<a[i]<<" ";
	cout<<endl;
}

