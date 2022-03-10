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
	output reg clk_blink,
	output reg clk_click
);
	reg [26:0] c_fast;
	reg [26:0] c_blink;
	reg [26:0] c_click;
	
	always @ (posedge clk) begin
		if (c_blink == 25'b1011111010111100001000000) begin
			clk_blink <= ~clk_blink;
			c_blink <= 0;
		end
		else if (c_fast == 18'b110000110101000000) begin
			clk_fast <= ~clk_fast;
			c_fast <= 0;
		end
		else if (c_click == 23'b11111111010100000000000) begin
			clk_click <= ~clk_click;
			c_click <= 0;
		end
		else begin
			c_fast <= 1 + c_fast;
			c_blink <= 1 + c_blink;
			c_click <= 1 + c_click;
		end
	end
endmodule

module display(
	input clk_fast,
	input clk_blink,
	input clk_click,
	input dollar,
	input quarter,
	input dime,
	input nickel,
	input credit,
	input [7:0] sw,
	output [3:0] an,
	output reg[7:0] seg,
	output l_select,
	output l_pay,
	output l_vend
);
	reg[3:0] flip = 4'b0111;
	wire[10:0] price;
	wire[10:0] paid;
	wire[10:0] disp_price;
	wire[10:0] disp_vend;
	wire[10:0] disp_val;
	reg vend = 0;
	
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
	
	always @(posedge clk_click) begin
		if (price <= paid && sw != 8'b00000000) begin
			vend <= 1;
		end
		else begin
			if (sw == 0) vend <= 0;
		end
		
		if (vend) begin
			dollar_presses <= 0;
			quarter_presses <= 0;
			dime_presses <= 0;
			nickel_presses <= 0;
			credit_pressed <= 0;
		end
		
		if (price != 0) begin 
			if (dollar) dollar_presses <= dollar_presses + 1;
			if (quarter) quarter_presses <= quarter_presses + 1;
			if (dime) dime_presses <= dime_presses + 1;
			if (nickel) nickel_presses <= nickel_presses + 1;
			if (credit) credit_pressed <= credit_pressed + 1;
		end
	end
	
	assign paid = credit_pressed ? 1515 : dollar_presses*100 + quarter_presses*25 + dime_presses*10 + nickel_presses*5;
	assign price = sw[0]*100 + sw[1]*120 + sw[2]*240 + sw[3]*300 + sw[4]*220 + sw[5]*195 + sw[6]*285 + sw[7]*55;
	assign disp_val = paid < price ? price - paid : 0;
	
	assign l_select = !vend && price == 0;
	assign l_pay = !vend && !l_select;
	assign l_vend = vend;
	
	wire[3:0] thousands, hundreds, tens, ones;
	binary_to_bcd conv(
		.bin(disp_val),
		.thousands(thousands),
		.hundreds(hundreds),
		.tens(tens),
		.ones(ones)
	);
	
	wire[7:0] seg1, seg2, seg3, seg4;
	bcd_to_seg conv_seg1(
		.bcd(thousands),
		.seg(seg1)
	);
	bcd_to_seg conv_seg2(
		.bcd(hundreds),
		.seg(seg4)
	);
	bcd_to_seg conv_seg3(
		.bcd(tens),
		.seg(seg3)
	);
	bcd_to_seg conv_seg4(
		.bcd(ones),
		.seg(seg2)
	);

	always @(posedge clk_fast) begin
		flip = {flip[0], flip[3:1]};
		if (!vend) begin
			if (!an[0]) 
				seg = seg1;
			else if (!an[1])
				seg = seg2;
			else if (!an[2])
				seg = seg3;
			else if (!an[3])
				seg = seg4 & 8'b01111111;
		end 
		else if (!clk_blink) begin
			seg = 8'b11111111;
		end
		else begin
			seg = 8'b11000000;
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
	output [7:0] seg,
	output [3:0] an,
	output l_select,
	output l_pay,
	output l_vend
);

wire clk_fast;
wire clk_blink;
wire clk_click;
clock_gen clocks(
	.clk(clk),
	.clk_fast(clk_fast),
	.clk_blink(clk_blink),
	.clk_click(clk_click)
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
	.clk_click(clk_click),
	.dollar(b_dollar),
	.quarter(b_quarter),
	.dime(b_dime),
	.nickel(b_nickel),
	.credit(b_credit),
	.sw(sw),
	.seg(seg),
	.an(an),
	.l_select(l_select),
	.l_pay(l_pay),
	.l_vend(l_vend)
);

endmodule