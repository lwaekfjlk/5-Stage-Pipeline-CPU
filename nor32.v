`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    13:06:38 02/28/2020 
// Design Name: 
// Module Name:    nor32 
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
module nor32(input [31:0] A,
	          input [31:0] B,
				 output [31:0] res
    );
assign res = ~(A|B);
endmodule
