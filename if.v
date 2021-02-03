`include "const.v"

module insf
  (
   input wire 		   clk,
   input wire 		   rst,
   input wire 		   rdy,

   input wire 		   write_pc,
   input wire [31 : 0] write_pc_val,

   output reg 		   ic_read,
   output reg [31 : 0] ic_addr,
   input wire [31 : 0] ic_ans,
   input wire 		   ic_done,

   output reg [31 : 0] inst_out,
   output reg [31 : 0] pc_out,

   input wire 		   if_id_done
   
   );

   reg 				   wait_if_id;
   reg 				   wait_ic;
   reg [31 : 0] 	   pc;
   reg 				   pc_stall;

   always @ (posedge clk) begin
	  if( rst ) begin
		 ic_read <= 0;
		 inst_out <= 0;
		 wait_if_id <= 0;
		 wait_ic <= 0;
		 pc <= 0;
		 pc_stall <= 0;
	  end else if( rdy == 0 ) begin
		 ;
	  end else begin
		 if( wait_if_id ) begin
			if( if_id_done ) begin
			   inst_out <= 0;
			   wait_if_id <= 0;
			end
		 end else begin
			if( pc_stall ) begin
			   if( write_pc ) begin
				  pc <= write_pc_val;
				  pc_stall <= 0;
			   end
			end else begin
			   if( wait_ic ) begin
				  if( ic_done ) begin
					 ic_read <= 0;
					 inst_out <= ic_ans;
					 pc_out <= pc;
					 wait_if_id <= 1;
					 wait_ic <= 0;
					 pc <= pc + 4;
					 if( ic_ans[6:0] == `OPCODE_JAL ||
						 ic_ans[6:0] == `OPCODE_JALR ||
						 ic_ans[6:0] == `OPCODE_BRANCH ) begin
						pc_stall <= 1;
					 end
				  end
			   end else begin
				  ic_read <= 1;
				  ic_addr <= pc;
				  wait_ic <= 1;
			   end
			end
		 end
	  end
   end

endmodule
