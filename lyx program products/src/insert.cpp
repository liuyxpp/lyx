#include <iostream.h>
#include <stdio.h>
#include <math.h>
//insertion
void main()
{
	static int m[11]={-22,-19,-12,0,4,6,7,9,13,19};//array initialization
	static int s=-6;//to be inserted
	int i,j;//counter
	int t;//temporary var
	for(i=0;i<10;i++)
		if(m[i]>s)//up order 
		{
			for(j=9;j>=i;j--) m[j+1]=m[j];
			m[i]=s;
			break;//if inserted,break from here
		}
	for(i=0;i<11;i++)
		cout<<m[i]<<" ";//print the result
	cout<<endl;
}

