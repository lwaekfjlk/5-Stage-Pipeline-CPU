`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    22:14:27 04/11/2020 
// Design Name: 
// Module Name:    slt 
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
module slt32(
	input [31:0] a,
	input [31:0] b,
	output [31:0] flag
    );
	assign flag=(a < b)?32'b1:32'b0;
endmodule
