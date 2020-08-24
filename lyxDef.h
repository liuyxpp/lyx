/*
* lyxDef.h - Typedefs and macros
*
* Maintained by Yixin Liu since 2010.4.17
* @Fudan Univ.
* Contact: liuyxpp@gmail.com
*/
/* $ Revision: 2010.5.12 $ */
#ifndef _LYXDEF_H_
#define _LYXDEF_H_

#include <complex>
#include <limits>

using namespace std;

//#define _CHECKBOUNDS_ 1
//#define _TURNONFPES_ 1

// macro-like inline functions
// template<class T>
// inline T SQR(const T a) {return a*a;}

// template<class T>
// inline const T &MAX(const T &a, const T &b)
// {return b > a ? (b) : (a);}

// inline float MAX(const double &a, const float &b)
// {return b > a ? (b) : float(a);}

// inline float MAX(const float &a, const double &b)
// {return b > a ? float(b) : (a);}

// template<class T>
// inline const T &MIN(const T &a, const T &b)
// {return b < a ? (b) : (a);}

// inline float MIN(const double &a, const float &b)
// {return b < a ? (b) : float(a);}

// inline float MIN(const float &a, const double &b)
// {return b < a ? float(b) : (a);}

// template<class T>
// inline T SIGN(const T &a, const T &b)
// {return b >= 0 ? (a >= 0 ? a : -a) : (a >= 0 ? -a : a);}

// inline float SIGN(const float &a, const double &b)
// {return b >= 0 ? (a >= 0 ? a : -a) : (a >= 0 ? -a : a);}

// inline float SIGN(const double &a, const float &b)
// {return (float)(b >= 0 ? (a >= 0 ? a : -a) : (a >= 0 ? -a : a));}

template<class T>
inline void SWAP(T &a, T &b)
{T dum=a; a=b; b=dum;}

inline bool isNaN(double x){
	// A simplest way to detect whether a double variable is a NaN
	// This function returns "true" when x is a NaN
	return (!(x==x));
}

inline bool isFiniteNumber(double x){
	// To test whether a double variable contains a finite number
	// i.e. not a NaN and not an infinity
	// Note: any comparisons involving NaN always fail.
	return (x<=numeric_limits<double>::max() && x>=-numeric_limits<double>::max());
}

// basic type names (redefine if your bit lengths don't match)

typedef int Int; // 32 bit integer
typedef unsigned int Uint;

#ifdef _MSC_VER
typedef __int64 Llong; // 64 bit integer
typedef unsigned __int64 Ullong;
#else
typedef long long int Llong; // 64 bit integer
typedef unsigned long long int Ullong;
#endif

typedef char Char; // 8 bit integer
typedef unsigned char Uchar;

typedef double Doub; // default floating type
typedef long double Ldoub;

typedef complex<double> Complex; // default complex type

typedef bool Bool;

// NaN: uncomment one of the following 3 methods of defining a global NaN
// you can test by verifying that (NaN != NaN) is true

//static const Doub NaN = numeric_limits<Doub>::quiet_NaN();

//Uint proto_nan[2]={0xffffffff, 0x7fffffff};
//double NaN = *( double* )proto_nan;

//Doub NaN = sqrt(-1.);

// Floating Point Exceptions for Microsoft compilers

#ifdef _TURNONFPES_
#ifdef _MSC_VER
struct turn_on_floating_exceptions {
	turn_on_floating_exceptions() {
		int cw = _controlfp( 0, 0 );
		cw &=~(EM_INVALID | EM_OVERFLOW | EM_ZERODIVIDE );
		_controlfp( cw, MCW_EM );
	}
};
turn_on_floating_exceptions yes_turn_on_floating_exceptions;
#endif /* _MSC_VER */
#endif /* _TURNONFPES */

#endif /* _LYXDEF_H_ */

