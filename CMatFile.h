/*
* CMatFile.h - A C++ wrapper for importing and exporting Matlab MAT-files
* 	MatIO version
*
* Create a MAT-file which can be loaded into MATLAB.
* This class is based on MatIO (an C library for reading and writing
* Matlab MAT files).
* It can be used to export N-dimensional data to a MAT-file.
* The supported data types can be found at MatIO manual or Matlab Help.
*
* To be compatible with existing codes, the interface is kept unchanged.
* To make mwSize, mxClassID, mxComplexity still usable, their definitions
* are grabbed from Matlab externel API: matrix.h and tmwtypes.h.
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
* Copyright (C) 2014 Yixin Liu since 2014.08.06
* @Fudan Univ.
* Contact: lyx@fudan.edu.cn
*/
/* $ Revision $
* 2014.08.06
* 	1. Migrate from Matlab Kernel API to MatIO.
* 2012.03.30:
*   1. Update comments
* 2011.06.14:
*   1. add const to some input arguments
* 2011.06.09:
*   1. modify the standard behavior of mode 'u'. If the MAT-file is not exist, then use mdoe 'w'.
*
*/

#ifndef _CMATFILE_H_
#define _CMATFILE_H_

#include <cstdlib>  // for size_t
#include <cstring>  // for strcpy, memcpy
#include <string>
//#include <fstream>
#include "matio.h"

using namespace std;

typedef size_t mwSize;  /* unsigned pointer-width integer */

/**
 * Enumeration corresponding to all the valid mxArray types.
 * Grab from Matlab external API: matrix.h
 */
typedef enum
{
    mxUNKNOWN_CLASS = 0,
    mxCELL_CLASS,
    mxSTRUCT_CLASS,
    mxLOGICAL_CLASS,
    mxCHAR_CLASS,
    mxVOID_CLASS,
    mxDOUBLE_CLASS,
    mxSINGLE_CLASS,
    mxINT8_CLASS,
    mxUINT8_CLASS,
    mxINT16_CLASS,
    mxUINT16_CLASS,
    mxINT32_CLASS,
    mxUINT32_CLASS,
    mxINT64_CLASS,
    mxUINT64_CLASS,
    mxFUNCTION_CLASS,
    mxOPAQUE_CLASS,
    mxOBJECT_CLASS, /* keep the last real item in the list */
#if defined(_LP64) || defined(_WIN64)
    mxINDEX_CLASS = mxUINT64_CLASS,
#else
    mxINDEX_CLASS = mxUINT32_CLASS,
#endif
    /* TEMPORARY AND NASTY HACK UNTIL mxSPARSE_CLASS IS COMPLETELY ELIMINATED */
    mxSPARSE_CLASS = mxVOID_CLASS /* OBSOLETE! DO NOT USE */
}
mxClassID;

/**
 * Indicates whether floating-point mxArrays are real or complex.
 * Grab from Matlab external API: matrix.h
 */
typedef enum
{
    mxREAL,
    mxCOMPLEX
}
mxComplexity;

class CMatFile{
private:
	// File handle of MAT file to be created
	mat_t *pmat;

	// Access flag:
	// 		MAT_ACC_RDONLY => "r"
	// 		MAT_ACC_RDWR =>"u"
	// enum should be explicitly stated for there is no typedef before
	// the declaration in matio.h
	enum mat_acc mat_rw;

	// MAT file version flag:
	// 		MAT_FT_MAT73 => "w7.3"
	// 		MAT_FT_MAT5 => "w5"
	// 		MAT_FT_MAT4 => "w4"
	// 		MAT_FT_DEFAULT (which depends on MatIO install,
	//						check it in matio_pubconf.h)
	enum mat_ft mat_ver;

	// Data compression:
	// 		MAT_COMPRESSION_NONE
	//		MAT_COMPRESSION_ZLIB => "wz"
	enum matio_compression mat_compress;

	matvar_t *mxVar;  // store the data to be put into MAT file

	// file processing mode: "r", "w", "u", "w4", "wL", "wz", "w7.3".
	string imode;

	// Internal state indication: 0 if successful; non-zero if failed
	int status;

	void prepareVar(const string varName, void *data, const mwSize sizeData,
					const mwSize ndim, const mwSize *dims,
					const mxClassID classID, const mxComplexity complexFlag)
	{
		enum matio_classes class_type = map_class_matlab_to_matio(classID);
		enum matio_types data_type = map_type_matlab_to_matio(classID);

		if(complexFlag == mxCOMPLEX)
			mxVar = Mat_VarCreate(varName.c_str(), class_type, data_type,
								  ndim, (size_t*) dims, data, MAT_F_COMPLEX);
		else  /* mxREAL or other unknown flags */
			mxVar = Mat_VarCreate(varName.c_str(), class_type, data_type,
								  ndim, (size_t*) dims, data, 0);

		if(NULL == mxVar){
			status = 1;
			return;
		}

		status = 0;
	}

	enum matio_classes map_class_matlab_to_matio(const mxClassID matlab_id){
		enum matio_classes matio_id;
		switch(matlab_id){
			case mxCELL_CLASS:
				matio_id = MAT_C_CELL;
				break;
			case mxSTRUCT_CLASS:
				matio_id = MAT_C_STRUCT;
				break;
			case mxOBJECT_CLASS:
				matio_id = MAT_C_OBJECT;
				break;
			case mxCHAR_CLASS:
				matio_id = MAT_C_CHAR;
				break;
			case mxVOID_CLASS:
				matio_id = MAT_C_EMPTY;
				break;
			case mxDOUBLE_CLASS:
				matio_id = MAT_C_DOUBLE;
				break;
			case mxSINGLE_CLASS:
				matio_id = MAT_C_SINGLE;
				break;
			case mxINT8_CLASS:
				matio_id = MAT_C_INT8;
				break;
			case mxUINT8_CLASS:
				matio_id = MAT_C_UINT8;
				break;
			case mxINT16_CLASS:
				matio_id = MAT_C_INT16;
				break;
			case mxUINT16_CLASS:
				matio_id = MAT_C_UINT16;
				break;
			case mxINT32_CLASS:
				matio_id = MAT_C_INT32;
				break;
			case mxUINT32_CLASS:
				matio_id = MAT_C_UINT32;
				break;
			case mxINT64_CLASS:
				matio_id = MAT_C_INT64;
				break;
			case mxUINT64_CLASS:
				matio_id = MAT_C_UINT64;
				break;
			case mxFUNCTION_CLASS:
				matio_id = MAT_C_FUNCTION;
				break;
			default:
				matio_id = MAT_C_EMPTY;
				break;
		}
		return matio_id;
	}

	enum matio_types map_type_matlab_to_matio(const mxClassID matlab_id){
		enum matio_types matio_id;
		switch(matlab_id){
			case mxCELL_CLASS:
				matio_id = MAT_T_CELL;
				break;
			case mxSTRUCT_CLASS:
				matio_id = MAT_T_STRUCT;
				break;
			case mxCHAR_CLASS:
				matio_id = MAT_T_UINT8;  /* MAT_C_UNIT8 */
				break;
			case mxVOID_CLASS:
				matio_id = MAT_T_ARRAY;
				break;
			case mxDOUBLE_CLASS:
				matio_id = MAT_T_DOUBLE;
				break;
			case mxSINGLE_CLASS:
				matio_id = MAT_T_SINGLE;
				break;
			case mxINT8_CLASS:
				matio_id = MAT_T_INT8;
				break;
			case mxUINT8_CLASS:
				matio_id = MAT_T_UINT8;
				break;
			case mxINT16_CLASS:
				matio_id = MAT_T_INT16;
				break;
			case mxUINT16_CLASS:
				matio_id = MAT_T_UINT16;
				break;
			case mxINT32_CLASS:
				matio_id = MAT_T_INT32;
				break;
			case mxUINT32_CLASS:
				matio_id = MAT_T_UINT32;
				break;
			case mxINT64_CLASS:
				matio_id = MAT_T_INT64;
				break;
			case mxUINT64_CLASS:
				matio_id = MAT_T_UINT64;
				break;
			case mxFUNCTION_CLASS:
				matio_id = MAT_T_FUNCTION;
				break;
			default:
				matio_id = MAT_T_UNKNOWN;
				break;
		}
		return matio_id;
	}

public:

	CMatFile():pmat(NULL),mxVar(NULL),status(0){} //constructor

	/*
	 * Method to initialize CMatFile object for creating MAT file.
	 * This method should first be called prior to do any other operation.
	 *
	 * Usage:
	 *		CMAT_Instance.matInit("data.mat", "w");
	 *
	 * Input:
	 *		file	- the file name of MAT file to be created
	 *		mode	- file opening mode
	 *				- "r": Opens file for reading only
	 *				- "w": Opens file for writing only;
	 * 					   Delete previous contents, if any.
	 *				- "u": Opens file for Update,
	 * 					   but does not create file if file does not exist.
	 *				- "w4": Creates a level 4 MAT-file,
	 * 						compatible with MATLAB version 4 and earlier.
	 *				- "wL": Opens file for writing character data
	 * 						using the default character set.
	 * 						The default encoding is Unicode.
	 *				- "wz": Open file for writing compressed data
	 *				- "w7.3": Creates a MAT-file in an HDF5-based format
	 * 						  that can store objects occupy more than 2GB.
	 *
	 * Internal state change:
	 *		status
	 * TESTED: "r", "w", "u".
	 */
	void matInit(const string file, const string mode)
	{
		status = 0;
		if(NULL != pmat) matRelease();
		if(status != 0) return;

		if(!mode.compare("r")){
			mat_rw = MAT_ACC_RDONLY;
			mat_ver = MAT_FT_MAT5;
			mat_compress = MAT_COMPRESSION_NONE;
		}
		else if(!mode.compare("w")){
			mat_rw = MAT_ACC_RDWR;
			mat_ver = MAT_FT_MAT5;
			mat_compress = MAT_COMPRESSION_NONE;
		}
		else if(!mode.compare("u")){
			mat_rw = MAT_ACC_RDWR;
			mat_ver = MAT_FT_MAT5;
			mat_compress = MAT_COMPRESSION_NONE;
		}
		else if(!mode.compare("w4")){
			mat_rw = MAT_ACC_RDWR;
			mat_ver = MAT_FT_MAT4;
			mat_compress = MAT_COMPRESSION_NONE;
		}
		else if(!mode.compare("wz")){
			mat_rw = MAT_ACC_RDWR;
			mat_ver = MAT_FT_MAT5;
			mat_compress = MAT_COMPRESSION_ZLIB;
		}
		else if(!mode.compare("w7.3")){
			mat_rw = MAT_ACC_RDWR;
			mat_ver = MAT_FT_MAT73;
			mat_compress = MAT_COMPRESSION_NONE;
		}
		else{
			status = 1;
			return;
		}

		if(!mode.compare("u")){
			pmat = Mat_Open(file.c_str(), mat_rw);
			if(NULL == pmat)
				pmat = Mat_CreateVer(file.c_str(), NULL, mat_ver);
		}
		else if(!mode.compare("r"))
			pmat = Mat_Open(file.c_str(), mat_rw);
		else
			pmat = Mat_CreateVer(file.c_str(), NULL, mat_ver);

		if(NULL == pmat){
			status = 1;
			return;
		}

		imode = mode;
	}

	/*
	 * Method for exporting C/C++ data to a MAT file. When importing to Matlab,
	 * the varName will be a local variable in Matlab.
	 *
	 * Usage:
	 *		CMatFile_Instance.matPut("x", pdata, sizeof(*pdata), 3, {8, 8, 8},
	 * 								 mxDOUBLE_CLASS, mxREAL)
	 *
	 * Input:
	 *		varName		- the mxArray variable name that shows in Matlab
	 *		data		- C/C++ data (arrays or allocated pointer) to be export
	 *		sizeData	- sizeof(data), which is not used in MatIO version.
	 *		ndim		- the dimension of the mxArray (1, 2, 3, ...)
	 *		dims		- an array carries the dimension extension
	 * 					  of each dimension.
	 *		classID		- the ID of the class of data type
	 * 					  which is defined by Matlab:
	 *					- Matlab				C/C++
	 *                    ----------------------------
	 *					- mxDOUBLE_CLASS		double
	 *					- mxSINGLE_CLASS		single
	 *					- mxINT64_CLASS			int64
	 *					- mxINT32_CLASS			int32
	 *					- more referring to Matlab Help
 	 *		complexFlag	- indicating whether the data will be stored in Real or Complex mode.
	 *					- mxREAL, mxCOMPLEX
	 *
	 * Internal state change:
	 *		status
	 * TESTED: dim (1, 2), class (DOUBLE), complexity (mxREAL, mxCOMPLEX).
	 */
	void matPut(const string varName,void *data,
				const mwSize sizeData, const mwSize ndim, const mwSize *dims,
				const mxClassID classID, const mxComplexity complexFlag)
	{
		if(mat_rw == MAT_ACC_RDONLY){
			status = 1;
			return;
		}

		// Matlab API version allow ndim = 1,
		// But MatIO refuse ndim = 1.
		// Below handle ndim = 1 case properly in MatIO.
		if(ndim == 1){
			mwSize ndim_new = 2;
			mwSize dims_new[2] = {dims[0], 1};  // dims[0] x 1 matrix
			prepareVar(varName, data, sizeData, ndim_new, dims_new,
					   classID, complexFlag);
		}
		else  /* ndim > 1 */
			prepareVar(varName, data, sizeData, ndim, dims,
					   classID, complexFlag);

		if(NULL != pmat && status == 0){
			status = Mat_VarWrite(pmat, mxVar, mat_compress);
			Mat_VarFree(mxVar);
		}
	}

	/*
	 * Same method as matPutG except it store varName
	 * as a global variable when importing to Matlab.
	 * Not implemented yet.
	 */
	void matPutG(const string varName,void *data,
				const mwSize sizeData, const mwSize ndim, const mwSize *dims,
				const mxClassID classID, const mxComplexity complexFlag)
	{
		if(mat_rw == MAT_ACC_RDONLY){
			status = 1;
			return;
		}

		if(NULL != pmat && status == 0){
			//status = Mat_VarWrite(pmat, mxVar, mat_compress);
			//Mat_VarFree(mxVar);
		}
	}

	/*
	 * Method for exporting scalar value from C++ data to MAT-file.
	 * Usage:
	 *	CMatFile_instance.matPutScalar(varName);
	 * Note:
	 * 	1. Complex scalar is not supported.
	 *  2. All data types are converted to double.
	 * TESTED: double, int.
	 */
	template <class T>
	void matPutScalar(const string varName, const T &data)
	{
		if(mat_rw == MAT_ACC_RDONLY){
			status = 1;
			return;
		}

		mwSize ndim = 2;
		mwSize dims[2] = {1, 1};
		double data_new = data;
		matPut(varName, &data_new, 0, ndim, dims, mxDOUBLE_CLASS, mxREAL);
	}

	/*
	 * Method for exporting string value from C++ data to MAT-file.
	 * string in Matlab is just an 1xN matrix.
	 * Usage:
	 *	CMatFile_instance.matPutScalar(varName,stringdata);
	 * Note:
	 * 	1. Empty string is not allowed.
	 * TESTED: string.
	 */
	void matPutString(const string varName, const string &data)
	{
		if(mat_rw == MAT_ACC_RDONLY){
			status = 1;
			return;
		}

		mwSize len = data.length();
		if(len < 1){
			status = 1;
			return;
		}

		mwSize ndim = 2;
		mwSize dims[2] = {1, len};
		char *data_new = new char[len+1];
		strcpy(data_new, data.c_str());
		matPut(varName, data_new, 0, ndim, dims, mxCHAR_CLASS, mxREAL);
	}

	/*
	 * Method for importing scalar value from MAT-file to C++ data.
	 * Usage:
	 *	CMatFile_instance.matGetScalar(varName,data);
	 * TESETED: double, int.
	 */
	template <class T>
	void matGetScalar(const string varName, T &data)
	{
		mxVar = Mat_VarRead(pmat, varName.c_str());
		if(NULL != mxVar){
			double* p = (double*) mxVar->data;
			data = static_cast<T>(p[0]);
			Mat_VarFree(mxVar);
		}
		else
			status = 1;
	}

	/*
	 * Method for importing string value from MAT-file to C++ data.
	 * Usage:
	 *	CMatFile_instance.matGetScalar(varName,data);
	 * TESTED: string.
	 */
	void matGetString(const string varName, string &data)
	{
		mxVar = Mat_VarRead(pmat, varName.c_str());
		if(NULL != mxVar){
			char* p = (char*) mxVar->data;
			string str(p);
			data = str;
			Mat_VarFree(mxVar);
		}
		else
			status = 1;
	}

	/*
	 * Method for importing arrays from MAT-file to C++ data.
	 * Usage:
	 *	CMatFile_instance.matGetArray(varName,data,sizeData);
	 * Note:
	 * 	1. Input variable *data is assumed to be stored in a contiguous
	 * 	   memory block.
	 * TESTED: dim (1, 2), class (DOUBLE), complexity (mxREAL, mxCOMPLEX).
	 */
	void matGetArray(const string varName, void *data, const mwSize sizeData)
	{
		mxVar = Mat_VarRead(pmat, varName.c_str());
		if(NULL != mxVar){
			if(mxVar->isComplex){
				// Must do this conversion, since *data contains information
				// about the mat_complex_split_t.
				mat_complex_split_t *z = (mat_complex_split_t*) mxVar->data;
				memcpy(data, z->Re, mxVar->nbytes);
				// Convert void* to char* for pointer arithmetic
				memcpy((char*) data + mxVar->nbytes, z->Im, mxVar->nbytes);
			}
			else
				memcpy(data, mxVar->data, mxVar->nbytes);
			Mat_VarFree(mxVar);
		}
		else
			status = 1;
	}

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
	void matRelease()
	{
		if(NULL != pmat) status = Mat_Close(pmat);
		pmat = NULL;
		status = 0;
	}

	/*
	 * Method for querying system state.
	 */
	int queryStatus(){
		return status;
	}

	/*
	 * Method for printing system state.
	 * Should be used only for debugging purpose.
	 */
	void printStatus()
	{
		if (status==0)
			cout<<"CMatFile status: Normal."<<endl;
		else
			cout<<"CMatFile status: Error!"<<endl;
	}
};

#endif // _CMATFILE_H_
