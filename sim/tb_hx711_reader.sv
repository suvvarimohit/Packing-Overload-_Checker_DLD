`timescale 1ns/1ps
module tb_hx711_reader;
  reg clk=0, reset=1, dout=1;
  wire sck,valid;
  wire signed [23:0] raw;
  reg [23:0] sample=24'h001234;
  integer b;
  always #5 clk=~clk;
  hx711_reader #(.CLK_HZ(1000),.SCK_HZ(100)) dut(
    .clk(clk),.reset(reset),.hx_dout(dout),.hx_sck(sck),.raw(raw),.valid(valid)
  );
  initial begin
    repeat(3) @(negedge clk); reset=0;
    // DOUT low starts a conversion; present one data bit per SCK rising edge.
    dout=sample[23];
    @(posedge sck);
    for(b=22;b>=0;b=b-1) begin
      @(negedge sck); dout=sample[b];
      @(posedge sck);
    end
    @(negedge sck); dout=1; // 25th pulse selects gain 128 for next sample
    wait(valid);
    if(raw!==sample) $fatal(1,"HX711 capture mismatch: got %h expected %h",raw,sample);
    $display("PASS: HX711 captures 24-bit sample");
    $finish;
  end
  initial begin #100000; $fatal(1,"HX711 test timeout"); end
endmodule
