/****************************  sumarray.as  ***********************************
* Author:        Agner Fog
* date created:  2018-02-24
* Version:       1.00
* Project:       ForwardCom example, assembly code
* Description:   Calculates the sum of the numbers from 1 to 100
*
* This code will fill an array with the numbers from 1 to 100 and then
* calculate the sum. The purpose is to show how the variable-length vector
* instructions work. 
* The expected result is the mean times the number: (1+100)*100/2 = 5050.
*
* Copyright 2018 GNU General Public License http://www.gnu.org/licenses
*****************************************************************************/

%num = 100                                       // number of array elements

const section read ip                            // read-only data section
conclude: int8 "\nThe sum of numbers from 1 to %i is %i\n",0 // format string for printf
const end

bss section datap uninitialized                  // uninitialized read/write data section
int32 myarray[num]                               // array of 100 integers
int64 parlist[4]                                 // parameter list for printf
bss end

code section execute align = 4                   // code section

extern _printf: function                         // library function: formatted output to stdout

_main function public                            // program begins here

// Step 1: Fill myarray with numbers 1 .. 100

int64 r0 = num                                   // = 100
int32 v1 = make_sequence(r0, 1)                  // will be (1, 2, 3, ...) up to as much as the maximum vector length allows, or 100
int64 r1 = get_len(v1)                           // length of vector in bytes
int32 v2 = rotate_up(r1, v1)                     // get last element into the first position of the vector
int32 v2 = broad(r1, v2)                         // broadcast this element to all vector positions

// A vector loop needs a pointer to the end of the array
int64 r2 = address([myarray+num*4])              // address of the end of myarray
int64 r1 = num * 4                               // total array size in bytes

// This loop will count down r1 with the maximum length until the array is filled
// The last iteration will automatically get fewer elements if the array size is not divisible by the maximum length
for (int32 v1 in [r2-r1]) {
   int32 [r2-r1, length = r1] = v1               // put as many elements into the array as the maximum length permits
   int32 v1 += v2                                // add up the vector of sequential numbers
}

// Step 2: Calculate the sum of all elements in the array
int32 v0 = broadcast_max(0)                      // make a vector of all zeroes and maximum length
int64 r1 = num * 4                               // total array size in bytes

// vector loop, counting down r1 with the maximum length until the array is filled
for (int32 v0 in [r2-r1]) {
   int32 v0 += [r2-r1, length = r1]              // add elements to vector
}

// Step 3: Calculate the horizontal sum of the elements in v0
int32 r1 = get_len(v0)                           // length of vector in bytes
// Round up the vector length to the nearest power of 2. 
// The maximum vector length is known to be a power of 2,
// but the length may be 'num' elements, which is not a power of 2
int32 r1 = round_u2(r1)                          // r1 is now a power of 2, not bigger than the maximum vector length
int32 v0 = set_len(r1, v0)                       // adjust vector length to nearest higher power of 2. Added elements will be zero
while (uint32+ r1 > 4) {                         // loop to calculate horizontal sum
   uint32+ r1 >>= 1                              // the vector length is halved
   int32 v1 = shift_reduce (r1, v0)              // get upper half of vector
   // Add upper half and lower half
   // The result vector has the length of the first operand, which will be halved each iteration
   int32 v0 = v1 + v0
}
// The sum is now a scalar in v0

// Step 4: Write the result
int64 r0 = address([conclude])                   // format string for printf
int64 r1 = address([parlist])                    // parameter list
int32 [r1] = num                                 // put number into parameter list
int32 [r1+8, scalar] = v0                        // put result into parameter list
call _printf                                     // printf("\nThe sum of numbers from 1 to %i is %i", num, v0)

// Return from main
int64 r0 = 0                                     // program return value
return                                           // return from main
_main end

code end