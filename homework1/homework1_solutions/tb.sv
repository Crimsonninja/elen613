typedef struct packed {
 logic [9:0]  head;
 logic [9:0]  tail;
 logic [9:0]  cnt;
 } t_fifo;

typedef struct packed {
  logic en;
  logic[7:0] data ;
} t_fifo_data;

interface t_fifo_intf(input clk,reset);
  logic full, empty;
  t_fifo_data dout,din;
  logic push,pop; 
  clocking cb1 @(posedge clk ) ;
    input #1 full,empty,dout; 
    output #1  push,pop,din;
  endclocking
  modport dut(input clk,reset,output full,empty, input din, output dout, input push,pop); endinterface

module tb();
  logic reset,clk; 

  t_fifo_intf fifo_intf(clk,reset);
  initial begin
    clk=0;
  end

  always #5 clk = !clk;

  fifo DUT (.fifo_intf(fifo_intf) ); 

  task reset_dut(); 
    reset = 1'b0; 
    fifo_intf.cb1.push <= 1'b0; 
    fifo_intf.cb1.pop <= 1'b0; 
    @(fifo_intf.cb1);
    reset = 1'b1; 
    @(fifo_intf.cb1);
  endtask

  task write(input t_fifo_data x);
    fifo_intf.cb1.din <= x; 
    fifo_intf.cb1.push <= 1'b1; 
    @(fifo_intf.cb1);
    fifo_intf.cb1.push <= 1'b0;
  endtask

  task read(output t_fifo_data x);
    fifo_intf.cb1.pop <= 1'b1;  
    @(fifo_intf.cb1);
    fifo_intf.cb1.pop <= 1'b0;
    $display("%p",fifo_intf.cb1.dout);
  endtask

  t_fifo_data tmp;
  initial begin
    $display("HELLO");
    reset_dut();
    write( '{1,1} );
    read(tmp);
    #10;
    $finish;
  end

endmodule
