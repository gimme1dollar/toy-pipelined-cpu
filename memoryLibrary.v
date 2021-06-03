`include "parameter.v"

module instMem(inputAddr, memData, readM1, address1, inst);
    input [`WORD_SIZE-1:0] inputAddr;
    input [`WORD_SIZE-1:0] memData;
    
    output readM1;
    output [`WORD_SIZE-1:0] address1;
    output [`WORD_SIZE-1:0] inst;

    assign readM1 = 1'b1;
    assign address1 = inputAddr;
    assign inst = memData;
endmodule

module dataMem(memRead, memWrite, addr, writeData, memData, readM2, writeM2, address2, pipe);
    input memRead;
    input memWrite;
    input [`WORD_SIZE-1:0] addr;
    input [`WORD_SIZE-1:0] writeData;

    output [`WORD_SIZE-1:0] memData;
    output readM2;
    output writeM2;
    output [`WORD_SIZE-1:0] address2;

    inout [`WORD_SIZE-1:0] pipe;

    assign memData = pipe;
    assign readM2 = memRead;
    assign writeM2 = memWrite;
    assign address2 = addr;
    assign pipe = memWrite ? writeData : `WORD_SIZE'bz;
endmodule