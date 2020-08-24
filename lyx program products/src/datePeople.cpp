#include <iostream.h>
#include <string>

class date
{
private:
        int year;
        int month;
        int day;
public:
        date( int y, int m, int d)
        {
                year = y;
                month = m;
                day = d;
        }
                
        void print()
        {
                cout<<year<<":"<<month<<":"<<day;
        }
};

class people
{
private:
        char name[10];
        char id[20];
        char sex;
        date dt;

public:
        people(char *n, char *i, char s,int y, int m, int d ):dt( y, m, d)
        {
                strcpy(name, n);
                strcpy(id, i);
                sex = s;
        
        }
        people( const people &peo );
    ~people()
        {
                cout<<name<<"'s Destructor is Ok!"<<endl;
        }

    void print()
        {
                //cout<<"number:"<<number;
                cout<<",name:"<<name;
                cout<<",id:"<<id;
                cout<<",sex:"<<sex;
                cout<<",Birthday:";
                dt.print();
                cout<<endl;
        }
};

people::people(const people& peo )
{
        strcpy(name, peo.name);
        strcpy(id, peo.id);
        sex = peo.sex;

}

void main()
{
        people pl("zhang", "3201089657", 'm',79,8,3),zh("wang", "1345678989",
 'm',56,7,31);
        pl.print();
        zh.print();
}
