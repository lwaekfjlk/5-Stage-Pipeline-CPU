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
	wire bbt;
   
	assign and32_out =   A[31:0] & B[31:0];
	assign or32_out  =   A[31:0] | B[31:0];
	assign xor32_out =   A[31:0] ^ B[31:0];
	assign nor32_out = ~(A[31:0] | B[31:0]);
	assign srl32_out = 	B[31:0] >> A[31:0];
	assign sll32_out = 	B[31:0] << A[31:0];
	assign slt32_out =  (A[31:0] < B[31:0])  ? 32'b1 : 32'b0;
	assign ABC32_out =  (ALU_Ctr[2] == 1'b1) ? (A[31:0] + (~B[31:0] + 32'b1)) 
													     : (A[31:0] + B[31:0]);
	assign zero      = ~(|A[31:0]);
	
	assign bbt       =  (ALU_Ctr[2:0] == 3'b010)? B[31]:((ALU_Ctr[2:0] == 3'b110 || ALU_Ctr[2:0] == 3'b111)? ~B[31] : ~A[31]);
	assign overflow  =  (A[31] == bbt && A[31] != ABC32_out[31])? 1 :0;

	assign res = (ALU_Ctr == 4'b0000) ? and32_out :
					 (ALU_Ctr == 4'b0001) ? or32_out  :
					 (ALU_Ctr == 4'b0010) ? ABC32_out :
					 (ALU_Ctr == 4'b0011) ? xor32_out :
					 (ALU_Ctr == 4'b0100) ? nor32_out :
					 (ALU_Ctr == 4'b0101) ? srl32_out :
					 (ALU_Ctr == 4'b0110) ? ABC32_out :
					 (ALU_Ctr == 4'b0111) ? slt32_out :
					 (ALU_Ctr == 4'b1000) ? sll32_out : 32'b0 ;
					
endmodule
