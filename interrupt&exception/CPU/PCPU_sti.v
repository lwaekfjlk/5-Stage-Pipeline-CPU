`timescale 1ns / 1ps

module PCPU_sti;

	// Inputs
	reg [5:0] debug_addr;
	reg clk;
	reg clk_cpu;
	reg rst;
	reg interrupt_priority_one;
	reg interrupt_priority_two;

	// Outputs
	wire [31:0] debug_data;
	// Instantiate the Unit Under Test (UUT)
	PCPU uut (
		.debug_addr(debug_addr), 
		.debug_data(debug_data), 
		.clk(clk), 
		.clk_cpu(clk_cpu),
		.rst(rst),
		.interrupt_one(interrupt_priority_one),
		.interrupt_two(interrupt_priority_two)
	);

	initial begin
		// Initialize Inputs
		debug_addr = 0;
		clk = 0;
		clk_cpu = 0;
		rst = 0;
		interrupt_priority_one = 0;
		interrupt_priority_two = 0;
		#20;
		rst = 1;
		#20;
		rst = 0;
		
		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		fork
		 forever #5 clk = ~clk; 
		 forever 
		 begin
			#20 clk_cpu = ~clk_cpu;
			#5  clk_cpu = ~clk_cpu;
		end
		 begin
		 
			#3862 	interrupt_priority_one = 1;
			#20 		interrupt_priority_one = 0;
			//#20   	interrupt_priority_two = 1;
			//#20      interrupt_priority_two = 0;
			#1550  interrupt_priority_two = 1;
			#20    interrupt_priority_two = 0;
			//#20  interrupt_priority_one = 1;
			//#5    interrupt_priority_one = 0;
		 
		 end
		 
		join

	end
      
endmodule

