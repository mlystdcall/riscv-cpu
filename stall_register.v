`include "const.v"

module stall_register
  (
   input wire 						 clk,
   input wire 						 rst,
   input wire 						 rdy,
  
   input wire 						 write,
   input wire [`LOG_REG_CNT - 1 : 0] write_addr,
  
   input wire 						 finish_write,
   input wire [`LOG_REG_CNT - 1 : 0] finish_write_addr,
  
   input wire 						 read_1,
   input wire [`LOG_REG_CNT - 1 : 0] read_1_addr,
   output reg [`REG_LEN - 1 : 0] 	 read_1_ans,

   input wire 						 read_2,
   input wire [`LOG_REG_CNT - 1 : 0] read_2_addr,
   output reg [`REG_LEN - 1 : 0] 	 read_2_ans
  
   );
   
   reg [`REG_LEN - 1 : 0] 			 write_cnt [`REG_CNT - 1 : 0];
   integer 							 i;
   
   always @ (posedge clk) begin
	  if( rst ) begin
		 for( i = 0; i < `REG_CNT; i = i + 1 ) begin
			write_cnt[i] <= 0;
		 end
	  end else if( rdy == 0 ) begin
		 ;
	  end else begin
		 if( write && finish_write ) begin
			if( write_addr == finish_write_addr ) begin
			   ;
			end else begin
			   write_cnt[write_addr] <= write_cnt[write_addr] + 1;
			   write_cnt[finish_write_addr] <= write_cnt[finish_write_addr] - 1;
			end
		 end else if( write ) begin
			write_cnt[write_addr] <= write_cnt[write_addr] + 1;
		 end else if( finish_write ) begin
			write_cnt[finish_write_addr] <= write_cnt[finish_write_addr] - 1;
		 end
		 write_cnt[0] <= 0;
	  end
   end // always @ (posedge clk)
   
   always @ (*) begin
	  read_1_ans = 0;
	  if( read_1 ) begin
		 read_1_ans = write_cnt[read_1_addr];
	  end
   end

   always @ (*) begin
	  read_2_ans = 0;
	  if( read_2 ) begin
		 read_2_ans = write_cnt[read_2_addr];
	  end
   end
   
endmodule
