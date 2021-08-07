/****************************  hello.as  **************************************
* Author:        Agner Fog
* date created:  2018-02-23
* last modified: 2021-08-04
* Version:       1.11
* Project:       ForwardCom example, assembly code
* Description:   Hello world example
*
* Copyright 2018-2021 GNU General Public License http://www.gnu.org/licenses
*****************************************************************************/

extern _puts: function                           // library function: write string to stdout

const section read ip                            // read-only data section
hello: int8 "\nHello ForwardCom world!", 0       // char string with terminating zero
const end

code section execute                             // executable code section

_main function public                            // program start

// breakpoint                                    // uncomment this if you want to wait for user to press run

int64 r0 = address([hello])                      // calculate address of string
call _puts                                       // call puts. parameter is in r0
int r0 = 0                                       // program return value
return                                           // return from main

_main end

code end