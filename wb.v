`include "const.v"

// TODO : unfreeze pc

module wb
  (
   input wire 						 clk,
   input wire 						 rst,
   input wire 						 rdy,

   input wire 						 write_pc,
   input wire [31 : 0] 				 pc_val,
  
   input wire 						 write_reg,
   input wire [`LOG_REG_CNT - 1 : 0] reg_id,
   input wire [`REG_LEN - 1 : 0] 	 reg_val,
  
   output reg 						 write_pc_out,
   output reg [31 : 0] 				 pc_val_out,
   
   output reg 						 write_reg_out,
   output reg [`LOG_REG_CNT - 1 : 0] reg_id_out,
   output reg [`REG_LEN - 1 : 0] 	 reg_val_out,

   output reg 						 write_reg_stall,
   output reg [`LOG_REG_CNT - 1 : 0] reg_stall_id
   
   );

   always @ (posedge clk) begin
	  if( rst ) begin
		 write_pc_out <= 0;
		 write_reg_out <= 0;
		 write_reg_stall <= 0;
	  end else if( rdy == 0 ) begin
		 ;
	  end else begin
		 write_pc_out <= write_pc;
		 pc_val_out <= pc_val;
		 
		 write_reg_out <= write_reg;
		 reg_id_out <= reg_id;
		 reg_val_out <= reg_val;

		 write_reg_stall <= write_reg;
		 reg_stall_id <= reg_id;
	  end
   end

endmodule
