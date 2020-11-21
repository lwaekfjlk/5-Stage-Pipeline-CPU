`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    23:46:31 04/05/2020 
// Design Name: 
// Module Name:    REG32 
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
module REG32(input clk,
				 input rst,
				 input id_shouldstall,
				 input [31:0] PC_next,
				 output reg [31:0] PC = 0
    );
always @(posedge clk or posedge rst)
	if (rst) PC <= 0;
	else if (id_shouldstall == 1) PC <= PC;
		  else PC <= PC_next;

endmodule
