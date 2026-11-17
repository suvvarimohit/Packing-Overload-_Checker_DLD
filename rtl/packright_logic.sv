// PackRight packing/weight decision engine. One scan pulse means one tag
// resolved to an item_id by the RC522 UID mapper.
module packright_logic #(
    parameter integer ITEM_COUNT = 8,
    parameter [7:0] MAX_WEIGHT_KG = 8'd5
) (
    input  wire clk, reset,
    input  wire [2:0] day_id,
    input  wire select_day, start_scan, check_bag,
    input  wire tag_valid,
    input  wire [2:0] tag_item_id,
    input  wire weight_valid,
    input  wire [15:0] weight_grams,
    output reg [7:0] packed_items,
    output reg [7:0] required_items,
    output reg [2:0] status,
    output reg [2:0] item_id,
    output reg red_led, yellow_led, green_led
);
    localparam S_SELECT=0, S_SCAN=1, S_RESULT=2;
    localparam M_SELECT=0, M_SCAN=1, M_MISSING=2, M_EXTRA=3,
               M_OVERWEIGHT=4, M_READY=5, M_INVALID_DAY=6;
    reg [7:0] pending;
    reg list_is_missing;
    wire [7:0] missing = required_items & ~packed_items;
    wire [7:0] extra = packed_items & ~required_items;
    integer k;
    always @* begin
        item_id=0;
        for(k=7;k>=0;k=k-1) if(pending[k]) item_id=k[2:0];
        red_led=(status==M_MISSING);
        yellow_led=(status==M_OVERWEIGHT);
        green_led=(status==M_READY);
    end
    function [7:0] timetable(input [2:0] d);
        begin case(d)
          0:timetable=8'b00110111;
          1:timetable=8'b11001011;
          2:timetable=8'b01010110;
          3:timetable=8'b10101101;
          4:timetable=8'b01111001;
          default:timetable=0;
        endcase end
    endfunction
    reg [1:0] state;
    always @(posedge clk) begin
      if(reset) begin
        state<=S_SELECT; status<=M_SELECT; required_items<=0;
        packed_items<=0; pending<=0; list_is_missing<=1;
      end else begin
        case(state)
          S_SELECT: begin
            status<=M_SELECT;
            if(select_day) begin
              if(day_id<5) begin
                required_items<=timetable(day_id); packed_items<=0;
                status<=M_SCAN; state<=S_SCAN;
              end else status<=M_INVALID_DAY;
            end
          end
          S_SCAN: begin
            status<=M_SCAN;
            if(tag_valid && tag_item_id<ITEM_COUNT)
              packed_items[tag_item_id]<=1'b1;
            if(check_bag) begin
              if(|missing) begin
                pending<=missing; list_is_missing<=1; status<=M_MISSING;
                state<=S_RESULT;
              end else if(|extra) begin
                pending<=extra; list_is_missing<=0; status<=M_EXTRA;
                state<=S_RESULT;
              end else if(weight_valid && weight_grams>({8'd0,MAX_WEIGHT_KG}*16'd1000)) begin
                status<=M_OVERWEIGHT; state<=S_RESULT;
              end else begin status<=M_READY; state<=S_RESULT; end
            end
          end
          S_RESULT: begin
            if((status==M_MISSING || status==M_EXTRA) && check_bag) begin
              pending[item_id]<=0;
              if((pending & ~(8'b1 << item_id))!=0) begin
                status<=list_is_missing?M_MISSING:M_EXTRA;
              end else if(list_is_missing && (|extra)) begin
                pending<=extra; list_is_missing<=0; status<=M_EXTRA;
              end else if(weight_valid && weight_grams>({8'd0,MAX_WEIGHT_KG}*16'd1000)) begin
                pending<=0; status<=M_OVERWEIGHT;
              end else begin pending<=0; status<=M_READY; end
            end
            if(start_scan) begin packed_items<=0; status<=M_SCAN; state<=S_SCAN; end
            if(select_day) state<=S_SELECT;
          end
          default: begin state<=S_SELECT; status<=M_SELECT; end
        endcase
      end
    end
endmodule
