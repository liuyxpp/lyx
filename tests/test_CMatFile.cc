#include <iostream>
#include "../CMatFile.h"

using namespace std;

void test_Array(CMatFile &mat){
    mwSize dim = 1;
    mwSize dims[1] = {9};
    double x[9] = {1, 2, 3, 4, 5, 6, 7, 8, 9};
    double y[9] = {11, 12, 13, 14, 15, 16, 17, 18, 19};
    struct mat_complex_split_t z = {x, y};

    mat.matPut("x", x, 0, dim, dims, mxDOUBLE_CLASS, mxREAL);
    mat.matPut("y", y, 0, dim, dims, mxDOUBLE_CLASS, mxREAL);
    mat.matPut("z", (void*) &z, 0, dim, dims, mxDOUBLE_CLASS, mxCOMPLEX);

    dim = 2;
    dims[0] = 3;
    dims[1] = 3;
    mat.matPut("x2", x, 0, dim, dims, mxDOUBLE_CLASS, mxREAL);
    mat.matPut("y2", y, 0, dim, dims, mxDOUBLE_CLASS, mxREAL);
    mat.matPut("z2", (void*) &z, 0, dim, dims, mxDOUBLE_CLASS, mxCOMPLEX);
}

void test_Scalar(CMatFile &mat){
    double pi = 3.14159;
    int I = 999;

    mat.matPutScalar("pi", pi);
    mat.matPutScalar("I", I);
}

void test_String(CMatFile &mat){
    string hello = "Hello World!";

    mat.matPutString("hello", hello);
}

void test_readArray(CMatFile &mat){
    double *x, *y, *x2, *y2;
    double *z, *z2;

    x = new double[9];
    mat.matGetArray("x", x, 0);
    cout<<"x = { "<<x[0];
    for(int i=1; i<9; i++)
        cout<<", "<<x[i];
    cout<<"}"<<endl;

    y = new double[9];
    mat.matGetArray("y", y, 0);
    cout<<"y = { "<<y[0];
    for(int i=1; i<9; i++)
        cout<<", "<<y[i];
    cout<<"}"<<endl;

    x2 = new double[9];
    mat.matGetArray("x2", x2, 0);
    int idx;
    cout<<"x2 = "<<endl;
    for(int i=0; i<3; i++){
        for(int j=0; j<3; j++){
            idx = 3 * i + j;
            cout<<x2[idx]<<", ";
        }
        cout<<endl;
    }

    y2 = new double[9];
    mat.matGetArray("y2", y2, 0);
    cout<<"y2 = "<<endl;
    for(int i=0; i<3; i++){
        for(int j=0; j<3; j++){
            idx = 3 * i + j;
            cout<<y2[idx]<<", ";
        }
        cout<<endl;
    }

    z = new double[9*2];
    mat.matGetArray("z", z, 0);
    cout<<"z = {("<<z[0]<<", "<<z[0+9]<<")";
    for(int i=1; i<9; i++)
        cout<<", ("<<z[i]<<", "<<z[i+9]<<")";
    cout<<"}"<<endl;
}

void test_readScalar(CMatFile &mat){
    double pi;
    int I;
    mat.matGetScalar("pi", pi);
    cout<<"pi = "<<pi<<endl;
    mat.matGetScalar("I", I);
    cout<<"I = "<<I<<endl;
}

void test_readString(CMatFile &mat){
    string hello;
    mat.matGetString("hello", hello);
    cout<<"hello = "<<hello<<endl;
}

int main(){
    CMatFile mat;


    string file = "data.mat";

    /** Write a new MAT file **/
    mat.matInit(file, "w");
    mat.printStatus();

    if(!mat.queryStatus()){
        test_Array(mat);
    }
    else{
        cerr<<"error: cannot open MAT-file: "<<file<<endl;
        exit(1);
    }

    mat.matRelease();

    /** Update an existing MAT file **/
    mat.matInit(file, "u");
    mat.printStatus();

    if(!mat.queryStatus()){
        test_Scalar(mat);
        test_String(mat);
    }
    else{
        cerr<<"error: cannot open MAT-file: "<<file<<endl;
        exit(1);
    }

    mat.matRelease();

    /** Read an existing MAT file **/
    mat.matInit(file, "r");
    mat.printStatus();

    if(!mat.queryStatus()){
        test_readArray(mat);
        test_readScalar(mat);
        test_readString(mat);
    }
    else{
        cerr<<"error: cannot open MAT-file: "<<file<<endl;
        exit(1);
    }

    return 0;
}
