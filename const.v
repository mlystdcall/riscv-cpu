`ifndef CONST_V
 `define CONST_V

 `define REG_CNT 32
 `define REG_LEN 32
 `define LOG_REG_CNT 5

 `define MEMCTRL_IDLE 0
 `define MEMCTRL_READ_INST 1
 `define MEMCTRL_READ_DATA 2
 `define MEMCTRL_WRITE_DATA 3

 `define ICACHE_SZ 1024
 `define LOG_ICACHE_SZ 10

 `define MEM_REG_IDLE 0
 `define MEM_REG_WB 1
 `define MEM_REG_LOAD 2
 `define MEM_REG_STORE 3

 `define MEM_TYPE_LB  3'b000
 `define MEM_TYPE_LH  3'b001
 `define MEM_TYPE_LW  3'b010
 `define MEM_TYPE_LBU 3'b100
 `define MEM_TYPE_LHU 3'b101
 `define MEM_TYPE_SB  3'b000
 `define MEM_TYPE_SH  3'b001
 `define MEM_TYPE_SW  3'b010

 `define EX_NOP 0

 `define EX_ADDI 1
 `define EX_SLTI 2
 `define EX_SLTIU 3
 `define EX_ANDI 4
 `define EX_ORI 5
 `define EX_XORI 6

 `define EX_SLLI 7
 `define EX_SRLI 8
 `define EX_SRAI 9

 `define EX_LUI 10
 `define EX_AUIPC 11

 `define EX_ADD 12
 `define EX_SLT 13
 `define EX_SLTU 14
 `define EX_AND 15
 `define EX_OR 16
 `define EX_XOR 17
 `define EX_SLL 18
 `define EX_SRL 19
 `define EX_SUB 20
 `define EX_SRA 21

 `define EX_JAL 22
 `define EX_JALR 23

 `define EX_BEQ 24
 `define EX_BNE 25
 `define EX_BLT 26
 `define EX_BLTU 27
 `define EX_BGE 28
 `define EX_BGEU 29

 `define EX_LW 30
 `define EX_LH 31
 `define EX_LHU 32
 `define EX_LB 33
 `define EX_LBU 34

 `define EX_SW 35
 `define EX_SH 36
 `define EX_SB 37

 `define OPCODE_OPIMM  7'b0010011
 `define OPCODE_LUI    7'b0110111
 `define OPCODE_AUIPC  7'b0010111
 `define OPCODE_OP     7'b0110011
 `define OPCODE_JAL    7'b1101111
 `define OPCODE_JALR   7'b1100111
 `define OPCODE_BRANCH 7'b1100011
 `define OPCODE_LOAD   7'b0000011
 `define OPCODE_STORE  7'b0100011

 `define FUNCT_JALR  3'b000
 `define FUNCT_BEQ   3'b000
 `define FUNCT_BNE   3'b001
 `define FUNCT_BLT   3'b100
 `define FUNCT_BGE   3'b101
 `define FUNCT_BLTU  3'b110
 `define FUNCT_BGEU  3'b111
 `define FUNCT_LB    3'b000
 `define FUNCT_LH    3'b001
 `define FUNCT_LW    3'b010
 `define FUNCT_LBU   3'b100
 `define FUNCT_LHU   3'b101
 `define FUNCT_SB    3'b000
 `define FUNCT_SH    3'b001
 `define FUNCT_SW    3'b010
 `define FUNCT_ADDI  3'b000
 `define FUNCT_SLTI  3'b010
 `define FUNCT_SLTIU 3'b011
 `define FUNCT_XORI  3'b100
 `define FUNCT_ORI   3'b110
 `define FUNCT_ANDI  3'b111
 `define FUNCT_SLLI  3'b001
 `define FUNCT_SRLI  3'b101
 `define FUNCT_SRAI  3'b101
 `define FUNCT_ADD   3'b000
 `define FUNCT_SUB   3'b000
 `define FUNCT_SLL   3'b001
 `define FUNCT_SLT   3'b010
 `define FUNCT_SLTU  3'b011
 `define FUNCT_XOR   3'b100
 `define FUNCT_SRL   3'b101
 `define FUNCT_SRA   3'b101
 `define FUNCT_OR    3'b110
 `define FUNCT_AND   3'b111

`endif
