`timescale 1ns / 1ps
`define DEBUG

module Regs(
            `ifdef DEBUG
            input [4:0] debug_addr,
            output [31:0] debug_data_reg,
            `endif
            input clk, rst, should_write,
            input [4:0] read_address_A, read_address_B,
            input [31:0] write_data, write_address,
            output [31:0] read_data_A, read_data_B
           );
           
	reg [31:0] registers [1:31];
	integer i = 0;
	initial begin
		for (i = 1; i <= 31; i = i + 1) begin
			registers[i] = 32'hffff_ffff;
		end
	end	
	
	assign read_data_A = (read_address_A == 0) ? 0 : registers[read_address_A];
	assign read_data_B = (read_address_B == 0) ? 0 : registers[read_address_B];

	integer j = 0;
	always @(negedge clk or posedge rst) 
	begin
		if (rst) for (j=1;j<=31;j=j+1) registers[j] <= 32'hffff_ffff;
		else if ((write_address != 0)&&(should_write == 1))
			registers[write_address] <= write_data;
	end

	`ifdef DEBUG
	assign debug_data_reg = (debug_addr == 0) ? 0 : registers[debug_addr];
	`endif 
endmodule
