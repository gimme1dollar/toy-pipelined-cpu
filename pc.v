`include "parameter.v"

module pc(Clk, Reset_N, pcWrite, inputAddr, outputAddr);
    input Clk;
    input Reset_N;
    input pcWrite;
    input [`WORD_SIZE-1:0] inputAddr;
    
    output [`WORD_SIZE-1:0] outputAddr;

    reg [`WORD_SIZE-1:0] current_pc;
    reg [`WORD_SIZE-1:0] nxt_pc;
    reg flag;

    assign outputAddr = current_pc;

    initial begin
        flag <= 0;
    end

    always @(*) begin
        nxt_pc <= inputAddr;
    end

    always @(posedge Clk) begin
        if((Reset_N&Clk) && !flag) begin
            current_pc <= 0;
            nxt_pc <= 0;
            flag <= 1;
        end
        else begin
            if(pcWrite) current_pc <= nxt_pc;
        end
    end
endmodule