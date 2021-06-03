`include "parameter.v"																					 

module ALU (A,B,C,FUNC);
	input [`WORD_SIZE-1:0] A;
	input [`WORD_SIZE-1:0] B;
	input [3:0] FUNC;	  
	output reg [`WORD_SIZE-1:0] C;
  
  always @(*) begin
    case(FUNC)
      4'b0000 : C = A + B;
      4'b0001 : C = A - B;
      4'b0010 : C = A & B;
      4'b0011 : C = A | B;
      4'b0100 : C = ~A;
      4'b0101 : C = ~A + 1;
      4'b0110 : C = A << 1;
      4'b0111 : C = A >> 1;

      4'b1000 : C = A + B;
      4'b1001 : C = A | B;
      4'b1010 : C = B << 8;
    endcase
  end
endmodule