# code-examples
Code examples for ForwardCom

Prerequisites:
* ForwardCom executable (Windows: forw.exe, Linus: forw)
* Instruction list: instruction_list.csv
* Function libraries: libc.li math.li

Assemble:
> forw -ass hello.as

Link:
> forw -link hello.ob libc.li math.li

Execute:
> forw -emu hello.ex
