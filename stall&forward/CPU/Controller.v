`timescale 1ns / 1ps
 
`define R_TYPE_OPCODE 	6'b000000

`define ADDI_OPCODE 		6'b001000
`define ANDI_OPCODE 		6'b001100
`define ORI_OPCODE 		6'b001101
`define XORI_OPCODE 		6'b001110
`define LUI_OPCODE 		6'b001111
`define LW_OPCODE 		6'b100011
`define SW_OPCODE 		6'b101011
`define BEQ_OPCODE 		6'b000100
`define BNE_OPCODE 		6'b000101
`define SLTI_OPCODE 		6'b001010

`define J_OPCODE 			6'b000010
`define JAL_OPCODE 		6'b000011

`define ADD_FUN			6'b100000
`define SUB_FUN			6'b100010
`define AND_FUN			6'b100100
`define OR_FUN				6'b100101
`define XOR_FUN			6'b100110
`define NOR_FUN			6'b100111
`define SLT_FUN			6'b101010
`define SLL_FUN			6'b000000
`define SRL_FUN			6'b000010
`define JR_FUN				6'b001000

`define ALU_AND			4'b0000
`define ALU_OR				4'b0001
`define ALU_ADD			4'b0010
`define ALU_XOR			4'b0011
`define ALU_NOR			4'b0100
`define ALU_SRL			4'b0101
`define ALU_SUB			4'b0110
`define ALU_SLT			4'b0111
`define ALU_SLL			4'b1000
`define ALU_DEFAULT		4'bxxxx


module Controller(
		input wire [31:0] instruction,
		input wire		 	whether_rs_equal_rt,
		input wire        exe_should_write_register,
		input wire        mem_should_write_register,
		input wire [1 :0] exe_should_ALUout_or_datamem_or_lui,
		input wire [1 :0] mem_should_ALUout_or_datamem_or_lui,
		input wire [4 :0] exe_rt_or_rd_or_31,
		input wire [4 :0] mem_rt_or_rd_or_31,
		
		input wire			id_is_NOP,
		input wire			exe_is_NOP,
		input wire			mem_is_NOP,
		input wire [31:0] exe_instruction,
		input wire [31:0] mem_instruction,
		input wire [31:0] wb_instruction,
		
		output wire       should_write_register,
		output wire	[1:0] should_ALUout_or_datamem_or_lui,
		output wire  	   should_write_datamem,
		output wire [3:0] should_ALUcontrol,
		output wire       should_shamt_or_A,
		output wire       should_imm_extend_or_B,
		output wire	[1:0] should_rt_or_rd_or_31,
		output wire       should_sign_or_zero_extend_immediate,
		output wire	[1:0] should_j_or_branch_or_jr,
		output wire		 	should_jal,
		
		output wire		 	should_not_PC_plus_4,
		output wire       should_stall_control_hazard,
		output wire       should_stall_data_hazard,
		
		output wire [1:0] should_forward_rs,
		output wire [1:0] should_forward_rt,
		output wire       should_rtor0_wbdatamemout
    );

	wire [5:0] opcode   = instruction[31:26];
	wire [5:0] fun      = instruction[5:0];
	wire [4:0] rs       = instruction[25:21];
	wire [4:0] rt       = instruction[20:16];
	
	wire is_R_type		  = opcode == `R_TYPE_OPCODE;
	wire is_I_type      = opcode == `ADDI_OPCODE || opcode == `ANDI_OPCODE ||
								 opcode == `ORI_OPCODE  || opcode == `XORI_OPCODE ||
								 opcode == `LUI_OPCODE  || opcode == `LW_OPCODE   ||
								 opcode == `SW_OPCODE   || opcode == `BEQ_OPCODE  ||
								 opcode == `BNE_OPCODE  || opcode == `SLTI_OPCODE ;
	wire is_J_type      = opcode == `J_OPCODE || opcode == `JAL_OPCODE;
	
	wire is_JAL			  = opcode == `JAL_OPCODE;
	wire is_BEQ			  = opcode == `BEQ_OPCODE;
	wire is_BNE			  = opcode == `BNE_OPCODE;
	wire is_BRANCH      = opcode == `BEQ_OPCODE || opcode == `BNE_OPCODE;
	wire is_JR			  = opcode == `R_TYPE_OPCODE && fun == `JR_FUN;
	wire is_LUI			  = opcode == `LUI_OPCODE;
	wire is_LW          = opcode == `LW_OPCODE;
	wire is_SW          = opcode == `SW_OPCODE;
	wire is_J			  = opcode == `J_OPCODE;
	
	wire exe_is_LW      = exe_instruction[31:26] == `LW_OPCODE;
	wire exe_is_SW      = exe_instruction[31:26] == `SW_OPCODE;
	wire mem_is_LW      = mem_instruction[31:26] == `LW_OPCODE;
	wire mem_is_SW      = mem_instruction[31:26] == `SW_OPCODE;
	wire wb_is_LW       = wb_instruction[31:26]  == `LW_OPCODE;
	wire wb_is_SW       = wb_instruction[31:26]  == `SW_OPCODE;
	
	
	assign should_write_register = 
	(is_R_type && 
	(fun == `ADD_FUN ||
	 fun == `SUB_FUN ||
	 fun == `AND_FUN ||
	 fun == `OR_FUN  ||
	 fun == `XOR_FUN ||
	 fun == `NOR_FUN ||
	 fun == `SLT_FUN ||
	 fun == `SLL_FUN ||
	 fun == `SRL_FUN))
	|| (should_rt_or_rd_or_31 == 0 && rt != 0 && !is_BRANCH && !is_SW) // I-type must exclude bne/beq and sw
	|| (is_JAL);
	
	assign should_ALUout_or_datamem_or_lui = 
	(  is_LUI
		? 2'b10 : is_LW 
					 ? 2'b01 : 2'b00);
	
	assign should_write_datamem = opcode ==`SW_OPCODE;
	
	assign should_ALUcontrol = 
	(  is_JAL 
		? `ALU_ADD : is_R_type 
						 ? (fun == `ADD_FUN
							? `ALU_ADD : fun == `SUB_FUN
							? `ALU_SUB : fun == `AND_FUN
							? `ALU_AND : fun == `OR_FUN
							? `ALU_OR  : fun == `XOR_FUN
							? `ALU_XOR : fun == `NOR_FUN
							? `ALU_NOR : fun == `SLT_FUN
							? `ALU_SLT : fun == `SLL_FUN
							? `ALU_SLL : fun == `SRL_FUN
							? `ALU_SRL : fun == `JR_FUN
                            ? `ALU_DEFAULT): opcode == `ADDI_OPCODE
																 ? `ALU_ADD : opcode == `ANDI_OPCODE
																 ? `ALU_AND : opcode == `ORI_OPCODE
																 ? `ALU_OR  : opcode == `XORI_OPCODE
																 ? `ALU_NOR : opcode == `LUI_OPCODE
																 ? `ALU_SLL : opcode == `LW_OPCODE
																 ? `ALU_ADD : opcode == `SW_OPCODE
																 ? `ALU_ADD : opcode == `BEQ_OPCODE
																 ? `ALU_SUB : opcode == `BNE_OPCODE
																 ? `ALU_SUB : opcode == `SLTI_OPCODE
																 ? `ALU_SLT : (is_J s)
																				  ? `ALU_AND : `ALU_DEFAULT
	);
	
	assign should_shamt_or_A = (!is_JAL && (is_R_type && (fun == `SLL_FUN || fun == `SRL_FUN)));
	
	assign should_imm_extend_or_B = 
	(  !is_JAL && (opcode == `ADDI_OPCODE ||
						opcode == `ANDI_OPCODE ||
						opcode == `ORI_OPCODE  ||
						opcode == `XORI_OPCODE ||
						opcode == `LUI_OPCODE  ||
						opcode == `LW_OPCODE   ||
						opcode == `SW_OPCODE   ||
						opcode == `BEQ_OPCODE  ||
						opcode == `BNE_OPCODE  ||
						opcode == `SLTI_OPCODE ));
	
	assign should_rt_or_rd_or_31 = 
	(  is_I_type 
		? 2'b00 : is_R_type 
					 ? 2'b01 : is_JAL
								  ? 2'b10 : 2'b11);
	
	assign should_sign_or_zero_extend_immediate = 
	(  opcode == `ADDI_OPCODE ||
		opcode == `BNE_OPCODE  ||
		opcode == `BEQ_OPCODE  ||
		opcode == `SLTI_OPCODE ||
		opcode == `LW_OPCODE   ||
		opcode == `SW_OPCODE   );
	
	assign should_j_or_branch_or_jr = 
	(	is_J_type ? 2'b01 : (is_BRANCH) && (whether_rs_equal_rt == is_BEQ)
								  ? 2'b10 : (is_JR)
												 ? 2'b11 : 2'b00
	);
	
	assign should_jal = opcode == `JAL_OPCODE;
	
	assign should_not_PC_plus_4 = should_j_or_branch_or_jr != 2'b00;


	// J-type and bne/beq control hazard
	wire	 J_type_control_hazard = is_J_type;
	wire   JR_control_hazard 	  = is_JR;
	wire	 branch_control_hazard = is_BRANCH && (should_j_or_branch_or_jr == 2'b10);
	
	 
	assign should_stall_control_hazard =
							   (J_type_control_hazard ||
								 JR_control_hazard     ||
								 branch_control_hazard);
	
	// forward part
	
	// next inst needs ALUout result
	wire exe_write_rs = exe_should_write_register && (exe_rt_or_rd_or_31 == rs && rs != 0) && (exe_should_ALUout_or_datamem_or_lui != 2'b01);
	wire exe_write_rt = exe_should_write_register && (exe_rt_or_rd_or_31 == rt && rt != 0) && (exe_should_ALUout_or_datamem_or_lui != 2'b01);
	
	// next next inst needs ALUout result
	wire mem_write_rs = mem_should_write_register && (mem_rt_or_rd_or_31 == rs && rs != 0) && (mem_should_ALUout_or_datamem_or_lui != 2'b01);
	wire mem_write_rt = mem_should_write_register && (mem_rt_or_rd_or_31 == rt && rt != 0) && (mem_should_ALUout_or_datamem_or_lui != 2'b01);
	
	// next inst needs MEM load result
	// we have to stall and insert a bubble inst
	wire exe_lw_rs    = exe_should_write_register && (exe_rt_or_rd_or_31 == rs && rs != 0) && (exe_should_ALUout_or_datamem_or_lui == 2'b01);
	wire exe_lw_rt	   = exe_should_write_register && (exe_rt_or_rd_or_31 == rt && rt != 0) && (exe_should_ALUout_or_datamem_or_lui == 2'b01);
	
	// next next inst needs MEM load result
	wire mem_lw_rs    = mem_should_write_register && (mem_rt_or_rd_or_31 == rs && rs != 0) && (mem_should_ALUout_or_datamem_or_lui == 2'b01);
	wire mem_lw_rt	   = mem_should_write_register && (mem_rt_or_rd_or_31 == rt && rt != 0) && (mem_should_ALUout_or_datamem_or_lui == 2'b01);
	
	assign should_stall_data_hazard = (exe_lw_rs || exe_lw_rt) && (!id_is_NOP) && (!exe_is_NOP) && (!(is_SW && exe_is_LW));
	assign should_forward_rs = (mem_lw_rs==1)    ? 2'b11 : (
										(mem_write_rs==1) ? 2'b10 : (
										(exe_write_rs==1) ? 2'b01 : 2'b00));
	assign should_forward_rt = (mem_lw_rt==1)    ? 2'b11 : ( 
										(mem_write_rt==1) ? 2'b10 : (
										(exe_write_rt==1) ? 2'b01 : 2'b00));

	assign should_rtor0_wbdatamemout = (mem_is_SW && wb_is_LW);
endmodule
