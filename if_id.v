`include "const.v"

module if_id
  (
   input wire 		   clk,
   input wire 		   rst,
   input wire 		   rdy,

   input wire [31 : 0] inst,
   input wire [31 : 0] pc_val,

   output reg [31 : 0] out_inst,
   output reg [31 : 0] out_pc_val,

   input wire 		   id_done,
   output reg 		   if_id_done
  
   );

   reg 				   wait_id;

   always @ (posedge clk) begin
	  if( rst ) begin
		 out_inst <= 0;
		 if_id_done <= 0;
		 wait_id <= 0;
	  end else if( rdy == 0 ) begin
		 ;
	  end else begin
		 if_id_done <= 0;

		 if( wait_id ) begin
			if( id_done ) begin
			   out_inst <= 0;
			   wait_id <= 0;
			end
		 end else begin
			if( inst ) begin
			   out_inst <= inst;
			   out_pc_val <= pc_val;
			   if_id_done <= 1;
			   wait_id <= 1;
			end
		 end
	  end
   end

endmodule
