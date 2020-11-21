`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:20:42 03/01/2020 
// Design Name: 
// Module Name:    add_32 
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
module add_32(
	input [31:0] a,
	input [31:0] b,
	output [31:0] c
);
	assign c = a + b; 
endmodule
