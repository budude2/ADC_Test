@echo off
set bin_path=C:\\Aldec\\Active-HDL-Student-Edition\\BIN
call "%bin_path%/avhdl" -do "do -tcl {bufferTB_simulate.do}"
set error=%errorlevel%
copy /Y "C:\Users\xtjac\Documents\ADC_Test\ADC_Test.sim\sim_1\behav\activehdl\ADC_Test\log\console.log" "simulate.log"
set errorlevel=%error%
exit %errorlevel%
