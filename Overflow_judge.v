`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:55:16 03/29/2020 
// Design Name: 
// Module Name:    overflow_judge 
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
module overflow_judge(input at,
							 input [2:0] alu_ctr,
                      input bt,
							 input rt,
							 output res
    );
wire bbt;
assign bbt = (alu_ctr == 3'b010)? bt:((alu_ctr == 3'b110 || alu_ctr == 3'b111)? ~bt : ~at);
assign res = (at == bbt && at != rt)? 1 :0;

endmodule
