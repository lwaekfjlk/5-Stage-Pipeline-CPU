`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    00:00:25 10/22/2020 
// Design Name: 
// Module Name:    ABC32 
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
module ABC32(input  [31:0] A, 
             input  [31:0] B,
             input  sub, 
             output Co, 
             output [31:0] S);
   
   wire [31:0] xor_out;
   
   ADC32  A1 (.A(A[31:0]), 
             .B(xor_out[31:0]), 
             .C0(sub), 
             .Co(Co), 
             .S(S[31:0]));
   xor32  A2 (.A({sub, sub, sub, sub, sub, sub, sub, sub, sub, sub, sub, sub, sub, sub, sub, sub, sub, sub, sub, sub, sub, sub, sub, sub, sub, sub, sub, sub, sub, sub, sub, sub}), 
             .B(B[31:0]), 
             .res(xor_out[31:0]));
				 
endmodule