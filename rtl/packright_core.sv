// Portable PackRight decision core. RFID and HX711 electrical interfaces are
// intentionally outside this module; feed it decoded item IDs and weight.
module packright_core #(
    parameter int ITEM_COUNT = 8,
    parameter int ITEM_ID_WIDTH = $clog2(ITEM_COUNT),
    parameter logic [ITEM_COUNT-1:0] MONDAY_REQUIRED  = 8'b0011_0111,
    parameter logic [ITEM_COUNT-1:0] TUESDAY_REQUIRED = 8'b1100_1011,
    parameter logic [ITEM_COUNT-1:0] WEDNESDAY_REQUIRED = 8'b0101_0110,
    parameter logic [ITEM_COUNT-1:0] THURSDAY_REQUIRED = 8'b1010_1101,
    parameter logic [ITEM_COUNT-1:0] FRIDAY_REQUIRED = 8'b0111_1001
) (
    input  logic clk,
    input  logic reset,
    input  logic select_day,
    input  logic [2:0] day_id,          // 0=Mon ... 4=Fri
    input  logic start_scanning,
    input  logic rfid_valid,            // one-cycle pulse for a recognized tag
    input  logic [ITEM_ID_WIDTH-1:0] rfid_item_id,
    input  logic check_bag,
    input  logic [15:0] weight_grams,   // calibrated grams from HX711 interface
    input  logic [15:0] max_weight_grams,
    output logic [ITEM_COUNT-1:0] packed_items,
    output logic [ITEM_COUNT-1:0] required_items,
    output logic [2:0] state,
    output logic [1:0] led,             // {yellow_overweight, red_missing}; green separate
    output logic green_led,
    output logic buzzer,
    output logic [2:0] message_kind,    // 0=select, 1=scan, 2=missing, 3=extra,
                                        // 4=overweight, 5=ready, 6=weight OK
    output logic [ITEM_ID_WIDTH-1:0] message_item_id
);

    localparam logic [2:0] ST_SELECT = 3'd0;
    localparam logic [2:0] ST_SCAN = 3'd1;
    localparam logic [2:0] ST_RESULT = 3'd2;
    localparam logic [2:0] MSG_SELECT = 3'd0;
    localparam logic [2:0] MSG_SCAN = 3'd1;
    localparam logic [2:0] MSG_MISSING = 3'd2;
    localparam logic [2:0] MSG_EXTRA = 3'd3;
    localparam logic [2:0] MSG_OVERWEIGHT = 3'd4;
    localparam logic [2:0] MSG_READY = 3'd5;
    localparam logic [2:0] MSG_WEIGHT_OK = 3'd6;

    logic [ITEM_COUNT-1:0] missing_mask, extra_mask;
    logic [ITEM_COUNT-1:0] pending_mask;
    logic showing_missing;

    always_comb begin
        missing_mask = required_items & ~packed_items;
        extra_mask = packed_items & ~required_items;
    end

    // Lowest numbered set bit is reported first; each subsequent Check Bag
    // press advances to the next item.
    always_comb begin
        message_item_id = '0;
        for (int k = ITEM_COUNT-1; k >= 0; k--)
            if (pending_mask[k]) message_item_id = ITEM_ID_WIDTH'(k);
    end

    always_comb begin
        led = 2'b00;
        green_led = 1'b0;
        buzzer = 1'b0;
        case (message_kind)
            MSG_MISSING: begin led[0] = 1'b1; buzzer = 1'b1; end
            MSG_OVERWEIGHT: begin led[1] = 1'b1; buzzer = 1'b1; end
            MSG_READY: green_led = 1'b1;
            default: ;
        endcase
    end

    always_ff @(posedge clk) begin
        if (reset) begin
            state <= ST_SELECT;
            required_items <= '0;
            packed_items <= '0;
            pending_mask <= '0;
            showing_missing <= 1'b0;
            message_kind <= MSG_SELECT;
        end else begin
            case (state)
                ST_SELECT: begin
                    message_kind <= MSG_SELECT;
                    if (select_day && (day_id <= 3'd4)) begin
                        case (day_id)
                            3'd0: required_items <= MONDAY_REQUIRED;
                            3'd1: required_items <= TUESDAY_REQUIRED;
                            3'd2: required_items <= WEDNESDAY_REQUIRED;
                            3'd3: required_items <= THURSDAY_REQUIRED;
                            3'd4: required_items <= FRIDAY_REQUIRED;
                            default: required_items <= '0;
                        endcase
                        packed_items <= '0;
                        state <= ST_SCAN;
                        message_kind <= MSG_SCAN;
                    end
                end
                ST_SCAN: begin
                    message_kind <= MSG_SCAN;
                    if (rfid_valid && (rfid_item_id < ITEM_COUNT))
                        packed_items[rfid_item_id] <= 1'b1;
                    if (check_bag) begin
                        if (|missing_mask) begin
                            pending_mask <= missing_mask;
                            showing_missing <= 1'b1;
                            message_kind <= MSG_MISSING;
                            state <= ST_RESULT;
                        end else if (|extra_mask) begin
                            pending_mask <= extra_mask;
                            showing_missing <= 1'b0;
                            message_kind <= MSG_EXTRA;
                            state <= ST_RESULT;
                        end else if (weight_grams > max_weight_grams) begin
                            message_kind <= MSG_OVERWEIGHT;
                            state <= ST_RESULT;
                        end else begin
                            message_kind <= MSG_READY;
                            state <= ST_RESULT;
                        end
                    end
                end
                ST_RESULT: begin
                    if ((message_kind == MSG_MISSING || message_kind == MSG_EXTRA) && check_bag) begin
                        pending_mask[message_item_id] <= 1'b0;
                        if ((pending_mask & ~(ITEM_COUNT'(1) << message_item_id)) != '0) begin
                            message_kind <= showing_missing ? MSG_MISSING : MSG_EXTRA;
                        end else if (showing_missing && (|extra_mask)) begin
                            pending_mask <= extra_mask;
                            showing_missing <= 1'b0;
                            message_kind <= MSG_EXTRA;
                        end else if (weight_grams > max_weight_grams) begin
                            pending_mask <= '0;
                            message_kind <= MSG_OVERWEIGHT;
                        end else begin
                            pending_mask <= '0;
                            message_kind <= MSG_WEIGHT_OK;
                        end
                    end
                    if (start_scanning) begin
                        packed_items <= '0;
                        state <= ST_SCAN;
                        message_kind <= MSG_SCAN;
                    end
                    if (select_day) state <= ST_SELECT;
                end
                default: begin state <= ST_SELECT; message_kind <= MSG_SELECT; end
            endcase
        end
    end
endmodule
