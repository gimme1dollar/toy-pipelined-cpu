`include "parameter.v"

module control (Stall, isTaken, inst, RegDst, ALUSrcA, ALUSrcB, ALUOp, MemWrite, MemRead, MemToReg, RegWrite, sigPC, sigB, sigW, sigH, sigNumInst);
    input Stall;
	input isTaken;
	input [`WORD_SIZE-1:0] inst;
	
	wire [3:0] opcode;
	wire [5:0] funccode;
    
	output [1:0] RegDst;
    output MemWrite;
    output MemRead;
    output MemToReg;
    output RegWrite;
   	output ALUSrcA;
	output [1:0] ALUSrcB;
    output [3:0] ALUOp;
	output [1:0] sigPC; // +1, +Imm, jump, $rs
    output [2:0] sigB;
    output sigW; //WWD
    output sigH; //HLT
	output sigNumInst;

    /* ID */
	reg [1:0] ctrlPC;
	reg [2:0] ctrlB; // 맨 첫번째는 Branch 여부를 의미

	/* EX */	
    reg ctrlW;
	reg [1:0] ctrlRegDst;
	reg ctrlALUSrcA; // "1bit"
	reg [1:0] ctrlALUSrcB;
	reg [3:0] ctrlALUOp; // 맨 첫번째는 I 여부를 의미

	/* MEM */
	reg ctrlMemWrite;
	reg ctrlMemRead;

	/* WB */
    reg ctrlH;
	reg ctrlMemToReg;
	reg ctrlRegWrite;
	reg ctrlNumInst;

    assign opcode = inst[`WORD_SIZE-1:`WORD_SIZE-4];
    assign funccode = inst[5:0];
    assign RegDst = ctrlRegDst;
    assign MemWrite = ctrlMemWrite;
    assign MemRead = ctrlMemRead;
    assign MemToReg = ctrlMemToReg;
    assign RegWrite = ctrlRegWrite;
   	assign ALUSrcA = ctrlALUSrcA;
	assign ALUSrcB = ctrlALUSrcB;
    assign ALUOp = ctrlALUOp; // "4bit"
	assign sigPC = ctrlPC;
    assign sigB = ctrlB;
    assign sigW = ctrlW; //WWD
    assign sigH = ctrlH; //HLT
	assign sigNumInst = ctrlNumInst;

	initial begin
		ctrlRegDst = 2'b00;
		ctrlMemWrite = 1'b0;
		ctrlMemRead = 1'b0;
		ctrlMemToReg = 1'b1;
		ctrlRegWrite = 1'b0;
		ctrlALUSrcA = 1'b1;
		ctrlALUSrcB = 2'b00;
		ctrlALUOp = 4'b000;

		ctrlPC = 2'b00;
		ctrlB = 3'b000;
        ctrlW = 1'b0;
        ctrlH = 1'b0;
		ctrlNumInst = 1'b0;
	end

	always @(opcode, funccode, Stall, isTaken) begin		
        /* Initialize Signals */
		ctrlPC = 2'b00;
		ctrlRegDst = 2'b00;
		ctrlMemWrite = 1'b0;
		ctrlMemRead = 1'b0;
		ctrlMemToReg = 1'b1;
		ctrlRegWrite = 1'b0;
		ctrlALUSrcA = 1'b1;
		ctrlALUSrcB = 2'b00;
		ctrlALUOp = 4'b000;
		ctrlPC = 2'b00;
		ctrlB = 3'b000;
        ctrlW = 1'b0;
        ctrlH = 1'b0;
		ctrlNumInst = 1'b0;

		if(inst!=0 && !Stall) begin // NOT NOP
			ctrlNumInst = 1'b1;
			case (opcode)
			/* R-Type */
			`OP_ALU : begin
				case (funccode)
				/* R-Type Ordinary */
				default : begin
					ctrlRegDst = 2'b00;
					ctrlRegWrite = 1'b1;
					ctrlALUSrcA = 1'b1;
					ctrlALUSrcB = 2'b01;
					ctrlALUOp = {1'b0, funccode[2:0]}; // 4bit
				end
				/* R-Type Special*/
				`FUNC_WWD : begin // EX단계에서 진행
					ctrlW = 1'b1;
					ctrlALUOp = 0000; // ADD
					ctrlALUSrcA = 2'b1; // RS
					ctrlALUSrcB = 2'b00; // 0
				end
				`FUNC_HLT : begin
					ctrlH = 1'b1;
				end
				/* R-Type Jump*/
				`FUNC_JPR : begin // EX단계 거침
					ctrlPC = 2'b11;
				end
				`FUNC_JRL : begin // EX단계 거침
					ctrlPC = 2'b11;
					ctrlRegWrite = 1'b1;
					ctrlRegDst = 2'b10; // $2
					ctrlALUOp = 4'b1000; // ADD
					ctrlALUSrcA = 1'b0; // PC
					ctrlALUSrcB = 2'b00; // 0
				end
				endcase
			end 

			/* I-Type Ordinary */
			`OP_ADI : begin
				ctrlRegWrite = 1'b1;
				ctrlRegDst = 2'b01;
				ctrlALUOp = 4'b1000;
				ctrlALUSrcA = 1'b1;
				ctrlALUSrcB = 2'b10;
			end
			`OP_ORI : begin
				ctrlRegWrite = 1'b1;
				ctrlRegDst = 2'b01;
				ctrlALUOp = 4'b1001; 
				ctrlALUSrcA = 1'b1;
				ctrlALUSrcB = 2'b10;
			end
			`OP_LHI : begin
				ctrlRegWrite = 1'b1;
				ctrlRegDst = 2'b01;
				ctrlALUOp = 4'b1010; 
				ctrlALUSrcA = 1'b1;
				ctrlALUSrcB = 2'b10;
			end
			/* I-Type Memory*/
			`OP_LWD : begin // 
				ctrlMemRead = 1'b1;
				ctrlMemToReg = 1'b0;
				ctrlRegWrite = 1'b1;
				ctrlRegDst = 2'b01;
				ctrlALUOp = 4'b1000; 
				ctrlALUSrcA = 1'b1;
				ctrlALUSrcB = 2'b10;
			end
			`OP_SWD : begin // 
				ctrlRegDst = 2'b01;
				ctrlMemWrite = 1'b1;
				ctrlALUOp = 4'b1000; 
				ctrlALUSrcA = 1'b1;
				ctrlALUSrcB = 2'b10;
			end
			/* I-Type Branch */
			`OP_BNE : begin
				ctrlPC = (isTaken) ? 2'b01 : 2'b00;
				ctrlB = 3'b100;
			end
			`OP_BEQ : begin
				ctrlPC = (isTaken) ? 2'b01 : 2'b00;
				ctrlB = 3'b101;
			end
			`OP_BGZ : begin
				ctrlPC = (isTaken) ? 2'b01 : 2'b00;
				ctrlB = 3'b110;
			end
			`OP_BLZ : begin
				ctrlPC = (isTaken) ? 2'b01 : 2'b00;
				ctrlB = 3'b111;
			end

			/* J-Type */
			`OP_JMP : begin
				ctrlPC = 2'b10;
			end
			`OP_JAL : begin // 한번 Stall도하고, EX도 거쳐서
				ctrlPC = 2'b10;
				ctrlRegWrite = 1'b1;
				ctrlRegDst = 2'b10; // $2
				ctrlALUOp = 1000;
				ctrlALUSrcA = 1'b0; // PC
				ctrlALUSrcB = 2'b00; // 0
			end
			endcase
		end
	end
endmodule

