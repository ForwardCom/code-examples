/****************************  events.as  *************************************
* Author:        Agner Fog
* date created:  2018-03-23
* Last modified: 2018-03-23
* Version:       1.00
* Project:       ForwardCom example
* Description:   Test event handler system
*
* Copyright 2018 GNU General Public License http://www.gnu.org/licenses
******************************************************************************/

// define event IDs
%EVT_CONSTRUCT = 1           // call static constructors and initialization procedures before calling main
%EVT_DESTRUCT  = 2           // call static destructors and clean up after return from main
%EVT_MY_DEF    = 0x100       // arbitrary user-defined event id
%KEY           = 1           // arbitrary key for my event
%DEFAULT_PRIORITY = 0x1000   // default event priority

/*
   Event records must be stored in a special read-only section with attribute 'event_hand'.
   These records will be reordered and combined by the linker.
   Each record contains:
   1. A scaled relative pointer to the event handler function
   2. Event priority
   3. Key
   4. Event ID
*/
events section read event_hand
int32 (constructor-__ip_base)/4, DEFAULT_PRIORITY,   0,   EVT_CONSTRUCT
int32 (destructor-__ip_base)/4,  DEFAULT_PRIORITY,   0,   EVT_DESTRUCT
int32 (event1-__ip_base)/4,      DEFAULT_PRIORITY,   KEY, EVT_MY_DEF
int32 (event2-__ip_base)/4,      DEFAULT_PRIORITY+1, KEY, EVT_MY_DEF
events end


const section read ip                            // read-only data section
// char strings with terminating zero
hello:  int8 "\nMain called", 0                   
constr: int8 "\nTesting event handler system:\n\n\nConstructor called", 0                   
destr:  int8 "\nDestructor called\n\n", 0                   
texte1: int8 "\nEvent handler 1 called", 0                   
texte2: int8 "\nEvent handler 2 called (higher priority)", 0                   
const end

code section execute align = 4                   // code section

extern __ip_base: ip                             // reference point
extern _puts: function                           // library function: write string to stdout
extern _raise_event: function                    // library function: make an event

_main function public                            // main is the program entry called by the startup code
int64 r0 = address([hello])                      // calculate address of string
call _puts                                       // call puts: write string pointed to by r0
// now create an event with key 1 and event ID = EVT_MY_DEF
int64 r0 = KEY + (EVT_MY_DEF << 32)              // constant expression calculated by assembler
call _raise_event                                // make the event

int64 r0 = 0                                     // program return value
return
_main end

// this function is assigned to the EVT_CONSTRUCT event to be called before main
constructor function
int64 r0 = address([constr])                     // calculate address of string
call _puts                                       // call puts. parameter is in r0
int64 r0 = 1                                     // return 1 to allow further event handlers
return
constructor end

// this function is assigned to the EVT_DESTRUCT event to be called after main
destructor function
int64 r0 = address([destr])                      // calculate address of string
call _puts                                       // call puts. parameter is in r0
int64 r0 = 1                                     // return 1 to allow further event handlers
return
destructor end

// this function is assigned to the user-defined EVT_MY_DEF event to be called at this custum event
event1 function
int64 r0 = address([texte1])                     // calculate address of string
call _puts                                       // call puts. parameter is in r0
int64 r0 = 1                                     // return 1 to allow further event handlers
return
event1 end

// this function is also assigned to the user-defined EVT_MY_DEF, but with a higher priority. It will be called first
event2 function
int64 r0 = address([texte2])                     // calculate address of string
call _puts                                       // call puts. parameter is in r0
int64 r0 = 1                                     // return 1 to allow further event handlers
return
event2 end

code end