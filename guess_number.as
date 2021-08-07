/************************  guess_number.as  **********************************
* Author:        Agner Fog
* date created:  2018-02-23
* last modified: 2021-08-04
* Version:       1.11
* Project:       ForwardCom example, assembly code
* Description:   Guessing game. Guess a number 1 - 100
*
* Copyright 2018-2021 GNU General Public License http://www.gnu.org/licenses
*****************************************************************************/

%buffersize = 0x20                               // size of input text buffer
%maxnum = 100                                    // maximum number

const section read ip                            // read-only data section
intro:    int8 "\nGuessing game. Guess a number 1 - %i\n",0  // format string
guess:    int8 "Your guess:",0                               // text
smaller:  int8 "\nSmaller",0                                 // text
bigger:   int8 "\nBigger",0                                  // text
conclude: int8 "\nYou guessed the number %i in %i tries",0   // format string
another:  int8 "\nAnother? (y/n) ",0                         // text
goodbye:  int8 "\nGoodbye", 0                                // text
const end

bss section datap uninitialized                  // uninitialized read/write data section
int64 parlist[4]                                 // parameter list for printf
int8 buf[buffersize]                             // input buffer
bss end

code section execute                             // code section

extern _puts: function                           // library function: write string to stdout
extern _gets_s: function                         // library function: read string from stdin
extern _printf: function                         // library function: formatted output to stdout
extern _atoi: function                           // library function: convert string to integer
extern _divide_int: function                     // library function: divide intergers (if core has no division instruction)

_main function public                            // program begins here
do {                                             // loop to repeat game
   int64 r0 = address([intro])                   // format string to printf
   int64 r1 = address([parlist])                 // parameter list
   int32 [r1] = maxnum                           // put maxnum in parameter list
   call _printf                                  // printf("\nguess a number 1 - %i\n", maxnum);
   int32 r0 = read_perf(perf1,1)                 // read CPU clock counter to use as a random number
   uint32 r0 = abs(r0,1)                         // avoid negative numbers
   //call _time                                  // or use time as random number
   // get number modulo maxnum (0 - 99)
   //uint32 r1 = r0 % maxnum                     // use this if core has division instruction
   int32 r1 = maxnum
   call _divide_int                              // this function returns a/b in r0 and a%b in r1
   
   int32 r16 = r1 + 1                            // number to guess (1 - 100)
   for (int64 r17 = 1; ; r17++) {                // loop to guess number. no exit condition here
      int64 r0 = address([guess])
      call _puts                                 // write "your guess"
      int64 r0 = address([buf]) 
      int64 r1 = buffersize
      call _gets_s                               // read input into buffer
      int64 r0 = address([buf]) 
      call _atoi                                 // convert string to integer
      if (int32 r0 == r16) {break}               // guess is correct. stop 'for' loop
      if (int32 r16 < r0) {                      // select text: "smaller" or "bigger"
         int64 r0 = address([smaller]) 
      }
      else {
         int64 r0 = address([bigger]) 
      }
      call _puts                                 // write "smaller" or "bigger"
   }

   // guessing loop is finished
   int64 r0 = address([conclude])                // format string for printf
   int64 r1 = address([parlist])                 // parameter list
   int32 [r1] = r16                              // put guessed number in parameter list
   int32 [r1+8] = r17                            // put number of tries in parameter list
   call  _printf                                 // printf("\nyou guessed the number %i in %i tries", r16, r17)
 
   int64 r0 = address([another])
   call  _puts                                   // write "\nanother? (y/n) "
   int64 r0 = address([buf]) 
   int64 r1 = buffersize
   call  _gets_s                                 // read answer into buffer
   int8  r0 = [buf]                              // get first character of answer, ignore the rest
   int8+ r0 |= 0x20                              // convert to lower case
}
while (int8 r0 == 'y')                           // repeat 'do' loop if answer is "y"

int64 r0 = address([goodbye]) 
call _puts                                       // write "goodbye"

int r0 = 0                                       // program return value
return                                           // return from main
_main end

code end