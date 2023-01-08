# code-examples
Code examples for ForwardCom

Prerequisites:
* ForwardCom executable (Windows: forw.exe, Linux: forw)
* Instruction list: instruction_list.csv
* Function libraries: libc.li math.li

Assemble:
> forw -ass hello.as

Link:
> forw -link hello.ex hello.ob libc_light.li libc.li math.li

Emulate:
> forw -emu hello.ex

A script doing all this in Windows:
> make_example.bat hello

Or in Linux: 
>./make_example.sh hello

Run:
>Some of these examples can run in a softcore when linked with libc-light.li. 
>See the manual for the softcore


You can find more code examples under test-suite and libraries.

##

Files included |  Description
--- | ---
hello.as  |  Simple Hello world example. Works on emulator and softcore
calculator.as   |    Inputs two integers and calculates +-*/% operations. Works on emulator and softcore
guess_number.as  |   Guessing game. Works on emulator and softcore
event.as  |   Demonstrates the event handling system. Works on emulator
sumarray.as  |  Calculate sum of array elements using vector loop 
trigonometric-f.as  |  Calculates trigonometric functions with single precision. Works on emulator
trigonometric.as  |  Calculates trigonometric functions with double precision. Works on emulator
integrate.as  |  Integration of sin function. Works on emulator
make_example.bat  |   Windows bat file for compiling and linking example
make_example.sh  |  Linux shell script for compiling and linking example
test_arithmetics.as  |  Test arithmetic instructions on softcore
test_bool_bit.as  |  Test boolean and bit-manipulation instructions on softcore
test_branch.as  |  Test branch instructions on softcore
test_formats.as  |  Test all instruction formats on softcore
test_muldiv.as  |  Test integer multiplication and division instructions on softcore
test_pipeline_stalls.as  |  Test if pipeline stalls are handled correctly on softcore
test_pushpop.as  |  Test push and pop instructions on softcore


