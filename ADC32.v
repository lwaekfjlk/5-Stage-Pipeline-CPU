`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:20:59 03/01/2020 
// Design Name: 
// Module Name:    ADC32 
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
module ADC32(input [31:0] A,
				 input [31:0] B,
				 input C0,
				 output [31:0] S,
				 output Co
    );
assign S = A+B+C0;
assign Co = S[31];
endmodule
