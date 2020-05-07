typedef struct packed {
  logic [9:0] head;
  logic [9:0] tail;
  logic [9:0] cnt;
} t_fifo;

typedef struct packed {
  logic en;
  logic[7:0] data;
} t_fifo_data;

module tb();

  reg full, empty, clk, reset, push, pop;
  t_fifo_data data_out, data_in;
  
  

  fifo my_test_fifo(full, empty, data_out, data_in, clk, reset, push, pop); // instantiation of fifo
  
  // task to initialize fifo (head, count, and tail) by resetting
  task initialize_reset_task(); begin
    clk = 0;
    reset = 1;
    push = 0;
    pop = 0;
    #10;
    reset = 0;
    #10;
    reset = 1;
  end
  endtask

  // task to push data into the fifo
  task push_data(input [7:0] some_data, push_enable); begin
    if (push_enable)
      data_in <= some_data;
  end
  endtask

  // task to pop data out of the fifo
  task pop_data(); begin
    pop <= 1;
  end
  endtask

  initial begin
    $monitor("DATA IN = %d, DATA OUT = %d, %t", data_in, data_out, $time);
    clk = 0;
    initialize_reset_task();
    push <= 1;
    #10 push_data(47, push);
    #10 push_data(48, push);
    #10 push_data(49, push);
    #10 push_data(50, push);
    #10 push <=0;
    pop_data();               // set the pop flag to 1
    #50;
    pop <= 0;
    $finish;
  end

  always #5 clk = !clk;

endmodule 
