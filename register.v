`include "const.v"

module register
  (
   input wire 						 clk, 
   input wire 						 rst,
   input wire 						 rdy,
  
   input wire 						 write,
   input wire [`LOG_REG_CNT - 1 : 0] write_addr,
   input wire [`REG_LEN - 1 : 0] 	 write_val,
  
   input wire 						 read_1,
   input wire [`LOG_REG_CNT - 1 : 0] read_1_addr,
   output reg [`REG_LEN - 1 : 0] 	 read_1_val,
  
   input wire 						 read_2,
   input wire [`LOG_REG_CNT - 1 : 0] read_2_addr,
   output reg [`REG_LEN - 1 : 0] 	 read_2_val
  
   );
   
   reg [`REG_LEN - 1 : 0] 			 regs [`REG_CNT - 1 : 0];
   integer 							 i;
   
   always @ (posedge clk) begin
	  if( rst ) begin
		 for( i = 0; i < `REG_CNT; i = i + 1 ) begin
			regs[i] <= 0;
		 end
	  end else if( rdy == 0 ) begin
		 ;
	  end else if( write ) begin
		 regs[write_addr] <= write_val;
	  end
   end

   always @ (*) begin
	  read_1_val = 0;
	  if( read_1 ) begin
		 read_1_val = regs[read_1_addr];
	  end
   end

   always @ (*) begin
	  read_2_val = 0;
	  if( read_2 ) begin
		 read_2_val = regs[read_2_addr];
	  end
   end
   
endmodule
