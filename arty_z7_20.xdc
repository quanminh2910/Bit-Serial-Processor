## Arty Z7-20 master constraint (simplified)
## Clock (125 MHz)
set_property PACKAGE_PIN H16 [get_ports {clk_125mhz}]
set_property IOSTANDARD LVCMOS33 [get_ports {clk_125mhz}]
create_clock -add -name sys_clk_pin -period 8.000 -waveform {0 4} [get_ports {clk_125mhz}]

## Reset button (BTN0)
set_property PACKAGE_PIN N17 [get_ports {rstn_btn}]
set_property IOSTANDARD LVCMOS33 [get_ports {rstn_btn}]
set_property PULLUP true [get_ports {rstn_btn}]

## LEDs (LD0–LD7)
set_property PACKAGE_PIN M14 [get_ports {led[0]}]
set_property PACKAGE_PIN M15 [get_ports {led[1]}]
set_property PACKAGE_PIN G14 [get_ports {led[2]}]
set_property PACKAGE_PIN D18 [get_ports {led[3]}]
set_property PACKAGE_PIN E18 [get_ports {led[4]}]
set_property PACKAGE_PIN G13 [get_ports {led[5]}]
set_property PACKAGE_PIN H17 [get_ports {led[6]}]
set_property PACKAGE_PIN H14 [get_ports {led[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[*]}]
