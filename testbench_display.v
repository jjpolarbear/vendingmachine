`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   21:48:36 02/05/2022
// Design Name:   display
// Module Name:   /home/ise/Xilinx_Host/VendingMachine-20220305T004502Z-001/VendingMachine/testbench_display.v
// Project Name:  VendingMachine
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: display
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module testbench_display;

	// Inputs
	reg clk_fast;
	reg clk_blink;
	reg dollar;
	reg quarter;
	reg dime;
	reg nickel;
	reg credit;
	reg [7:0] sw;

	// Outputs
	wire select_led;
	wire payment_led;
	wire vend_led;
	wire [3:0] an;
	wire [7:0] seg;

	// Instantiate the Unit Under Test (UUT)
	display uut (
		.clk_fast(clk_fast), 
		.clk_blink(clk_blink), 
		.dollar(dollar), 
		.quarter(quarter), 
		.dime(dime), 
		.nickel(nickel), 
		.credit(credit), 
		.sw(sw), 
		.select_led(select_led), 
		.payment_led(payment_led), 
		.vend_led(vend_led), 
		.an(an), 
		.seg(seg)
	);
	integer i;
	always #1 clk_fast = ~clk_fast;
	initial begin
		// Initialize Inputs
		clk_fast = 0;
		clk_blink = 0;
		dollar = 0;
		quarter = 0;
		dime = 0;
		nickel = 0;
		credit = 0;
		sw = 0;

		// Wait 100 ns for global reset to finish
		#100;
		
		// Testing switches
		/*
		for(i = 0; i < 1000; i = i + 1) begin
			#10 sw = sw + 1;
		end
		*/
		
		// Testing payment
		#10 sw[2] = 1; // 240
		#10 sw[3] = 1; // 300
		#10 sw[5] = 1; // 195
		// 			Total 735
		
		// 700
		// Clock ticks every #1, so use #2 to simulate a single button press
		#2 dollar = 1;
		#2 dollar = 0;
		#2 dollar = 1;
		#2 dollar = 0;
		#2 dollar = 1;
		#2 dollar = 0;
		#2 dollar = 1;
		#2 dollar = 0;
		#2 dollar = 1;
		#2 dollar = 0;
		#2 dollar = 1;
		#2 dollar = 0;
		#2 dollar = 1;
		#2 dollar = 0;
		
		// 25
		#2 quarter = 1;
		#2 quarter = 0;
		
		// 5
		#2 nickel = 1;
		#2 nickel = 0;
		
		// 10
		#2 dime = 1;
		#2 dime = 0;
	
	end
      
endmodule

