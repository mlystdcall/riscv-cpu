`include "const.v"

module ex
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
   
   output reg 						 write_pc,
   output reg [31 : 0] 				 write_pc_val,
   output reg [`LOG_REG_CNT - 1 : 0] jmp_rd,
   output reg [31 : 0] 				 jmp_rd_val,
   
   output reg [`LOG_REG_CNT - 1 : 0] write_reg_id,
   output reg [1 : 0] 				 write_reg_op,
   output reg [`REG_LEN - 1 : 0] 	 write_reg_val,
   output reg [31 : 0] 				 mem_addr,
   output reg [2 : 0] 				 mem_type,
   
   input wire 						 ex_mem_done,
   output reg 						 ex_done
   
   );

   reg 								 wait_ex_mem;

   always @ (posedge clk) begin
	  if( rst ) begin
		 write_pc <= 0;
		 write_reg_op <= `MEM_REG_IDLE;
		 ex_done <= 0;
		 wait_ex_mem <= 0;
	  end else if( rdy == 0 ) begin
		 ;
	  end else begin
		 ex_done <= 0;

		 if( wait_ex_mem ) begin
			if( ex_mem_done ) begin
			   write_pc <= 0;
			   write_reg_op <= `MEM_REG_IDLE;
			   wait_ex_mem <= 0;
			end
		 end else begin
			if( ex_op ) begin
			   write_reg_id <= rd_id;
			   jmp_rd_val <= pc_val + 4;
			   mem_addr <= rs1_val + imm;
			   
			   if( ex_op == `EX_ADDI ) begin
				  write_reg_op <= `MEM_REG_WB;
				  write_reg_val <= rs1_val + imm;
			   end else if( ex_op == `EX_SLTI ) begin
				  write_reg_op <= `MEM_REG_WB;
				  if( $signed(rs1_val) < $signed(imm) ) begin
					 write_reg_val <= 1;
				  end else begin
					 write_reg_val <= 0;
				  end
			   end else if( ex_op == `EX_SLTIU ) begin
				  write_reg_op <= `MEM_REG_WB;
				  if( rs1_val < imm ) begin
					 write_reg_val <= 1;
				  end else begin
					 write_reg_val <= 0;
				  end
			   end else if( ex_op == `EX_ANDI ) begin
				  write_reg_op <= `MEM_REG_WB;
				  write_reg_val <= rs1_val & imm;
			   end else if( ex_op == `EX_ORI ) begin
				  write_reg_op <= `MEM_REG_WB;
				  write_reg_val <= rs1_val | imm;
			   end else if( ex_op == `EX_XORI ) begin
				  write_reg_op <= `MEM_REG_WB;
				  write_reg_val <= rs1_val ^ imm;
			   end else if( ex_op == `EX_SLLI ) begin
				  write_reg_op <= `MEM_REG_WB;
				  write_reg_val <= rs1_val << imm[4:0];
			   end else if( ex_op == `EX_SRLI ) begin
				  write_reg_op <= `MEM_REG_WB;
				  write_reg_val <= rs1_val >> imm[4:0];
			   end else if( ex_op == `EX_SRAI ) begin
				  write_reg_op <= `MEM_REG_WB;
				  write_reg_val <= rs1_val >>> imm[4:0];
			   end else if( ex_op == `EX_LUI ) begin
				  write_reg_op <= `MEM_REG_WB;
				  write_reg_val <= imm;
			   end else if( ex_op == `EX_AUIPC ) begin
				  write_reg_op <= `MEM_REG_WB;
				  write_reg_val <= imm + pc_val;
			   end else if( ex_op == `EX_ADD ) begin
				  write_reg_op <= `MEM_REG_WB;
				  write_reg_val <= rs1_val + rs2_val;
			   end else if( ex_op == `EX_SLT ) begin
				  write_reg_op <= `MEM_REG_WB;
				  if( $signed(rs1_val) < $signed(rs2_val) ) begin
					 write_reg_val <= 1;
				  end else begin
					 write_reg_val <= 0;
				  end
			   end else if( ex_op == `EX_SLTU ) begin
				  write_reg_op <= `MEM_REG_WB;
				  if( rs1_val < rs2_val ) begin
					 write_reg_val <= 1;
				  end else begin
					 write_reg_val <= 0;
				  end
			   end else if( ex_op == `EX_AND ) begin
				  write_reg_op <= `MEM_REG_WB;
				  write_reg_val <= rs1_val & rs2_val;
			   end else if( ex_op == `EX_OR ) begin
				  write_reg_op <= `MEM_REG_WB;
				  write_reg_val <= rs1_val | rs2_val;
			   end else if( ex_op == `EX_XOR ) begin
				  write_reg_op <= `MEM_REG_WB;
				  write_reg_val <= rs1_val ^ rs2_val;
			   end else if( ex_op == `EX_SLL ) begin
				  write_reg_op <= `MEM_REG_WB;
				  write_reg_val <= rs1_val << rs2_val[4:0];
			   end else if( ex_op == `EX_SRL ) begin
				  write_reg_op <= `MEM_REG_WB;
				  write_reg_val <= rs1_val >> rs2_val[4:0];
			   end else if( ex_op == `EX_SUB ) begin
				  write_reg_op <= `MEM_REG_WB;
				  write_reg_val <= rs1_val - rs2_val;
			   end else if( ex_op == `EX_SRA ) begin
				  write_reg_op <= `MEM_REG_WB;
				  write_reg_val <= rs1_val >>> rs2_val[4:0];
			   end else if( ex_op == `EX_JAL ) begin
				  write_pc <= 1;
				  write_pc_val <= pc_val + imm;
				  jmp_rd <= rd_id;
			   end else if( ex_op == `EX_JALR ) begin
				  write_pc <= 1;
				  write_pc_val <= rs1_val + imm;
				  write_pc_val[0] <= 0;
				  jmp_rd <= rd_id;
			   end else if( ex_op == `EX_BEQ ) begin
				  write_pc <= 1;
				  jmp_rd <= 0;
				  if( rs1_val == rs2_val ) begin
					 write_pc_val <= pc_val + imm;
				  end else begin
					 write_pc_val <= pc_val + 4;
				  end
			   end else if( ex_op == `EX_BNE ) begin
				  write_pc <= 1;
				  jmp_rd <= 0;
				  if( rs1_val != rs2_val ) begin
					 write_pc_val <= pc_val + imm;
				  end else begin
					 write_pc_val <= pc_val + 4;
				  end
			   end else if( ex_op == `EX_BLT ) begin
				  write_pc <= 1;
				  jmp_rd <= 0;
				  if( $signed(rs1_val) < $signed(rs2_val) ) begin
					 write_pc_val <= pc_val + imm;
				  end else begin
					 write_pc_val <= pc_val + 4;
				  end
			   end else if( ex_op == `EX_BLTU ) begin
				  write_pc <= 1;
				  jmp_rd <= 0;
				  if( rs1_val < rs2_val ) begin
					 write_pc_val <= pc_val + imm;
				  end else begin
					 write_pc_val <= pc_val + 4;
				  end
			   end else if( ex_op == `EX_BGE ) begin
				  write_pc <= 1;
				  jmp_rd <= 0;
				  if( $signed(rs1_val) >= $signed(rs2_val) ) begin
					 write_pc_val <= pc_val + imm;
				  end else begin
					 write_pc_val <= pc_val + 4;
				  end
			   end else if( ex_op == `EX_BGEU ) begin
				  write_pc <= 1;
				  jmp_rd <= 0;
				  if( rs1_val >= rs2_val ) begin
					 write_pc_val <= pc_val + imm;
				  end else begin
					 write_pc_val <= pc_val + 4;
				  end
			   end else if( ex_op == `EX_LW ) begin
				  write_reg_op <= `MEM_REG_LOAD;
				  mem_type <= `MEM_TYPE_LW;
			   end else if( ex_op == `EX_LH ) begin
				  write_reg_op <= `MEM_REG_LOAD;
				  mem_type <= `MEM_TYPE_LH;
			   end else if( ex_op == `EX_LHU ) begin
				  write_reg_op <= `MEM_REG_LOAD;
				  mem_type <= `MEM_TYPE_LHU;
			   end else if( ex_op == `EX_LB ) begin
				  write_reg_op <= `MEM_REG_LOAD;
				  mem_type <= `MEM_TYPE_LB;
			   end else if( ex_op == `EX_LBU ) begin
				  write_reg_op <= `MEM_REG_LOAD;
				  mem_type <= `MEM_TYPE_LBU;
			   end else if( ex_op == `EX_SW ) begin
				  write_reg_op <= `MEM_REG_STORE;
				  mem_type <= `MEM_TYPE_SW;
				  write_reg_val <= rs2_val;
			   end else if( ex_op == `EX_SH ) begin
				  write_reg_op <= `MEM_REG_STORE;
				  mem_type <= `MEM_TYPE_SH;
				  write_reg_val <= rs2_val;
			   end else if( ex_op == `EX_SB ) begin
				  write_reg_op <= `MEM_REG_STORE;
				  mem_type <= `MEM_TYPE_SB;
				  write_reg_val <= rs2_val;
			   end
			   
			   ex_done <= 1;
			   wait_ex_mem <= 1;
			end
		 end
	  end
   end

endmodule
