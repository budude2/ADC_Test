create_clock -name TS_dco_p -period 2 [get_ports dco1_p]
create_clock -name TS_fco1_p -period 8 [get_ports fco1_p]

## Copied from AD Example Constraints
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets ADC_Control_i/iser_top_0/inst/iser_fco] 

set_property IOB true [get_ports {d0_a1_p, d1_a1_p, d0_b1_p, d1_b1_p, d0_c1_p, d1_c1_p, d0_d1_p, d1_d1}]

set_input_delay -clock TS_dco_p -max 0.5 [get_ports { d0_a1_p }];
set_input_delay -clock TS_dco_p -min 0.5 [get_ports { d0_a1_p }];
set_input_delay -clock TS_dco_p -max 0.5 [get_ports { d0_a1_p }] -clock_fall;
set_input_delay -clock TS_dco_p -min 0.5 [get_ports { d0_a1_p }] -clock_fall;

set_input_delay -clock TS_dco_p -max 0.5 [get_ports { d1_a1_p }];
set_input_delay -clock TS_dco_p -min 0.5 [get_ports { d1_a1_p }];
set_input_delay -clock TS_dco_p -max 0.5 [get_ports { d1_a1_p }] -clock_fall;
set_input_delay -clock TS_dco_p -min 0.5 [get_ports { d1_a1_p }] -clock_fall;

set_input_delay -clock TS_dco_p -max 0.5 [get_ports { d0_b1_p }];
set_input_delay -clock TS_dco_p -min 0.5 [get_ports { d0_b1_p }];
set_input_delay -clock TS_dco_p -max 0.5 [get_ports { d0_b1_p }] -clock_fall;
set_input_delay -clock TS_dco_p -min 0.5 [get_ports { d0_b1_p }] -clock_fall;

set_input_delay -clock TS_dco_p -max 0.5 [get_ports { d1_b1_p }];
set_input_delay -clock TS_dco_p -min 0.5 [get_ports { d1_b1_p }];
set_input_delay -clock TS_dco_p -max 0.5 [get_ports { d1_b1_p }] -clock_fall;
set_input_delay -clock TS_dco_p -min 0.5 [get_ports { d1_b1_p }] -clock_fall;

set_input_delay -clock TS_dco_p -max 0.5 [get_ports { d0_c1_p }];
set_input_delay -clock TS_dco_p -min 0.5 [get_ports { d0_c1_p }];
set_input_delay -clock TS_dco_p -max 0.5 [get_ports { d0_c1_p }] -clock_fall;
set_input_delay -clock TS_dco_p -min 0.5 [get_ports { d0_c1_p }] -clock_fall;

set_input_delay -clock TS_dco_p -max 0.5 [get_ports { d1_c1_p }];
set_input_delay -clock TS_dco_p -min 0.5 [get_ports { d1_c1_p }];
set_input_delay -clock TS_dco_p -max 0.5 [get_ports { d1_c1_p }] -clock_fall;
set_input_delay -clock TS_dco_p -min 0.5 [get_ports { d1_c1_p }] -clock_fall;

set_input_delay -clock TS_dco_p -max 0.5 [get_ports { d0_d1_p }];
set_input_delay -clock TS_dco_p -min 0.5 [get_ports { d0_d1_p }];
set_input_delay -clock TS_dco_p -max 0.5 [get_ports { d0_d1_p }] -clock_fall;
set_input_delay -clock TS_dco_p -min 0.5 [get_ports { d0_d1_p }] -clock_fall;

set_input_delay -clock TS_dco_p -max 0.5 [get_ports { d1_d1_p }];
set_input_delay -clock TS_dco_p -min 0.5 [get_ports { d1_d1_p }];
set_input_delay -clock TS_dco_p -max 0.5 [get_ports { d1_d1_p }] -clock_fall;
set_input_delay -clock TS_dco_p -min 0.5 [get_ports { d1_d1_p }] -clock_fall;