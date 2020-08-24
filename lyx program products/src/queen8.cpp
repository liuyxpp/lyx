#include <iostream.h>
#include <stdio.h>
#include <math.h>
//gloabal var
int x[9];//store the position
static bool a[9],b[17],c[16];//a for row,b for tri-up,c for tri-down
static int cnt;//counter
//print the table header
void printhead()
{
	int k;
	cout<<"±àºÅ";
	for(k=1;k<9;k++)
		cout<<"  "<<k;
	cout<<endl<<endl;
}
//print 1 set of queen scheme
void print()
{
	int i;
	cnt+=1;
	printf("%2d  ",cnt);
	for(i=1;i<9;i++)
		cout<<"  "<<x[i];
	cout<<endl;
}
//find position available,use recursion
void tryqueen(int i)
{
	int j;
	int cs;//for c[]'s suffix
	for(j=1;j<9;j++)
	{
		cs=i-j;//(i-j) may below 0,so trans it to -cs+7,ie.-3->7+3=10
		if(cs<0) cs=-cs+7;
		if(!a[j]&&!b[i+j]&&!c[cs])
		{
			x[i]=j;
			a[j]=true;
			b[i+j]=true;
			c[cs]=true;
			if(i<8) tryqueen(i+1);
			else print();
			//release the position
			a[j]=false;
			b[i+j]=false;
			c[cs]=false;
		}
	}
}
void main()
{
	void printhead();
	void print();
	void tryqueen(int i);
	
	printhead();
	tryqueen(1);
}