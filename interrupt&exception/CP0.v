`timescale 1ns / 1ps
module CP0(
	//`ifdef DEBUG
	//input [4:0] debug_addr,
	//output [31:0] debug_data_reg,
	//`endif
	input wire  clk,clk_cpu,rst,
	input wire  [4 :0] mfc_CPRrd_address,
	
	input wire  [31:0] exe_PC,
	input wire  [31:0] mem_PC,
	input wire			 interrupt_or_not_one,
	input wire         interrupt_or_not_two,
	input wire         exception_or_not,
	//input wire  [31:0] wb_PC,
	input wire         mem_stall,
	input wire         should_eret_or_not,
	
	input wire  [4 :0] mtc_CPRrd_address,
	input wire         mtc_should_mtc_or_not,
	input wire  [31:0] mtc_GPRrt_data,

	output wire [31:0] mfc_CPRrd_data,
	output wire [31:0] epc_data,
	output wire [31:0] cause_data,
	output wire [31:0] ebase_data,
	output wire [31:0] status_data,
	output reg         gohandle_or_not = 0,
	output reg         gohandle_exception_or_not = 0,
	output reg         gohandle_interrupt_or_not_one = 0,
	output reg         gohandle_interrupt_or_not_two = 0,
	
	output wire [1:0] current_priority_wire,
	output wire [1:0] prev_priority_wire
	
    );
	
	reg  [31:0] CPR [0:31];
	integer i = 0;
	initial begin
		for (i = 0; i <= 31; i = i + 1) begin
			CPR[i] = 32'h0000_0000;
		end
	end	
	
	assign status_data = CPR[12];
	assign cause_data  = CPR[13];
	assign epc_data    = CPR[14];
	assign ebase_data  = CPR[15];
	assign current_priority_wire = current_priority;
	assign prev_priority_wire = prev_priority;
	assign mfc_CPRrd_data = CPR[mfc_CPRrd_address];
	

	
	// when interrupt enable is open and mode is supervisor mode or user mode and we are ready to jump to handler, we can begin doing exception
	wire gohandle_interrupt_or_not_one_wire = (CPR[12][0] == 1'b1) && (CPR[12][4:3] == 2'b01 || CPR[12][4:3] == 2'b10) && (interrupt_or_not_one == 1'b1) && (current_priority <= 2'h2);
	wire gohandle_interrupt_or_not_two_wire = (CPR[12][0] == 1'b1) && (CPR[12][4:3] == 2'b01 || CPR[12][4:3] == 2'b10) && (interrupt_or_not_two == 1'b1) && (current_priority <= 2'h3);
	wire gohandle_clk = clk_cpu || gohandle_interrupt_or_not_one_wire || gohandle_interrupt_or_not_two_wire;
	always @(posedge gohandle_clk or posedge rst) begin
		if (rst) begin
			gohandle_interrupt_or_not_one <= 0;
			gohandle_interrupt_or_not_two <= 0;
		end
		else if (gohandle_interrupt_or_not_one_wire) gohandle_interrupt_or_not_one <= gohandle_interrupt_or_not_one_wire;
		else if (gohandle_interrupt_or_not_two_wire) gohandle_interrupt_or_not_two <= gohandle_interrupt_or_not_two_wire;
		else begin
			gohandle_interrupt_or_not_one <= 0;
			gohandle_interrupt_or_not_two <= 0;
		end
	end
	
	
	assign gohandle_exception_or_not_wire = (CPR[12][0] == 1'b1) && (CPR[12][4:3] == 2'b01 || CPR[12][4:3] == 2'b10) && (exception_or_not == 1'b1) && (current_priority <= 2'h1);
	always @(posedge clk or posedge rst) begin
		if (rst) gohandle_exception_or_not <= 0;
		else gohandle_exception_or_not <= gohandle_exception_or_not_wire;
	end
	
	
	always @(posedge clk or posedge rst)begin
		if (rst) gohandle_or_not <= 0;
		else gohandle_or_not <= gohandle_exception_or_not || gohandle_interrupt_or_not_one || gohandle_interrupt_or_not_two;
	end
	
	// immediately update clk_cpu length signal
	integer j = 0;
	always @(negedge clk or posedge rst) 
	begin
		if (rst) for (j=1;j<=31;j=j+1) CPR[j] <= 32'h0000_0000;
		else if (mtc_should_mtc_or_not) CPR[mtc_CPRrd_address] <= mtc_GPRrt_data;
		else if (gohandle_or_not) CPR[14] <= mem_PC+4;
		else if (should_eret_or_not) CPR[12][0] <= 1'b1;
	end	
	
	
	reg  [1:0]  prev_priority = 0;
	reg  [1:0]  current_priority = 0;
	// update status signal based on eret--gohandle gap
	// must use = instead of <=
	wire handling_clk = gohandle_or_not || should_eret_or_not;
	always @(posedge handling_clk or posedge rst)
	begin
		if (rst)
		begin
			prev_priority = 0;
			current_priority = 0;
		end
		else if (gohandle_exception_or_not) begin
			prev_priority = current_priority;
			current_priority = 2'h1;
		end
		else if (gohandle_interrupt_or_not_one) begin
			prev_priority = current_priority;
			current_priority = 2'h2;
		end
		else if (gohandle_interrupt_or_not_two) begin
			prev_priority = current_priority;
			current_priority = 3'h3;
		end
		else if (should_eret_or_not && current_priority == prev_priority) begin
			current_priority = (current_priority == 2'b0) ? 2'b0 : current_priority - 2'b1;
			prev_priority = (prev_priority == 2'b0) ? 2'b0 : prev_priority - 2'b1;
		end
		else if(should_eret_or_not && current_priority != prev_priority)
			current_priority = prev_priority;
	end
	
endmodule
