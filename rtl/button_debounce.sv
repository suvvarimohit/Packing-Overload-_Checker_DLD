module button_debounce #(parameter integer CLK_HZ=100_000_000,
                         parameter integer DEBOUNCE_MS=10) (
    input wire clk, reset, button_in,
    output reg button_pulse
);
    localparam integer LIMIT=(CLK_HZ/1000)*DEBOUNCE_MS;
    localparam integer CW=(LIMIT<2)?1:$clog2(LIMIT+1);
    reg sync0,sync1,stable;
    reg [CW-1:0] count;
    always @(posedge clk) begin
      if(reset) begin sync0<=0; sync1<=0; stable<=0; count<=0; button_pulse<=0; end
      else begin
        sync0<=button_in; sync1<=sync0; button_pulse<=0;
        if(sync1==stable) count<=0;
        else if(count==LIMIT-1) begin
          stable<=sync1; count<=0;
          if(sync1) button_pulse<=1;
        end else count<=count+1'b1;
      end
    end
endmodule
