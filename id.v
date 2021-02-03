`include "const.v"

module id
  (
   input wire 						 clk,
   input wire 						 rst,
   input wire 						 rdy,

   input wire [31 : 0] 				 inst,
   input wire [31 : 0] 				 pc_val,

   output reg 						 read_rs1,
   output reg [`LOG_REG_CNT - 1 : 0] rs1_id,
   input wire [31 : 0] 				 rs1_val_raw,
   input wire [31 : 0] 				 rs1_wcnt,

   output reg 						 read_rs2,
   output reg [`LOG_REG_CNT - 1 : 0] rs2_id,
   input wire [31 : 0] 				 rs2_val_raw,
   input wire [31 : 0] 				 rs2_wcnt,

   output reg 						 write_rd_wcnt,

   output reg [31 : 0] 				 ex_op,
   output reg [31 : 0] 				 rs1_val,
   output reg [31 : 0] 				 rs2_val,
   output reg [`LOG_REG_CNT - 1 : 0] rd_id,
   output reg [31 : 0] 				 imm,
   output reg [31 : 0] 				 ex_pc_val,

   input wire 						 id_ex_done,
   output reg 						 id_done
   
   );

   reg 								 wait_id_ex;
   reg 								 init_done;
   reg 								 rs1_req;
   reg 								 rs2_req;
   reg 								 rd_req;
   
   reg [31 : 0] 					 ex_op_tmp;
   reg [6 : 0] 						 opcode;
   reg [4 : 0] 						 shamt;
   reg [2 : 0] 						 funct;

   always @ (posedge clk) begin
	  if( rst ) begin
		 read_rs1 <= 0;
		 read_rs2 <= 0;
		 write_rd_wcnt <= 0;
		 ex_op <= `EX_NOP;
		 id_done <= 0;
		 wait_id_ex <= 0;
		 init_done <= 0;
		 rs1_req <= 0;
		 rs2_req <= 0;
		 rd_req <= 0;
	  end else if( rdy == 0 ) begin
		 ;
	  end else begin
		 id_done <= 0;
		 write_rd_wcnt <= 0;
		 
		 if( wait_id_ex ) begin
			if( id_ex_done ) begin
			   ex_op <= `EX_NOP;
			   wait_id_ex <= 0;
			end
		 end else begin
			if( inst ) begin
			   if( init_done ) begin
				  if( rs2_req ) begin
					 if( rs1_wcnt || rs2_wcnt ) begin
						;
					 end else begin
						read_rs1 <= 0;
						rs1_req <= 0;
						rs1_val <= rs1_val_raw;
						read_rs2 <= 0;
						rs2_req <= 0;
						rs2_val <= rs2_val_raw;
						if( rd_req && rd_id ) begin
						   write_rd_wcnt <= 1;
						end
						rd_req <= 0;
						ex_op <= ex_op_tmp;
						id_done <= 1;
						wait_id_ex <= 1;
						init_done <= 0;
					 end
				  end else if( rs1_req ) begin
					 if( rs1_wcnt ) begin
						;
					 end else begin
						read_rs1 <= 0;
						rs1_req <= 0;
						rs1_val <= rs1_val_raw;
						if( rd_req && rd_id ) begin
						   write_rd_wcnt <= 1;
						end
						rd_req <= 0;
						ex_op <= ex_op_tmp;
						id_done <= 1;
						wait_id_ex <= 1;
						init_done <= 0;
					 end
				  end else begin
					 if( rd_req && rd_id ) begin
						write_rd_wcnt <= 1;
					 end
					 rd_req <= 0;
					 ex_op <= ex_op_tmp;
					 id_done <= 1;
					 wait_id_ex <= 1;
					 init_done <= 0;
				  end
			   end else begin
				  opcode <= inst[6:0];
				  shamt <= inst[24:20];
				  funct <= inst[14:12];
				  rs1_id <= inst[19:15];
				  rs2_id <= inst[24:20];
				  rd_id <= inst[11:7];
				  ex_pc_val <= pc_val;
				  imm <= 0;
				  rs1_req <= 0;
				  rs2_req <= 0;
				  rd_req <= 0;
				  ex_op_tmp <= `EX_NOP;
				  if( inst[6:0] == `OPCODE_OPIMM ) begin
					 imm[10:0] <= inst[30:20];
					 imm[31:11] <= {21{inst[31]}};
					 rs1_req <= 1;
					 read_rs1 <= 1;
					 rd_req <= 1;
					 if( inst[14:12] == `FUNCT_ADDI ) begin
						ex_op_tmp <= `EX_ADDI;
					 end else if( inst[14:12] == `FUNCT_SLTI ) begin
						ex_op_tmp <= `EX_SLTI;
					 end else if( inst[14:12] == `FUNCT_SLTIU ) begin
						ex_op_tmp <= `EX_SLTIU;
					 end else if( inst[14:12] == `FUNCT_XORI ) begin
						ex_op_tmp <= `EX_XORI;
					 end else if( inst[14:12] == `FUNCT_ORI ) begin
						ex_op_tmp <= `EX_ORI;
					 end else if( inst[14:12] == `FUNCT_ANDI ) begin
						ex_op_tmp <= `EX_ANDI;
					 end else if( inst[14:12] == `FUNCT_SLLI ) begin
						ex_op_tmp <= `EX_SLLI;
					 end else if( inst[14:12] == `FUNCT_SRLI ) begin
						// inst[14:12] == `FUNCT_SRAI
						if( inst[30] ) begin
						   ex_op_tmp <= `EX_SRAI;
						end else begin
						   ex_op_tmp <= `EX_SRLI;
						end
					 end
				  end else if( inst[6:0] == `OPCODE_LUI ) begin
					 imm[31:12] <= inst[31:12];
					 rd_req <= 1;
					 ex_op_tmp <= `EX_LUI;
				  end else if( inst[6:0] == `OPCODE_AUIPC ) begin
					 imm[31:12] <= inst[31:12];
					 rd_req <= 1;
					 ex_op_tmp <= `EX_AUIPC;
				  end else if( inst[6:0] == `OPCODE_OP ) begin
					 rs1_req <= 1;
					 read_rs1 <= 1;
					 rs2_req <= 1;
					 read_rs2 <= 1;
					 rd_req <= 1;
					 if( inst[14:12] == `FUNCT_ADD ) begin
						// inst[14:12] == `FUNCT_SUB
						if( inst[30] ) begin
						   ex_op_tmp <= `EX_SUB;
						end else begin
						   ex_op_tmp <= `EX_ADD;
						end
					 end else if( inst[14:12] == `FUNCT_SLL ) begin
						ex_op_tmp <= `EX_SLL;
					 end else if( inst[14:12] == `FUNCT_SLT ) begin
						ex_op_tmp <= `EX_SLT;
					 end else if( inst[14:12] == `FUNCT_SLTU ) begin
						ex_op_tmp <= `EX_SLTU;
					 end else if( inst[14:12] == `FUNCT_XOR ) begin
						ex_op_tmp <= `EX_XOR;
					 end else if( inst[14:12] == `FUNCT_SRL ) begin
						// inst[14:12] == `FUNC_SRA
						if( inst[30] ) begin
						   ex_op_tmp <= `EX_SRA;
						end else begin
						   ex_op_tmp <= `EX_SRL;
						end
					 end else if( inst[14:12] == `FUNCT_OR ) begin
						ex_op_tmp <= `EX_OR;
					 end else if( inst[14:12] == `FUNCT_AND ) begin
						ex_op_tmp <= `EX_AND;
					 end
				  end else if( inst[6:0] == `OPCODE_JAL ) begin
					 imm[10:1] <= inst[30:21];
					 imm[11] <= inst[20];
					 imm[19:12] <= inst[19:12];
					 imm[31:20] <= {12{inst[31]}};
					 rd_req <= 1;
					 ex_op_tmp <= `EX_JAL;
				  end else if( inst[6:0] == `OPCODE_JALR ) begin
					 imm[10:0] <= inst[30:20];
					 imm[31:11] <= {21{inst[31]}};
					 rs1_req <= 1;
					 read_rs1 <= 1;
					 rd_req <= 1;
					 ex_op_tmp <= `EX_JALR;
				  end else if( inst[6:0] == `OPCODE_BRANCH ) begin
					 imm[4:1] <= inst[11:8];
					 imm[10:5] <= inst[30:25];
					 imm[11] <= inst[7];
					 imm[31:12] <= {20{inst[31]}};
					 rs1_req <= 1;
					 read_rs1 <= 1;
					 rs2_req <= 1;
					 read_rs2 <= 1;
					 if( inst[14:12] == `FUNCT_BEQ ) begin
						ex_op_tmp <= `EX_BEQ;
					 end else if( inst[14:12] == `FUNCT_BNE ) begin
						ex_op_tmp <= `EX_BNE;
					 end else if( inst[14:12] == `FUNCT_BLT ) begin
						ex_op_tmp <= `EX_BLT;
					 end else if( inst[14:12] == `FUNCT_BGE ) begin
						ex_op_tmp <= `EX_BGE;
					 end else if( inst[14:12] == `FUNCT_BLTU ) begin
						ex_op_tmp <= `EX_BLTU;
					 end else if( inst[14:12] == `FUNCT_BGEU ) begin
						ex_op_tmp <= `EX_BGEU;
					 end
				  end else if( inst[6:0] == `OPCODE_LOAD ) begin
					 imm[10:0] <= inst[30:20];
					 imm[31:11] <= {21{inst[31]}};
					 rs1_req <= 1;
					 read_rs1 <= 1;
					 rd_req <= 1;
					 if( inst[14:12] == `FUNCT_LB ) begin
						ex_op_tmp <= `EX_LB;
					 end else if( inst[14:12] == `FUNCT_LH ) begin
						ex_op_tmp <= `EX_LH;
					 end else if( inst[14:12] == `FUNCT_LW ) begin
						ex_op_tmp <= `EX_LW;
					 end else if( inst[14:12] == `FUNCT_LBU ) begin
						ex_op_tmp <= `EX_LBU;
					 end else if( inst[14:12] == `FUNCT_LHU ) begin
						ex_op_tmp <= `EX_LHU;
					 end
				  end else if( inst[6:0] == `OPCODE_STORE ) begin
					 imm[4:0] <= inst[11:7];
					 imm[10:5] <= inst[30:25];
					 imm[31:11] <= {21{inst[31]}};
					 rs1_req <= 1;
					 read_rs1 <= 1;
					 rs2_req <= 1;
					 read_rs2 <= 1;
					 if( inst[14:12] == `FUNCT_SB ) begin
						ex_op_tmp <= `EX_SB;
					 end else if( inst[14:12] == `FUNCT_SH ) begin
						ex_op_tmp <= `EX_SH;
					 end else if( inst[14:12] == `FUNCT_SW ) begin
						ex_op_tmp <= `EX_SW;
					 end
				  end
				  init_done <= 1;
			   end
			end
		 end
	  end
   end
   
endmodule
