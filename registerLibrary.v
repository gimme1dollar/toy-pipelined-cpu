`include "parameter.v"

module register(Clk, Reset_N, regWrite, reg1, reg2, regW, writeData, reg1D, reg2D);
    input Clk;
    input Reset_N;
    input regWrite;
    input [`REG_SIZE-1:0] reg1;
    input [`REG_SIZE-1:0] reg2;
    input [`REG_SIZE-1:0] regW;
    input [`WORD_SIZE-1:0] writeData;

    output [`WORD_SIZE-1:0] reg1D;
    output [`WORD_SIZE-1:0] reg2D;

    reg [`WORD_SIZE-1:0] current_reg [0:`REG_NUMS-1];
    reg [`WORD_SIZE-1:0] nxt_reg [0:`REG_NUMS-1];
    reg flag;

    assign reg1D = current_reg[reg1];
    assign reg2D = current_reg[reg2];

    // delete
    wire [`WORD_SIZE-1:0] debug0;
    wire [`WORD_SIZE-1:0] debug1;
    wire [`WORD_SIZE-1:0] debug2;
    wire [`WORD_SIZE-1:0] debug3;
    assign debug0 = current_reg[0];
    assign debug1 = current_reg[1];
    assign debug2 = current_reg[2];
    assign debug3 = current_reg[3];

    initial begin
        flag <= 0;
    end

    always @(*) begin
        if(writeData!==`WORD_SIZE'bz && regWrite) nxt_reg[regW] <= writeData;
    end

    always @(posedge Clk) begin
        if((Reset_N&Clk) && !flag) begin
            current_reg[0] <= 0;
            current_reg[1] <= 0;
            current_reg[2] <= 0;
            current_reg[3] <= 0;

            nxt_reg[0] <= 0;
            nxt_reg[1] <= 0;
            nxt_reg[2] <= 0;
            nxt_reg[3] <= 0;

            flag <= 1;
        end
    end

    always @(negedge Clk) begin
        if(regWrite) current_reg[0] <= nxt_reg[0];
        if(regWrite) current_reg[1] <= nxt_reg[1];
        if(regWrite) current_reg[2] <= nxt_reg[2];
        if(regWrite) current_reg[3] <= nxt_reg[3];
    end
endmodule

module registerTemplate(clk, regWrite, Reset_N, inputData, outputData);
    input clk;
    input regWrite;
    input Reset_N;
    input [`WORD_SIZE-1:0] inputData;

    output [`WORD_SIZE-1:0] outputData;

    reg [`WORD_SIZE-1:0] current_data;
    reg [`WORD_SIZE-1:0] nxt_data;

    assign outputData = current_data;

    always @(*) begin
        if(inputData!==`WORD_SIZE'bz) nxt_data <= inputData;
    end

    always @(posedge clk) begin
        if(!Reset_N) begin
            current_data <= 0;
            nxt_data <= 0;
        end
        else begin
            if(regWrite) current_data <= nxt_data;
        end
    end
endmodule