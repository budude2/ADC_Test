@echo off
set bin_path=C:\\Aldec\\Active-HDL-Student-Edition\\BIN
call "%bin_path%/VSimSA" -l "compile.log" -do "do -tcl bufferTB_compile.do"
exit %errorlevel%
