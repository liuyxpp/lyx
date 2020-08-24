/*
* CMatFile.h - A C++ wrapper for importing and exporting Matlab MAT-files
*
* Create a MAT-file which can be loaded into MATLAB. This class is based on MATLAB
* external library for importing and exporting MAT-files (libmat.dll). It can be
* used to export N-dimensional data (the supported data types can be found at
* Matlab Help) to a MAT-file.
*
* General usage:
*	Exporting:
*		CMatFile mat;
*		mat.matInit(someFileName,mode); // open file handle to be created 
*		if(!mat.queryStatus()){
*			mat.matPut(varName,data,sizeof(data),ndim,dims,classID,complexFlag);
*			// add any additional exporting here
*		}
*		mat.Release(); // Close file handle.
*	Importing:
*		CMatFile mat;
*		double var;
*		mat.matInit(someFileName,mode); // mode containing "r"
*		if(!mat.queryStatus()){
*			var=mat.matGetScalar(varName);
*		}
*
* Public Method:
*		matInit
*		matPut
*		matPutG
*		matPutScalar
*		matPutString
*		matGetScalar
*		matGetArray
*		matGetString
*		matRelease
*		printStatus
*		queryStatus
*
* Copyright 2010 Yixin Liu since 2010.4.15
* @Fudan Univ.
* Contact: liuyxpp@gmail.com
*/
/* $ Revision: 2012.3.30 $ 
* 2012.3.30:
*   1. Update comments
* 2011.6.14:
*   1. add const to some input arguments
* 2011.6.9:
*   1. modify the standard behavior of mode 'u'. If the MAT-file is not exist, then use mdoe 'w'.
*
*/

#ifndef _CMATFILE_H_
#define _CMATFILE_H_

#include <cstring> // for memcpy
#include <string>
#include <fstream>
#include "mat.h"

using namespace std;

class CMatFile{
private:

	MATFile *pmat;	// the file handle of MAT file to be created
	mxArray *mxVar;	// store the data to be put into MAT file
	string imode;	// file processing mode: "r", "w", "u", "w4", "wL", "wz", "w7.3".
	int status;	// Internal state indication: 0 if successful; non-zero if failed

	void prepareVar(void *data, const mwSize sizeData, const mwSize ndim, const mwSize *dims, const mxClassID classID, const mxComplexity complexFlag)
	{
		mxVar=mxCreateNumericArray(ndim,dims,classID,complexFlag);
		if(mxVar==NULL){
			status=1;
			return;
		}
		memcpy((void *)(mxGetPr(mxVar)), data, sizeData);
		status=0;
	}

public:

	CMatFile():pmat(NULL),mxVar(NULL),status(0){} //constructor

	void matInit(const string file,const string mode)
	/*
	* Method to initialize CMatFile object for creating MAT file.
	* This method should first be called prior to do any other operation.
	*
	* Usage:
	*		CMAT_Instance.matInit(someFileName)
	*
	* Input:
	*		file	- the file name of MAT file to be created
	*		mode	- file opening mode
	*				- "r": Opens file for reading only
	*				- "w": Opens file for writing only; Delete previous contents, if any.
	*				- "u": Opens file for Update, but does not create file if file does not exist.
	*				- "w4": Creates a level 4 MAT-file, compatible with MATLAB version 4 and earlier.
	*				- "wL": Opens file for writing character data using the default character set. The default encoding is Unicode.
	*				- "wz": Open file for writing compressed data
	*				- "w7.3": Creates a MAT-file in an HDF5-based format that can store objects occupy more than 2GB.
	*
	* Internal state change:
	*		status
	*/
	{
		status=0;
		if(pmat!=NULL) matRelease();
		if(status!=0) return;
        
        string u("u");
        if(mode==u){
            ifstream fin(file.c_str(),ios::in);
            if(fin.fail())
		        pmat=matOpen(file.c_str(),"w"); // MAT-file not exits, then use "w" to create a new one.
            else{
                fin.close();
		        pmat=matOpen(file.c_str(),mode.c_str());
            }
        }
        else
        	pmat=matOpen(file.c_str(),mode.c_str());
        
		if(pmat==NULL){
			status=1;
			return;
		}
		imode=mode;
	}

	void matPut(const string varName,void *data, 
				const mwSize sizeData, const mwSize ndim, const mwSize *dims, 
				const mxClassID classID, const mxComplexity complexFlag)
	/*
	* Method for exporting C/C++ data to a MAT file. When importing to Matlab,
	* the varName will be a local variable in Matlab.
	*
	* Usage:
	*		CMatFile_Instance.matPut(varName,data,sizeof(data),ndim,dims,classID,complexFlag)
	*
	* Input:
	*		varName		- the mxArray variable name that shows in Matlab
	*		data		- C/C++ data (arrays or allocated pointer) to be export
	*		sizeData	- sizeof(data)
	*		ndim		- the dimension of the mxArray
	*		dims		- an array carries the dimension extension of each dimension.
	*		classID		- the ID of the class of data type which is defined by Matlab
	*					- Matlab				C/C++
	*					- mxDOUBLE_CLASS		double
	*					- mxSINGLE_CLASS		single
	*					- mxInt64_CLASS			int64
	*					- mxInt32_CLASS			int32
	*					- more referring to Matlab Help
	*		complexFlag	- indicating whether the data will be stored in Real or Complex mode.
	*					- mxREAL, mxCOMPLEX
	*		
	* Internal state change:
	*		status
	*/
	{
		if(imode.empty() || !imode.compare("r")){
			/* 
			* IMPORTANT
			* imode.compare("r")=0 if imode.c_str()=="r", the file is read-only
			* for other mode, the file is writable.
			*/
			status=1;
			return;
		}
		prepareVar(data, sizeData, ndim, dims, classID, complexFlag);
		if(pmat!=NULL && status==0)
			status=matPutVariable(pmat,varName.c_str(),mxVar);
		mxDestroyArray(mxVar);
	}

	void matPutG(const string varName,void *data, 
				const mwSize sizeData, const mwSize ndim, const mwSize *dims, 
				const mxClassID classID, const mxComplexity complexFlag)
	/*
	* Same method as matPutG except it store varName as a global variable when importing
	* to Matlab.
	*/
	{
		if(imode.empty() || !imode.compare("r")){
			status=1;
			return;
		}
		prepareVar(data, sizeData, ndim, dims, classID, complexFlag);
		if(pmat!=NULL && status==0)
			status=matPutVariableAsGlobal(pmat,varName.c_str(),mxVar);
		mxDestroyArray(mxVar);
	}

	template <class T>
	void matPutScalar(const string varName,const T &data)
		/*
		* Method for exporting scalar value from C++ data to MAT-file.
		* Usage:
		*	CMatFile_instance.matPutScalar(varName);
		*/
	{
		mxVar=mxCreateDoubleScalar(data);
		status=matPutVariable(pmat,varName.c_str(),mxVar);
		mxDestroyArray(mxVar);
	}
	
	void matPutString(const string varName,const string &data)
		/*
		* Method for exporting string value from C++ data to MAT-file.
		* Usage:
		*	CMatFile_instance.matPutScalar(varName,stringdata);
		*/
	{
		mxVar=mxCreateString(data.c_str());
		status=matPutVariable(pmat,varName.c_str(),mxVar);
		mxDestroyArray(mxVar);
	}

	template <class T>
	void matGetScalar(const string varName,T &data)
	/*
	* Method for importing scalar value from MAT-file to C++ data.
	* Usage:
	*	CMatFile_instance.matGetScalar(varName,data);
	*/
	{
		mxVar=matGetVariable(pmat,varName.c_str());
		data=static_cast<T> (mxGetScalar(mxVar));
		mxDestroyArray(mxVar);
	}

	void matGetString(const string varName,string &data)
		/*
		* Method for importing string value from MAT-file to C++ data.
		* Usage:
		*	CMatFile_instance.matGetScalar(varName,data);
		*/
	{
		mxVar=matGetVariable(pmat,varName.c_str());
		data=mxArrayToString(mxVar);
		mxDestroyArray(mxVar);
	}

	void matGetArray(const string varName,void *data, const mwSize sizeData)
		/*
		* Method for importing arrays from MAT-file to C++ data.
		* Usage:
		*	CMatFile_instance.matGetArray(varName,data,sizeData);
		*/
	{
		mxVar=matGetVariable(pmat,varName.c_str());
		memcpy((void *)(data), mxGetData(mxVar), sizeData);
		mxDestroyArray(mxVar);
	}

	void matRelease()
	/*
	* Method for releasing an opened MAT file.
	* This method should be called after finishing writing MAT file.
	*
	* Usage:
	*		CMAT_Instance.matRelease()
	*
	* Internal state change:
	*		status
	*/
	{
		status=0;
		if(pmat!=NULL) status=matClose(pmat);
		pmat=NULL;
	}

	int queryStatus(){	return status;	} // Method for querying system state. 

	void printStatus()
	// Method for printing system state.
	// Should be used only for debugging purpose. 
	{
		if (status==0)
			cout<<"Normal."<<endl;
		else
			cout<<"An error occurred!"<<endl;
	}
};

#endif // _CMATFILE_H_
