set_property SRC_FILE_INFO {cfile:C:/Users/Jacob/Research/ADC_Design/ADC_Test.srcs/constrs_1/imports/Constraints/KC705_AdcToplevel_Toplevel.xdc rfile:../ADC_Test.srcs/constrs_1/imports/Constraints/KC705_AdcToplevel_Toplevel.xdc id:1} [current_design]
set_property src_info {type:XDC file:1 line:102 export:INPUT save:INPUT read:READ} [current_design]
create_pblock Apps_AdcToplevel
add_cells_to_pblock [get_pblocks Apps_AdcToplevel] [get_cells -quiet [list ADC/AdcToplevel_Toplevel_I_AdcToplevel]]
resize_pblock [get_pblocks Apps_AdcToplevel] -add {SLICE_X0Y200:SLICE_X7Y249}
