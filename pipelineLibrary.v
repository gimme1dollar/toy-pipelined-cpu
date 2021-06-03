`include "parameter.v"
`include "latchLibrary.v"

module pipelineIF_ID(Clk, Reset_N, latchWrite, inputPC, outputPC, inputInst, outputInst, inputPred, outputPred, inputTarget, outputTarget);
    input Clk;
    input Reset_N;
    input latchWrite;
    input [`WORD_SIZE-1:0] inputPC;
    input [`WORD_SIZE-1:0] inputInst;
    input [`WORD_SIZE-1:0] inputPred;
    input [`WORD_SIZE-1:0] inputTarget;

    output [`WORD_SIZE-1:0] outputPC;
    output [`WORD_SIZE-1:0] outputInst;
    output [`WORD_SIZE-1:0] outputPred;
    output [`WORD_SIZE-1:0] outputTarget;

    latch_16 pcLatch(.Clk(Clk), .Reset_N(Reset_N), .latchWrite(latchWrite), .inputData(inputPC), .outputData(outputPC));
    latch_16 instLatch(.Clk(Clk), .Reset_N(Reset_N), .latchWrite(latchWrite), .inputData(inputInst), .outputData(outputInst));
    latch_16 predLatch(.Clk(Clk), .Reset_N(Reset_N), .latchWrite(latchWrite), .inputData(inputPred), .outputData(outputPred));
    latch_16 targetLatch(.Clk(Clk), .Reset_N(Reset_N), .latchWrite(latchWrite), .inputData(inputTarget), .outputData(outputTarget));
endmodule

module pipelineID_EX(Clk, Reset_N, inputPC, outputPC, inputR1, outputR1, inputR2, outputR2,
                        inputOff, outputOff, inputRt, outputRt, inputRd, outputRd, inputRs, outputRs,
                        inputCtrlWB, outputCtrlWB, inputCtrlMEM, outputCtrlMEM, inputCtrlEX, outputCtrlEX);
    input Clk;
    input Reset_N;

    input [`WORD_SIZE-1:0] inputPC;
    output [`WORD_SIZE-1:0] outputPC;

    input [`WORD_SIZE-1:0] inputR1;
    output [`WORD_SIZE-1:0] outputR1;

    input [`WORD_SIZE-1:0] inputR2;
    output [`WORD_SIZE-1:0] outputR2;

    input [`WORD_SIZE-1:0] inputOff;
    output [`WORD_SIZE-1:0] outputOff;

    input [`REG_SIZE-1:0] inputRt;
    output [`REG_SIZE-1:0] outputRt;

    input [`REG_SIZE-1:0] inputRd;
    output [`REG_SIZE-1:0] outputRd;

    input [`REG_SIZE-1:0] inputRs;
    output [`REG_SIZE-1:0] outputRs;

    input[4:0] inputCtrlWB; //RegWrite, MemToReg
    output[4:0] outputCtrlWB;

    input[1:0] inputCtrlMEM; // readMEM, writeMEM
    output[1:0] outputCtrlMEM;

    input[8:0] inputCtrlEX; // ALUOp(4), ALUsrcA(1), ALUsrcB(2), RegDst(2)
    output[8:0] outputCtrlEX;

    // EX  9
    // MEM 2
    // WB 5

    latch_16 pcLatch(.Clk(Clk), .Reset_N(Reset_N), .latchWrite(1'b1), .inputData(inputPC), .outputData(outputPC));
    latch_16 r1Latch(.Clk(Clk), .Reset_N(Reset_N), .latchWrite(1'b1), .inputData(inputR1), .outputData(outputR1));
    latch_16 r2Latch(.Clk(Clk), .Reset_N(Reset_N), .latchWrite(1'b1), .inputData(inputR2), .outputData(outputR2));
    latch_16 offLatch(.Clk(Clk), .Reset_N(Reset_N), .latchWrite(1'b1), .inputData(inputOff), .outputData(outputOff));
    latch_2 rsLatch(.Clk(Clk), .Reset_N(Reset_N), .latchWrite(1'b1), .inputData(inputRs), .outputData(outputRs));
    latch_2 rtLatch(.Clk(Clk), .Reset_N(Reset_N), .latchWrite(1'b1), .inputData(inputRt), .outputData(outputRt));
    latch_2 rdLatch(.Clk(Clk), .Reset_N(Reset_N), .latchWrite(1'b1), .inputData(inputRd), .outputData(outputRd));
    latch_2 ctrlMEMLatch(.Clk(Clk), .Reset_N(Reset_N), .latchWrite(1'b1), .inputData(inputCtrlMEM), .outputData(outputCtrlMEM));
    latch_5 ctrlWBLatch(.Clk(Clk), .Reset_N(Reset_N), .latchWrite(1'b1), .inputData(inputCtrlWB), .outputData(outputCtrlWB));
    latch_9 ctrlEXLatch(.Clk(Clk), .Reset_N(Reset_N), .latchWrite(1'b1), .inputData(inputCtrlEX), .outputData(outputCtrlEX));

endmodule

module pipelineEX_MEM(Clk, Reset_N, inputALU, outputALU,
                        inputWD, outputWD, inputRw, outputRw,
                        inputCtrlWB, outputCtrlWB, inputCtrlMEM, outputCtrlMEM);
    input Clk;
    input Reset_N;

    input [`WORD_SIZE-1:0] inputALU;
    output [`WORD_SIZE-1:0] outputALU;

    input [`WORD_SIZE-1:0] inputWD;
    output [`WORD_SIZE-1:0] outputWD;

    input [`REG_SIZE-1:0] inputRw;
    output [`REG_SIZE-1:0] outputRw;

    input[4:0] inputCtrlWB; //RegWrite, MemToReg
    output[4:0] outputCtrlWB;

    input[1:0] inputCtrlMEM; // readMEM, writeMEM
    output[1:0] outputCtrlMEM;

    // EX  10
    // MEM 2
    // WB 4

    latch_16 aluLatch(.Clk(Clk), .Reset_N(Reset_N), .latchWrite(1'b1), .inputData(inputALU), .outputData(outputALU));
    latch_16 wdLatch(.Clk(Clk), .Reset_N(Reset_N), .latchWrite(1'b1), .inputData(inputWD), .outputData(outputWD));
    latch_2 rwLatch(.Clk(Clk), .Reset_N(Reset_N), .latchWrite(1'b1), .inputData(inputRw), .outputData(outputRw));
    latch_2 ctrlMEMLatch(.Clk(Clk), .Reset_N(Reset_N), .latchWrite(1'b1), .inputData(inputCtrlMEM), .outputData(outputCtrlMEM));
    latch_5 ctrlWBLatch(.Clk(Clk), .Reset_N(Reset_N), .latchWrite(1'b1), .inputData(inputCtrlWB), .outputData(outputCtrlWB));

endmodule

module pipelineMEM_WB(Clk, Reset_N, inputMEM, outputMEM,
                        inputWD, outputWD, inputRw, outputRw, inputCtrlWB, outputCtrlWB);
    input Clk;
    input Reset_N;

    input [`WORD_SIZE-1:0] inputMEM;
    output [`WORD_SIZE-1:0] outputMEM;

    input [`WORD_SIZE-1:0] inputWD;
    output [`WORD_SIZE-1:0] outputWD;

    input [`REG_SIZE-1:0] inputRw;
    output [`REG_SIZE-1:0] outputRw;

    input[4:0] inputCtrlWB; //RegWrite, MemToReg
    output[4:0] outputCtrlWB;

    // EX  10
    // MEM 2
    // WB 4

    latch_16 memLatch(.Clk(Clk), .Reset_N(Reset_N), .latchWrite(1'b1), .inputData(inputMEM), .outputData(outputMEM));
    latch_16 aluLatch(.Clk(Clk), .Reset_N(Reset_N), .latchWrite(1'b1), .inputData(inputWD), .outputData(outputWD));
    latch_2 rwLatch(.Clk(Clk), .Reset_N(Reset_N), .latchWrite(1'b1), .inputData(inputRw), .outputData(outputRw));
    latch_5 ctrlWBLatch(.Clk(Clk), .Reset_N(Reset_N), .latchWrite(1'b1), .inputData(inputCtrlWB), .outputData(outputCtrlWB));
endmodule