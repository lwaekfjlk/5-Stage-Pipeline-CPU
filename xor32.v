`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    23:06:30 02/27/2020 
// Design Name: 
// Module Name:    xor32 
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
module xor32(input [31:0] A,
				 input [31:0] B,
				 output [31:0] res
    );
assign res = A ^ B;
endmodule
