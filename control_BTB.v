`include "parameter.v"

module BTB_tag(Clk, Reset_N, curPC, targetPC, Flush, isTaken, upBit);
    input Clk;
    input Reset_N;
    input [`WORD_SIZE-1:0] curPC;
    input [`WORD_SIZE-1:0] targetPC;
    input Flush;
    input isTaken;
    output [`TAG_SIZE-1:0] upBit;

    integer idx;

    reg [`TAG_SIZE-1:0] tagTable[0:`TABLE_NUMS-1];
    reg [`TAG_SIZE-1:0] nxtTag;
    reg [`WORD_SIZE-1:0] nxtTagIdx;
    reg flag;

    assign upBit = tagTable[curPC[`BUFFER_SIZE-1:0]];

    initial begin
        flag <= 0;
        
        for(idx = 0;idx<`TABLE_NUMS;idx=idx+1) begin
            tagTable[idx] <= `BUFFER_SIZE'b1;
        end

        nxtTag <= 0;
        nxtTagIdx <= 0;
    end

    always @(*) begin
        nxtTag <= targetPC[`WORD_SIZE-1:`WORD_SIZE-`TAG_SIZE];
        nxtTagIdx <= targetPC[`BUFFER_SIZE-1:0];
    end

    always @(Clk) begin
        if((Reset_N & Clk) && !flag) begin
            flag <= 1;

            for(idx = 0;idx<`TABLE_NUMS;idx=idx+1) begin
                tagTable[idx] <= `TAG_SIZE'b1;
            end

            nxtTag <= 0;
            nxtTagIdx <= 0;
        end
        else begin
            if(isTaken) tagTable[nxtTagIdx] <= nxtTag;
        end
    end

    
endmodule

module BTB_history(Clk, Reset_N, Flush, isTaken, predTaken);
    input Clk;
    input Reset_N;
    input Flush;
    input isTaken;
    output predTaken;

    reg [1:0] curState; // Global
    reg [1:0] nxtState;
    reg flag;

    assign predTaken = (curState < 2) ? 1'b0 : 1'b1;

    initial begin
        curState <= `STRONG_N;
        nxtState <= `STRONG_N;
        flag <= 0;
    end

    always @(*) begin
        if(isTaken) begin
            if(curState < `MAX_STATE) nxtState <= curState + 1;
            else nxtState <= `MAX_STATE;
        end
        else begin
            if(curState > 0) nxtState <= curState - 1;
            else nxtState <= 0;
        end
    end

    always @(Clk) begin
        if((Reset_N & Clk) && !flag) begin
            curState <= `STRONG_N;
            nxtState <= `STRONG_N;
            flag <= 1;
        end
        else begin
            if(isTaken) curState <= nxtState;
        end
    end
endmodule
    
module BTB_buffer(Clk, Reset_N, curPC, targetPC, realPC, Flush, isTaken, predPC);
    input Clk;
    input Reset_N;
    input [`WORD_SIZE-1:0] curPC;
    input [`WORD_SIZE-1:0] targetPC;
    input [`WORD_SIZE-1:0] realPC;
    input Flush;
    input isTaken;
    output [`WORD_SIZE-1:0] predPC;

    integer idx;
    
    reg [`WORD_SIZE-1:0] bufferTable [0:`TABLE_NUMS-1];
    reg [`WORD_SIZE-1:0] nxtBufferIdx;
    reg [`WORD_SIZE-1:0] nxtBuffer;
    reg flag;

    assign predPC = bufferTable[curPC[`BUFFER_SIZE-1:0]];

    initial begin
        flag <= 0;

        for(idx = 0; idx < `TABLE_NUMS; idx = idx + 1) begin
            bufferTable[idx] = `WORD_SIZE'b0;
        end

        nxtBuffer = `WORD_SIZE'b0;
        nxtBufferIdx = `WORD_SIZE'b0;
    end

    always @(*) begin
        nxtBuffer <= realPC;
        nxtBufferIdx <= targetPC[`BUFFER_SIZE-1:0];
    end

    always @(Clk) begin
        if((Reset_N & Clk) && !flag) begin
            flag <= 1;

            for(idx = 0; idx < `TABLE_NUMS; idx = idx + 1) begin
                bufferTable[idx] <= `WORD_SIZE'b0;
            end

            nxtBuffer <= `WORD_SIZE'b0;
            nxtBufferIdx <= `WORD_SIZE'b0;          
        end
        else begin
            if(isTaken) bufferTable[nxtBufferIdx] = nxtBuffer;
        end
    end

endmodule

module branchTargetBuffer(Clk, Reset_N, curPC, targetPC, realPC, Flush, isTaken, Valid, predPC);
    input Clk;
    input Reset_N;
    input [`WORD_SIZE-1:0] curPC;
    input [`WORD_SIZE-1:0] targetPC;
    input [`WORD_SIZE-1:0] realPC;
    input Flush;
    input isTaken;
    output Valid;
    output [`WORD_SIZE-1:0] predPC;

    wire [`TAG_SIZE-1:0] tag;
    wire Taken;
    wire isSame;
    wire [`TAG_SIZE-1:0] upBit;

    assign upBit = curPC[`WORD_SIZE-1:`WORD_SIZE-`TAG_SIZE];
    assign isSame = (upBit == tag) ? 1'b1 : 1'b0;
    assign Valid = isSame && Taken;

    BTB_tag BTB_tag(.Clk(Clk), .Reset_N(Reset_N), .curPC(curPC), .targetPC(targetPC), .Flush(Flush),
                    .isTaken(isTaken), .upBit(tag));
    BTB_history BTB_history(.Clk(Clk), .Reset_N(Reset_N), .Flush(Flush), .isTaken(isTaken), .predTaken(Taken));
    BTB_buffer BTB_buffer(.Clk(Clk), .Reset_N(Reset_N), .curPC(curPC), .targetPC(targetPC), .realPC(realPC),
                            .Flush(Flush), .isTaken(isTaken), .predPC(predPC));
endmodule
