`timescale 1ns / 1ps

module testbench_bintobcd;

	// Inputs
	reg [10:0] bin;

	// Outputs
	wire [3:0] thousands;
	wire [3:0] hundreds;
	wire [3:0] tens;
	wire [3:0] ones;

	// Instantiate the Unit Under Test (UUT)
	binary_to_bcd uut (
		.bin(bin), 
		.thousands(thousands), 
		.hundreds(hundreds), 
		.tens(tens), 
		.ones(ones)
	);
	integer i;
	initial begin
		// Initialize Inputs
		bin = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		
		for(i = 0; i < 100; i = i + 1) begin
			#10 bin = bin + 1;
		end
	end
      
endmodule

