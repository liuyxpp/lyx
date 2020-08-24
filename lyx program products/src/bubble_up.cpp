#include <iostream.h>
#include <stdio.h>
#include <math.h>
//bubble up method for integers
void main()
{
	int a[11];//10 numbers,leaving a[0] without using
	int i,j;//counter
	int t;//temporary var
	for(i=1;i<11;i++)
		cin>>a[i];
	cout<<endl;
	for(i=1;i<10;i++)//only compared numbers(10)-1 times
		for(j=1;j<=10-i;j++)//compare for numbers(10)-i
			if(a[j]>a[j+1]) {t=a[j];a[j]=a[j+1];a[j+1]=t;}
	cout<<"the sorted numbers:"<<endl;
	for(i=1;i<11;i++)
		cout<<a[i]<<" ";
}
