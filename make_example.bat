@echo off
rem Assemble, link, and run an example ForwardCom assembly file
rem Usage: make_example hello

rem make_example.bat
rem By Agner Fog 2018-03-30


rem Assemble:
forw -ass %1.as
if errorlevel 1 pause

rem Link:
forw -link %1.ex %1.ob libc.li math.li
if errorlevel 1 pause

rem Execute:
echo: 
echo Running %1.ex:
forw -emu %1.ex -list=out.txt

rem pause