`define REG_SIZE 2
`define REG_NUMS 4
`define WORD_SIZE 16
`define HALF_SIZE 8

//OPCODES
`define	OP_ALU	4'b1111
`define	OP_ADI  4'b0100
`define	OP_ORI	4'b0101
`define	OP_LHI	4'b0110
`define	OP_LWD	4'b0111   		  
`define	OP_SWD	4'b1000 
`define	OP_BNE	4'b0000
`define	OP_BEQ	4'b0001
`define OP_BGZ	4'b0010
`define OP_BLZ	4'b0011
`define	OP_JMP	4'b1001
`define OP_JAL	4'b1010

// FUNCCODES
`define FUNC_ADD 6'd0
`define FUNC_SUB 6'd1
`define FUNC_AND 6'd2
`define FUNC_ORR 6'd3
`define FUNC_NOT 6'd4
`define FUNC_TCP 6'd5
`define FUNC_SHL 6'd6
`define FUNC_SHR 6'd7
`define FUNC_WWD 6'd28
`define FUNC_JPR 6'd25
`define FUNC_JRL 6'd26
`define FUNC_HLT 6'd29

// BTB
`define BUFFER_SIZE 10
`define TAG_SIZE 6
`define TABLE_NUMS 1024

// history
`define STRONG_N 0
`define WEAK_N 1
`define WEAK_T 2
`define STRONG_T 3
`define MAX_STATE 3