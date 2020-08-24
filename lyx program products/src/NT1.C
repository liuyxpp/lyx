
#include <stdio.h>
#include <string.h>
#include <conio.h>
#include <ctype.h>

char WORD[10][10] = {"you", "for", "your", "on", "no","if","the","in","to","all"} ;
char xx[50][80] ;
int maxline = 0 ;  /* 文章的总行数 */

int ReadDat(void) ;
void WriteDat(void) ;
void DelWord(void);


void main()
{
  if(ReadDat()) {
    printf("数据文件ENG.IN不能打开!\n\007") ;
    return ;
  }
  DelWord() ;
  WriteDat() ;
}

int ReadDat(void)
{
  FILE *fp ;
  int i = 0 ;
  char *p ;

  if((fp = fopen("eng.in", "r")) == NULL) return 1 ;
  while(fgets(xx[i], 80, fp) != NULL) {
    p = strchr(xx[i], '\n') ;
    if(p) xx[i][p - xx[i]] =0;
    i++ ;
  }
  maxline = i ;
  fclose(fp) ;
  return 0 ;
}

void WriteDat(void)
{
  FILE *fp ;
  int i ;

  fp = fopen("ps6.out", "w") ;
  for(i = 0 ; i < maxline ; i++) {
    printf("%s\n", xx[i]) ;
    fprintf(fp, "%s\n", xx[i]) ;
  }
  fclose(fp) ;
}
void DelWord()
{
  int i,j,k;
  int w;
  int cur;
  int ischar=0;
  char ch[80];
  for(i=0;i<maxline;i++)
  {
	cur=0;k=0;
    for(j=0;xx[i][j]!='\0';j++)
    { 
      while(xx[i][j]!=' '&&xx[i][j]!='\0')
       {
			xx[i][cur++]=xx[i][j];
			ch[k++]=xx[i][j++];
			if(xx[i][j]==' ') {ch[k]='\0';ischar=1;}
			else if(xx[i][j]=='\0'){ch[k]='\0';ischar=2;}
       }
      if(ischar)
      {
		w=0;
		while(strcmp(strlwr(ch),WORD[w])!=0&&w<10) w++;
		if(w<10)
		{
			cur-=strlen(WORD[w]);
			if(cur<0) cur=0;
		}
		if(ischar==2){xx[i][cur]=0;break;}
		k=0;
		ischar=0;
      }
    }
  }
}
