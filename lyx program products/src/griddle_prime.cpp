#include <iostream.h>
#include <stdio.h>
#include <math.h>
//筛法求2-100范围内的素数

//function:find the minimum number in the array;
int min(int a[],int m)
{
	int i;
	for(i=m;i<101;i++)
		if(a[i]!=0) return a[i];//actually it is been sorted at the very beginning
	return 0;
}	
void main()
{
	int min(int a[],int m);
	int mini;//stored the value of min() returned 
	int a[101];//numbers
	int i;//counter
	for(i=2;i<101;i++) a[i]=i;
	mini=2;
	while((mini=min(a,mini))!=0)//when all elements in array are 0,stop
	{
		cout<<mini<<endl;
		for(i=mini;i<=101;i++)
			if(i%mini==0) a[i]=0;//set the multiple number to 0
	}
}

