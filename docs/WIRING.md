# PackRight hardware wiring reference

This wiring is for the RealDigital Boolean board with the PMOD C and PMOD D expansion connectors. The FPGA GPIO is 3.3 V LVCMOS. Turn power off while wiring.

## Pin-to-pin map

| Boolean board Pmod contact | FPGA package pin | Connect to |
| --- | --- | --- |
| Pmod C contact 1 (JC1_P) | T6 | OLED SCL |
| Pmod C contact 2 (JC1_N) | T5 | OLED SDA |
| Pmod C contacts 5/11 | GND | Common ground |
| Pmod C contacts 6/12 | 3V3 | OLED VCC (only if module accepts 3.3 V) |
| Pmod D contact 1 (JD1_P) | R4 | RC522 SCK |
| Pmod D contact 2 (JD1_N) | T3 | RC522 MOSI |
| Pmod D contact 3 (JD2_P) | N5 | RC522 MISO |
| Pmod D contact 4 (JD2_N) | N4 | RC522 SDA / SS / NSS |
| Pmod D contact 7 (JD3_P) | L5 | RC522 RST |
| Pmod D contact 10 (JD4_P) | K4 | HX711 SCK |
| Pmod D contact 9 (JD4_N) | L4 | HX711 DOUT |
| Pmod D contacts 5/11 | GND | Common ground |
| Pmod D contacts 6/12 | 3V3 | RC522 VCC; HX711 VCC if module supports 3.3 V |

The Boolean board’s silkscreen labels PMOD C and PMOD D. Pmod header numbering follows the standard two-row 12-contact arrangement; verify the pin-1 mark before connecting. The package pin names above come from the official Boolean schematic.

## Power and passive components

- RC522 is a 3.3 V module. Do not power it from 5 V or apply 5 V logic to its pins.
- Power the OLED from 3.3 V when its module permits it. Connect SDA and SCL pull-ups to 3.3 V, not 5 V. Use one 10 kΩ resistor from SDA to 3.3 V and one 10 kΩ resistor from SCL to 3.3 V if your OLED board does not already have pull-ups.
- HX711 module supply and logic level depend on the specific breakout. For direct FPGA connections, its DOUT high level must not exceed 3.3 V. Confirm the module board before powering.
- Connect the load cell to the HX711 terminals marked E+, E−, A+, and A−. Wire colors vary; use the load cell/module documentation. After wiring, tare the empty platform and calibrate with a known mass.
- Use the Boolean board’s built-in BTN0–BTN3 and LD0–LD2 for reset, day selection, scan, check, and status indication. The extra tactile buttons and LEDs are not required. If driving external LEDs, use a suitable series resistor; 10 kΩ is safe but may be very dim.
- All connected modules need a common ground. Do not tie external 5 V to the Boolean board’s 3.3 V rail.

## What this project currently supports

`packright_top` currently drives the timetable/packing logic and reads the HX711. `SW[2:0]` selects the day, BTN0 resets, BTN1 loads the selected day, BTN2 starts a fresh scan, and BTN3 checks. In the logic bring-up build, a rising edge on SW7 injects a demonstration item ID from SW[6:4]. LEDs LD0, LD1, and LD2 indicate missing, overweight, and ready.

The current RTL does **not** yet instantiate the MFRC522 SPI/ISO14443A reader or the SSD1306/SH1106 OLED I²C display driver. Therefore, do not connect the RC522 or OLED expecting them to work with this bitstream. The table above is the intended physical wiring for the next integration step, not a claim that the present bitstream controls those modules.

The S50 card UID is factory-set and the UID-to-item table must be filled from the actual card UIDs. A blank MIFARE Classic card also has no user data until it is written/authenticated. The reader frontend and UID mapping will be needed before physical card scanning can replace the SW7 demo input.
