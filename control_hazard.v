`include "parameter.v"

module control_hazard(realPC, predPC, inst_ID, rt_EX, memRead_EX, Stall, Flush_IF);
    input [`WORD_SIZE-1:0] realPC;
    input [`WORD_SIZE-1:0] predPC;
    input [`WORD_SIZE-1:0] inst_ID;
    input [1:0] rt_EX;
    input memRead_EX;

    output Stall;
    output Flush_IF;

    wire [1:0] rs_ID;
    wire [1:0] rt_ID;

    assign rs_ID = inst_ID[11:10];
    assign rt_ID = inst_ID[9:8];

    assign Stall = (((rs_ID == rt_EX) || (rt_ID == rt_EX)) && memRead_EX) ? 1'b1 : 1'b0;
    assign Flush_IF = ((realPC != predPC) && inst_ID !=0) ? 1'b1 : 1'b0;
endmodule