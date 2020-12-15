`timescale 1ns / 1ps

module CP0(
	input wire  clk,clk_cpu,rst,
	input wire  [4 :0] mfc_CPRrd_address,
	
	input wire  [31:0] id_PC,
	input wire  [31:0] exe_PC,
	input wire  [31:0] mem_PC,
	input wire  [31:0] wb_PC,
	input wire         mem_stall,
    
	input wire		   interrupt_or_not_one,
	input wire         interrupt_or_not_two,
	input wire         undefined_exception_or_not,
	input wire         overflow_exception_or_not,
	input wire         mem_outofrange_exception_or_not,

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
	output reg         gohandle_interrupt_or_not_two = 0
   );
	
	reg  [31:0] CPR [0:31];
	integer i = 0;
	initial begin
		for (i = 0; i <= 31; i = i + 1) begin
			CPR[i] = 32'h0000_0000;
		end
	end	
	
	assign status_data    = CPR[12];
	assign cause_data     = CPR[13];
	assign epc_data       = CPR[14];
	assign ebase_data     = CPR[15];
	assign mfc_CPRrd_data = CPR[mfc_CPRrd_address];

	
	// when interrupt enable is open and mask & pending has value, we are ready to jump to handler

	always @(posedge clk_cpu or posedge rst) begin
		if (rst) begin
			gohandle_interrupt_or_not_one <= 0;
			gohandle_interrupt_or_not_two <= 0;
		end
		else begin
			gohandle_interrupt_or_not_one <= ((CPR[12][0] == 1'b1) && (CPR[12][8] && CPR[13][8] == 1'b1));
			gohandle_interrupt_or_not_two <= ((CPR[12][0] == 1'b1) && (CPR[12][9] && CPR[13][9] == 1'b1));
		end
	end
	
	always @(posedge clk or posedge rst) begin
		if (rst) gohandle_exception_or_not <= 0;
		else gohandle_exception_or_not <= (CPR[12][0] == 1'b1) && ((undefined_exception_or_not || overflow_exception_or_not || mem_outofrange_exception_or_not) == 1'b1);
	end
	
	always @(posedge clk or posedge rst)begin
		if (rst) gohandle_or_not <= 0;
		else gohandle_or_not <= gohandle_exception_or_not || gohandle_interrupt_or_not_one || gohandle_interrupt_or_not_two;
	end
	
	// exception has the highest priority
	// because exception is OS code , cannot be interrupted
	// interrupt can wait since it is human action
	integer j = 0;
	always @(posedge clk or posedge rst) 
	begin
		if (rst) for (j=1;j<=31;j=j+1) CPR[j] = 32'h0000_0000;
		else begin
			if (mtc_should_mtc_or_not) 							      CPR[mtc_CPRrd_address] = mtc_GPRrt_data;
			
			// when return from exception or interruption
			if (should_eret_or_not) 								  begin
                                                                        // when eret int1 / int2 enable , set user mode, disable exception mode , enable interrupt
                                                                        CPR[12] = {CPR[12][31:16],8'b00000011,CPR[12][7:5],1'b1,CPR[12][3:2],2'b01};
                                                                        // clear exception type
                                                                        CPR[13] = {CPR[13][31:7],5'b00000,CPR[13][1:0]};
                                                                      end
			// when int1 and can int1 and can int
			if (interrupt_or_not_one && 
				 CPR[12][8] == 1'b1  &&
				 CPR[12][0] == 1'b1)	  							  begin
                                                                        // add int1 to the pending sequence , set exception type == interrupt
                                                                        CPR[13] = {CPR[13][31:16], {CPR[13][15:9],1'b1} ,CPR[13][7],5'b00000,CPR[13][1:0]};
                                                                      end
																			  
			// when is clk_cpu , can int , can int1 and have int 1 pending
			if (clk_cpu             &&
			   (CPR[12][0] == 1'b1) && 
               (CPR[12][8] && CPR[13][8] == 1'b1))    		          begin
                                                                        // int2 enable int1 disable , set kernel mode , enable interrupt
                                                                        CPR[12] = {CPR[12][31:16],8'b00000010,CPR[12][7:5],1'b0,CPR[12][3:2],2'b01};
                                                                      end
			// when int2 and can int2 and can int																  
			if (interrupt_or_not_two &&
				 CPR[12][9] == 1'b1  &&
				 CPR[12][0] == 1'b1)    							  begin
                                                                        // add pending sequence
                                                                        CPR[13] = {CPR[13][31:16], {CPR[13][15:10],1'b1,CPR[13][8]} ,CPR[13][7],5'b00000,CPR[13][1:0]};
                                                                      end
																			  
			// when is clk_cpu , can int , can int2 and have int 2 pending
			if (clk_cpu &&
				(CPR[12][0] == 1'b1) && 
				(CPR[12][9] && CPR[13][9] == 1'b1))     		      begin
                                                                        // int1 disable int2 disable , set kernel mode , enable interrupt
                                                                        CPR[12] = {CPR[12][31:16],8'b00000000,CPR[12][7:5],1'b0,CPR[12][3:2],2'b01};
                                                                      end
																			  
			// when is undefined exception															  
			if (undefined_exception_or_not) 		 				  begin
                                                                        // int1 disable int2 disable , set kernel mode , enable interrupt and exception mode
                                                                        CPR[12] = {CPR[12][31:16],8'b00000000,CPR[12][7:5],1'b0,CPR[12][3:2],2'b11};
                                                                        // set exception type
                                                                        CPR[13] = {CPR[13][31:7],5'b00001,CPR[13][1:0]};
                                                                      end
			
			// when is memory out of range exception
			if (mem_outofrange_exception_or_not)		 		      begin
                                                                        // int1 disable int2 disable , set kernel mode , enable interrupt and exception mode
                                                                        CPR[12] = {CPR[12][31:16],8'b00000000,CPR[12][7:5],1'b0,CPR[12][3:2],2'b11};
                                                                        // set exception type
                                                                        CPR[13] = {CPR[13][31:7],5'b00100,CPR[13][1:0]};
                                                                      end
			
			// when overflow exception
			if (overflow_exception_or_not)		  		 		      begin
                                                                        // int1 disable int2 disable , set kernel mode , enable interrupt and exception mode
                                                                        CPR[12] = {CPR[12][31:16],8'b00000000,CPR[12][7:5],1'b0,CPR[12][3:2],2'b11};
                                                                        // set exception type
                                                                        CPR[13] = {CPR[13][31:7],5'b01100,CPR[13][1:0]};
                                                                      end

			// when jumpt to handle interrupt or exception
			if (gohandle_or_not) 					 				  begin
                                                                        // set EPC
                                                                        CPR[14] = (mem_PC < exe_PC) ? exe_PC : id_PC;
                                                                      end
		end
	end	
	
endmodule
