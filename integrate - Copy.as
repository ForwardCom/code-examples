/***************************  integrate.as  ***********************************
* Author:        Agner Fog
* date created:  2018-02-30
* Version:       1.00
* Project:       ForwardCom example, assembly code
* Description:   Numerical integration of sin(x) from 0 to pi/2
*
* Link with libraries libc.li and math.li
*
* Copyright 2018 GNU General Public License http://www.gnu.org/licenses
*****************************************************************************/

// define parameters. you may change these
% npoints = 8                          // number of function points to calculate. must be a power of 2
% M_PI = 3.14159265358979323846        // pi
% startvalue = 0                       // start of x interval
% endvalue = M_PI / 2                  // end of x interval



const section read ip                  // read-only data section
// format string for printf
form: int8 "\nNumerical integration of sin(x) from %f to %f "
      int8 "with %i function points."
      int8 "\nThe result is %.15f\n",0
const end

bss section datap uninitialized        // uninitialized read/write data section
int64 parlist[8]                       // parameter list for printf
bss end

code section execute align = 4         // code section

extern _sin: function                  // library function: sine in radians
extern _integrate: function            // library function: numerical integration
extern _printf: function               // library function: formatted output to stdout

_main function public                  // program begins here

double v0 = startvalue                 // x interval start
double v1 = endvalue                   // x interval end
int64  r0 = address([_sin])            // function pointer
int64  r1 = npoints                    // number of x points
call _integrate                        // integrate sin(x)

// print results
int64  r0 = address([form])            // format string for printf
int64  r1 = address([parlist])         // parameter list for printf
double v1 = startvalue                 // parameters
double v2 = endvalue
int32+ r2 = npoints
double [r1,    scalar] = v1            // put parameters into variable argument list for printf
double [r1+8,  scalar] = v2
int64  [r1+16        ] = r2
double [r1+24, scalar] = v0
call _printf                           // print results

int64 r0 = 0                           // program return value
return                                 // return from main
_main end

code end
