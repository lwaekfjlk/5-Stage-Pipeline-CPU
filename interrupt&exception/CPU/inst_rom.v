`timescale 1ns / 1ps

module inst_rom (
	input wire rst,
	input wire clk,
	input wire gohandle_or_not,
	input wire [31:0] addr,
	output reg [31:0] dout
	);
	
	parameter ADDR_WIDTH = 7;
	
	reg [31:0] data [0:(1<<ADDR_WIDTH)-1];
	
	initial	begin
		$readmemh("inst_mem.hex", data);
	end
	
	reg [31:0] out;
	always @(negedge clk or posedge rst) begin
        if (rst || gohandle_or_not) begin
            out <= 32'b0;
        end else begin
            out <= data[addr[ADDR_WIDTH-1:0]];
        end
	end
	
	always @(*) begin
		if (addr[31:ADDR_WIDTH] != 0)
			dout = 32'h0;
		else
			dout = out;
	end
	
endmodule
