## RealDigital Boolean board: XC7S50-CSGA324-1, 100 MHz clock.
set_property -dict {PACKAGE_PIN F14 IOSTANDARD LVCMOS33} [get_ports clk]
create_clock -period 10.000 -name gclk [get_ports clk]

## On-board momentary buttons (active high)
set_property -dict {PACKAGE_PIN J2 IOSTANDARD LVCMOS33} [get_ports {btn[0]}]
set_property -dict {PACKAGE_PIN J5 IOSTANDARD LVCMOS33} [get_ports {btn[1]}]
set_property -dict {PACKAGE_PIN H2 IOSTANDARD LVCMOS33} [get_ports {btn[2]}]
set_property -dict {PACKAGE_PIN J1 IOSTANDARD LVCMOS33} [get_ports {btn[3]}]

## On-board slide switches
set_property -dict {PACKAGE_PIN V2 IOSTANDARD LVCMOS33} [get_ports {sw[0]}]
set_property -dict {PACKAGE_PIN U2 IOSTANDARD LVCMOS33} [get_ports {sw[1]}]
set_property -dict {PACKAGE_PIN U1 IOSTANDARD LVCMOS33} [get_ports {sw[2]}]
set_property -dict {PACKAGE_PIN T2 IOSTANDARD LVCMOS33} [get_ports {sw[3]}]
set_property -dict {PACKAGE_PIN T1 IOSTANDARD LVCMOS33} [get_ports {sw[4]}]
set_property -dict {PACKAGE_PIN R2 IOSTANDARD LVCMOS33} [get_ports {sw[5]}]
set_property -dict {PACKAGE_PIN R1 IOSTANDARD LVCMOS33} [get_ports {sw[6]}]
set_property -dict {PACKAGE_PIN P2 IOSTANDARD LVCMOS33} [get_ports {sw[7]}]

## On-board LEDs: LD0 red, LD1 yellow, LD2 green
set_property -dict {PACKAGE_PIN G1 IOSTANDARD LVCMOS33} [get_ports {led[0]}]
set_property -dict {PACKAGE_PIN G2 IOSTANDARD LVCMOS33} [get_ports {led[1]}]
set_property -dict {PACKAGE_PIN F1 IOSTANDARD LVCMOS33} [get_ports {led[2]}]

## HX711: use Boolean board Pmod D contact pair JD4_P / JD4_N.
## Confirm pin numbering from the board silkscreen before connecting.
set_property -dict {PACKAGE_PIN K4 IOSTANDARD LVCMOS33} [get_ports hx_sck]
set_property -dict {PACKAGE_PIN L4 IOSTANDARD LVCMOS33} [get_ports hx_dout]

## Planned assignments for a future integrated peripheral top. Keep commented
## until matching RTL ports/drivers are added.
## OLED: JC1_P/T6 = SCL, JC1_N/T5 = SDA (SDA must be open-drain).
## set_property -dict {PACKAGE_PIN T6 IOSTANDARD LVCMOS33} [get_ports oled_scl]
## set_property -dict {PACKAGE_PIN T5 IOSTANDARD LVCMOS33} [get_ports oled_sda]
## RC522: JD1_P/R4=SCK, JD1_N/T3=MOSI, JD2_P/N5=MISO,
## JD2_N/N4=SS, JD3_P/L5=RST.
## set_property -dict {PACKAGE_PIN R4 IOSTANDARD LVCMOS33} [get_ports rc522_sck]
## set_property -dict {PACKAGE_PIN T3 IOSTANDARD LVCMOS33} [get_ports rc522_mosi]
## set_property -dict {PACKAGE_PIN N5 IOSTANDARD LVCMOS33} [get_ports rc522_miso]
## set_property -dict {PACKAGE_PIN N4 IOSTANDARD LVCMOS33} [get_ports rc522_ss_n]
## set_property -dict {PACKAGE_PIN L5 IOSTANDARD LVCMOS33} [get_ports rc522_rst_n]

set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
