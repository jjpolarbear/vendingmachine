`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   11:15:38 02/28/2022
// Design Name:   bcd_to_seg
// Module Name:   C:/Users/Student/Xilinx/VendingMachine/testbench_bcdtoseg.v
// Project Name:  VendingMachine
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: bcd_to_seg
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module testbench_bcdtoseg;

	// Inputs
	reg [3:0] bcd;

	// Outputs
	wire [7:0] seg;

	// Instantiate the Unit Under Test (UUT)
	bcd_to_seg uut (
		.bcd(bcd), 
		.seg(seg)
	);
	integer i;
	initial begin
		// Initialize Inputs
		bcd = 0;

		// Wait 100 ns for global reset to finish
		#100;
		for(i = 0; i < 1000; i = i + 1) begin
			#10 bcd = bcd + 1;
		end
        
		// Add stimulus here

	end
      
endmodule

