######################################################################
#
# File name : bufferTB_simulate.do
# Created on: Thu Jul 11 12:58:11 -0500 2019
#
# Auto generated by Vivado for 'behavioral' simulation
#
######################################################################
transcript on
quiet on
createdesign {ADC_Test} {C:/Users/xtjac/Documents/ADC_Test/ADC_Test.sim/sim_1/behav/activehdl}
opendesign {C:/Users/xtjac/Documents/ADC_Test/ADC_Test.sim/sim_1/behav/activehdl/ADC_Test/ADC_Test.adf}
set SIM_WORKING_FOLDER $dsn/..
set worklib ADC_Test

vmap xil_defaultlib {C:/Users/xtjac/Documents/ADC_Test/ADC_Test.sim/sim_1/behav/activehdl/activehdl/xil_defaultlib}
quiet off
asim -asdb +access +r -L unisims_ver -L unimacro_ver -L secureip -L xil_defaultlib -L fifo_generator_v13_2_4 -O5 -L xpm -dbg +access +r xil_defaultlib.bufferTB xil_defaultlib.glbl

log -rec *
log /glbl/GSR
if { ![batch_mode] } {
	wave *
}

run 1000ns
if [batch_mode] {
	endsim
	quit
}