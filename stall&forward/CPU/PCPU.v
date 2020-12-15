`timescale 1ns / 1ps
`define DEBUG

module PCPU(
             `ifdef DEBUG
             input wire [5:0] debug_addr,
             output wire [31:0] debug_data,
             `endif
             input clk,
             input clk_cpu,
             input rst
			);

///////////////////////////////////////////////////////////////////////////////////////////////////////////////
// variable declare
///////////////////////////////////////////////////////////////////////////////////////////////////////////////

// PC register
	reg [31:0] if_PC = 0;
	
// IF stage
	wire [31:0] if_PC_plus_4;
	wire [31:0] if_PC_next;
	wire [31:0] rom_instruction;
	
	// special register
	reg  [31:0] if_instruction = 0;
	
// IF-ID register
	reg [31:0]  id_PC_plus_4 = 0;
	reg [31:0]  id_instruction = 0;
	
// ID stage
	// controller wire (from up to down)
	wire 			id_should_write_register;
	wire [1:0]	    id_should_ALUout_or_datamem_or_lui;
	
	wire 			id_should_write_datamem;
			
	wire [3:0]	    id_should_ALUcontrol;
	wire 			id_should__shamt_or_A;
	wire 			id_should_imm_extend_or_B;
	
	wire 			id_whether_rs_equal_rt;
	
	wire [1:0]	    id_should_rt_or_rd_or_31;
	wire 			id_should_sign_or_zero_extend_immediate;
	wire [1:0]	    id_should_j_or_branch_or_jr;
	wire 			id_should_jal;
	
	wire id_should_not_PC_plus_4;
	wire id_should_stall_data_hazard;
	wire id_should_stall_control_hazard;
	
	//forward control signal
	wire [1:0] id_should_forward_rs;
	wire [1:0] id_should_forward_rt;
	
	// datapath wire
    wire [4:0] id_rs;
    wire [4:0] id_rt;
	wire [4:0] id_rd;
	wire [4:0] id_shamt;
	
	wire [15:0] id_imm;
	wire [31:0] id_imm_extend;
	
	wire [31:0] id_j_type_address;
	wire [31:0] id_branch_address;
	wire [31:0] id_j_or_branch_or_jr_address;
	
	wire [31:0] id_rs_mux;
	wire [31:0] id_rt_mux;
	wire [31:0] id_rs_data;
	wire [31:0] id_rt_data;
	wire [31:0] id_rs_or_PC_plus_4;
	wire [31:0] id_rt_or_0;
	
	wire [4 :0] id_rt_or_rd_or_31;
	
	wire 		id_is_NOP;

// ID-EXE register
	reg 	   exe_should_write_register = 0;
	reg [1 :0] exe_should_ALUout_or_datamem_or_lui = 0;
	reg        exe_should_write_datamem = 0;
	reg [3 :0] exe_should_ALUcontrol = 0;
	reg        exe_should_shamt_or_A = 0;
	reg        exe_should_imm_extend_or_B = 0;
	reg [31:0] exe_rs_or_PC_plus_4 = 0;
	reg [31:0] exe_rt_or_0;
	reg [4 :0] exe_shamt = 0;
	reg [31:0] exe_imm_extend = 0;
	reg [4 :0] exe_rt_or_rd_or_31 = 0;
	reg [31:0] exe_instruction = 0;
	
	
// EXE stage
	wire [31:0] exe_ALU_input_A;
	wire [31:0] exe_ALU_input_B;
	wire [31:0] exe_imm_lui;
	
	wire 		exe_zero;
	wire		exe_overflow;
	wire [31:0] exe_ALUout;
	
	wire        exe_is_NOP;
	
// EXE-MEM register
	reg 		mem_should_write_register = 0;
	reg [1:0]   mem_should_ALUout_or_datamem_or_lui = 0;
	reg			mem_should_write_datamem = 0;
	
	reg [31:0]  mem_ALUout = 0;
	reg [31:0]  mem_rt_or_0 = 0;
	reg [31:0]  mem_imm_lui = 0;
	reg [4 :0]  mem_rt_or_rd_or_31 = 0; 
	
	reg [31:0]  mem_instruction = 0;

// MEM stage
	wire  		mem_should_rtor0_wbdatamemout;

	wire [31:0] mem_datamem_out;
	wire [31:0] mem_datamem_out_miobus_out;
	wire [31:0] mem_sw_value;
	 
	wire   		mem_is_NOP;
	 
// MEM-WB register
	reg			wb_should_write_register = 0;
	reg [1 :0]	wb_should_ALUout_or_datamem_or_lui = 0;
	reg [31:0] 	wb_datamem_out = 0;
	reg [31:0]  wb_ALUout = 0;
	reg [31:0]  wb_imm_lui = 0;
	reg [4 :0]  wb_rt_or_rd_or_31 = 0;
	reg [31:0]  wb_instruction = 0;
	
// WB stage
	wire [31:0] wb_write_back_address;
	wire [31:0] wb_write_back_data;
	

///////////////////////////////////////////////////////////////////////////////////////////////////////////////
// debug information
///////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	`ifdef DEBUG
		wire [31:0] debug_data_reg;
		
		reg [31:0]  debug_data_signal;
		always @(posedge clk)begin
			case (debug_addr[4:0])
				5'b00000: debug_data_signal <= if_instruction;
				5'b00001: debug_data_signal <= id_instruction;
				5'b00010: debug_data_signal <= exe_instruction;
				5'b00011: debug_data_signal <= mem_instruction;
				5'b00100: debug_data_signal <= wb_instruction;
				5'b00101: debug_data_signal <= if_PC;
				
				5'b00110: debug_data_signal <= wb_write_back_address;
				5'b00111: debug_data_signal <= wb_write_back_data;
				
				5'b01000: debug_data_signal <= {30'b0, clk_cpu};
				
				5'b01001: debug_data_signal <= {30'b0, id_should_forward_rs};
				5'b01010: debug_data_signal <= {30'b0, id_should_forward_rt};
				5'b01011: debug_data_signal <= {31'b0, id_should_stall_data_hazard};
				5'b01100: debug_data_signal <= {31'b0, id_should_stall_control_hazard};

				default: debug_data_signal <= 32'hFFFF_FFFF;
			endcase
		end
		assign debug_data = debug_addr[5] ? debug_data_signal : debug_data_reg;
	`else 
		//wire clk_cpu;
		//assign clk_cpu = clk;
	`endif

///////////////////////////////////////////////////////////////////////////////////////////////////////////////
// PC
///////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	always @(posedge clk_cpu or posedge rst)
		if (rst) if_PC <= 0;
		else if (id_should_stall_data_hazard) if_PC <= if_PC;
			  else if_PC <= if_PC_next;

///////////////////////////////////////////////////////////////////////////////////////////////////////////////
// IF Stage
///////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	assign if_PC_plus_4 = if_PC+4;

	always @(*) begin
		if_instruction <= rom_instruction;
	end
	
	inst_rom INST_ROM (.rst(rst),
					 .clk(clk_cpu),
					 .addr({2'b0, if_PC[31:2]}),
					 .dout(rom_instruction[31:0]));
							  
	assign if_PC_next = (id_should_not_PC_plus_4 == 1'b0) ? if_PC_plus_4[31:0] : id_j_or_branch_or_jr_address[31:0];

///////////////////////////////////////////////////////////////////////////////////////////////////////////////
// IF-ID register
///////////////////////////////////////////////////////////////////////////////////////////////////////////////

	always @(posedge clk_cpu or posedge rst) begin
		if (rst) begin
			id_PC_plus_4 <= 0;
			id_instruction <= 0;
		end else if (id_should_stall_data_hazard) begin
			id_PC_plus_4 <= id_PC_plus_4;
			id_instruction <= id_instruction;
		end else if (id_should_stall_control_hazard) begin
			id_PC_plus_4 <= 0;
			id_instruction <= 0;
		end else begin
			id_PC_plus_4 <= if_PC_plus_4;
			id_instruction <= if_instruction;
		end
	end

///////////////////////////////////////////////////////////////////////////////////////////////////////////////
// ID Stage
///////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	assign id_rs    = id_instruction[25:21];
	assign id_rt    = id_instruction[20:16];
	assign id_rd    = id_instruction[15:11];
	assign id_shamt = id_instruction[10:6];
	assign id_imm   = id_instruction[15:0];
	assign id_imm_extend 	 = {id_should_sign_or_zero_extend_immediate ? {16{id_imm[15]}} : 16'b0 , id_imm};
	assign id_j_type_address = {id_PC_plus_4[31:28],id_instruction[25:0],2'b0};
	assign id_branch_address = id_PC_plus_4 + {id_imm_extend[29:0] , 2'b0};
	assign id_is_NOP = (id_instruction == 32'b0) ? 1'b1 : 1'b0;


	Controller PController(.instruction(id_instruction),
						  .whether_rs_equal_rt(id_whether_rs_equal_rt),
						  .exe_should_write_register(exe_should_write_register),
						  .mem_should_write_register(mem_should_write_register),
						  .exe_rt_or_rd_or_31(exe_rt_or_rd_or_31),
						  .mem_rt_or_rd_or_31(mem_rt_or_rd_or_31),
						  .exe_should_ALUout_or_datamem_or_lui(exe_should_ALUout_or_datamem_or_lui),
						  .mem_should_ALUout_or_datamem_or_lui(mem_should_ALUout_or_datamem_or_lui),
						  .id_is_NOP(id_is_NOP),
						  .exe_is_NOP(exe_is_NOP),
						  .mem_is_NOP(mem_is_NOP),
						  .exe_instruction(exe_instruction),
						  .mem_instruction(mem_instruction),
						  .wb_instruction(wb_instruction),
						  
						  .should_write_register(id_should_write_register),
						  .should_ALUout_or_datamem_or_lui(id_should_ALUout_or_datamem_or_lui),
						  .should_write_datamem(id_should_write_datamem),
						  .should_ALUcontrol(id_should_ALUcontrol),
						  .should_shamt_or_A(id_should_shamt_or_A),
						  .should_imm_extend_or_B(id_should_imm_extend_or_B),
						  
						  .should_rt_or_rd_or_31(id_should_rt_or_rd_or_31),
						  .should_sign_or_zero_extend_immediate(id_should_sign_or_zero_extend_immediate),
						  .should_j_or_branch_or_jr(id_should_j_or_branch_or_jr),
						  .should_jal(id_should_jal),
						  
						  .should_not_PC_plus_4(id_should_not_PC_plus_4),
						  .should_stall_control_hazard(id_should_stall_control_hazard),
						  .should_stall_data_hazard(id_should_stall_data_hazard),
						  
						  .should_forward_rs(id_should_forward_rs),
						  .should_forward_rt(id_should_forward_rt),
						  
						  .should_rtor0_wbdatamemout(mem_should_rtor0_wbdatamemout)
						  );

	Regs   RegFile(`ifdef DEBUG
					.debug_addr(debug_addr[4:0]),
					.debug_data_reg(debug_data_reg),
					`endif
					.clk(clk_cpu), 
					.should_write(wb_should_write_register), 
					.rst(rst), 
					.read_address_A(id_rs), 
					.read_address_B(id_rt), 
					.write_address(wb_write_back_address), 
					.write_data(wb_write_back_data), 
					.read_data_A(id_rs_data), 
					.read_data_B(id_rt_data));
	
	assign id_whether_rs_equal_rt = (id_rs_mux == id_rt_mux) ? 1'b1 : 1'b0;

	assign id_rs_or_PC_plus_4 = id_should_jal ? id_PC_plus_4 : id_rs_mux;
	assign id_rt_or_0         = id_should_jal ? 32'b0 : id_rt_mux;
	
	assign id_j_or_branch_or_jr_address = (id_should_j_or_branch_or_jr == 2'b00) ? 32'b0 :
                                          (id_should_j_or_branch_or_jr == 2'b01) ? id_j_type_address :
                                          (id_should_j_or_branch_or_jr == 2'b10) ? id_branch_address : id_rs_data ;

	assign id_rt_or_rd_or_31 = (id_should_rt_or_rd_or_31 == 2'b00) ? id_rt :
                               (id_should_rt_or_rd_or_31 == 2'b01) ? id_rd :
                               (id_should_rt_or_rd_or_31 == 2'b10) ? 5'b11111 : 5'b00000 ;

	assign id_rs_mux = (id_should_forward_rs == 2'b00) ? id_rs_data :
                       (id_should_forward_rs == 2'b01) ? exe_ALUout :
                       (id_should_forward_rs == 2'b10) ? mem_ALUout : mem_datamem_out_miobus_out;

	assign id_rt_mux = (id_should_forward_rt == 2'b00) ? id_rt_data :
                       (id_should_forward_rt == 2'b01) ? exe_ALUout :
                       (id_should_forward_rt == 2'b10) ? mem_ALUout : mem_datamem_out_miobus_out;
	
///////////////////////////////////////////////////////////////////////////////////////////////////////////////
// ID-EXE register
///////////////////////////////////////////////////////////////////////////////////////////////////////////////


	always @(posedge clk_cpu or posedge rst) begin
		if (rst || id_should_stall_data_hazard) begin
			exe_should_write_register <= 0;
			exe_should_ALUout_or_datamem_or_lui <= 0;
			
			exe_should_write_datamem <= 0;
			
			exe_should_ALUcontrol <= 0;
			exe_should_shamt_or_A <= 0;
			exe_should_imm_extend_or_B <= 0;
			
			exe_rs_or_PC_plus_4 <= 0;
			exe_rt_or_0 <= 0;
			
			exe_shamt <= 0;
			exe_imm_extend <= 0;
			exe_rt_or_rd_or_31 <= 0;
			
			exe_instruction <= 0;
		end else begin
			// control signal
			exe_should_write_register <= id_should_write_register;
			exe_should_ALUout_or_datamem_or_lui <= id_should_ALUout_or_datamem_or_lui;
			
			exe_should_write_datamem <= id_should_write_datamem;
			
			exe_should_ALUcontrol <= id_should_ALUcontrol;
			exe_should_shamt_or_A <= id_should_shamt_or_A;
			exe_should_imm_extend_or_B <= id_should_imm_extend_or_B;
			
			// datapath signal 
			exe_rs_or_PC_plus_4 <= id_rs_or_PC_plus_4;
			exe_rt_or_0 <= id_rt_or_0;
			
			exe_shamt <= id_shamt;
			exe_imm_extend <= id_imm_extend;
			exe_rt_or_rd_or_31 <= id_rt_or_rd_or_31;
			
			exe_instruction <= id_instruction;
		end
	end

///////////////////////////////////////////////////////////////////////////////////////////////////////////////
// EXE stage
///////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	assign exe_ALU_input_A = exe_should_shamt_or_A ?  exe_shamt : exe_rs_or_PC_plus_4;
	assign exe_ALU_input_B = exe_should_imm_extend_or_B ? exe_imm_extend : exe_rt_or_0;
	
	assign exe_imm_lui = {exe_instruction[15:0], 16'b0};
	assign exe_is_NOP = (exe_instruction == 32'b0) ? 1'b1 : 1'b0;
	
	alu  ALU (.A(exe_ALU_input_A[31:0]), 
				 .ALU_Ctr(exe_should_ALUcontrol[3:0]), 
				 .B(exe_ALU_input_B[31:0]), 
				 .overflow(exe_overflow), 
				 .res(exe_ALUout[31:0]), 
				 .zero(exe_zero));

///////////////////////////////////////////////////////////////////////////////////////////////////////////////
// EXE-MEM register
///////////////////////////////////////////////////////////////////////////////////////////////////////////////

	
	always @ (posedge clk_cpu or posedge rst)begin
		if (rst) begin
			mem_should_write_register <= 0;
			mem_should_ALUout_or_datamem_or_lui <= 0;
			
			mem_should_write_datamem <= 0;
			
			mem_ALUout <= 0;
			mem_rt_or_0 <= 0;
			mem_imm_lui <= 0;
			mem_rt_or_rd_or_31 <= 0;
			
			mem_instruction <= 0;
		end else begin
			// control signal
			mem_should_write_register <= exe_should_write_register;
			mem_should_ALUout_or_datamem_or_lui <= exe_should_ALUout_or_datamem_or_lui;
			
			mem_should_write_datamem <= exe_should_write_datamem;
			
			mem_ALUout <= exe_ALUout;
			mem_rt_or_0 <= exe_rt_or_0;
			mem_imm_lui <= exe_imm_lui[31:0];
			mem_rt_or_rd_or_31 <= exe_rt_or_rd_or_31;
			
			mem_instruction <= exe_instruction[31:0];
		end
	end
	
///////////////////////////////////////////////////////////////////////////////////////////////////////////////
// MEM stage
///////////////////////////////////////////////////////////////////////////////////////////////////////////////

	assign mem_is_NOP = (mem_instruction == 32'b0) ? 1'b1 : 1'b0;
	
	data_ram DATA_RAM (
		.clk(clk_cpu),
		.we(mem_should_write_datamem),
		.addr(mem_ALUout[31:0]),
		.din(mem_sw_value),
		.dout(mem_datamem_out[31:0])
		);
		
	assign mem_datamem_out_miobus_out = mem_datamem_out;

	assign mem_sw_value = (mem_should_rtor0_wbdatamemout == 1'b0) ? mem_rt_or_0 : wb_datamem_out ; 
	
///////////////////////////////////////////////////////////////////////////////////////////////////////////////
// MEM-WB register
///////////////////////////////////////////////////////////////////////////////////////////////////////////////

	
	always @(posedge clk_cpu or posedge rst) begin
		if (rst) begin
			wb_should_write_register <= 0;
			wb_should_ALUout_or_datamem_or_lui <= 0;
			
			wb_datamem_out <= 0;
			wb_ALUout <= 0;
			wb_imm_lui <= 0;
			
			wb_instruction <= 0;
		end else begin
			wb_should_write_register <= mem_should_write_register;
			wb_should_ALUout_or_datamem_or_lui <= mem_should_ALUout_or_datamem_or_lui;
			
			wb_datamem_out <= mem_datamem_out_miobus_out;
			wb_ALUout <= mem_ALUout;
			wb_imm_lui <= mem_imm_lui[31:0];
			wb_rt_or_rd_or_31 <= mem_rt_or_rd_or_31;
			
			wb_instruction <= mem_instruction;
		end
	end
	
///////////////////////////////////////////////////////////////////////////////////////////////////////////////
// WB stage
///////////////////////////////////////////////////////////////////////////////////////////////////////////////

	assign wb_write_back_address = wb_rt_or_rd_or_31;
	
	assign wb_write_back_data = (wb_should_ALUout_or_datamem_or_lui == 2'b00) ? wb_ALUout :
								(wb_should_ALUout_or_datamem_or_lui == 2'b01) ? wb_datamem_out :
								(wb_should_ALUout_or_datamem_or_lui == 2'b10) ? wb_imm_lui :
								wb_imm_lui ;
		
endmodule
