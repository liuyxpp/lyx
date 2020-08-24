#include <iostream.h>
#include <stdio.h>
//find saddle point in a array[][]
//define: max in row and min in column
 
void main()
{
	static int a[][3]={{4,4,4},{4,2,4},{8,0,4},{4,4,4}};
	int i,j,k,l,max,min;
	for(i=0;i<4;i++)
	{
		max=a[i][0];
		for(k=1;k<3;k++)
			if(a[i][k]>max) max=a[i][k];
		for(j=0;j<3;j++)
		{
			min=a[0][j];
			for(k=1;k<4;k++)
				if(a[k][j]<min) min=a[k][j];
			if(max==min) printf("a(%d,%d)=%d\n",i,j,max);
		}
	}
}
