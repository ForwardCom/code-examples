rem @echo off
rem Assemble, link, and run an example ForwardCom assembly file
rem Usage: make_example hello

rem make_example.bat
rem By Agner Fog 2023-01-08

set forwx="..\forw\x64\Release\forw.exe"

rem Assemble:
%forwx% -ass %1.as
if errorlevel 1 pause

rem Link:
%forwx% -link %1.ex %1.ob ..\libraries\libc_light.li ..\libraries\libc.li ..\libraries\math.li
if errorlevel 1 pause

rem Execute:
rem echo: 
rem echo Running %1.ex:
%forwx% -emu %1.ex -list=out.txt

pause