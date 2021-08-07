/*************************  trigonometric.as  *********************************
* Author:        Agner Fog
* date created:  2018-02-29
* last modified: 2020-04-24
* Version:       1.09
* Project:       ForwardCom example, assembly code
* Description:   Makes a table of sine, cosine, and tangent
*                Uses a simple loop without vectorization
*
* Link with libraries libc.li and math.li
*
* Copyright 2018-2020 GNU General Public License http://www.gnu.org/licenses
*****************************************************************************/

const section read ip                            // read-only data section
intro: int8 "\n   x        sin(x)        cos(x)        tan(x)",0  // table heading
form: int8 "\n%6.3f  %12.8f  %12.8f  %12.8f",0   // format string for printf
newline: int8 "\n",0                             // newline
const end

bss section datap uninitialized                  // uninitialized read/write data section
int64 parlist[5]                                 // parameter list for printf
bss end

code section execute align = 4                   // code section

extern _sincosf: function, reguse = 0, 0x7BF      // library function: sine and cosine in radians
extern _printf: function                         // library function: formatted output to stdout
extern _puts:   function                         // library function: print string to stdout

_main function public                            // program begins here

int64 r0 = address([intro])
call _puts

for (double v12 = -1; v12 < 4; v12 += 0.1) {     // loop
   double v0 = compress(v12, 0)
   float v0 = v0
   call _sincosf                                  // sin(x) in v0, cos(x) in v1
   double v0 = expand(v0, 0)
   double v1 = expand(v1, 0)
   double v2 = v0 / v1                           // tan(x) = sin(x) / cos(x)
   int64 r0 = address([form])                    // format string
   int64 r1 = address([parlist])                 // parameter list for _printf
   double [parlist,    scalar] = v12             // x
   double [parlist+8,  scalar] = v0              // sin(x)
   double [parlist+16, scalar] = v1              // cos(x)
   double [parlist+24, scalar] = v2              // tan(x)
   call _printf                                  // print formatted results
}

int64 r0 = address([newline])                    // end with newline
call _puts

int64 r0 = 0                                     // program return value
return                                           // return from main
_main end

code end