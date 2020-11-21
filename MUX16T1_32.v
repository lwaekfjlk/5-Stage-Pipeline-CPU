`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:16:28 09/28/2020 
// Design Name: 
// Module Name:    MUX16T1_32 
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
module MUX16T1_32(input [31:0] I0,
					 input [31:0] I1,
					 input [31:0] I2,
					 input [31:0] I3,
					 input [31:0] I4,
					 input [31:0] I5,
					 input [31:0] I6,
					 input [31:0] I7,
					 input [31:0] I8,
					 input [31:0] I9,
					 input [31:0] I10,
					 input [31:0] I11,
					 input [31:0] I12,
					 input [31:0] I13,
					 input [31:0] I14,
					 input [31:0] I15,
					 input [3:0] s,
					 output reg[31:0] o = 0
    );
always @*
	case (s)
		4'b0000: o <= I0;
		4'b0001: o <= I1;
		4'b0010: o <= I2;
		4'b0011: o <= I3;
		4'b0100: o <= I4;
		4'b0101: o <= I5;
		4'b0110: o <= I6;
		4'b0111: o <= I7;
		4'b1000: o <= I8;
		4'b1001: o <= I9;
		4'b1010: o <= I10;
		4'b1011: o <= I11;
		4'b1100: o <= I12;
		4'b1101: o <= I13;
		4'b1110: o <= I14;
		4'b1111: o <= I15;
		default:;
	endcase
endmodule
