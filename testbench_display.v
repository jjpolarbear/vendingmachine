`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   10:34:00 03/02/2022
// Design Name:   display
// Module Name:   C:/Users/Student/Xilinx/VendingMachine/testbench_display.v
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
		
		for(i = 0; i < 1000; i = i + 1) begin
			#10 sw = sw + 1;
		end
        
		// Add stimulus here

	end
      
endmodule

