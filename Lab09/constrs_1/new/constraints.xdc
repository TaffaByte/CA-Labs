set_property PACKAGE_PIN W5   [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports clk]
set_property PACKAGE_PIN T17  [get_ports rst]
set_property IOSTANDARD LVCMOS33 [get_ports rst]
set_property PACKAGE_PIN U18  [get_ports btn]
set_property IOSTANDARD LVCMOS33 [get_ports btn]
set_property PACKAGE_PIN V17  [get_ports {sw[0]}]  ;# SW0
set_property PACKAGE_PIN V16  [get_ports {sw[1]}]  ;# SW1
set_property PACKAGE_PIN W16  [get_ports {sw[2]}]  ;# SW2
set_property PACKAGE_PIN W17  [get_ports {sw[3]}]  ;# SW3
set_property PACKAGE_PIN W15  [get_ports {sw[4]}]  ;# SW4
set_property PACKAGE_PIN V15  [get_ports {sw[5]}]  ;# SW5
set_property PACKAGE_PIN W14  [get_ports {sw[6]}]  ;# SW6  (opcode[6])
set_property PACKAGE_PIN W13  [get_ports {sw[7]}]  ;# SW7  (funct3[0])
set_property PACKAGE_PIN V2   [get_ports {sw[8]}]  ;# SW8  (funct3[1])
set_property PACKAGE_PIN T3   [get_ports {sw[9]}]  ;# SW9  (funct3[2])
set_property PACKAGE_PIN T2   [get_ports {sw[10]}] ;# SW10 (funct7)
set_property PACKAGE_PIN R3   [get_ports {sw[11]}] ;# SW11 (unused)
set_property PACKAGE_PIN W2   [get_ports {sw[12]}] ;# SW12 (unused)
set_property PACKAGE_PIN U1   [get_ports {sw[13]}] ;# SW13 (unused)
set_property PACKAGE_PIN T1   [get_ports {sw[14]}] ;# SW14 (unused)
set_property PACKAGE_PIN R2   [get_ports {sw[15]}] ;# SW15 (unused)
set_property IOSTANDARD LVCMOS33 [get_ports {sw[*]}]
set_property PACKAGE_PIN U16  [get_ports {led_out[0]}]   ;# LD0  RegWrite
set_property PACKAGE_PIN E19  [get_ports {led_out[1]}]   ;# LD1  ALUSrc
set_property PACKAGE_PIN U19  [get_ports {led_out[2]}]   ;# LD2  MemRead
set_property PACKAGE_PIN V19  [get_ports {led_out[3]}]   ;# LD3  MemWrite
set_property PACKAGE_PIN W18  [get_ports {led_out[4]}]   ;# LD4  MemtoReg
set_property PACKAGE_PIN U15  [get_ports {led_out[5]}]   ;# LD5  Branch
set_property PACKAGE_PIN U14  [get_ports {led_out[6]}]   ;# LD6  ALUOp[0]
set_property PACKAGE_PIN V14  [get_ports {led_out[7]}]   ;# LD7  ALUOp[1]
set_property PACKAGE_PIN V13  [get_ports {led_out[8]}]   ;# LD8  ALUControl[0]
set_property PACKAGE_PIN V3   [get_ports {led_out[9]}]   ;# LD9  ALUControl[1]
set_property PACKAGE_PIN W3   [get_ports {led_out[10]}]  ;# LD10 ALUControl[2]
set_property PACKAGE_PIN U3   [get_ports {led_out[11]}]  ;# LD11 ALUControl[3]
set_property PACKAGE_PIN P3   [get_ports {led_out[12]}]  ;# LD12 (spare)
set_property PACKAGE_PIN N3   [get_ports {led_out[13]}]  ;# LD13 (spare)
set_property PACKAGE_PIN P1   [get_ports {led_out[14]}]  ;# LD14 (spare)
set_property PACKAGE_PIN L1   [get_ports {led_out[15]}]  ;# LD15 (spare)
set_property IOSTANDARD LVCMOS33 [get_ports {led_out[*]}]