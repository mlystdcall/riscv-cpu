`include "const.v"

module id_ex
  (
   input wire 						 clk,
   input wire 						 rst,
   input wire 						 rdy,

   input wire [31 : 0] 				 ex_op,
   input wire [31 : 0] 				 rs1_val,
   input wire [31 : 0] 				 rs2_val,
   input wire [`LOG_REG_CNT - 1 : 0] rd_id,
   input wire [31 : 0] 				 imm,
   input wire [31 : 0] 				 pc_val,

   output reg [31 : 0] 				 ex_ex_op,
   output reg [31 : 0] 				 ex_rs1_val,
   output reg [31 : 0] 				 ex_rs2_val,
   output reg [`LOG_REG_CNT - 1 : 0] ex_rd_id,
   output reg [31 : 0] 				 ex_imm,
   output reg [31 : 0] 				 ex_pc_val,

   input wire 						 ex_done,
   output reg 						 id_ex_done
  
   );

   reg 								 wait_ex;

   always @ (posedge clk) begin
	  if( rst ) begin
		 ex_ex_op <= `EX_NOP;
		 id_ex_done <= 0;
		 wait_ex <= 0;
	  end else if( rdy == 0 ) begin
		 ;
	  end else begin
		 id_ex_done <= 0;

		 if( wait_ex ) begin
			if( ex_done ) begin
			   ex_ex_op <= `EX_NOP;
			   wait_ex <= 0;
			end
		 end else begin
			if( ex_op ) begin
			   ex_ex_op <= ex_op;
			   ex_rs1_val <= rs1_val;
			   ex_rs2_val <= rs2_val;
			   ex_rd_id <= rd_id;
			   ex_imm <= imm;
			   ex_pc_val <= pc_val;
			   id_ex_done <= 1;
			   wait_ex <= 1;
			end
		 end
	  end
   end
   
endmodule
