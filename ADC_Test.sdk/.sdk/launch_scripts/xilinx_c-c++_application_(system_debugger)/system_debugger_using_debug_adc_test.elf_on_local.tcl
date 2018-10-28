connect -url tcp:127.0.0.1:3121
configparams mdm-detect-bscan-mask 2
targets -set -nocase -filter {name =~ "microblaze*#0" && bscan=="USER2"  && jtag_cable_name =~ "Digilent Genesys 2 200300A8C57EB"} -index 0
rst -processor
targets -set -nocase -filter {name =~ "microblaze*#0" && bscan=="USER2"  && jtag_cable_name =~ "Digilent Genesys 2 200300A8C57EB"} -index 0
dow C:/Users/Jacob/Research/ADC_Design/ADC_Test.sdk/ADC_test/Debug/ADC_test.elf
bpadd -addr &main
