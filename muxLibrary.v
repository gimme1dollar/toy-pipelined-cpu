`include "parameter.v"

module mux2_16(state, zero, one, return);
    input state;
    input [`WORD_SIZE-1:0] zero;
    input [`WORD_SIZE-1:0] one;

    output [`WORD_SIZE-1:0] return;

    assign return = (state) ? one : zero;
endmodule

module mux4_2(state, zero, one, two, three, return);
    input [1:0] state;
    input [`REG_SIZE-1:0] zero;
    input [`REG_SIZE-1:0] one;
    input [`REG_SIZE-1:0] two;
    input [`REG_SIZE-1:0] three;

    output [`REG_SIZE-1:0] return;

    assign return = (state==0) ? zero : (
            (state==1) ? one : (
            (state==2) ? two : three
        ));
endmodule

module mux4_16(state, zero, one, two, three, return);
    input [1:0] state;
    input [`WORD_SIZE-1:0] zero;
    input [`WORD_SIZE-1:0] one;
    input [`WORD_SIZE-1:0] two;
    input [`WORD_SIZE-1:0] three;

    output [`WORD_SIZE-1:0] return;

    assign return = (state==0) ? zero : (
            (state==1) ? one : (
            (state==2) ? two : three
        ));
endmodule