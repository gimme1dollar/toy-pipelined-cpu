`include "parameter.v"

module concat(pc, inst, jump);
    input [`WORD_SIZE-1:0] pc;
    input [`WORD_SIZE-1:0] inst;

    output [`WORD_SIZE-1:0] jump;

    assign jump = {pc[15:12],inst[11:0]};
endmodule

module signExt(inputData, outputData);
    input [`HALF_SIZE-1:0] inputData;

    output[`WORD_SIZE-1:0] outputData;

    assign outputData = {{`HALF_SIZE{inputData[`HALF_SIZE-1]}}, inputData};
endmodule

module branchUnit(rs, rt, cond, type);
    input [`WORD_SIZE-1:0] rs;
    input [`WORD_SIZE-1:0] rt;
    input [2:0] type;
    output cond;

    reg semi;
    assign cond = semi;

    always @(*) begin
        if(type[2])
            case(type[1:0])
                2'b00: begin
                    if(rs != rt) semi <= 1;
                    else semi <= 0;
                end
                2'b01: begin
                    if(rs == rt) semi <= 1;
                    else semi <= 0;
                end
                2'b10: begin
                    if(rs[`WORD_SIZE-1] == 0 && rs!=0) semi <= 1;
                    else semi <= 0;
                end
                2'b11: begin
                    if(rs[`WORD_SIZE-1] == 1 && rs!=0) semi <= 1;
                    else semi <= 0;
                end
            endcase
        else semi <= 1;
    end    
endmodule
