// RISCV32I CPU top module
// port modification allowed for debugging purposes

`include "const.v"

module cpu
  (
   input wire 		  clk_in, // system clock signal
   input wire 		  rst_in, // reset signal
   input wire 		  rdy_in, // ready signal, pause cpu when low

   input wire [ 7:0]  mem_din, // data input bus
   output wire [ 7:0] mem_dout, // data output bus
   output wire [31:0] mem_a, // address bus (only 17:0 is used)
   output wire 		  mem_wr, // write/read signal (1 for write)

   input wire 		  io_buffer_full, // 1 if uart buffer is full

   output wire [31:0] dbgreg_dout		// cpu register output (debugging demo)
   );

   // implementation goes here

   // Specifications:
   // - Pause cpu(freeze pc, registers, etc.) when rdy_in is low
   // - Memory read result will be returned in the next cycle. Write takes 1 cycle(no need to wait)
   // - Memory is of size 128KB, with valid address ranging from 0x0 to 0x20000
   // - I/O port is mapped to address higher than 0x30000 (mem_a[17:16]==2'b11)
   // - 0x30000 read: read a byte from input
   // - 0x30000 write: write a byte to output (write 0x00 is ignored)
   // - 0x30004 read: read clocks passed since cpu starts (in dword, 4 bytes)
   // - 0x30004 write: indicates program stop (will output '\0' through uart tx)
   
   // id output
   wire 			  id_read_rs1;
   wire [4 : 0] 	  id_rs1_id;
   wire 			  id_read_rs2;
   wire [4 : 0] 	  id_rs2_id;
   wire 			  id_write_rd_wcnt;
   wire [31 : 0] 	  id_ex_op;
   wire [31 : 0] 	  id_rs1_val;
   wire [31 : 0] 	  id_rs2_val;
   wire [4 : 0] 	  id_rd_id;
   wire [31 : 0] 	  id_imm;
   wire [31 : 0] 	  id_ex_pc_val;
   wire 			  id_id_done;
   
   // ex output
   wire 			  ex_write_pc;
   wire [31 : 0] 	  ex_write_pc_val;
   wire [4 : 0] 	  ex_jmp_rd;
   wire [31 : 0] 	  ex_jmp_rd_val;
   wire [4 : 0] 	  ex_write_reg_id;
   wire [1 : 0] 	  ex_write_reg_op;
   wire [31 : 0] 	  ex_write_reg_val;
   wire [31 : 0] 	  ex_mem_addr;
   wire [2 : 0] 	  ex_mem_type;
   wire 			  ex_ex_done;

   // memctrl output
   wire [7 : 0] 	  mc_data_output;
   wire [31 : 0] 	  mc_data_addr;
   wire 			  mc_wr_state;
   wire [31 : 0] 	  mc_read_inst_ans;
   wire 			  mc_read_inst_ok;
   wire [31 : 0] 	  mc_read_data_ans;
   wire 			  mc_read_data_ok;
   wire 			  mc_write_data_ok;

   // mem output
   wire 			  mem_wb_write_pc;
   wire [31 : 0] 	  mem_wb_pc_val;
   wire 			  mem_wb_write_reg;
   wire [4 : 0] 	  mem_wb_reg_id;
   wire [31 : 0] 	  mem_wb_reg_val;
   wire 			  mem_mctrl_read;
   wire [31 : 0] 	  mem_mctrl_read_addr;
   wire [1 : 0] 	  mem_mctrl_read_len;
   wire 			  mem_mctrl_write;
   wire [31 : 0] 	  mem_mctrl_write_addr;
   wire [1 : 0] 	  mem_mctrl_write_len;
   wire [31 : 0] 	  mem_mctrl_write_val;
   wire 			  mem_work_done;

   // icache output
   wire [31 : 0] 	  ic_read_ans;
   wire 			  ic_read_ok;
   wire 			  ic_memctrl_read;
   wire [31 : 0] 	  ic_memctrl_addr;

   // ex_mem output
   wire 			  exmem_mem_write_pc;
   wire [31 : 0] 	  exmem_mem_pc_val;
   wire [4 : 0] 	  exmem_mem_jmp_rd;
   wire [31 : 0] 	  exmem_mem_jmp_rd_val;
   wire [4 : 0] 	  exmem_mem_reg_id;
   wire [1 : 0] 	  exmem_mem_reg_op;
   wire [31 : 0] 	  exmem_mem_reg_val;
   wire [31 : 0] 	  exmem_mem_mem_addr;
   wire [2 : 0] 	  exmem_mem_mem_type;
   wire 			  exmem_ex_mem_done;

   // stall_register output
   wire [31 : 0] 	  wc_read_1_ans;
   wire [31 : 0] 	  wc_read_2_ans;

   // insf output
   wire 			  if_ic_read;
   wire [31 : 0] 	  if_ic_addr;
   wire [31 : 0] 	  if_inst_out;
   wire [31 : 0] 	  if_pc_out;
   
   // id_ex output
   wire [31 : 0] 	  idex_ex_ex_op;
   wire [31 : 0] 	  idex_ex_rs1_val;
   wire [31 : 0] 	  idex_ex_rs2_val;
   wire [4 : 0] 	  idex_ex_rd_id;
   wire [31 : 0] 	  idex_ex_imm;
   wire [31 : 0] 	  idex_ex_pc_val;
   wire 			  idex_id_ex_done;
   
   // register output
   wire [31 : 0] 	  reg_read_1_val;
   wire [31 : 0] 	  reg_read_2_val;

   // wb output
   wire 			  wb_write_pc_out;
   wire [31 : 0] 	  wb_pc_val_out;
   wire 			  wb_write_reg_out;
   wire [4 : 0] 	  wb_reg_id_out;
   wire [31 : 0] 	  wb_reg_val_out;
   wire 			  wb_write_reg_stall;
   wire [4 : 0] 	  wb_reg_stall_id;

   // if_id output
   wire [31 : 0] 	  ifid_out_inst;
   wire [31 : 0] 	  ifid_out_pc_val;
   wire 			  ifid_if_id_done;

   id _id
	 (
	  .clk(clk_in),
	  .rst(rst_in),
	  .rdy(rdy_in),
	  
	  .inst(ifid_out_inst),
	  .pc_val(ifid_out_pc_val),
	  
	  .read_rs1(id_read_rs1),
	  .rs1_id(id_rs1_id),
	  .rs1_val_raw(reg_read_1_val),
	  .rs1_wcnt(wc_read_1_ans),

	  .read_rs2(id_read_rs2),
	  .rs2_id(id_rs2_id),
	  .rs2_val_raw(reg_read_2_val),
	  .rs2_wcnt(wc_read_2_ans),

	  .write_rd_wcnt(id_write_rd_wcnt),

	  .ex_op(id_ex_op),
	  .rs1_val(id_rs1_val),
	  .rs2_val(id_rs2_val),
	  .rd_id(id_rd_id),
	  .imm(id_imm),
	  .ex_pc_val(id_ex_pc_val),

	  .id_ex_done(idex_id_ex_done),
	  .id_done(id_id_done)
	  );

   ex _ex
	 (
	  .clk(clk_in),
	  .rst(rst_in),
	  .rdy(rdy_in),

	  .ex_op(idex_ex_ex_op),
	  .rs1_val(idex_ex_rs1_val),
	  .rs2_val(idex_ex_rs2_val),
	  .rd_id(idex_ex_rd_id),
	  .imm(idex_ex_imm),
	  .pc_val(idex_ex_pc_val),

	  .write_pc(ex_write_pc),
	  .write_pc_val(ex_write_pc_val),
	  .jmp_rd(ex_jmp_rd),
	  .jmp_rd_val(ex_jmp_rd_val),

	  .write_reg_id(ex_write_reg_id),
	  .write_reg_op(ex_write_reg_op),
	  .write_reg_val(ex_write_reg_val),
	  .mem_addr(ex_mem_addr),
	  .mem_type(ex_mem_type),

	  .ex_mem_done(exmem_ex_mem_done),
	  .ex_done(ex_ex_done)
	  );
   
   memctrl _memctrl
	 (
	  .clk(clk_in),
	  .rst(rst_in),
	  .rdy(rdy_in),
	  .io_buffer_full(io_buffer_full),

	  .data_input(mem_din),
	  .data_output(mem_dout),
	  .data_addr(mem_a),
	  .wr_state(mem_wr),

	  .read_inst(ic_memctrl_read),
	  .read_inst_addr(ic_memctrl_addr),
	  .read_inst_ans(mc_read_inst_ans),
	  .read_inst_ok(mc_read_inst_ok),

	  .read_data(mem_mctrl_read),
	  .read_data_addr(mem_mctrl_read_addr),
	  .read_data_len(mem_mctrl_read_len),
	  .read_data_ans(mc_read_data_ans),
	  .read_data_ok(mc_read_data_ok),

	  .write_data(mem_mctrl_write),
	  .write_data_addr(mem_mctrl_write_addr),
	  .write_data_len(mem_mctrl_write_len),
	  .write_data_val(mem_mctrl_write_val),
	  .write_data_ok(mc_write_data_ok)
	  );

   mem _mem
	 (
	  .clk(clk_in),
	  .rst(rst_in),
	  .rdy(rdy_in),

	  .write_pc(exmem_mem_write_pc),
	  .pc_val(exmem_mem_pc_val),
	  .jmp_rd(exmem_mem_jmp_rd),
	  .jmp_rd_val(exmem_mem_jmp_rd_val),

	  .reg_id(exmem_mem_reg_id),
	  .reg_op(exmem_mem_reg_op),
	  .reg_val(exmem_mem_reg_val),
	  .mem_addr(exmem_mem_mem_addr),
	  .mem_type(exmem_mem_mem_type),

	  .wb_write_pc(mem_wb_write_pc),
	  .wb_pc_val(mem_wb_pc_val),

	  .wb_write_reg(mem_wb_write_reg),
	  .wb_reg_id(mem_wb_reg_id),
	  .wb_reg_val(mem_wb_reg_val),

	  .mctrl_read(mem_mctrl_read),
	  .mctrl_read_addr(mem_mctrl_read_addr),
	  .mctrl_read_len(mem_mctrl_read_len),
	  .mctrl_read_ans(mc_read_data_ans),
	  .mctrl_read_ok(mc_read_data_ok),

	  .mctrl_write(mem_mctrl_write),
	  .mctrl_write_addr(mem_mctrl_write_addr),
	  .mctrl_write_len(mem_mctrl_write_len),
	  .mctrl_write_val(mem_mctrl_write_val),
	  .mctrl_write_ok(mc_write_data_ok),

	  .work_done(mem_work_done)
	  );

   icache _icache
	 (
	  .clk(clk_in),
	  .rst(rst_in),
	  .rdy(rdy_in),

	  .read(if_ic_read),
	  .read_addr(if_ic_addr),
	  .read_ans(ic_read_ans),
	  .read_ok(ic_read_ok),

	  .memctrl_ok(mc_read_inst_ok),
	  .memctrl_rtn(mc_read_inst_ans),
	  .memctrl_read(ic_memctrl_read),
	  .memctrl_addr(ic_memctrl_addr)
	  );

   ex_mem _ex_mem
	 (
	  .clk(clk_in),
	  .rst(rst_in),
	  .rdy(rdy_in),

	  .write_pc(ex_write_pc),
	  .pc_val(ex_write_pc_val),
	  .jmp_rd(ex_jmp_rd),
	  .jmp_rd_val(ex_jmp_rd_val),

	  .reg_id(ex_write_reg_id),
	  .reg_op(ex_write_reg_op),
	  .reg_val(ex_write_reg_val),
	  .mem_addr(ex_mem_addr),
	  .mem_type(ex_mem_type),

	  .mem_write_pc(exmem_mem_write_pc),
	  .mem_pc_val(exmem_mem_pc_val),
	  .mem_jmp_rd(exmem_mem_jmp_rd),
	  .mem_jmp_rd_val(exmem_mem_jmp_rd_val),

	  .mem_reg_id(exmem_mem_reg_id),
	  .mem_reg_op(exmem_mem_reg_op),
	  .mem_reg_val(exmem_mem_reg_val),
	  .mem_mem_addr(exmem_mem_mem_addr),
	  .mem_mem_type(exmem_mem_mem_type),

	  .mem_done(mem_work_done),
	  .ex_mem_done(exmem_ex_mem_done)
	  );

   stall_register _stall_register
	 (
	  .clk(clk_in),
	  .rst(rst_in),
	  .rdy(rdy_in),

	  .write(id_write_rd_wcnt),
	  .write_addr(id_rd_id),

	  .finish_write(wb_write_reg_stall),
	  .finish_write_addr(wb_reg_stall_id),

	  .read_1(id_read_rs1),
	  .read_1_addr(id_rs1_id),
	  .read_1_ans(wc_read_1_ans),

	  .read_2(id_read_rs2),
	  .read_2_addr(id_rs2_id),
	  .read_2_ans(wc_read_2_ans)
	  );

   insf _insf
	 (
	  .clk(clk_in),
	  .rst(rst_in),
	  .rdy(rdy_in),

	  .write_pc(wb_write_pc_out),
	  .write_pc_val(wb_pc_val_out),

	  .ic_read(if_ic_read),
	  .ic_addr(if_ic_addr),
	  .ic_ans(ic_read_ans),
	  .ic_done(ic_read_ok),

	  .inst_out(if_inst_out),
	  .pc_out(if_pc_out),

	  .if_id_done(ifid_if_id_done)
	  );

   id_ex _id_ex
	 (
	  .clk(clk_in),
	  .rst(rst_in),
	  .rdy(rdy_in),

	  .ex_op(id_ex_op),
	  .rs1_val(id_rs1_val),
	  .rs2_val(id_rs2_val),
	  .rd_id(id_rd_id),
	  .imm(id_imm),
	  .pc_val(id_ex_pc_val),

	  .ex_ex_op(idex_ex_ex_op),
	  .ex_rs1_val(idex_ex_rs1_val),
	  .ex_rs2_val(idex_ex_rs2_val),
	  .ex_rd_id(idex_ex_rd_id),
	  .ex_imm(idex_ex_imm),
	  .ex_pc_val(idex_ex_pc_val),

	  .ex_done(ex_ex_done),
	  .id_ex_done(idex_id_ex_done)
	  );

   register _register
	 (
	  .clk(clk_in),
	  .rst(rst_in),
	  .rdy(rdy_in),

	  .write(wb_write_reg_out),
	  .write_addr(wb_reg_id_out),
	  .write_val(wb_reg_val_out),

	  .read_1(id_read_rs1),
	  .read_1_addr(id_rs1_id),
	  .read_1_val(reg_read_1_val),

	  .read_2(id_read_rs2),
	  .read_2_addr(id_rs2_id),
	  .read_2_val(reg_read_2_val)
	  );

   wb _wb
	 (
	  .clk(clk_in),
	  .rst(rst_in),
	  .rdy(rdy_in),

	  .write_pc(mem_wb_write_pc),
	  .pc_val(mem_wb_pc_val),

	  .write_reg(mem_wb_write_reg),
	  .reg_id(mem_wb_reg_id),
	  .reg_val(mem_wb_reg_val),

	  .write_pc_out(wb_write_pc_out),
	  .pc_val_out(wb_pc_val_out),

	  .write_reg_out(wb_write_reg_out),
	  .reg_id_out(wb_reg_id_out),
	  .reg_val_out(wb_reg_val_out),

	  .write_reg_stall(wb_write_reg_stall),
	  .reg_stall_id(wb_reg_stall_id)
	  );

   if_id _if_id
	 (
	  .clk(clk_in),
	  .rst(rst_in),
	  .rdy(rdy_in),

	  .inst(if_inst_out),
	  .pc_val(if_pc_out),

	  .out_inst(ifid_out_inst),
	  .out_pc_val(ifid_out_pc_val),

	  .id_done(id_id_done),
	  .if_id_done(ifid_if_id_done)
	  );
   
   
endmodule
