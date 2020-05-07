module tb();
  logic reset, clk;
  
  alu_intf my_intf(clk, reset);
  ALU DUT (.clk(my_intf.clk),.reset(my_intf.reset),.operand1(my_intf.operand1),.operand2(my_intf.operand2),.opcode(my_intf.opcode),.result(my_intf.result));
  initial begin
    clk = 0;
  end

  always #5 clk = !clk;

  task reset_dut();
    begin
      my_intf.cb1.reset <= 0;
      @(my_intf.cb1);
      my_intf.cb1.reset <= 1;
    end
  endtask

  task one_opcode(input opcode_t op, input [7:0] op1, op2);
    begin
      //$display("%p", op);
      my_intf.cb1.opcode <= op;
      my_intf.cb1.operand1 <= op1;
      my_intf.cb1.operand2 <= op2;
      @(my_intf.cb1);
    end
  endtask

  opcode_t tmp;
  initial begin
    $display("HELLO");
    $monitor("%s \t %d \t %d \t %d \t %t", my_intf.opcode.name(), my_intf.operand1, my_intf.operand2, my_intf.result, $time);
    //$monitor("%p %d %d %d", my_intf.operand1, my_intf.operand2,my_intf.result);
    $assertoff();
    reset_dut();
    $asserton();
    repeat(20) begin
    //one_opcode(opcode_t'($random%4), $random, $random);
    //one_opcode(opcode_t'(1), $random, $random);
    one_opcode(opcode_t'($urandom%4), $random, $random);
    end
    #10;
    $finish;
  end
endmodule
