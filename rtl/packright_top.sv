// Logic-only bring-up top for the RealDigital Boolean (XC7S50-CSGA324).
// SW7 rising edge injects one demo item ID from SW[6:4]; this lets the FPGA
// logic be checked before the RC522 protocol frontend is integrated.
module packright_top(
    input  wire clk,
    input  wire [3:0] btn,
    input  wire [7:0] sw,
    input  wire hx_dout,
    output wire hx_sck,
    output wire [2:0] led
);
    parameter [7:0] MAX_WEIGHT_KG = 8'd5;
    wire reset = btn[0];
    wire select_pulse, scan_pulse, check_pulse;
    button_debounce db_select(.clk(clk),.reset(reset),.button_in(btn[1]),.button_pulse(select_pulse));
    button_debounce db_scan  (.clk(clk),.reset(reset),.button_in(btn[2]),.button_pulse(scan_pulse));
    button_debounce db_check (.clk(clk),.reset(reset),.button_in(btn[3]),.button_pulse(check_pulse));
    wire [23:0] hx_raw;
    wire hx_valid;
    hx711_reader #(.CLK_HZ(100_000_000), .SCK_HZ(100_000)) scale_i(
        .clk(clk), .reset(reset), .hx_dout(hx_dout), .hx_sck(hx_sck),
        .raw(hx_raw), .valid(hx_valid)
    );

    // Set this after calibrating the assembled 20 kg sensor. Raw zero offset
    // should be measured with no load; counts/kg is the loaded delta.
    parameter signed [23:0] TARE_COUNTS = 24'sd0;
    parameter integer COUNTS_PER_KG = 1000;
    localparam [15:0] MAX_WEIGHT_GRAMS = MAX_WEIGHT_KG * 16'd1000;
    localparam signed [24:0] OVERWEIGHT_COUNTS = MAX_WEIGHT_KG * COUNTS_PER_KG;
    wire signed [24:0] delta = $signed(hx_raw) - TARE_COUNTS;
    // The result logic only needs a limit decision, not a displayed gram value.
    // Compare calibrated raw counts directly to avoid a wide multiply/divide
    // combinational path that can fail the Boolean board's 100 MHz timing.
    wire weight_over_limit_now = delta > OVERWEIGHT_COUNTS;
    reg [15:0] weight_grams_latched;
    reg weight_ready;
    always @(posedge clk) begin
      if(reset) begin weight_grams_latched<=0; weight_ready<=0; end
      else if(hx_valid) begin
        // Encode the threshold decision for packright_logic; no user-facing
        // gram readout exists in this bring-up top.
        weight_grams_latched<=weight_over_limit_now ? (MAX_WEIGHT_GRAMS + 16'd1) : MAX_WEIGHT_GRAMS;
        weight_ready<=1;
      end
    end

    reg sw7_d;
    always @(posedge clk) begin
      if(reset) sw7_d<=0;
      else sw7_d<=sw[7];
    end
    wire demo_tag_valid=sw[7] & ~sw7_d;
    wire [2:0] demo_item_id=sw[6:4];

    wire [7:0] packed_items, required_items;
    wire [2:0] status, item_id;
    wire red_led, yellow_led, green_led;
    packright_logic #(.MAX_WEIGHT_KG(MAX_WEIGHT_KG)) logic_i(
        .clk(clk), .reset(reset), .day_id(sw[2:0]),
        .select_day(select_pulse), .start_scan(scan_pulse), .check_bag(check_pulse),
        .tag_valid(demo_tag_valid), .tag_item_id(demo_item_id),
        .weight_valid(weight_ready), .weight_grams(weight_grams_latched),
        .packed_items(packed_items), .required_items(required_items),
        .status(status), .item_id(item_id),
        .red_led(red_led), .yellow_led(yellow_led), .green_led(green_led)
    );
    assign led = {green_led,yellow_led,red_led};

endmodule
