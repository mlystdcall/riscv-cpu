`include "const.v"

module mem
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
  
   output reg 						 wb_write_pc,
   output reg [31 : 0] 				 wb_pc_val,

   output reg 						 wb_write_reg,
   output reg [`LOG_REG_CNT - 1 : 0] wb_reg_id,
   output reg [`REG_LEN - 1 : 0] 	 wb_reg_val,
  
   output reg 						 mctrl_read,
   output reg [31 : 0] 				 mctrl_read_addr,
   output reg [1 : 0] 				 mctrl_read_len,
   input wire [31 : 0] 				 mctrl_read_ans,
   input wire 						 mctrl_read_ok,
  
   output reg 						 mctrl_write,
   output reg [31 : 0] 				 mctrl_write_addr,
   output reg [1 : 0] 				 mctrl_write_len,
   output reg [31 : 0] 				 mctrl_write_val,
   input wire 						 mctrl_write_ok,

   output reg 						 work_done
  
   );

   reg 								 need_rest;
   reg 								 wait_mctrl;
   
   always @ (posedge clk) begin
	  if( rst ) begin
		 wb_write_pc <= 0;
		 wb_write_reg <= 0;
		 mctrl_read <= 0;
		 mctrl_write <= 0;
		 work_done <= 0;
		 need_rest <= 0;
		 wait_mctrl <= 0;
	  end else if( rdy == 0 ) begin
		 ;
	  end else begin
		 wb_write_pc <= 0;
		 wb_write_reg <= 0;
		 work_done <= 0;
		 
		 if( wait_mctrl ) begin
			if( reg_op == `MEM_REG_LOAD ) begin
			   if( mctrl_read_ok ) begin
				  mctrl_read <= 0;
				  work_done <= 1;
				  need_rest <= 1;
				  wait_mctrl <= 0;
				  wb_write_reg <= 1;
				  wb_reg_id <= reg_id;
				  wb_reg_val <= mctrl_read_ans;
				  if( mem_type == `MEM_TYPE_LB ) begin
					 wb_reg_val[31:8] <= {24{mctrl_read_ans[7]}};
				  end else if( mem_type == `MEM_TYPE_LBU ) begin
					 wb_reg_val[31:8] <= 0;
				  end else if( mem_type == `MEM_TYPE_LH ) begin
					 wb_reg_val[31:16] <= {16{mctrl_read_ans[15]}};
				  end else if( mem_type == `MEM_TYPE_LHU ) begin
					 wb_reg_val[31:16] <= 0;
				  end else if( mem_type == `MEM_TYPE_LW ) begin
					 ;
				  end
			   end else begin
				  ;
			   end
			end else if( reg_op == `MEM_REG_STORE ) begin
			   if( mctrl_write_ok ) begin
				  mctrl_write <= 0;
				  work_done <= 1;
				  need_rest <= 1;
				  wait_mctrl <= 0;
			   end else begin
				  ;
			   end
			end
		 end else begin
			if( need_rest ) begin
			   need_rest <= 0;
			end else begin
			   if( write_pc ) begin
				  wb_write_pc <= 1;
				  wb_pc_val <= pc_val;
				  if( jmp_rd ) begin
					 wb_write_reg <= 1;
					 wb_reg_id <= jmp_rd;
					 wb_reg_val <= jmp_rd_val;
				  end
				  work_done <= 1;
				  need_rest <= 1;
			   end else if( reg_op == `MEM_REG_WB ) begin
				  wb_write_reg <= 1;
				  wb_reg_id <= reg_id;
				  wb_reg_val <= reg_val;
				  work_done <= 1;
				  need_rest <= 1;
			   end else if( reg_op == `MEM_REG_LOAD ) begin
				  mctrl_read <= 1;
				  mctrl_read_addr <= mem_addr;
				  if( mem_type == `MEM_TYPE_LB ||
					  mem_type == `MEM_TYPE_LBU ) begin
					 mctrl_read_len <= 0;
				  end else if( mem_type == `MEM_TYPE_LH ||
							   mem_type == `MEM_TYPE_LHU ) begin
					 mctrl_read_len <= 1;
				  end else if( mem_type == `MEM_TYPE_LW ) begin
					 mctrl_read_len <= 3;
				  end
				  wait_mctrl <= 1;
			   end else if( reg_op == `MEM_REG_STORE ) begin
				  mctrl_write <= 1;
				  mctrl_write_addr <= mem_addr;
				  mctrl_write_val <= reg_val;
				  if( mem_type == `MEM_TYPE_SB ) begin
					 mctrl_write_len <= 0;
				  end else if( mem_type == `MEM_TYPE_SH ) begin
					 mctrl_write_len <= 1;
				  end else if( mem_type == `MEM_TYPE_SW ) begin
					 mctrl_write_len <= 3;
				  end
				  wait_mctrl <= 1;
			   end
			end
		 end
	  end
   end
   
endmodule
