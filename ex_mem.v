`include "const.v"

module ex_mem
  (
   input wire 						 clk,
   input wire 						 rst,
   input wire 						 rdy,
   
   input wire 						 write_pc,
   input wire [31 : 0] 				 pc_val,
   input wire [`LOG_REG_CNT - 1 : 0] jmp_rd,
   input wire [31 : 0] 				 jmp_rd_val,

   input wire [`LOG_REG_CNT - 1 : 0] reg_id,
   input wire [1 : 0] 				 reg_op,
   input wire [`REG_LEN - 1 : 0] 	 reg_val,
   input wire [31 : 0] 				 mem_addr,
   input wire [2 : 0] 				 mem_type,

   output reg 						 mem_write_pc,
   output reg [31 : 0] 				 mem_pc_val,
   output reg [`LOG_REG_CNT - 1 : 0] mem_jmp_rd,
   output reg [31 : 0] 				 mem_jmp_rd_val,

   output reg [`LOG_REG_CNT - 1 : 0] mem_reg_id,
   output reg [1 : 0] 				 mem_reg_op,
   output reg [`REG_LEN - 1 : 0] 	 mem_reg_val,
   output reg [31 : 0] 				 mem_mem_addr,
   output reg [2 : 0] 				 mem_mem_type,

   input wire 						 mem_done,
   output reg 						 ex_mem_done
  
   );

   reg 								 wait_mem;

   always @ (posedge clk) begin
	  if( rst ) begin
		 mem_write_pc <= 0;
		 mem_reg_op <= `MEM_REG_IDLE;
		 ex_mem_done <= 0;
		 wait_mem <= 0;
	  end else if( rdy == 0 ) begin
		 ;
	  end else begin
		 ex_mem_done <= 0;
		 
		 if( wait_mem ) begin
			if( mem_done ) begin
			   mem_write_pc <= 0;
			   mem_reg_op <= `MEM_REG_IDLE;
			   wait_mem <= 0;
			end
		 end else begin
			if( write_pc || reg_op != `MEM_REG_IDLE ) begin
			   mem_write_pc <= write_pc;
			   mem_pc_val <= pc_val;
			   mem_jmp_rd <= jmp_rd;
			   mem_jmp_rd_val <= jmp_rd_val;
			   mem_reg_id <= reg_id;
			   mem_reg_op <= reg_op;
			   mem_reg_val <= reg_val;
			   mem_mem_addr <= mem_addr;
			   mem_mem_type <= mem_type;
			   wait_mem <= 1;
			   ex_mem_done <= 1;
			end
		 end
	  end
   end
   
endmodule 
