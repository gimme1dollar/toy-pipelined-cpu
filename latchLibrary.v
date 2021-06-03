`include "parameter.v"

module latch_2(Clk, Reset_N, latchWrite, inputData, outputData);
    input Clk;
    input Reset_N;
    input [`REG_SIZE-1:0] inputData;
    input latchWrite;

    output [`REG_SIZE-1:0] outputData;

    reg [`REG_SIZE-1:0] current_data;
    reg [`REG_SIZE-1:0] nxt_data;
    reg flag;

    assign outputData = current_data;
    
    initial begin
        current_data <= 0;
        nxt_data <=0;
        flag <= 0;
    end

    always @(*) begin
        nxt_data <= inputData;
    end

    always @(posedge Clk) begin
        if((Reset_N&Clk) && !flag) begin
            current_data <= 0;
            nxt_data <= 0;
            flag <= 1;
        end
        else begin
            if (latchWrite) current_data <= nxt_data;
        end
    end
endmodule

module latch_4(Clk, Reset_N, latchWrite, inputData, outputData);
    input Clk;
    input Reset_N;
    input [3:0] inputData;
    input latchWrite;

    output [3:0] outputData;

    reg [3:0] current_data;
    reg [3:0] nxt_data;
    reg flag;

    assign outputData = current_data;
    
    initial begin
        current_data <= 0;
        nxt_data <=0;
        flag <= 0;
    end

    always @(*) begin
        nxt_data <= inputData;
    end

    always @(posedge Clk) begin
        if((Reset_N&Clk) && !flag) begin
            current_data <= 0;
            nxt_data <= 0;
            flag <= 1;
        end
        else begin
            if (latchWrite) current_data <= nxt_data;
        end
    end
endmodule

module latch_5(Clk, Reset_N, latchWrite, inputData, outputData);
    input Clk;
    input Reset_N;
    input [4:0] inputData;
    input latchWrite;

    output [4:0] outputData;

    reg [4:0] current_data;
    reg [4:0] nxt_data;
    reg flag;

    assign outputData = current_data;
    
    initial begin
        current_data <= 0;
        nxt_data <=0;
        flag <= 0;
    end

    always @(*) begin
        nxt_data <= inputData;
    end

    always @(posedge Clk) begin
        if((Reset_N&Clk) && !flag) begin
            current_data <= 0;
            nxt_data <= 0;
            flag <= 1;
        end
        else begin
            if (latchWrite) current_data <= nxt_data;
        end
    end
endmodule

module latch_9(Clk, Reset_N, latchWrite, inputData, outputData);
    input Clk;
    input Reset_N;
    input [8:0] inputData;
    input latchWrite;

    output [8:0] outputData;

    reg [8:0] current_data;
    reg [8:0] nxt_data;
    reg flag;

    assign outputData = current_data;
    
    initial begin
        current_data <= 0;
        nxt_data <=0;
        flag <= 0;
    end

    always @(*) begin
        nxt_data <= inputData;
    end

    always @(posedge Clk) begin
        if((Reset_N&Clk) && !flag) begin
            current_data <= 0;
            nxt_data <= 0;
            flag <= 1;
        end
        else begin
            if (latchWrite) current_data <= nxt_data;
        end
    end
endmodule

module latch_16(Clk, Reset_N, latchWrite, inputData, outputData);
    input Clk;
    input Reset_N;
    input [`WORD_SIZE-1:0] inputData;
    input latchWrite;

    output [`WORD_SIZE-1:0] outputData;

    reg [`WORD_SIZE-1:0] current_data;
    reg [`WORD_SIZE-1:0] nxt_data;
    reg flag;

    assign outputData = current_data;

    initial begin
        current_data <= 0;
        nxt_data <=0;
        flag <= 0;
    end

    always @(*) begin
        nxt_data <= inputData;
    end

    always @(posedge Clk) begin
        if((Reset_N&Clk) && !flag) begin
            current_data <= 0;
            nxt_data <= 0;
            flag <= 1;
        end
        else begin
            if(latchWrite) current_data <= nxt_data;
        end
    end
endmodule