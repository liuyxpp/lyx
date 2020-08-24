#include <iostream.h>
#include <stdio.h>
#include<string.h>
//count lowercase,uppercase,number,space and other signal in the line 
void main()
{
	static char s[3][80]={{"Good morning!"},{"Good afternoon!"},{"Good night!"}};
	static int lc[3],uc[3],n[3],sp[3],other[3];
	char ch;
	int i,j;
	for(i=0;i<3;i++)
	{
		j=0;
		while((ch=s[i][j])!='\0')
		{
			if(ch>='a'&&ch<='z') lc[i]+=1;
			else if(ch>='A'&&ch<='Z') uc[i]+=1;
			else if(ch>='0'&&ch<='9') n[i]+=1;
			else if(ch==' ') sp[i]+=1;
			else other[i]+=1;
			j++;
		}
		printf("%d,%d,%d,%d,%d\n",lc[i],uc[i],n[i],sp[i],other[i]);
	}
}
