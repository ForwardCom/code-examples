/****************************  hello.as  **************************************
* Author:        Agner Fog
* date created:  2018-02-23
* Version:       1.00
* Project:       ForwardCom example, assembly code
* Description:   Hello world example
*
* Copyright 2018 GNU General Public License http://www.gnu.org/licenses
*****************************************************************************/

const section read ip                            // read-only data section
hello: int8 "\nHello ForwardCom world!", 0       // char string with terminating zero
const end

code section execute align = 4                   // code section

extern _puts: function                           // library function: write string to stdout

_main function public
int64 r0 = address([hello])                      // calculate address of string
call _puts                                       // call puts. parameter is in r0
int64 r0 = 0                                     // program return value
return                                           // return from main
_main end

code end