// HX711 24-bit serial capture. DOUT is sampled on SCK rising edges; 25th
// pulse selects gain 128 for the next conversion. Output is signed raw counts.
module hx711_reader #(parameter integer CLK_HZ=100_000_000,
                       parameter integer SCK_HZ=100_000) (
    input wire clk, reset, hx_dout,
    output reg hx_sck,
    output reg signed [23:0] raw,
    output reg valid
);
    localparam integer HALF_DIV=CLK_HZ/(2*SCK_HZ);
    reg [$clog2(HALF_DIV+1)-1:0] divcnt;
    reg [5:0] bitcnt;
    reg [23:0] shift;
    reg busy;
    always @(posedge clk) begin
      if(reset) begin hx_sck<=0; raw<=0; valid<=0; divcnt<=0; bitcnt<=0; shift<=0; busy<=0; end
      else begin
        valid<=0;
        if(!busy && hx_dout==0) begin busy<=1; bitcnt<=0; divcnt<=0; shift<=0; end
        else if(busy) begin
          if(divcnt==HALF_DIV-1) begin
            divcnt<=0;
            if(!hx_sck) begin
              hx_sck<=1;
              if(bitcnt<24) shift<={shift[22:0],hx_dout};
            end else begin
              hx_sck<=0;
              if(bitcnt==24) begin raw<=shift; valid<=1; busy<=0; end
              bitcnt<=bitcnt+1'b1;
            end
          end else divcnt<=divcnt+1'b1;
        end
      end
    end
endmodule
