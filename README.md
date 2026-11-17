# PackRight Vivado bring-up project

This folder contains an initial Vivado project for the RealDigital Boolean FPGA board (Spartan-7 XC7S50-CSGA324). The RTL implements timetable selection, packed-item bitmask comparison, HX711 24-bit capture, calibrated weight-limit detection, and board LED indications. It includes simulation testbenches and an XDC for the Boolean board.

## Files

- `rtl/packright_logic.sv` — timetable, missing/extra comparisons, state machine, status LEDs.
- `rtl/hx711_reader.sv` — HX711 serial capture and raw signed result.
- `rtl/packright_top.sv` — Boolean-board demo top; SW7 injects one simulated item ID from SW[6:4].
- `sim/tb_packright_logic.sv` — testbench for timetable, missing-item, ready, and overweight cases.
- `constraints/boolean_packright.xdc` — clock, buttons, switches, LEDs, and HX711 pin constraints.
- `create_vivado_project.tcl` — creates a Vivado project for `xc7s50-csga324-1`.
- `docs/WIRING.md` — Pmod contact/package-pin wiring map for the planned complete assembly.

## Create and simulate

Open Vivado Tcl Console in this directory and run:

```tcl
source create_vivado_project.tcl
```

Run **Run Simulation → Run Behavioral Simulation**. `tb_packright_logic` checks the RTL decision engine. For synthesis and bitstream generation, select `packright_top` as the synthesis top, then run **Run Synthesis**, **Run Implementation**, and **Generate Bitstream**. The project uses the 100 MHz Boolean board clock.

## Demo controls

- `SW[2:0]`: day, where 0=Monday through 4=Friday.
- `BTN0`: reset; `BTN1`: load selected day; `BTN2`: clear packed items and start scanning; `BTN3`: check bag.
- `SW[6:4]`: demonstration item ID, 0–7. Toggle `SW7` from low to high once to inject that item into the packed mask.
- `LD0`: missing item; `LD1`: overweight; `LD2`: ready.

The timetable masks and 5 kg default threshold are example settings. Set `TARE_COUNTS` and `COUNTS_PER_KG` in `rtl/packright_top.sv` for the assembled load cell. The bring-up top compares calibrated HX711 counts with the configured weight limit; it does not calculate a gram display value.

## Hardware integration status

This is a bring-up project, not yet the finished all-hardware PackRight system. It does not yet contain the MFRC522 SPI / ISO14443A card reader or the SSD1306 / SH1106 OLED I²C display driver. The RC522 and OLED pins are documented in `docs/WIRING.md` as the planned wiring, but these modules are not active in this bitstream. Physical tag scans and OLED messages will not work until those drivers are integrated and the actual card UIDs are entered in a UID-to-item map.

Keep the RC522 and FPGA signals at 3.3 V. Confirm the exact HX711/OLED breakout power and logic requirements before wiring. Refer to `docs/WIRING.md` before connecting the modules.


## Build artifacts

The `build/` folder contains the generated `packright_top.bit` and the routed timing summary from Vivado 2022.1. The timing report records WNS = 4.670 ns with zero failing endpoints for the specified 100 MHz clock constraints. Rebuild from the included `vivado/PackRight/PackRight.xpr` or recreate the project with `create_vivado_project.tcl`.
