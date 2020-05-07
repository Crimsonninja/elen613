module fifo(output full, output empty, output t_fifo_data dout, input t_fifo_data din, input clk, input reset, input push, input pop);

t_fifo_data mem[1023:0];
t_fifo fifo;
assign dout= mem[fifo.tail];
assign empty = (fifo.cnt == 0);
assign full = (fifo.cnt == 1024);

always @(posedge clk or negedge reset) begin 
  if (!reset) begin
    //$display("RESETTING");
    fifo.head <= 0;
    fifo.tail <= 0;
    fifo.cnt <= 0;
  end
  else if (pop && (!empty)) begin
    //$display("POPPING: %d", dout.data);
    fifo.tail <= (fifo.tail + 1);
    fifo.cnt <= (fifo.cnt - 1);
  end
  else if (push && (!full)) begin
    //$display("PUSHING DATA into FIFO: %d", din);
    mem[fifo.head] <= din;
    fifo.head <= (fifo.head + 1);
    fifo.cnt <= (fifo.cnt + 1);
  end
end

endmodule  

