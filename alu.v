`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:41:17 05/17/2020 
// Design Name: 
// Module Name:    ALU 
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
module alu(input [31:0]A, 
           input [31:0]B, 
           input [3:0]ALU_Ctr, 

           output overflow, 
           output [31:0]res, 
           output zero
			  );
   
   wire [31:0] ABC32_out;
   wire [31:0] and32_out;
   wire [31:0] or32_out;
   wire [31:0] xor32_out;
   wire [31:0] nor32_out;
   wire [31:0] srl32_out;
	wire [31:0] sll32_out;
	wire [31:0] slt32_out;
   wire Co;
	wire Coo;
   
   and32  alu_and32 (.A(A[31:0]), .B(B[31:0]), .res(and32_out[31:0]));

   or32   alu_or32  (.A(A[31:0]), .B(B[31:0]), .res(or32_out[31:0]));
						
   ABC32  alu_abc32 (.A(A[31:0]),  .B(B[31:0]), .sub(ALU_Ctr[2]), .Co(Co), .S(ABC32_out[31:0]));
									 
   xor32  alu_xor32 (.A(A[31:0]), .B(B[31:0]), .res(xor32_out[31:0]));
						  
   nor32  alu_nor32 (.A(A[31:0]), .B(B[31:0]), .res(nor32_out[31:0]));
			
   srl32  alu_srl32 (.A(A[31:0]), .B(B[31:0]), .res(srl32_out[31:0]));
						  
	sll32  alu_sll32 (.A(A[31:0]), .B(B[31:0]), .res(sll32_out[31:0]));	
						  
   slt32  alu_slt32 (.a(A[31:0]), .b(B[31:0]), .flag(slt32_out[31:0]));
	
	or_bit_32  alu_or_bit_32 (.A(res[31:0]), .o(zero));
					

   overflow_judge  alu_overflow (.alu_ctr(ALU_Ctr[2:0]), 
                                .at(A[31]), 
                                .bt(B[31]), 
                                .rt(ABC32_out[31]), 
                                .res(overflow));
										  
   XOR2  alu_xor2 (.I0(overflow), 
                  .I1(Co), 
                  .O(Coo));


   MUX16T1_32  alu_MUX16T1_32 (.I0(and32_out[31:0]), 
                            .I1(or32_out[31:0]), 
                            .I2(ABC32_out[31:0]), 
                            .I3(xor32_out[31:0]), 
                            .I4(nor32_out[31:0]), 
                            .I5(srl32_out[31:0]), 
                            .I6(ABC32_out[31:0]), 
                            .I7(slt32_out[31:0]), 
									 .I8(sll32_out[31:0]),
									 .I9(32'b0),
									 .I10(32'b0),
									 .I11(32'b0),
									 .I12(32'b0),
									 .I13(32'b0),
									 .I14(32'b0),
									 .I15(32'b0),
                            .s(ALU_Ctr[3:0]), 
                            .o(res[31:0]));
					
endmodule
