`include "parameter.v"

module control_forwarding_ID(inputS, inputT, inputW_X, inputW_M, forwardA, forwardB, controlEX, controlMEM);
    input controlEX;
    input controlMEM;
    input[`REG_SIZE-1:0] inputS;
    input[`REG_SIZE-1:0] inputT;
    input[`REG_SIZE-1:0] inputW_X;
    input[`REG_SIZE-1:0] inputW_M;

    output[1:0] forwardA;
    output[1:0] forwardB;

    assign forwardA  = controlEX && (inputS == inputW_X) ? 1 : 
                        (controlMEM && (inputS == inputW_M) ? 2 : 0);
    assign forwardB  = controlEX && (inputT == inputW_X) ? 1 :
                        (controlMEM && (inputT == inputW_M) ? 2 : 0);
endmodule

module control_forwarding_EX(inputS, inputT, inputW_M, inputW_W, forwardA, forwardB, controlWB, controlMEM);
    input controlWB;
    input controlMEM;
    input[`REG_SIZE-1:0] inputS;
    input[`REG_SIZE-1:0] inputT;
    input[`REG_SIZE-1:0] inputW_M;
    input[`REG_SIZE-1:0] inputW_W;

    output[1:0] forwardA;
    output[1:0] forwardB;

    assign forwardA  = controlWB && (inputS == inputW_W) ? 1 :
                        (controlMEM && (inputS == inputW_M) ? 2 : 0);
    assign forwardB  = controlWB && (inputT == inputW_W) ? 1 :
                        (controlMEM && (inputT == inputW_M) ? 2 : 0);
endmodule
