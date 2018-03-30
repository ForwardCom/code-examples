# code-examples
Code examples for ForwardCom

Prerequisites:
* ForwardCom executable (Windows: forw.exe, Linux: forw)
* Instruction list: instruction_list.csv
* Function libraries: libc.li math.li

Assemble:
> forw -ass hello.as

Link:
> forw -link hello.ex hello.ob libc.li math.li

Execute:
> forw -emu hello.ex


A script doing all this in Windows:
> make_example.bat hello

Or in Linux: 
>./make_example.sh hello


You can find more code examples under libraries.
