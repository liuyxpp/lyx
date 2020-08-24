#include <stdio.h>
#include <math.h>
#include "resource.h"
#include <windows.h>
#define eps 1e-6      // 定义解的精度
#define kw 1.0e-14      //水的Ｋｗ值 
//设定全局变量
double c[100],k[8][100];
int npart,nhyd[100],ne[100];
//函数：求delta值 
double disk(double ph,int j)
{
	double *pItem=new double[nhyd[j]+1];
	double Ka_m=1.0;
	double sum=0;
	double result=0;
	int m;
	for(m=0;m<=nhyd[j];m++)
	{
		Ka_m*=k[m][j];
		pItem[m]=pow(ph,(double)(nhyd[j]-m))*Ka_m;
		sum+=pItem[m];
	}
	for(m=0;m<=nhyd[j];m++)
		result+=pItem[m]*(double)(ne[j]-m);
	delete[] pItem;
	return result*c[j]/sum;
}
//函数：求部分含[H+]的方程的值
double partFH(double ph)
{
	double result=0;
	int j;
	for(j=1;j<=npart;j++)
		result+=disk(ph,j);
	return result;
}
//函数：在函数partFH()的基础上求方程左边值
double fHy(double ph)
{
	double fh;
	fh=ph-kw/ph+partFH(ph);
	return(fh);
}
//函数：用割线法求得pH的值
double pH(double ph1,double ph2)
{
	int i=0;
	double ph,fh,fh1,fh2;
	fh1=fHy(ph1);
	fh2=fHy(ph2);
	do 
	{	
		ph=ph2-(ph2-ph1)/(fh2-fh1)*fh2;
		fh=fHy(ph);
		if(fh*fh1<0)
		{
			fh2=fh;
			ph2=ph;
		}
		else
		{
			ph1=ph;
			fh1=fh;
		}
	}while((fabs(fh1)>=eps)||(fabs(ph1-ph)>=eps));
	ph=-log10(ph);
	return(ph);
}
//函数：输入初始条件
void prompt(void)
{
	int i,j;
	double phz,ph1=1.0,ph2=1e-14;
	printf("\n 该溶液中含有几种酸: ");
	scanf("%d",&npart);
	printf("\n       ******强酸：Ka=1e15;强碱：Ka=0 ******");
	for(j=1;j<=npart;j++)
	{
		printf("\n 酸%d的浓度是：",j);
		scanf("%le",&c[j]);
		printf("\n 酸%d是几元酸:",j);
		scanf("%d",&nhyd[j]);
		printf("\n 电荷数是:");
		scanf("%d",&ne[j]);
		for(i=1;i<=nhyd[j];i++)
		{
			printf("\n解离常数 Ka%d=",i);
			scanf("%le",&k[i][j]);
		}
		k[0][j]=1.0;
	}
	phz=pH(ph1,ph2);
	printf("\n 溶液的pH值是:%6.2f\n",phz);
}
//主函数
void main()
{
	double fHy(double ph);
	double disk(double ph,int j,int i);
	double partFH(double ph);
	double pH(double ph1,double ph2);
	HICON hicon;
	BOOL draw;
	HDC hdc=NULL;
	hicon=LoadIcon(NULL,IDI_HAND);
	draw=DrawIcon(hdc,0,0,hicon);
	void prompt(void);
	char ch;   
	//while()句实现
	while(1)
	{
		prompt();
		ch=' ';
		printf("\n\n(Y/N)?");
		while(ch!='Y'&&ch!='y'&&ch!='N'&&ch!='n')
			scanf("%c",&ch);
		printf("\n");
		if(ch=='n'||ch=='N')
			break;
	}
}

