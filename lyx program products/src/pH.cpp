#include <stdio.h>
#include <math.h>
#include "resource.h"
#include <windows.h>
#define eps 1e-6      // �����ľ���
#define kw 1.0e-14      //ˮ�ģˣ�ֵ 
//�趨ȫ�ֱ���
double c[100],k[8][100];
int npart,nhyd[100],ne[100];
//��������deltaֵ 
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
//�������󲿷ֺ�[H+]�ķ��̵�ֵ
double partFH(double ph)
{
	double result=0;
	int j;
	for(j=1;j<=npart;j++)
		result+=disk(ph,j);
	return result;
}
//�������ں���partFH()�Ļ������󷽳����ֵ
double fHy(double ph)
{
	double fh;
	fh=ph-kw/ph+partFH(ph);
	return(fh);
}
//�������ø��߷����pH��ֵ
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
//�����������ʼ����
void prompt(void)
{
	int i,j;
	double phz,ph1=1.0,ph2=1e-14;
	printf("\n ����Һ�к��м�����: ");
	scanf("%d",&npart);
	printf("\n       ******ǿ�᣺Ka=1e15;ǿ�Ka=0 ******");
	for(j=1;j<=npart;j++)
	{
		printf("\n ��%d��Ũ���ǣ�",j);
		scanf("%le",&c[j]);
		printf("\n ��%d�Ǽ�Ԫ��:",j);
		scanf("%d",&nhyd[j]);
		printf("\n �������:");
		scanf("%d",&ne[j]);
		for(i=1;i<=nhyd[j];i++)
		{
			printf("\n���볣�� Ka%d=",i);
			scanf("%le",&k[i][j]);
		}
		k[0][j]=1.0;
	}
	phz=pH(ph1,ph2);
	printf("\n ��Һ��pHֵ��:%6.2f\n",phz);
}
//������
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
	//while()��ʵ��
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

