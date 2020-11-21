`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    08:32:59 02/24/2020 
// Design Name: 
// Module Name:    MUX2T1_32 
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
module MUX2T1_32(input [31:0] I0,
					  input [31:0] I1,
					  input Sel,
					  output reg[31:0] o
				     );
always @* begin
	if (Sel == 1'b1)
		o <= I1;
	else
		o <= I0;
end
endmodule
