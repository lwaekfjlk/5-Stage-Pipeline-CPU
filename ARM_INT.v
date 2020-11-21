`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    13:44:30 04/25/2020 
// Design Name: 
// Module Name:    ARM_INT 
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
module ARM_INT(
	input clk,
	input rst,
	input INT,
	input INTA,
	input eret,
	input [31:0]pc_next,
	output INTR,
	output reg[31:0] pc
    );
    reg int_act = 0, int_req_r = 0, int_en = 1;
    reg [31:0] EPC = 32'h00000000;                    // interrupt Trigger
    assign int_clr = rst | int_act;                 // clear interrupt Request
    
    always @(posedge INT or posedge int_clr) begin    // interrupt Request, clear interrupt Request
        if (int_clr == 1)
            int_req_r <= 0;  //clear interrupt Request
        else
            int_req_r <= 1;     //set interrupt Request
    end
    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            EPC     <= 0;
            int_act <= 0;
            int_en  <= 1;
        end
        else if (int_req_r & int_en) begin // int_req_r: interrupt Request reg
            EPC     <= pc_next; // interrupt return PC
            int_act <= 1; // interrupt Service
            int_en  <= 0; // interrupt disable
        end
        else begin
            int_act          <= 0;
            if (eret) int_en <= 1; // interrupt enable if pc <= EPC;
        end
    end
    
    // PC Out
    always @* begin
        if (rst == 1)
            pc <= 32'h00000000;
        else if (int_req_r & int_en)
            pc <= 32'h00000004; // interrupt Vector
        else if (eret)
            pc <= EPC;          // interrupt return
        else
            pc <= pc_next;      // next instruction
    end
endmodule
