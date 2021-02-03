`include "const.v"

module icache
  (
   input wire 		   clk,
   input wire 		   rst,
   input wire 		   rdy,
  
   input wire 		   read,
   input wire [31 : 0] read_addr,
   output reg [31 : 0] read_ans,
   output reg 		   read_ok,
  
   input wire 		   memctrl_ok,
   input wire [31 : 0] memctrl_rtn,
   output reg 		   memctrl_read,
   output reg [31 : 0] memctrl_addr
  
   );

   reg [31 : 0] 	   cache[`ICACHE_SZ - 1 : 0];
   reg [31 : 0] 	   tag[`ICACHE_SZ - 1 : 0];
   reg 				   valid[`ICACHE_SZ - 1 : 0];
   reg 				   wait_memctrl;
   reg 				   need_rest;
   integer 			   i;
   
   always @ (posedge clk) begin
	  if( rst ) begin
		 for( i = 0; i < `ICACHE_SZ; i = i + 1 ) begin
			valid[i] <= 0;
		 end
		 memctrl_read <= 0;
		 read_ok <= 0;
		 wait_memctrl <= 0;
		 need_rest <= 0;
	  end else if( rdy == 0 ) begin
		 ;
	  end else begin
		 read_ok <= 0;
		 if( wait_memctrl ) begin
			if( memctrl_ok ) begin
			   memctrl_read <= 0;
			   wait_memctrl <= 0;
			   valid[read_addr[`LOG_ICACHE_SZ - 1 : 0]] <= 1;
			   tag[read_addr[`LOG_ICACHE_SZ - 1 : 0]] <= read_addr;
			   cache[read_addr[`LOG_ICACHE_SZ - 1 : 0]] <= memctrl_rtn;
			   read_ans <= memctrl_rtn;
			   read_ok <= 1;
			   need_rest <= 1;
			end else begin
			   ;
			end
		 end else begin
			if( need_rest ) begin
			   need_rest <= 0;
			end else begin
			   if( read ) begin
				  if( valid[read_addr[`LOG_ICACHE_SZ - 1 : 0]] &&
					  tag[read_addr[`LOG_ICACHE_SZ - 1 : 0]] == read_addr ) begin
					 read_ans <= cache[read_addr[`LOG_ICACHE_SZ - 1 : 0]];
					 read_ok <= 1;
					 need_rest <= 1;
				  end else begin
					 memctrl_read <= 1;
					 memctrl_addr <= read_addr;
					 wait_memctrl <= 1;
				  end
			   end else begin
				  ;
			   end
			end
		 end
	  end
   end
   
endmodule
