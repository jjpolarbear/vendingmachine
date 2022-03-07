`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:04:10 02/23/2022 
// Design Name: 
// Module Name:    Vend 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module clock_gen(
	input clk,
	output reg clk_fast,
	output reg clk_blink
);
	reg [17:0] c_fast;
	reg [24:0] c_blink;
	
	always @ (posedge clk) begin
		if (c_blink == 25'b1011111010111100001000000) begin
			clk_blink <= ~clk_blink;
			c_blink <= 0;
		end
		else if (c_fast == 18'b110000110101000000) begin
			clk_fast <= ~clk_fast;
			c_fast <= 0;
		end
		else begin
			c_fast <= 1 + c_fast;
			c_blink <= 1 + c_blink;
		end
	end
endmodule

module display(
	input clk_fast,
	input clk_blink,
	input dollar,
	input quarter,
	input dime,
	input nickel,
	input credit,
	input [7:0] sw,
	output select_led,
	output payment_led,
	output vend_led,
	output [3:0] an,
	output reg[7:0] seg
);
	reg[3:0] flip = 4'b0111;
	wire[10:0] price;
	wire[10:0] paid;
	wire[10:0] disp_val;
	/*
	sw[0] = $1.00
	sw[1] = $1.20
	sw[2] = $2.40
	sw[3] = $3.00
	sw[4] = $2.20
	sw[5] = $1.95
	sw[6] = $2.85
	sw[7] = $0.55
	11 bits
	*/
	reg[10:0] dollar_presses = 0;
	reg[10:0] quarter_presses = 0;
	reg[10:0] dime_presses = 0;
	reg[10:0] nickel_presses = 0;
	reg credit_pressed = 0;
	
	assign paid = credit_pressed ? 1515 : dollar_presses*100 + quarter_presses*25 + dime_presses*10 + nickel_presses*5;
	assign price = sw[0]*100 + sw[1]*120 + sw[2]*240 + sw[3]*300 + sw[4]*220 + sw[5]*195 + sw[6]*285 + sw[7]*55;
	assign disp_val = paid < price ? price - paid : 0;
	
	wire[3:0] thousands, hundreds, tens, ones;
	binary_to_bcd conv(
		.bin(disp_val),
		.thousands(thousands),
		.hundreds(hundreds),
		.tens(tens),
		.ones(ones)
	);
	
	wire[7:0] tens_dollars, ones_dollars, tens_cents, ones_cents;
	bcd_to_seg conv_tens_dollars(
		.bcd(thousands),
		.seg(tens_dollars)
	);
	bcd_to_seg conv_ones_dollars(
		.bcd(hundreds),
		.seg(ones_dollars)
	);
	bcd_to_seg conv_tens_cents(
		.bcd(tens),
		.seg(tens_cents)
	);
	bcd_to_seg conv_ones_cents(
		.bcd(ones),
		.seg(ones_cents)
	);
	reg vending = 0;
	// NOTE: during testing, found some bugs:
	// -> PAYMENT led will light up sometimes while VEND led is on
	// ----> Maybe having to do with pressing the buttons after payment?
	// ----> Also, maybe conditions need tweaking?
	// -> Sometimes takes a bit of time for VEND led to turn on after
	//    PAYMENT led turns off
	// ----> Not in an always (synch) block but assigned with assign statements
	// ----> Potentially due to updating vending (variable in assign statement)
	//       in the always (synch) block
	// ----> Actually, probably so after looking at waveform closely
	// ----> Must somehow transform vending logic
	// ----> UNLESS it isn't really that noticeable on the actual board
	// ----> IF SO, then we're good
	assign select_led = !vending && sw == 0 ? 1 : 0;
	assign payment_led = disp_val > 0 ? 1 : 0;
	assign vend_led = vending;
	always @(posedge clk_fast) begin
		if(credit) begin
			credit_pressed = 1;
		end
		if(dollar) begin
			dollar_presses = dollar_presses + 1;
		end
		if(quarter) begin
			quarter_presses = quarter_presses + 1;
		end
		if(dime) begin
			dime_presses = dime_presses + 1;
		end
		if(nickel) begin
			nickel_presses = nickel_presses + 1;
		end
		if(clk_fast) begin
			flip = {flip[0], flip[3:1]};
			if(disp_val == 0 && paid > 0) begin
				vending = 1;
			end
			if(vending && sw == 0) begin
				vending = 0;
				credit_pressed = 0;
				dollar_presses = 0;
				quarter_presses = 0;
				dime_presses = 0;
				nickel_presses = 0;
			end
			if (!an[0]) begin
				if(!vending || clk_blink) begin
					seg = tens_dollars;
				end
				else begin
					seg = 8'b11111111;
				end
			end
			else if (!an[1]) begin
				if(!vending || clk_blink) begin
					seg = ones_cents;
				end
				else begin
					seg = 8'b11111111;
				end
			end
			else if (!an[2]) begin
				if(!vending || clk_blink) begin
					seg = tens_cents;
				end
				else begin
					seg = 8'b11111111;
				end;
			end
			else if (!an[3]) begin
				if(!vending || clk_blink) begin
					seg = ones_dollars;
				end
				else begin
					seg = 8'b11111111;
				end
			end
		end
	end
	assign an[0] = flip[0];
	assign an[1] = flip[1];
	assign an[2] = flip[2];
	assign an[3] = flip[3];
endmodule

module debouncer(
	input clk,
	input sig,
	output bounced
);
	reg[1:0] arst_ff;
	assign bounced = arst_ff[0];
	always @ (posedge clk or posedge sig)
		if (sig)
			arst_ff <= 2'b11;
		else
			arst_ff <= {1'b0, arst_ff[1]};
endmodule

module debounce_2(
	input clk,
	input sig,
	output bounced
);
	reg[1:0] arst_ff;
	assign bounced = arst_ff[0] && arst_ff[1] == 0;
	always @ (posedge clk or posedge sig)
		if (sig)
			arst_ff <= 2'b11;
		else
			arst_ff <= {1'b0, arst_ff[1]};
endmodule

module bcd_to_seg(
	input[3:0] bcd,
	output reg[7:0] seg
);
	always @(bcd) begin
		case (bcd)
			0: begin
				seg = 8'b11000000;
			end
			1: begin
				seg = 8'b11111001;
			end
			2: begin
				seg = 8'b10100100;
			end
			3: begin
				seg = 8'b10110000;
			end
			4: begin
				seg = 8'b10011001;
			end
			5: begin
				seg = 8'b10010010;
			end
			6: begin
				seg = 8'b10000010;
			end
			7: begin
				seg = 8'b11111000;
			end
			8: begin
				seg = 8'b10000000;
			end
			9: begin
				seg = 8'b10010000;
			end
		endcase 
	end
endmodule

module binary_to_bcd(
	input[10:0] bin,
	output reg[3:0] thousands,
	output reg[3:0] hundreds,
	output reg[3:0] tens,
	output reg[3:0] ones
);
	integer i;
	always @(bin) begin
		thousands = 4'b0000;
		hundreds = 4'b0000;
		tens = 4'b0000;
		ones = 4'b0000;
		
		for (i = 10; i >= 0; i = i-1) begin
			if (thousands >= 5)
				thousands = thousands + 3;
			if (hundreds >= 5) 
				hundreds = hundreds + 3;
			if (tens >= 5)
				tens = tens + 3;
			if (ones >= 5)
				ones = ones + 3;
			
			thousands = thousands << 1;
			thousands[0] = hundreds[3];
			hundreds = hundreds << 1;
			hundreds[0] = tens[3];
			tens = tens << 1;
			tens[0] = ones[3];
			ones = ones << 1;
			ones[0] = bin[i];
		end
	end
endmodule

module meta(
	input[7:0] sw_in,
	input clk,
	output reg[7:0] sw_out
);
	reg[7:0] sw_hold;
	always @(sw_in)
		sw_hold <= sw_in;
	always @(clk)
		sw_out <= sw_hold;
endmodule

module Vend(
	input clk,
	input [7:0] sw,
	input dollar,
	input quarter,
	input dime,
	input nickel,
	input credit,
	output select_led,
	output payment_led,
	output vend_led,
	output [7:0] seg,
	output [3:0] an
);

wire clk_fast;
wire clk_blink;
clock_gen clocks(
	.clk(clk),
	.clk_fast(clk_fast),
	.clk_blink(clk_blink)
);

wire b_dollar;
debouncer d_dollar(
	.clk(clk_fast),
	.sig(dollar),
	.bounced(b_dollar)
);

wire b_quarter;
debouncer d_quarter(
	.clk(clk_fast),
	.sig(quarter),
	.bounced(b_quarter)
);

wire b_dime;
debouncer d_dime(
	.clk(clk_fast),
	.sig(dime),
	.bounced(b_dime)
);

wire b_nickel;
debouncer d_nickel(
	.clk(clk_fast),
	.sig(nickel),
	.bounced(b_nickel)
);

wire b_credit;
debouncer d_credit(
	.clk(clk_fast),
	.sig(credit),
	.bounced(b_credit)
);

display disp(
	.clk_fast(clk_fast),
	.clk_blink(clk_blink),
	.dollar(b_dollar),
	.quarter(b_quarter),
	.dime(b_dime),
	.nickel(b_nickel),
	.credit(b_credit),
	.sw(sw),
	.select_led(select_led),
	.payment_led(payment_led),
	.vend_led(vend_led),
	.seg(seg),
	.an(an)
);

endmodule