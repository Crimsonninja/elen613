module fifo  ( t_fifo_intf.dut fifo_intf);
  t_fifo_data mem[1023:0];
  t_fifo fifo;
  assign fifo_intf.dout = mem[fifo.tail];
  assign fifo_intf.empty = (fifo.cnt == 0);
  assign fifo_intf.full = (fifo.cnt == 1023);


        

always @(posedge fifo_intf.clk or negedge fifo_intf.reset) if (!fifo_intf.reset) begin
          fifo.head <= 0;
          fifo.tail <= 0;
          fifo.cnt <= 0;
        end
        else if (fifo_intf.pop && (!fifo_intf.empty)) begin
          fifo.tail <= (fifo.tail + 1);
          fifo.cnt <= (fifo.cnt - 1);
        end
        else if (fifo_intf.push && (!fifo_intf.full)) begin
          mem[fifo.head] <= fifo_intf.din;
          fifo.head <= (fifo.head + 1);
          fifo.cnt <= (fifo.cnt + 1);
        end
endmodule
//module fifo  (output full, output empty, output t_fifo_data  dout, input t_fifo_data din, 
//input clk, input reset, input push, input pop);
