#include <iostream.h>

//decipher
//a->z,b->y,c->x...
//A->Z,B-Y,C->X...
//others leaving not changed 
void main()
{
	static char ch[]="Svool,obc!";//ciper
	char deci[80];//deciper
	int i=0;
	while(ch[i]!='\0')
	{
		if(ch[i]>='a'&&ch[i]<='z') deci[i]='a'+'z'-ch[i];
		else if (ch[i]>='A'&&ch[i]<='Z')  deci[i]='A'+'Z'-ch[i];
		else deci[i]=ch[i];
		i++;
	}
	deci[i]='\0';
	cout<<ch<<endl;
	cout<<deci<<endl;
}
