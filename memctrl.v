`include "const.v"

module memctrl
  (
   input wire 		   clk,
   input wire 		   rst,
   input wire 		   rdy,
   input wire 		   io_buffer_full,

   input wire [7 : 0]  data_input,
   output reg [7 : 0]  data_output,
   output reg [31 : 0] data_addr,
   output reg 		   wr_state, // 1 for write
   // Memory read result will be returned in the next cycle
   // Write takes 1 cycle(no need to wait)
  
   input wire 		   read_inst,
   input wire [31 : 0] read_inst_addr,
   output reg [31 : 0] read_inst_ans,
   output reg 		   read_inst_ok,

   input wire 		   read_data,
   input wire [31 : 0] read_data_addr,
   input wire [1 : 0]  read_data_len,
   output reg [31 : 0] read_data_ans,
   output reg 		   read_data_ok,
  
   input wire 		   write_data,
   input wire [31 : 0] write_data_addr,
   input wire [1 : 0]  write_data_len,
   input wire [31 : 0] write_data_val,
   output reg 		   write_data_ok		   
  
   );

   reg [2 : 0] 		   step;
   reg [1 : 0] 		   op_type;
   reg 				   need_rest;				   

   always @ (posedge clk) begin
	  if( rst ) begin
		 wr_state <= 0;
		 data_addr <= 0;
		 read_inst_ok <= 0;
		 read_data_ok <= 0;
		 write_data_ok <= 0;
		 op_type <= 0;
		 need_rest <= 0;
	  end else if( rdy == 0 ) begin
		 ;
	  end else begin
		 read_inst_ok <= 0;
		 read_data_ok <= 0;
		 write_data_ok <= 0;
		 wr_state <= 0;
		 data_addr <= 0;
		 need_rest <= 0;
		 
		 if( op_type == `MEMCTRL_IDLE ) begin
			if( need_rest ) begin
			   need_rest <= 0;
			end else begin
			   if( read_inst ) begin
				  step <= 0;
				  op_type <= `MEMCTRL_READ_INST;
				  wr_state <= 0;
				  data_addr <= read_inst_addr;
			   end else if( read_data ) begin
				  step <= 0;
				  op_type <= `MEMCTRL_READ_DATA;
				  wr_state <= 0;
				  data_addr <= read_data_addr;
			   end else if( write_data ) begin
				  if( io_buffer_full ) begin
					 ;
				  end else begin
					 step <= 0;
					 op_type <= `MEMCTRL_WRITE_DATA;
					 wr_state <= 1;
					 data_addr <= write_data_addr;
					 data_output <= write_data_val[7:0];
				  end
			   end
			end
		 end else if( op_type == `MEMCTRL_READ_INST ) begin
			if( step == 0 ) begin
			   wr_state <= 0;
			   data_addr <= read_inst_addr + 1;
			   step <= step + 1;
			end else if( step == 1 ) begin
			   read_inst_ans[7:0] <= data_input;
			   wr_state <= 0;
			   data_addr <= read_inst_addr + 2;
			   step <= step + 1;
			end else if( step == 2 ) begin
			   read_inst_ans[15:8] <= data_input;
			   wr_state <= 0;
			   data_addr <= read_inst_addr + 3;
			   step <= step + 1;
			end else if( step == 3 ) begin
			   read_inst_ans[23:16] <= data_input;
			   step <= step + 1;
			end else if( step == 4 ) begin
			   read_inst_ans[31:24] <= data_input;
			   read_inst_ok <= 1;
			   op_type <= `MEMCTRL_IDLE;
			   need_rest <= 1;
			end
		 end else if( op_type == `MEMCTRL_READ_DATA ) begin
			if( step == 0 ) begin
			   wr_state <= 0;
			   data_addr <= read_data_addr + 1;
			   step <= step + 1;
			end else if( step == 1 ) begin
			   read_data_ans[7:0] <= data_input;
			   wr_state <= 0;
			   data_addr <= read_data_addr + 2;
			   step <= step + 1;
			end else if( step == 2 ) begin
			   read_data_ans[15:8] <= data_input;
			   wr_state <= 0;
			   data_addr <= read_data_addr + 3;
			   step <= step + 1;
			end else if( step == 3 ) begin
			   read_data_ans[23:16] <= data_input;
			   step <= step + 1;
			end else if( step == 4 ) begin
			   read_data_ans[31:24] <= data_input;
			end
			if( step == read_data_len ) begin
			   data_addr <= 0;
			end
			if( step - 1 == read_data_len ) begin
			   op_type <= `MEMCTRL_IDLE;
			   read_data_ok <= 1;
			   data_addr <= 0;
			   need_rest <= 1;
			end
		 end else if( op_type == `MEMCTRL_WRITE_DATA ) begin
			if( io_buffer_full ) begin
			   ;
			end else begin
			   if( step == 0 ) begin
				  wr_state <= 1;
				  data_addr <= write_data_addr + 1;
				  data_output <= write_data_val[15:8];
				  step <= step + 1;
			   end else if( step == 1 ) begin
				  wr_state <= 1;
				  data_addr <= write_data_addr + 2;
				  data_output <= write_data_val[23:16];
				  step <= step + 1;
			   end else if( step == 2 ) begin
				  wr_state <= 1;
				  data_addr <= write_data_addr + 3;
				  data_output <= write_data_val[31:24];
				  step <= step + 1;
			   end
			   if( step == write_data_len ) begin
				  wr_state <= 0;
				  data_addr <= 0;
				  write_data_ok <= 1;
				  op_type <= `MEMCTRL_IDLE;
				  need_rest <= 1;
			   end
			end
		 end
	  end
   end
   
endmodule
