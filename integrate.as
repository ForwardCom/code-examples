/*******************************  integrate.as  *******************************
* Author:        Agner Fog
* date created:  2018-03-30
* Last modified: 2020-04-24
* Version:       1.09
* Project:       ForwardCom library math.li
* Description:   Numerical integration of a function f(x) over a given x-interval
*                Uses 4-point Gauss-Legendre integration method
*
* Parameters:
* v0 = start of x interval, double scalar
* v1 = end   of x interval, double scalar
* r0 = function pointer
* r1 = number of function points, int32
* r2 = method. currently unused
* r3 = optional extra parameter to the function, can be integer or pointer
* return value: double scalar in v0
* will return NAN if the maximum vector length is less than 256 bits or if the function returns NAN
*
* The function that is integrated is pointed to by r0. This function must take a double vector
* as input and return a double vector as results. It can have one optional extra parameter which
* can be an integer or a pointer. The function must conform to the default register use.
*
* The number of function points will be rounded up to a power of 2 or a multiple of the maximum
* vector length. It must be at least 4.
*
* Copyright 2018-2020 GNU General Public License http://www.gnu.org/licenses
*****************************************************************************/

// define constants
%xval1   = 0.861136311594                        // x-values for 4-point Gauss-Legendre integration
%xval2   = 0.339981043585
%weight1 = 0.347854845137                        // weights  for 4-point Gauss-Legendre integration
%weight2 = 0.652145154863
%nan     = 0x7FF8100000000000                    // NAN error return

const section read ip                            // read-only data section
xvals:   double (1-xval1)/2, (1-xval2)/2, (1+xval2)/2, (1+xval1)/2  // x-points in interval from 0 - 1
weights: double weight1/2, weight2/2, weight2/2, weight1/2          // corresponding weights
const end

code section execute align = 4                   // code section

_integrate function public
push (r16, r17, r18, v16, v17, v18, v19)         // save registers
int64  r16 = r0                                  // function pointer
int64  r18 = r3                                  // save optional extra parameter to function
if (int32 r1 < 4) {
   int32+ r1 = 4                                 // must have at least 4 points
}
double v2 = broadcast_max(0)                     // find maximum vector length
int64 r3 = get_num(v2)                           // maximum elements
if (int32 r1 < r3) {                             // number fits into a single vector
   int32  r1 = roundp2(r1, 1)                    // round up to nearest power of 2
}
else {                                           // more than one vector needed
   int32 r1 = r1 + r3 - 1                        // round up to nearest multiple of maximum vector length
   int32 r3 = -r3
   int32+ r1 &= r3
}
uint32+ r3 = r1 >> 2                             // number of steps, nsteps = points / 4
int64  r0 = 4*8                                  // length of one step
int64  r2 = r3 * r0                              // total length, bytes
double v16 = [xvals,   length = r0]              // x values for one step
double v17 = [weights, length = r0]              // weights for one step
int64 r4 = get_len(v16)
if (int64 r4 < r0) {                             // maximum vector length is insufficient for one step. a fix for this is not implemented
   int64 v0 = nan                                // return NAN to indicate error
   jump ERROREXIT
}
double v18 = v1 - v0                             // length of x interval
int64  v2  = gp2vec(r3)                          // number of steps
double v2  = int2float(v2, 0)                    // same, as float
double v18 /= v2                                 // x-step size = length / nsteps
double v18 = broad(r2, v18)                      // broadcast x-step size
double v16 *= v18                                // first 4 x-values relative to start
double v0  = broad(r2, v0)                       // broadcast x start value
double v16 += v0                                 // first 4 x-values
double v17 *= v18                                // multiply weights by step size
double v16 = repeat_block(r2, v16, 4*8)          // repeat x-values block nsteps times or until the maximum vector length
double v17 = repeat_block(r2, v17, 4*8)          // repeat weights  block nsteps times or until the maximum vector length

int64  v2  = make_sequence(r1, 0)                // 0, 1, 2, ..
int64  v2  >>= 2                                 // 0, 0, 0, 0, 1, 1, 1, 1, 2, 2, 2, 2, ...
double v2 = int2float(v2, 0)                     // same, as double
double v2 *= v18                                 // multiply by x-step size
double v16 += v2                                 // make each x block = previous block + x-step size

int64  r3 = get_len(v2)                          // actual vector length
double v2 = rotate_up(r3, v2)                    // get last addend of last block
double v2 += v18                                 // start value for next x vector
double v19 = broad(r3, v2)                       // (x-step size) * (steps per vector). add this to x vector to get next x vector

uint32 r17 = r2 / r3                             // number of iterations
double v18 = replace(v16, 0)                     // vector of zeroes for summation

// calculation loop. calculate as many function values per iteration as the maximum vector length allows
while (int32+ r17 > 0) {
   double v0 = v16                               // x-values
   int64  r0 = r18                               // optional extra parameter
   call (r16)                                    // function(x)
   double v0  *= v17                             // multiply results by weights
   double v18 += v0                              // summation
   double v16 += v19                             // next vector of x-values
   int32+ r17--                                  // loop counter
}

// the sums are in v18. make horizontal sum
int64  r2 = get_len(v18)                         // vector length
while (uint64 r2 > 8) {                          // loop to calculate horizontal sum
   uint64 r2 >>= 1                               // the vector length is halved
   double v1 = shift_reduce(r2, v18)             // get upper half of vector
   double v18 = v1 + v18                         // Add upper half and lower half
}
double v0 = v18                                  // return value
ERROREXIT:
pop (v19, v18, v17, v16, r18, r17, r16)          // restore registers
return
_integrate end

code end
