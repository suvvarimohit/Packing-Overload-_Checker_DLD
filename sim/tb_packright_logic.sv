`timescale 1ns/1ps
module tb_packright_logic;
  reg clk=0, reset=1;
  reg [2:0] day_id=0;
  reg select_day=0,start_scan=0,check_bag=0,tag_valid=0,weight_valid=1;
  reg [2:0] tag_item_id=0;
  reg [15:0] weight_grams=0;
  wire [7:0] packed_items,required_items;
  wire [2:0] status,item_id;
  wire red_led,yellow_led,green_led;
  always #5 clk=~clk;
  packright_logic dut(.*);
  task pulse_select; begin @(negedge clk); select_day=1; @(negedge clk); select_day=0; end endtask
  task scan(input [2:0] id); begin @(negedge clk); tag_item_id=id; tag_valid=1; @(negedge clk); tag_valid=0; end endtask
  task press_check; begin @(negedge clk); check_bag=1; @(negedge clk); check_bag=0; end endtask
  initial begin
    repeat(3) @(negedge clk); reset=0;
    day_id=0; pulse_select();
    if(required_items!==8'b00110111) $fatal(1,"Monday timetable mismatch");
    scan(0); scan(1); scan(4); scan(5);
    press_check();
    if(status!=2 || !red_led || item_id!=2) $fatal(1,"Expected missing Physics textbook (item 2)");
    scan(2); // add missing item, then restart the final check
    start_scan=1; @(negedge clk); start_scan=0;
    scan(0);scan(1);scan(2);scan(3);scan(4);scan(5);
    press_check();
    if(status!=5 || !green_led) $fatal(1,"Expected ready with all items");
    weight_grams=6000;
    start_scan=1; @(negedge clk); start_scan=0;
    scan(0);scan(1);scan(2);scan(3);scan(4);scan(5);
    press_check();
    if(status!=4 || !yellow_led) $fatal(1,"Expected overweight");
    $display("PASS: timetable, missing item, ready, overweight");
    $finish;
  end
endmodule
