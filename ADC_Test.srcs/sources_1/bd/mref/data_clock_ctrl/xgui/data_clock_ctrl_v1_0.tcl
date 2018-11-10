# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "CLKFBOUT_MULT_F" -parent ${Page_0}
  ipgui::add_param $IPINST -name "CLKOUT1_DIVIDE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "CLKOUT1_PHASE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "CLKOUT2_DIVIDE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "CLKOUT2_PHASE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "DIVCLK_DIVIDE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "R1_MAX" -parent ${Page_0}
  ipgui::add_param $IPINST -name "R2_MAX" -parent ${Page_0}
  ipgui::add_param $IPINST -name "R3_MAX" -parent ${Page_0}
  ipgui::add_param $IPINST -name "R4_MAX" -parent ${Page_0}
  ipgui::add_param $IPINST -name "S1_CLKFBOUT_MULT" -parent ${Page_0}
  ipgui::add_param $IPINST -name "S1_CLKOUT1_DIVIDE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "S1_CLKOUT1_PHASE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "S1_CLKOUT2_DIVIDE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "S1_CLKOUT2_PHASE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "S1_DIVCLK_DIVIDE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "S2_CLKFBOUT_MULT" -parent ${Page_0}
  ipgui::add_param $IPINST -name "S2_CLKOUT1_DIVIDE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "S2_CLKOUT1_PHASE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "S2_CLKOUT2_DIVIDE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "S2_CLKOUT2_PHASE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "S2_DIVCLK_DIVIDE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "S3_CLKFBOUT_MULT" -parent ${Page_0}
  ipgui::add_param $IPINST -name "S3_CLKOUT1_DIVIDE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "S3_CLKOUT1_PHASE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "S3_CLKOUT2_DIVIDE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "S3_CLKOUT2_PHASE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "S3_DIVCLK_DIVIDE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "S4_CLKFBOUT_MULT" -parent ${Page_0}
  ipgui::add_param $IPINST -name "S4_CLKOUT1_DIVIDE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "S4_CLKOUT1_PHASE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "S4_CLKOUT2_DIVIDE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "S4_CLKOUT2_PHASE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "S4_DIVCLK_DIVIDE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "S5_CLKFBOUT_MULT" -parent ${Page_0}
  ipgui::add_param $IPINST -name "S5_CLKOUT1_DIVIDE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "S5_CLKOUT1_PHASE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "S5_CLKOUT2_DIVIDE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "S5_CLKOUT2_PHASE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "S5_DIVCLK_DIVIDE" -parent ${Page_0}


}

proc update_PARAM_VALUE.CLKFBOUT_MULT_F { PARAM_VALUE.CLKFBOUT_MULT_F } {
	# Procedure called to update CLKFBOUT_MULT_F when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.CLKFBOUT_MULT_F { PARAM_VALUE.CLKFBOUT_MULT_F } {
	# Procedure called to validate CLKFBOUT_MULT_F
	return true
}

proc update_PARAM_VALUE.CLKOUT1_DIVIDE { PARAM_VALUE.CLKOUT1_DIVIDE } {
	# Procedure called to update CLKOUT1_DIVIDE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.CLKOUT1_DIVIDE { PARAM_VALUE.CLKOUT1_DIVIDE } {
	# Procedure called to validate CLKOUT1_DIVIDE
	return true
}

proc update_PARAM_VALUE.CLKOUT1_PHASE { PARAM_VALUE.CLKOUT1_PHASE } {
	# Procedure called to update CLKOUT1_PHASE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.CLKOUT1_PHASE { PARAM_VALUE.CLKOUT1_PHASE } {
	# Procedure called to validate CLKOUT1_PHASE
	return true
}

proc update_PARAM_VALUE.CLKOUT2_DIVIDE { PARAM_VALUE.CLKOUT2_DIVIDE } {
	# Procedure called to update CLKOUT2_DIVIDE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.CLKOUT2_DIVIDE { PARAM_VALUE.CLKOUT2_DIVIDE } {
	# Procedure called to validate CLKOUT2_DIVIDE
	return true
}

proc update_PARAM_VALUE.CLKOUT2_PHASE { PARAM_VALUE.CLKOUT2_PHASE } {
	# Procedure called to update CLKOUT2_PHASE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.CLKOUT2_PHASE { PARAM_VALUE.CLKOUT2_PHASE } {
	# Procedure called to validate CLKOUT2_PHASE
	return true
}

proc update_PARAM_VALUE.DIVCLK_DIVIDE { PARAM_VALUE.DIVCLK_DIVIDE } {
	# Procedure called to update DIVCLK_DIVIDE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DIVCLK_DIVIDE { PARAM_VALUE.DIVCLK_DIVIDE } {
	# Procedure called to validate DIVCLK_DIVIDE
	return true
}

proc update_PARAM_VALUE.R1_MAX { PARAM_VALUE.R1_MAX } {
	# Procedure called to update R1_MAX when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.R1_MAX { PARAM_VALUE.R1_MAX } {
	# Procedure called to validate R1_MAX
	return true
}

proc update_PARAM_VALUE.R2_MAX { PARAM_VALUE.R2_MAX } {
	# Procedure called to update R2_MAX when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.R2_MAX { PARAM_VALUE.R2_MAX } {
	# Procedure called to validate R2_MAX
	return true
}

proc update_PARAM_VALUE.R3_MAX { PARAM_VALUE.R3_MAX } {
	# Procedure called to update R3_MAX when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.R3_MAX { PARAM_VALUE.R3_MAX } {
	# Procedure called to validate R3_MAX
	return true
}

proc update_PARAM_VALUE.R4_MAX { PARAM_VALUE.R4_MAX } {
	# Procedure called to update R4_MAX when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.R4_MAX { PARAM_VALUE.R4_MAX } {
	# Procedure called to validate R4_MAX
	return true
}

proc update_PARAM_VALUE.S1_CLKFBOUT_MULT { PARAM_VALUE.S1_CLKFBOUT_MULT } {
	# Procedure called to update S1_CLKFBOUT_MULT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.S1_CLKFBOUT_MULT { PARAM_VALUE.S1_CLKFBOUT_MULT } {
	# Procedure called to validate S1_CLKFBOUT_MULT
	return true
}

proc update_PARAM_VALUE.S1_CLKOUT1_DIVIDE { PARAM_VALUE.S1_CLKOUT1_DIVIDE } {
	# Procedure called to update S1_CLKOUT1_DIVIDE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.S1_CLKOUT1_DIVIDE { PARAM_VALUE.S1_CLKOUT1_DIVIDE } {
	# Procedure called to validate S1_CLKOUT1_DIVIDE
	return true
}

proc update_PARAM_VALUE.S1_CLKOUT1_PHASE { PARAM_VALUE.S1_CLKOUT1_PHASE } {
	# Procedure called to update S1_CLKOUT1_PHASE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.S1_CLKOUT1_PHASE { PARAM_VALUE.S1_CLKOUT1_PHASE } {
	# Procedure called to validate S1_CLKOUT1_PHASE
	return true
}

proc update_PARAM_VALUE.S1_CLKOUT2_DIVIDE { PARAM_VALUE.S1_CLKOUT2_DIVIDE } {
	# Procedure called to update S1_CLKOUT2_DIVIDE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.S1_CLKOUT2_DIVIDE { PARAM_VALUE.S1_CLKOUT2_DIVIDE } {
	# Procedure called to validate S1_CLKOUT2_DIVIDE
	return true
}

proc update_PARAM_VALUE.S1_CLKOUT2_PHASE { PARAM_VALUE.S1_CLKOUT2_PHASE } {
	# Procedure called to update S1_CLKOUT2_PHASE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.S1_CLKOUT2_PHASE { PARAM_VALUE.S1_CLKOUT2_PHASE } {
	# Procedure called to validate S1_CLKOUT2_PHASE
	return true
}

proc update_PARAM_VALUE.S1_DIVCLK_DIVIDE { PARAM_VALUE.S1_DIVCLK_DIVIDE } {
	# Procedure called to update S1_DIVCLK_DIVIDE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.S1_DIVCLK_DIVIDE { PARAM_VALUE.S1_DIVCLK_DIVIDE } {
	# Procedure called to validate S1_DIVCLK_DIVIDE
	return true
}

proc update_PARAM_VALUE.S2_CLKFBOUT_MULT { PARAM_VALUE.S2_CLKFBOUT_MULT } {
	# Procedure called to update S2_CLKFBOUT_MULT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.S2_CLKFBOUT_MULT { PARAM_VALUE.S2_CLKFBOUT_MULT } {
	# Procedure called to validate S2_CLKFBOUT_MULT
	return true
}

proc update_PARAM_VALUE.S2_CLKOUT1_DIVIDE { PARAM_VALUE.S2_CLKOUT1_DIVIDE } {
	# Procedure called to update S2_CLKOUT1_DIVIDE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.S2_CLKOUT1_DIVIDE { PARAM_VALUE.S2_CLKOUT1_DIVIDE } {
	# Procedure called to validate S2_CLKOUT1_DIVIDE
	return true
}

proc update_PARAM_VALUE.S2_CLKOUT1_PHASE { PARAM_VALUE.S2_CLKOUT1_PHASE } {
	# Procedure called to update S2_CLKOUT1_PHASE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.S2_CLKOUT1_PHASE { PARAM_VALUE.S2_CLKOUT1_PHASE } {
	# Procedure called to validate S2_CLKOUT1_PHASE
	return true
}

proc update_PARAM_VALUE.S2_CLKOUT2_DIVIDE { PARAM_VALUE.S2_CLKOUT2_DIVIDE } {
	# Procedure called to update S2_CLKOUT2_DIVIDE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.S2_CLKOUT2_DIVIDE { PARAM_VALUE.S2_CLKOUT2_DIVIDE } {
	# Procedure called to validate S2_CLKOUT2_DIVIDE
	return true
}

proc update_PARAM_VALUE.S2_CLKOUT2_PHASE { PARAM_VALUE.S2_CLKOUT2_PHASE } {
	# Procedure called to update S2_CLKOUT2_PHASE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.S2_CLKOUT2_PHASE { PARAM_VALUE.S2_CLKOUT2_PHASE } {
	# Procedure called to validate S2_CLKOUT2_PHASE
	return true
}

proc update_PARAM_VALUE.S2_DIVCLK_DIVIDE { PARAM_VALUE.S2_DIVCLK_DIVIDE } {
	# Procedure called to update S2_DIVCLK_DIVIDE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.S2_DIVCLK_DIVIDE { PARAM_VALUE.S2_DIVCLK_DIVIDE } {
	# Procedure called to validate S2_DIVCLK_DIVIDE
	return true
}

proc update_PARAM_VALUE.S3_CLKFBOUT_MULT { PARAM_VALUE.S3_CLKFBOUT_MULT } {
	# Procedure called to update S3_CLKFBOUT_MULT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.S3_CLKFBOUT_MULT { PARAM_VALUE.S3_CLKFBOUT_MULT } {
	# Procedure called to validate S3_CLKFBOUT_MULT
	return true
}

proc update_PARAM_VALUE.S3_CLKOUT1_DIVIDE { PARAM_VALUE.S3_CLKOUT1_DIVIDE } {
	# Procedure called to update S3_CLKOUT1_DIVIDE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.S3_CLKOUT1_DIVIDE { PARAM_VALUE.S3_CLKOUT1_DIVIDE } {
	# Procedure called to validate S3_CLKOUT1_DIVIDE
	return true
}

proc update_PARAM_VALUE.S3_CLKOUT1_PHASE { PARAM_VALUE.S3_CLKOUT1_PHASE } {
	# Procedure called to update S3_CLKOUT1_PHASE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.S3_CLKOUT1_PHASE { PARAM_VALUE.S3_CLKOUT1_PHASE } {
	# Procedure called to validate S3_CLKOUT1_PHASE
	return true
}

proc update_PARAM_VALUE.S3_CLKOUT2_DIVIDE { PARAM_VALUE.S3_CLKOUT2_DIVIDE } {
	# Procedure called to update S3_CLKOUT2_DIVIDE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.S3_CLKOUT2_DIVIDE { PARAM_VALUE.S3_CLKOUT2_DIVIDE } {
	# Procedure called to validate S3_CLKOUT2_DIVIDE
	return true
}

proc update_PARAM_VALUE.S3_CLKOUT2_PHASE { PARAM_VALUE.S3_CLKOUT2_PHASE } {
	# Procedure called to update S3_CLKOUT2_PHASE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.S3_CLKOUT2_PHASE { PARAM_VALUE.S3_CLKOUT2_PHASE } {
	# Procedure called to validate S3_CLKOUT2_PHASE
	return true
}

proc update_PARAM_VALUE.S3_DIVCLK_DIVIDE { PARAM_VALUE.S3_DIVCLK_DIVIDE } {
	# Procedure called to update S3_DIVCLK_DIVIDE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.S3_DIVCLK_DIVIDE { PARAM_VALUE.S3_DIVCLK_DIVIDE } {
	# Procedure called to validate S3_DIVCLK_DIVIDE
	return true
}

proc update_PARAM_VALUE.S4_CLKFBOUT_MULT { PARAM_VALUE.S4_CLKFBOUT_MULT } {
	# Procedure called to update S4_CLKFBOUT_MULT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.S4_CLKFBOUT_MULT { PARAM_VALUE.S4_CLKFBOUT_MULT } {
	# Procedure called to validate S4_CLKFBOUT_MULT
	return true
}

proc update_PARAM_VALUE.S4_CLKOUT1_DIVIDE { PARAM_VALUE.S4_CLKOUT1_DIVIDE } {
	# Procedure called to update S4_CLKOUT1_DIVIDE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.S4_CLKOUT1_DIVIDE { PARAM_VALUE.S4_CLKOUT1_DIVIDE } {
	# Procedure called to validate S4_CLKOUT1_DIVIDE
	return true
}

proc update_PARAM_VALUE.S4_CLKOUT1_PHASE { PARAM_VALUE.S4_CLKOUT1_PHASE } {
	# Procedure called to update S4_CLKOUT1_PHASE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.S4_CLKOUT1_PHASE { PARAM_VALUE.S4_CLKOUT1_PHASE } {
	# Procedure called to validate S4_CLKOUT1_PHASE
	return true
}

proc update_PARAM_VALUE.S4_CLKOUT2_DIVIDE { PARAM_VALUE.S4_CLKOUT2_DIVIDE } {
	# Procedure called to update S4_CLKOUT2_DIVIDE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.S4_CLKOUT2_DIVIDE { PARAM_VALUE.S4_CLKOUT2_DIVIDE } {
	# Procedure called to validate S4_CLKOUT2_DIVIDE
	return true
}

proc update_PARAM_VALUE.S4_CLKOUT2_PHASE { PARAM_VALUE.S4_CLKOUT2_PHASE } {
	# Procedure called to update S4_CLKOUT2_PHASE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.S4_CLKOUT2_PHASE { PARAM_VALUE.S4_CLKOUT2_PHASE } {
	# Procedure called to validate S4_CLKOUT2_PHASE
	return true
}

proc update_PARAM_VALUE.S4_DIVCLK_DIVIDE { PARAM_VALUE.S4_DIVCLK_DIVIDE } {
	# Procedure called to update S4_DIVCLK_DIVIDE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.S4_DIVCLK_DIVIDE { PARAM_VALUE.S4_DIVCLK_DIVIDE } {
	# Procedure called to validate S4_DIVCLK_DIVIDE
	return true
}

proc update_PARAM_VALUE.S5_CLKFBOUT_MULT { PARAM_VALUE.S5_CLKFBOUT_MULT } {
	# Procedure called to update S5_CLKFBOUT_MULT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.S5_CLKFBOUT_MULT { PARAM_VALUE.S5_CLKFBOUT_MULT } {
	# Procedure called to validate S5_CLKFBOUT_MULT
	return true
}

proc update_PARAM_VALUE.S5_CLKOUT1_DIVIDE { PARAM_VALUE.S5_CLKOUT1_DIVIDE } {
	# Procedure called to update S5_CLKOUT1_DIVIDE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.S5_CLKOUT1_DIVIDE { PARAM_VALUE.S5_CLKOUT1_DIVIDE } {
	# Procedure called to validate S5_CLKOUT1_DIVIDE
	return true
}

proc update_PARAM_VALUE.S5_CLKOUT1_PHASE { PARAM_VALUE.S5_CLKOUT1_PHASE } {
	# Procedure called to update S5_CLKOUT1_PHASE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.S5_CLKOUT1_PHASE { PARAM_VALUE.S5_CLKOUT1_PHASE } {
	# Procedure called to validate S5_CLKOUT1_PHASE
	return true
}

proc update_PARAM_VALUE.S5_CLKOUT2_DIVIDE { PARAM_VALUE.S5_CLKOUT2_DIVIDE } {
	# Procedure called to update S5_CLKOUT2_DIVIDE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.S5_CLKOUT2_DIVIDE { PARAM_VALUE.S5_CLKOUT2_DIVIDE } {
	# Procedure called to validate S5_CLKOUT2_DIVIDE
	return true
}

proc update_PARAM_VALUE.S5_CLKOUT2_PHASE { PARAM_VALUE.S5_CLKOUT2_PHASE } {
	# Procedure called to update S5_CLKOUT2_PHASE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.S5_CLKOUT2_PHASE { PARAM_VALUE.S5_CLKOUT2_PHASE } {
	# Procedure called to validate S5_CLKOUT2_PHASE
	return true
}

proc update_PARAM_VALUE.S5_DIVCLK_DIVIDE { PARAM_VALUE.S5_DIVCLK_DIVIDE } {
	# Procedure called to update S5_DIVCLK_DIVIDE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.S5_DIVCLK_DIVIDE { PARAM_VALUE.S5_DIVCLK_DIVIDE } {
	# Procedure called to validate S5_DIVCLK_DIVIDE
	return true
}


proc update_MODELPARAM_VALUE.R4_MAX { MODELPARAM_VALUE.R4_MAX PARAM_VALUE.R4_MAX } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.R4_MAX}] ${MODELPARAM_VALUE.R4_MAX}
}

proc update_MODELPARAM_VALUE.R3_MAX { MODELPARAM_VALUE.R3_MAX PARAM_VALUE.R3_MAX } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.R3_MAX}] ${MODELPARAM_VALUE.R3_MAX}
}

proc update_MODELPARAM_VALUE.R2_MAX { MODELPARAM_VALUE.R2_MAX PARAM_VALUE.R2_MAX } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.R2_MAX}] ${MODELPARAM_VALUE.R2_MAX}
}

proc update_MODELPARAM_VALUE.R1_MAX { MODELPARAM_VALUE.R1_MAX PARAM_VALUE.R1_MAX } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.R1_MAX}] ${MODELPARAM_VALUE.R1_MAX}
}

proc update_MODELPARAM_VALUE.CLKFBOUT_MULT_F { MODELPARAM_VALUE.CLKFBOUT_MULT_F PARAM_VALUE.CLKFBOUT_MULT_F } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.CLKFBOUT_MULT_F}] ${MODELPARAM_VALUE.CLKFBOUT_MULT_F}
}

proc update_MODELPARAM_VALUE.DIVCLK_DIVIDE { MODELPARAM_VALUE.DIVCLK_DIVIDE PARAM_VALUE.DIVCLK_DIVIDE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DIVCLK_DIVIDE}] ${MODELPARAM_VALUE.DIVCLK_DIVIDE}
}

proc update_MODELPARAM_VALUE.CLKOUT1_DIVIDE { MODELPARAM_VALUE.CLKOUT1_DIVIDE PARAM_VALUE.CLKOUT1_DIVIDE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.CLKOUT1_DIVIDE}] ${MODELPARAM_VALUE.CLKOUT1_DIVIDE}
}

proc update_MODELPARAM_VALUE.CLKOUT1_PHASE { MODELPARAM_VALUE.CLKOUT1_PHASE PARAM_VALUE.CLKOUT1_PHASE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.CLKOUT1_PHASE}] ${MODELPARAM_VALUE.CLKOUT1_PHASE}
}

proc update_MODELPARAM_VALUE.CLKOUT2_DIVIDE { MODELPARAM_VALUE.CLKOUT2_DIVIDE PARAM_VALUE.CLKOUT2_DIVIDE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.CLKOUT2_DIVIDE}] ${MODELPARAM_VALUE.CLKOUT2_DIVIDE}
}

proc update_MODELPARAM_VALUE.CLKOUT2_PHASE { MODELPARAM_VALUE.CLKOUT2_PHASE PARAM_VALUE.CLKOUT2_PHASE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.CLKOUT2_PHASE}] ${MODELPARAM_VALUE.CLKOUT2_PHASE}
}

proc update_MODELPARAM_VALUE.S1_CLKFBOUT_MULT { MODELPARAM_VALUE.S1_CLKFBOUT_MULT PARAM_VALUE.S1_CLKFBOUT_MULT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.S1_CLKFBOUT_MULT}] ${MODELPARAM_VALUE.S1_CLKFBOUT_MULT}
}

proc update_MODELPARAM_VALUE.S1_DIVCLK_DIVIDE { MODELPARAM_VALUE.S1_DIVCLK_DIVIDE PARAM_VALUE.S1_DIVCLK_DIVIDE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.S1_DIVCLK_DIVIDE}] ${MODELPARAM_VALUE.S1_DIVCLK_DIVIDE}
}

proc update_MODELPARAM_VALUE.S1_CLKOUT1_DIVIDE { MODELPARAM_VALUE.S1_CLKOUT1_DIVIDE PARAM_VALUE.S1_CLKOUT1_DIVIDE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.S1_CLKOUT1_DIVIDE}] ${MODELPARAM_VALUE.S1_CLKOUT1_DIVIDE}
}

proc update_MODELPARAM_VALUE.S1_CLKOUT1_PHASE { MODELPARAM_VALUE.S1_CLKOUT1_PHASE PARAM_VALUE.S1_CLKOUT1_PHASE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.S1_CLKOUT1_PHASE}] ${MODELPARAM_VALUE.S1_CLKOUT1_PHASE}
}

proc update_MODELPARAM_VALUE.S1_CLKOUT2_DIVIDE { MODELPARAM_VALUE.S1_CLKOUT2_DIVIDE PARAM_VALUE.S1_CLKOUT2_DIVIDE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.S1_CLKOUT2_DIVIDE}] ${MODELPARAM_VALUE.S1_CLKOUT2_DIVIDE}
}

proc update_MODELPARAM_VALUE.S1_CLKOUT2_PHASE { MODELPARAM_VALUE.S1_CLKOUT2_PHASE PARAM_VALUE.S1_CLKOUT2_PHASE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.S1_CLKOUT2_PHASE}] ${MODELPARAM_VALUE.S1_CLKOUT2_PHASE}
}

proc update_MODELPARAM_VALUE.S2_CLKFBOUT_MULT { MODELPARAM_VALUE.S2_CLKFBOUT_MULT PARAM_VALUE.S2_CLKFBOUT_MULT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.S2_CLKFBOUT_MULT}] ${MODELPARAM_VALUE.S2_CLKFBOUT_MULT}
}

proc update_MODELPARAM_VALUE.S2_DIVCLK_DIVIDE { MODELPARAM_VALUE.S2_DIVCLK_DIVIDE PARAM_VALUE.S2_DIVCLK_DIVIDE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.S2_DIVCLK_DIVIDE}] ${MODELPARAM_VALUE.S2_DIVCLK_DIVIDE}
}

proc update_MODELPARAM_VALUE.S2_CLKOUT1_DIVIDE { MODELPARAM_VALUE.S2_CLKOUT1_DIVIDE PARAM_VALUE.S2_CLKOUT1_DIVIDE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.S2_CLKOUT1_DIVIDE}] ${MODELPARAM_VALUE.S2_CLKOUT1_DIVIDE}
}

proc update_MODELPARAM_VALUE.S2_CLKOUT1_PHASE { MODELPARAM_VALUE.S2_CLKOUT1_PHASE PARAM_VALUE.S2_CLKOUT1_PHASE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.S2_CLKOUT1_PHASE}] ${MODELPARAM_VALUE.S2_CLKOUT1_PHASE}
}

proc update_MODELPARAM_VALUE.S2_CLKOUT2_DIVIDE { MODELPARAM_VALUE.S2_CLKOUT2_DIVIDE PARAM_VALUE.S2_CLKOUT2_DIVIDE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.S2_CLKOUT2_DIVIDE}] ${MODELPARAM_VALUE.S2_CLKOUT2_DIVIDE}
}

proc update_MODELPARAM_VALUE.S2_CLKOUT2_PHASE { MODELPARAM_VALUE.S2_CLKOUT2_PHASE PARAM_VALUE.S2_CLKOUT2_PHASE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.S2_CLKOUT2_PHASE}] ${MODELPARAM_VALUE.S2_CLKOUT2_PHASE}
}

proc update_MODELPARAM_VALUE.S3_CLKFBOUT_MULT { MODELPARAM_VALUE.S3_CLKFBOUT_MULT PARAM_VALUE.S3_CLKFBOUT_MULT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.S3_CLKFBOUT_MULT}] ${MODELPARAM_VALUE.S3_CLKFBOUT_MULT}
}

proc update_MODELPARAM_VALUE.S3_DIVCLK_DIVIDE { MODELPARAM_VALUE.S3_DIVCLK_DIVIDE PARAM_VALUE.S3_DIVCLK_DIVIDE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.S3_DIVCLK_DIVIDE}] ${MODELPARAM_VALUE.S3_DIVCLK_DIVIDE}
}

proc update_MODELPARAM_VALUE.S3_CLKOUT1_DIVIDE { MODELPARAM_VALUE.S3_CLKOUT1_DIVIDE PARAM_VALUE.S3_CLKOUT1_DIVIDE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.S3_CLKOUT1_DIVIDE}] ${MODELPARAM_VALUE.S3_CLKOUT1_DIVIDE}
}

proc update_MODELPARAM_VALUE.S3_CLKOUT1_PHASE { MODELPARAM_VALUE.S3_CLKOUT1_PHASE PARAM_VALUE.S3_CLKOUT1_PHASE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.S3_CLKOUT1_PHASE}] ${MODELPARAM_VALUE.S3_CLKOUT1_PHASE}
}

proc update_MODELPARAM_VALUE.S3_CLKOUT2_DIVIDE { MODELPARAM_VALUE.S3_CLKOUT2_DIVIDE PARAM_VALUE.S3_CLKOUT2_DIVIDE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.S3_CLKOUT2_DIVIDE}] ${MODELPARAM_VALUE.S3_CLKOUT2_DIVIDE}
}

proc update_MODELPARAM_VALUE.S3_CLKOUT2_PHASE { MODELPARAM_VALUE.S3_CLKOUT2_PHASE PARAM_VALUE.S3_CLKOUT2_PHASE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.S3_CLKOUT2_PHASE}] ${MODELPARAM_VALUE.S3_CLKOUT2_PHASE}
}

proc update_MODELPARAM_VALUE.S4_CLKFBOUT_MULT { MODELPARAM_VALUE.S4_CLKFBOUT_MULT PARAM_VALUE.S4_CLKFBOUT_MULT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.S4_CLKFBOUT_MULT}] ${MODELPARAM_VALUE.S4_CLKFBOUT_MULT}
}

proc update_MODELPARAM_VALUE.S4_DIVCLK_DIVIDE { MODELPARAM_VALUE.S4_DIVCLK_DIVIDE PARAM_VALUE.S4_DIVCLK_DIVIDE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.S4_DIVCLK_DIVIDE}] ${MODELPARAM_VALUE.S4_DIVCLK_DIVIDE}
}

proc update_MODELPARAM_VALUE.S4_CLKOUT1_DIVIDE { MODELPARAM_VALUE.S4_CLKOUT1_DIVIDE PARAM_VALUE.S4_CLKOUT1_DIVIDE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.S4_CLKOUT1_DIVIDE}] ${MODELPARAM_VALUE.S4_CLKOUT1_DIVIDE}
}

proc update_MODELPARAM_VALUE.S4_CLKOUT1_PHASE { MODELPARAM_VALUE.S4_CLKOUT1_PHASE PARAM_VALUE.S4_CLKOUT1_PHASE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.S4_CLKOUT1_PHASE}] ${MODELPARAM_VALUE.S4_CLKOUT1_PHASE}
}

proc update_MODELPARAM_VALUE.S4_CLKOUT2_DIVIDE { MODELPARAM_VALUE.S4_CLKOUT2_DIVIDE PARAM_VALUE.S4_CLKOUT2_DIVIDE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.S4_CLKOUT2_DIVIDE}] ${MODELPARAM_VALUE.S4_CLKOUT2_DIVIDE}
}

proc update_MODELPARAM_VALUE.S4_CLKOUT2_PHASE { MODELPARAM_VALUE.S4_CLKOUT2_PHASE PARAM_VALUE.S4_CLKOUT2_PHASE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.S4_CLKOUT2_PHASE}] ${MODELPARAM_VALUE.S4_CLKOUT2_PHASE}
}

proc update_MODELPARAM_VALUE.S5_CLKFBOUT_MULT { MODELPARAM_VALUE.S5_CLKFBOUT_MULT PARAM_VALUE.S5_CLKFBOUT_MULT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.S5_CLKFBOUT_MULT}] ${MODELPARAM_VALUE.S5_CLKFBOUT_MULT}
}

proc update_MODELPARAM_VALUE.S5_DIVCLK_DIVIDE { MODELPARAM_VALUE.S5_DIVCLK_DIVIDE PARAM_VALUE.S5_DIVCLK_DIVIDE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.S5_DIVCLK_DIVIDE}] ${MODELPARAM_VALUE.S5_DIVCLK_DIVIDE}
}

proc update_MODELPARAM_VALUE.S5_CLKOUT1_DIVIDE { MODELPARAM_VALUE.S5_CLKOUT1_DIVIDE PARAM_VALUE.S5_CLKOUT1_DIVIDE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.S5_CLKOUT1_DIVIDE}] ${MODELPARAM_VALUE.S5_CLKOUT1_DIVIDE}
}

proc update_MODELPARAM_VALUE.S5_CLKOUT1_PHASE { MODELPARAM_VALUE.S5_CLKOUT1_PHASE PARAM_VALUE.S5_CLKOUT1_PHASE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.S5_CLKOUT1_PHASE}] ${MODELPARAM_VALUE.S5_CLKOUT1_PHASE}
}

proc update_MODELPARAM_VALUE.S5_CLKOUT2_DIVIDE { MODELPARAM_VALUE.S5_CLKOUT2_DIVIDE PARAM_VALUE.S5_CLKOUT2_DIVIDE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.S5_CLKOUT2_DIVIDE}] ${MODELPARAM_VALUE.S5_CLKOUT2_DIVIDE}
}

proc update_MODELPARAM_VALUE.S5_CLKOUT2_PHASE { MODELPARAM_VALUE.S5_CLKOUT2_PHASE PARAM_VALUE.S5_CLKOUT2_PHASE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.S5_CLKOUT2_PHASE}] ${MODELPARAM_VALUE.S5_CLKOUT2_PHASE}
}

