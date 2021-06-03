`timescale 1ns/1ns
`include "parameter.v"
`include "alu.v"
`include "control_forwarding.v"
`include "control_hazard.v"
`include "control.v"
`include "helperLibrary.v"
`include "latchLibrary.v"
`include "memoryLibrary.v"
`include "muxLibrary.v"
`include "pc.v"
`include "pipelineLibrary.v"
`include "registerLibrary.v"
`include "control_BTB.v"

module cpu(Clk, Reset_N, readM1, address1, data1, readM2, writeM2, address2, data2, num_inst, output_port, is_halted);
	input Clk;
	input Reset_N;

	output readM1;
	output [`WORD_SIZE-1:0] address1;
	
	output readM2;
	output writeM2;
	output [`WORD_SIZE-1:0] address2;

	input [`WORD_SIZE-1:0] data1;
	inout [`WORD_SIZE-1:0] data2;

	output [`WORD_SIZE-1:0] num_inst;
	output [`WORD_SIZE-1:0] output_port;
	output is_halted;

	reg [`WORD_SIZE-1:0] num_inst_reg;
	reg flag;

	wire [`WORD_SIZE-1:0] pc2inst;
	wire [`WORD_SIZE-1:0] inst2mux;
	wire [`WORD_SIZE-1:0] instMux2pipeIF_ID;
	wire [`WORD_SIZE-1:0] pcNext;
	wire [`WORD_SIZE-1:0] pcJump;
	wire [`WORD_SIZE-1:0] mux2pc;

	wire [`WORD_SIZE-1:0] instOut_ID;
	wire [1:0] inst11_10;
	wire [1:0] inst9_8;
	wire [1:0] inst7_6;
	wire [`HALF_SIZE-1:0] inst7_0;
	wire [`WORD_SIZE-1:0] instSignExt;
	wire [`WORD_SIZE-1:0] pcOut_ID;
	wire [`WORD_SIZE-1:0] reg1D_ID;
	wire [`WORD_SIZE-1:0] reg2D_ID;
	wire [`WORD_SIZE-1:0] r1Mux_ID;
	wire [`WORD_SIZE-1:0] r2Mux_ID;
	wire [`WORD_SIZE-1:0] pcImm;
	wire [`WORD_SIZE-1:0] pcOut_EX;
	wire [`WORD_SIZE-1:0] r1Out_EX;
	wire [`WORD_SIZE-1:0] r2Out_EX;
	wire [`WORD_SIZE-1:0] r1Mux_EX;
	wire [`WORD_SIZE-1:0] r2Mux_EX;
	wire [`WORD_SIZE-1:0] offOut_EX;
	wire [`WORD_SIZE-1:0] alu1Out_EX;
	wire [`WORD_SIZE-1:0] alu2Out_EX;
	wire [`WORD_SIZE-1:0] aluOut_EX;
	wire [1:0] rtOut_EX;
	wire [1:0] rdOut_EX;
	wire [1:0] rsOut_EX;
	wire [1:0] rwMuxOut_EX;
	wire [`WORD_SIZE-1:0] aluOut_MEM;
	wire [`WORD_SIZE-1:0] wdOut_MEM;
	wire [1:0] rwOut_MEM;
	wire [`WORD_SIZE-1:0] memData;
	wire [`WORD_SIZE-1:0] memOut_WB;
	wire [`WORD_SIZE-1:0] wdOut_WB;
	wire [`WORD_SIZE-1:0] wdResult_WB;
	wire [1:0] rwOut_WB;
	wire [1:0] forwardA_ID;
	wire [1:0] forwardB_ID;
	wire [1:0] forwardA_EX;
	wire [1:0] forwardB_EX;

	/* Control */
	wire [1:0] ctrlPC;
	wire [2:0] ctrlB;
	wire [4:0] ctrl_ID;
	wire ctrlW;
	wire [1:0] ctrlRegDst;
	wire ctrlALUsrcA;
	wire [1:0] ctrlALUsrcB;
	wire [3:0] ctrlALUOp;
	wire [8:0] ctrl_EX;
	wire [8:0] ctrl_EX_forward;
	wire ctrlMemWrite;
	wire ctrlMemRead;
	wire [1:0] ctrl_MEM;
	wire [1:0] ctrl_MEM_MEM;
	wire [1:0] ctrl_MEM_forward;
	wire ctrlH;
	wire ctrlMemToReg;
	wire ctrlRegWrite;
	wire ctrlNumInst;
	wire [4:0] ctrl_WB;
	wire [4:0] ctrl_WB_MEM;
	wire [4:0] ctrl_WB_WB;
	wire [4:0] ctrl_WB_forward;
	wire isTaken;
	wire Stall;
	wire Flush_IF;
	wire sigNumInst_WB;
	wire [`WORD_SIZE-1:0] btb2flush;

	wire [`WORD_SIZE-1:0] pred_IF;
	wire [`WORD_SIZE-1:0] pred_ID;
	wire [`WORD_SIZE-1:0] target_ID;
	wire valid_IF;
	wire [`WORD_SIZE-1:0] realPC_ID;

	assign inst11_10 = instOut_ID[11:10];
	assign inst9_8 = instOut_ID[9:8];
	assign inst7_6 = instOut_ID[7:6];
	assign inst7_0 = instOut_ID[7:0];

	assign ctrl_ID = {ctrlPC[1:0], ctrlB[2:0]};
	assign ctrl_EX = {ctrlRegDst[1:0], ctrlALUsrcA, ctrlALUsrcB, ctrlALUOp};
	assign ctrl_MEM = {ctrlMemWrite, ctrlMemRead};
	assign ctrl_WB = {ctrlW, ctrlH, ctrlMemToReg, ctrlRegWrite, ctrlNumInst};
	assign is_halted = ctrl_WB_forward[3];
	assign num_inst = num_inst_reg;
	assign sigNumInst_WB = ctrl_WB_forward[0];

	initial begin
		flag <= 0;
	end

	always @(posedge Clk) begin
		if((Reset_N&Clk) && !flag) begin
			num_inst_reg <= 0;
			flag <= 1;
		end
		else begin
			if(sigNumInst_WB && flag) num_inst_reg = num_inst_reg + 1;
		end
	end

	/* IF */
	pc pc(.Clk(Clk), .Reset_N(Reset_N), .pcWrite(!Stall), .inputAddr(mux2pc), .outputAddr(pc2inst));
	mux2_16 muxBTB(.state(valid_IF), .zero(pcNext), .one(pred_IF), .return(btb2flush));
	mux2_16 muxFlush(.state(Flush_IF), .zero(btb2flush), .one(realPC_ID), .return(mux2pc));
	ALU adderIF(.A(pc2inst), .B(16'b1), .C(pcNext), .FUNC(4'b0000));
	concat concatIF(.pc(pcOut_ID), .inst(instOut_ID), .jump(pcJump));
	instMem INSTMEM(.inputAddr(pc2inst), .memData(data1), .readM1(readM1), .address1(address1), .inst(inst2mux));
	mux2_16 muxInst(.state(Flush_IF), .zero(inst2mux), .one(16'b0), .return(instMux2pipeIF_ID));
	branchTargetBuffer BTB(.Clk(Clk), .Reset_N(Reset_N), .curPC(pc2inst), .targetPC(target_ID), .realPC(realPC_ID),
							.Flush(Flush_IF), .isTaken(isTaken), .Valid(valid_IF), .predPC(pred_IF));

	/* IF_ID */
	pipelineIF_ID plIF_ID(.Clk(Clk), .Reset_N(Reset_N), .latchWrite(!Stall), .inputPC(pcNext), .outputPC(pcOut_ID),
							.inputInst(instMux2pipeIF_ID), .outputInst(instOut_ID), .inputPred(mux2pc), .outputPred(pred_ID),
							.inputTarget(pc2inst), .outputTarget(target_ID));
	
	/* ID */
	mux4_16 muxPC(.state(ctrl_ID[4:3]), .zero(pcOut_ID), .one(pcImm), .two(pcJump), .three(r1Mux_ID), .return(realPC_ID));
	ALU adderID(.A(instSignExt), .B(pcOut_ID), .C(pcImm), .FUNC(4'b0000));
	register REG(.Clk(Clk), .Reset_N(Reset_N), .regWrite(ctrl_WB_forward[1]), .reg1(inst11_10), .reg2(inst9_8), .regW(rwOut_WB),
					.writeData(wdResult_WB), .reg1D(reg1D_ID), .reg2D(reg2D_ID));
	signExt ext(.inputData(inst7_0), .outputData(instSignExt));
	mux4_16 r1_ID(.state(forwardA_ID), .zero(reg1D_ID), .one(aluOut_EX), .two(aluOut_MEM), .three(16'b0), .return(r1Mux_ID));
	mux4_16 r2_ID(.state(forwardB_ID), .zero(reg2D_ID), .one(aluOut_EX), .two(aluOut_MEM), .three(16'b0), .return(r2Mux_ID));
	branchUnit branch(.rs(r1Mux_ID), .rt(r2Mux_ID), .cond(isTaken), .type(ctrl_ID[2:0]));

	/* ID_EX */
	pipelineID_EX plID_EX(.Clk(Clk), .Reset_N(Reset_N), .inputPC(pcOut_ID), .outputPC(pcOut_EX), .inputR1(r1Mux_ID), .outputR1(r1Out_EX), .inputR2(r2Mux_ID), .outputR2(r2Out_EX),
                        .inputOff(instSignExt), .outputOff(offOut_EX), .inputRt(inst9_8), .outputRt(rtOut_EX), .inputRd(inst7_6), .outputRd(rdOut_EX), .inputRs(inst11_10), .outputRs(rsOut_EX),
						.inputCtrlWB(ctrl_WB), .outputCtrlWB(ctrl_WB_MEM), .inputCtrlMEM(ctrl_MEM), .outputCtrlMEM(ctrl_MEM_MEM), .inputCtrlEX(ctrl_EX), .outputCtrlEX(ctrl_EX_forward));

	/* EX */
	mux4_16 r1_EX(.state(forwardA_EX), .zero(r1Out_EX), .one(wdResult_WB), .two(aluOut_MEM), .three(16'b0), .return(r1Mux_EX));
	mux4_16 r2_EX(.state(forwardB_EX), .zero(r2Out_EX), .one(wdResult_WB), .two(aluOut_MEM), .three(16'b0), .return(r2Mux_EX));
	mux2_16 aluSrc1(.state(ctrl_EX_forward[6]), .zero(pcOut_EX), .one(r1Mux_EX), .return(alu1Out_EX));
	mux4_16 aluSrc2(.state(ctrl_EX_forward[5:4]), .zero(16'b0), .one(r2Mux_EX), .two(offOut_EX), .three(16'b0), .return(alu2Out_EX));
	mux4_2 rW_EX(.state(ctrl_EX_forward[8:7]), .zero(rdOut_EX), .one(rtOut_EX), .two(2'b10), .three(2'b0), .return(rwMuxOut_EX));
	ALU alu(.A(alu1Out_EX), .B(alu2Out_EX), .C(aluOut_EX), .FUNC(ctrl_EX_forward[3:0]));
	registerTemplate OUTPUT(.clk(Clk), .Reset_N(Reset_N), .regWrite(ctrl_WB_forward[4]), .inputData(wdOut_WB), .outputData(output_port));
    
	/* EX_MEM */
	pipelineEX_MEM plEX_MEM(.Clk(Clk), .Reset_N(Reset_N), .inputALU(aluOut_EX), .outputALU(aluOut_MEM),
                        .inputWD(r2Out_EX), .outputWD(wdOut_MEM), .inputRw(rwMuxOut_EX), .outputRw(rwOut_MEM),
                       .inputCtrlWB(ctrl_WB_MEM), .outputCtrlWB(ctrl_WB_WB), .inputCtrlMEM(ctrl_MEM_MEM), .outputCtrlMEM(ctrl_MEM_forward));

	/* MEM */
	dataMem DATAMEM(.memRead(ctrl_MEM_forward[0]), .memWrite(ctrl_MEM_forward[1]), .addr(aluOut_MEM), .writeData(wdOut_MEM),
						.memData(memData), .readM2(readM2), .writeM2(writeM2), .address2(address2), .pipe(data2));

	/* MEM_WB */
	pipelineMEM_WB plMEM_WB(.Clk(Clk), .Reset_N(Reset_N), .inputMEM(memData), .outputMEM(memOut_WB),
                        .inputWD(aluOut_MEM), .outputWD(wdOut_WB), .inputRw(rwOut_MEM), .outputRw(rwOut_WB),
						.inputCtrlWB(ctrl_WB_WB), .outputCtrlWB(ctrl_WB_forward));

	/* WB */

	mux2_16 data_WB(.state(ctrl_WB_forward[2]), .zero(memOut_WB), .one(wdOut_WB), .return(wdResult_WB));

	/* Control Units */
	control Ctrl(.Stall(Stall), .isTaken(isTaken), .inst(instOut_ID), .RegDst(ctrlRegDst), .ALUSrcA(ctrlALUsrcA), .ALUSrcB(ctrlALUsrcB), .ALUOp(ctrlALUOp),
				 .MemWrite(ctrlMemWrite), .MemRead(ctrlMemRead), .MemToReg(ctrlMemToReg), .RegWrite(ctrlRegWrite), 
				 .sigPC(ctrlPC), .sigB(ctrlB), .sigW(ctrlW), .sigH(ctrlH), .sigNumInst(ctrlNumInst));
	control_forwarding_ID Ctrl_Forw_ID(.inputS(inst11_10), .inputT(inst9_8), .inputW_X(rwMuxOut_EX), .inputW_M(rwOut_MEM),
										.forwardA(forwardA_ID), .forwardB(forwardB_ID), .controlEX(ctrl_WB_MEM[1]), .controlMEM(ctrl_WB_WB[1]));
	control_forwarding_EX Ctrl_Forw_EX(.inputS(rsOut_EX), .inputT(rtOut_EX), .inputW_M(rwOut_MEM), .inputW_W(rwOut_WB),
										.forwardA(forwardA_EX), .forwardB(forwardB_EX), .controlWB(ctrl_WB_forward[1]), .controlMEM(ctrl_WB_WB[1]));
	control_hazard Ctrl_Hzrd(.realPC(realPC_ID), .predPC(pred_ID), .inst_ID(instOut_ID), .rt_EX(rtOut_EX),
								.memRead_EX(ctrl_MEM_MEM[0]), .Stall(Stall), .Flush_IF(Flush_IF));
endmodule
