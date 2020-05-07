typedef enum {ADD, MULT, SUB, XOR} opcode_t;

module ALU(input clk, reset, input [7:0] operand1, operand2, input opcode_t opcode, output logic [15:0] result);

  always@* begin
    case (opcode)
      ADD:  result = operand1 + operand2;
      MULT: result = operand1 * operand2;
      SUB:  result = operand1 - operand2;
      XOR:  result = operand1 ^ operand2;
    endcase
  end
endmodule

interface alu_intf(input clk, reset);
  logic [7:0] operand1, operand2;
  opcode_t opcode;
  logic [15:0] result;
  clocking cb1 @(posedge clk);
    output #1 operand1, operand2, opcode, reset;
    input #1 result;
  endclocking
  
  assert property (@(posedge clk) opcode == ADD |-> operand1+operand2 == result);
  assert property (@(posedge clk) opcode == MULT |-> operand1*operand2 == result);
  assert property (@(posedge clk) opcode == SUB |-> operand1-operand2 == result);
  assert property (@(posedge clk) opcode == XOR |-> operand1^operand2 == result);
  

endinterface
