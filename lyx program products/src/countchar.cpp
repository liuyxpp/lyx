#include <iostream.h>
#include <stdio.h>

void main()
{
	int ch,sp,num,other;
	char c;
	ch=sp=num=other=0;
	while((c=getchar())!='\n')
	{
		if(c>='a'&&c<='z'||c>='A'&&c<='Z') {ch+=1;continue;}
		if(c==' ') {sp+=1;continue;}
		if(c>='0'&&c<='9') {num+=1;continue;}
		other+=1;
	}
	cout<<ch<<":"<<sp<<":"<<num<<":"<<other<<endl;
}
