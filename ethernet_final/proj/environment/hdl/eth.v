`timescale 1ns/1ps
/*
                    instances: 0
*/





/*
                    instances: 0
                        nodes: 14 (0)
                  node widths: 31 (0)
                      process: 3 (0)
                        ports: 6 (0)
*/




module fault_sm(status_local_fault_crx, status_remote_fault_crx, clk_xgmii_rx,
	reset_xgmii_rx_n, local_fault_msg_det, remote_fault_msg_det);
	input			clk_xgmii_rx;
	input			reset_xgmii_rx_n;
	input	[1:0]		local_fault_msg_det;
	input	[1:0]		remote_fault_msg_det;
	output			status_local_fault_crx;

	reg			status_local_fault_crx;
	output			status_remote_fault_crx;
	reg			status_remote_fault_crx;
	reg	[1:0]		curr_state;
	reg	[7:0]		col_cnt;
	reg	[1:0]		fault_sequence;
	reg	[1:0]		last_seq_type;
	reg	[1:0]		link_fault;
	reg	[2:0]		seq_cnt;
	reg	[1:0]		seq_type;
	reg	[1:0]		seq_add;
	parameter [1:0]		SM_INIT		= 2'b0;
	parameter [1:0]		SM_COUNT	= 2'b1;
	parameter [1:0]		SM_FAULT	= 2'd2;
	parameter [1:0]		SM_NEW_FAULT	= 2'd3;

	always @(local_fault_msg_det or remote_fault_msg_det) begin
	  fault_sequence = (local_fault_msg_det | remote_fault_msg_det);
	  if (|local_fault_msg_det) begin
	    seq_type = 2'b1;
	  end
	  else if (|remote_fault_msg_det) begin
	    seq_type = 2'd2;
	  end
	  else
	    begin
	      seq_type = 2'b0;
	    end
	  if (|remote_fault_msg_det) begin
	    seq_add = (remote_fault_msg_det[1] + remote_fault_msg_det[0]);
	  end
	  else
	    begin
	      seq_add = (local_fault_msg_det[1] + local_fault_msg_det[0]);
	    end
	end
	always @(posedge clk_xgmii_rx or negedge reset_xgmii_rx_n) begin
	  if (reset_xgmii_rx_n == 1'b0) begin
	    status_local_fault_crx <= 1'b0;
	    status_remote_fault_crx <= 1'b0;
	  end
	  else
	    begin
	      status_local_fault_crx <= ((curr_state == SM_FAULT) && (link_fault
		      == 2'b1));
	      status_remote_fault_crx <= ((curr_state == SM_FAULT) &&
		      (link_fault == 2'd2));
	    end
	end
	always @(posedge clk_xgmii_rx or negedge reset_xgmii_rx_n) begin
	  if (reset_xgmii_rx_n == 1'b0) begin
	    curr_state <= SM_INIT;
	    col_cnt <= 8'b0;
	    last_seq_type <= 2'b0;
	    link_fault <= 2'b0;
	    seq_cnt <= 3'b0;
	  end
	  else
	    begin
	      case (curr_state)
		SM_INIT: begin
		  last_seq_type <= seq_type;
		  if (|fault_sequence) begin
		    if (fault_sequence[0]) begin
		      col_cnt <= 8'd2;
		    end
		    else
		      begin
			col_cnt <= 8'b1;
		      end
		    seq_cnt <= {1'b0, seq_add};
		    curr_state <= SM_COUNT;
		  end
		  else
		    begin
		      col_cnt <= 8'b0;
		      seq_cnt <= 3'b0;
		    end
		end
		SM_COUNT: begin
		  col_cnt <= (col_cnt + 8'd2);
		  seq_cnt <= (seq_cnt + {1'b0, seq_add});
		  if ((!fault_sequence[0]) && (col_cnt >= 8'd127)) begin
		    curr_state <= SM_INIT;
		  end
		  else if (col_cnt > 8'd127) begin
		    curr_state <= SM_INIT;
		  end
		  else if (|fault_sequence) begin
		    if (seq_type != last_seq_type) begin
		      curr_state <= SM_NEW_FAULT;
		    end
		    else
		      begin
			if ((seq_cnt + {1'b0, seq_add}) > 3'd3) begin
			  col_cnt <= 8'b0;
			  link_fault <= seq_type;
			  curr_state <= SM_FAULT;
			end
		      end
		  end
		end
		SM_FAULT: begin
		  col_cnt <= (col_cnt + 8'd2);
		  if ((!fault_sequence[0]) && (col_cnt >= 8'd127)) begin
		    curr_state <= SM_INIT;
		  end
		  else if (col_cnt > 8'd127) begin
		    curr_state <= SM_INIT;
		  end
		  else if (|fault_sequence) begin
		    col_cnt <= 8'b0;
		    if (seq_type != last_seq_type) begin
		      curr_state <= SM_NEW_FAULT;
		    end
		  end
		end
		SM_NEW_FAULT: begin
		  col_cnt <= 8'b0;
		  last_seq_type <= seq_type;
		  seq_cnt <= {1'b0, seq_add};
		  curr_state <= SM_COUNT;
		end
	      endcase
	    end
	end
endmodule

/*
                    instances: 0
                        nodes: 14 (0)
                  node widths: 33 (0)
                      process: 3 (0)
                        ports: 11 (0)
*/


module generic_mem_small(wclk, wrst_n, wen, waddr, wdata, rclk, rrst_n, ren,
	roen, raddr, rdata);
	parameter		DWIDTH		= 32;
	parameter		AWIDTH		= 3;
	parameter		RAM_DEPTH	= (1 << AWIDTH);
	parameter		REGISTER_READ	= 0;
	input			wclk;
	input			wrst_n;
	input			wen;
	input	[(AWIDTH - 1):0]
				waddr;
	input	[(DWIDTH - 1):0]
				wdata;
	input			rclk;
	input			rrst_n;
	input			ren;
	input			roen;
	input	[(AWIDTH - 1):0]
				raddr;
	output	[(DWIDTH - 1):0]
				rdata;

	reg	[(DWIDTH - 1):0]
				rdata;
	reg	[(DWIDTH - 1):0]
				mem_rdata;
	reg	[(AWIDTH - 1):0]
				raddr_d1;

	reg	[(DWIDTH - 1):0]
				mem[0:(RAM_DEPTH - 1)];
	integer			i;

	always @(posedge wclk) begin
	  if (wen) begin
	    mem[waddr[(AWIDTH - 1):0]] <= wdata;
	  end
	end
	always @(posedge rclk) begin
	  if (ren) begin
	    raddr_d1 <= raddr;
	  end
	end
	always @(raddr_d1 or rclk) begin
	  mem_rdata = mem[raddr_d1[(AWIDTH - 1):0]];
	end

	if (REGISTER_READ) begin : genblk1 

	  always @(posedge rclk or negedge rrst_n) begin
	    if (!rrst_n) begin
	      rdata <= {DWIDTH {1'b0}};
	    end
	    else if (roen) begin
	      rdata <= mem_rdata;
	    end
	  end
	end
	else  begin : genblk1_0 

	  always @(mem_rdata) begin
	    rdata = mem_rdata;
	  end
	end
endmodule

/*
                    instances: 0
                        nodes: 14 (0)
                  node widths: 33 (0)
                      process: 3 (0)
                        ports: 11 (0)
*/


module generic_mem_medium(wclk, wrst_n, wen, waddr, wdata, rclk, rrst_n, ren,
	roen, raddr, rdata);
	parameter		DWIDTH		= 32;
	parameter		AWIDTH		= 3;
	parameter		RAM_DEPTH	= (1 << AWIDTH);
	parameter		REGISTER_READ	= 0;
	input			wclk;
	input			wrst_n;
	input			wen;
	input	[(AWIDTH - 1):0]
				waddr;
	input	[(DWIDTH - 1):0]
				wdata;
	input			rclk;
	input			rrst_n;
	input			ren;
	input			roen;
	input	[(AWIDTH - 1):0]
				raddr;
	output	[(DWIDTH - 1):0]
				rdata;

	reg	[(DWIDTH - 1):0]
				rdata;
	reg	[(DWIDTH - 1):0]
				mem_rdata;
	reg	[(AWIDTH - 1):0]
				raddr_d1;

	reg	[(DWIDTH - 1):0]
				mem[0:(RAM_DEPTH - 1)];
	integer			i;

	always @(posedge wclk) begin
	  if (wen) begin
	    mem[waddr[(AWIDTH - 1):0]] <= wdata;
	  end
	end
	always @(posedge rclk) begin
	  if (ren) begin
	    raddr_d1 <= raddr;
	  end
	end
	always @(raddr_d1 or rclk) begin
	  mem_rdata = mem[raddr_d1[(AWIDTH - 1):0]];
	end

	if (REGISTER_READ) begin : genblk1 

	  always @(posedge rclk or negedge rrst_n) begin
	    if (!rrst_n) begin
	      rdata <= {DWIDTH {1'b0}};
	    end
	    else if (roen) begin
	      rdata <= mem_rdata;
	    end
	  end
	end
	else  begin : genblk1_0 

	  always @(mem_rdata) begin
	    rdata = mem_rdata;
	  end
	end
endmodule

/*
                    instances: 0
                        nodes: 33 (0)
                  node widths: 24 (0)
                      process: 5 (0)
                   contassign:  13 (0)
                        ports: 14 (0)
*/


module generic_fifo_ctrl(wclk, wrst_n, wen, wfull, walmost_full, mem_wen,
	mem_waddr, rclk, rrst_n, ren, rempty, ralmost_empty, mem_ren, mem_raddr)
	;
	parameter		AWIDTH		= 3;
	parameter		RAM_DEPTH	= (1 << AWIDTH);
	parameter		EARLY_READ	= 0;
	parameter		CLOCK_CROSSING	= 1;
	parameter		ALMOST_EMPTY_THRESH
						= 1;
	parameter		ALMOST_FULL_THRESH
						= (RAM_DEPTH - 2);
	input			wclk;
	input			wrst_n;
	input			wen;
	output			wfull;
	output			walmost_full;
	output			mem_wen;
	output	[AWIDTH:0]	mem_waddr;
	input			rclk;
	input			rrst_n;
	input			ren;
	output			rempty;
	output			ralmost_empty;
	output			mem_ren;
	output	[AWIDTH:0]	mem_raddr;

	reg	[AWIDTH:0]	wr_ptr;
	reg	[AWIDTH:0]	rd_ptr;
	reg	[AWIDTH:0]	next_rd_ptr;
	wire	[AWIDTH:0]	wr_gray;
	reg	[AWIDTH:0]	wr_gray_reg;
	reg	[AWIDTH:0]	wr_gray_meta;
	reg	[AWIDTH:0]	wr_gray_sync;
	reg	[AWIDTH:0]	wck_rd_ptr;
	wire	[AWIDTH:0]	wck_level;
	wire	[AWIDTH:0]	rd_gray;
	reg	[AWIDTH:0]	rd_gray_reg;
	reg	[AWIDTH:0]	rd_gray_meta;
	reg	[AWIDTH:0]	rd_gray_sync;
	reg	[AWIDTH:0]	rck_wr_ptr;
	wire	[AWIDTH:0]	rck_level;
	wire	[AWIDTH:0]	depth;
	wire	[AWIDTH:0]	empty_thresh;
	wire	[AWIDTH:0]	full_thresh;
	integer			i;

	assign depth = RAM_DEPTH[AWIDTH:0];
	assign empty_thresh = ALMOST_EMPTY_THRESH[AWIDTH:0];
	assign full_thresh = ALMOST_FULL_THRESH[AWIDTH:0];
	assign wfull = (wck_level == depth);
	assign walmost_full = (wck_level >= (depth - full_thresh));
	assign rempty = (rck_level == 0);
	assign ralmost_empty = (rck_level <= empty_thresh);
	assign wr_gray = (wr_ptr ^ (wr_ptr >> 1));
	assign rd_gray = (rd_ptr ^ (rd_ptr >> 1));
	assign wck_level = (wr_ptr - wck_rd_ptr);
	assign rck_level = (rck_wr_ptr - rd_ptr);
	assign mem_waddr = wr_ptr;
	assign mem_wen = (wen && (!wfull));

	always @(posedge wclk or negedge wrst_n) begin
	  if (!wrst_n) begin
	    wr_ptr <= {(AWIDTH + 1) {1'b0}};
	  end
	  else if (wen && (!wfull)) begin
	    wr_ptr <= (wr_ptr + {{AWIDTH {1'b0}}, 1'b1});
	  end
	end
	always @(ren or rd_ptr or rck_wr_ptr) begin
	  next_rd_ptr = rd_ptr;
	  if (ren && (rd_ptr != rck_wr_ptr)) begin
	    next_rd_ptr = (rd_ptr + {{AWIDTH {1'b0}}, 1'b1});
	  end
	end
	always @(posedge rclk or negedge rrst_n) begin
	  if (!rrst_n) begin
	    rd_ptr <= {(AWIDTH + 1) {1'b0}};
	  end
	  else
	    begin
	      rd_ptr <= next_rd_ptr;
	    end
	end
	always @(wr_gray_sync) begin
	  rck_wr_ptr[AWIDTH] = wr_gray_sync[AWIDTH];
	  for (i = 0; (i < AWIDTH); i = (i + 1)) begin
	    rck_wr_ptr[((AWIDTH - i) - 1)] = (rck_wr_ptr[(AWIDTH - i)] ^
		    wr_gray_sync[((AWIDTH - i) - 1)]);
	  end
	end
	always @(rd_gray_sync) begin
	  wck_rd_ptr[AWIDTH] = rd_gray_sync[AWIDTH];
	  for (i = 0; (i < AWIDTH); i = (i + 1)) begin
	    wck_rd_ptr[((AWIDTH - i) - 1)] = (wck_rd_ptr[(AWIDTH - i)] ^
		    rd_gray_sync[((AWIDTH - i) - 1)]);
	  end
	end

	if (CLOCK_CROSSING) begin : genblk1 

	  always @(posedge rclk or negedge rrst_n) begin
	    if (!rrst_n) begin
	      rd_gray_reg <= {(AWIDTH + 1) {1'b0}};
	      wr_gray_meta <= {(AWIDTH + 1) {1'b0}};
	      wr_gray_sync <= {(AWIDTH + 1) {1'b0}};
	    end
	    else
	      begin
		rd_gray_reg <= rd_gray;
		wr_gray_meta <= wr_gray_reg;
		wr_gray_sync <= wr_gray_meta;
	      end
	  end
	  always @(posedge wclk or negedge wrst_n) begin
	    if (!wrst_n) begin
	      wr_gray_reg <= {(AWIDTH + 1) {1'b0}};
	      rd_gray_meta <= {(AWIDTH + 1) {1'b0}};
	      rd_gray_sync <= {(AWIDTH + 1) {1'b0}};
	    end
	    else
	      begin
		wr_gray_reg <= wr_gray;
		rd_gray_meta <= rd_gray_reg;
		rd_gray_sync <= rd_gray_meta;
	      end
	  end
	end
	else  begin : genblk1_0 

	  always @(wr_gray or rd_gray) begin
	    wr_gray_sync = wr_gray;
	    rd_gray_sync = rd_gray;
	  end
	end

	if (EARLY_READ) begin : genblk2 

	  assign mem_raddr = next_rd_ptr;
	  assign mem_ren = 1'b1;
	end
	else  begin : genblk2_0 

	  assign mem_raddr = rd_ptr;
	  assign mem_ren = ren;
	end
endmodule

/*
                    instances: 0
                        nodes: 16 (0)
                  node widths: 8 (0)
                        ports: 12 (0)
                        ports: 1 (0)
                 portconnects: 14 (0)
*/


module generic_fifo(wclk, wrst_n, wen, wdata, wfull, walmost_full, rclk, rrst_n,
	ren, rdata, rempty, ralmost_empty);
	parameter		DWIDTH		= 32;
	parameter		AWIDTH		= 3;
	parameter		RAM_DEPTH	= (1 << AWIDTH);
	parameter		REGISTER_READ	= 0;
	parameter		EARLY_READ	= 0;
	parameter		CLOCK_CROSSING	= 1;
	parameter		ALMOST_EMPTY_THRESH
						= 1;
	parameter		ALMOST_FULL_THRESH
						= (RAM_DEPTH - 2);
	parameter		MEM_TYPE	= 1;
	input			wclk;
	input			wrst_n;
	input			wen;
	input	[(DWIDTH - 1):0]
				wdata;
	output			wfull;
	output			walmost_full;
	input			rclk;
	input			rrst_n;
	input			ren;
	output	[(DWIDTH - 1):0]
				rdata;
	output			rempty;
	output			ralmost_empty;

	wire			mem_wen;
	wire	[AWIDTH:0]	mem_waddr;
	wire			mem_ren;
	wire	[AWIDTH:0]	mem_raddr;
	generic_fifo_ctrl #(.AWIDTH(AWIDTH), .RAM_DEPTH(RAM_DEPTH), .EARLY_READ(
		EARLY_READ), .CLOCK_CROSSING(CLOCK_CROSSING), .
		ALMOST_EMPTY_THRESH(ALMOST_EMPTY_THRESH), .ALMOST_FULL_THRESH(
		ALMOST_FULL_THRESH)) ctrl0(
		.wclk				(wclk), 
		.wrst_n				(wrst_n), 
		.wen				(wen), 
		.wfull				(wfull), 
		.walmost_full			(walmost_full), 
		.mem_wen			(mem_wen), 
		.mem_waddr			(mem_waddr), 
		.rclk				(rclk), 
		.rrst_n				(rrst_n), 
		.ren				(ren), 
		.rempty				(rempty), 
		.ralmost_empty			(ralmost_empty), 
		.mem_ren			(mem_ren), 
		.mem_raddr			(mem_raddr));

	if (MEM_TYPE == 1) begin : genblk1 
	  generic_mem_small #(.DWIDTH(DWIDTH), .AWIDTH(AWIDTH), .RAM_DEPTH(
		  RAM_DEPTH), .REGISTER_READ(REGISTER_READ)) mem0(
		.wclk				(wclk), 
		.wrst_n				(wrst_n), 
		.wen				(mem_wen), 
		.waddr				(mem_waddr[(AWIDTH - 1):0]), 
		.wdata				(wdata), 
		.rclk				(rclk), 
		.rrst_n				(rrst_n), 
		.ren				(mem_ren), 
		.roen				(ren), 
		.raddr				(mem_raddr[(AWIDTH - 1):0]), 
		.rdata				(rdata));
	end

	if (MEM_TYPE == 2) begin : genblk2 
	  generic_mem_medium #(.DWIDTH(DWIDTH), .AWIDTH(AWIDTH), .RAM_DEPTH(
		  RAM_DEPTH), .REGISTER_READ(REGISTER_READ)) mem0(
		.wclk				(wclk), 
		.wrst_n				(wrst_n), 
		.wen				(mem_wen), 
		.waddr				(mem_waddr[(AWIDTH - 1):0]), 
		.wdata				(wdata), 
		.rclk				(rclk), 
		.rrst_n				(rrst_n), 
		.ren				(mem_ren), 
		.roen				(ren), 
		.raddr				(mem_raddr[(AWIDTH - 1):0]), 
		.rdata				(rdata));
	end
endmodule

/*
                    instances: 0
                        nodes: 5 (0)
                  node widths: 32 (0)
                        ports: 4 (0)
*/


module meta_sync(out, clk, reset_n, in);
	parameter		DWIDTH		= 1;
	parameter		EDGE_DETECT	= 0;
	input			clk;
	input			reset_n;
	input	[(DWIDTH - 1):0]
				in;
	output	[(DWIDTH - 1):0]
				out;

	genvar 			i;

	for (i = 0; (i < DWIDTH); i = (i + 1)) begin : meta 
	  meta_sync_single #(.EDGE_DETECT(EDGE_DETECT)) meta_sync_single0(
		.out				(out[i]), 
		.clk				(clk), 
		.reset_n			(reset_n), 
		.in				(in[i]));
	end
endmodule

/*
                    instances: 0
                        nodes: 4 (0)
                  node widths: 4 (0)
                        ports: 4 (0)
*/


module meta_sync_single(out, clk, reset_n, in);
	parameter		EDGE_DETECT	= 0;
	input			clk;
	input			reset_n;
	input			in;
	output			out;

	reg			out;

	if (EDGE_DETECT) begin : genblk1 

	  reg			meta;
	  reg			edg1;
	  reg			edg2;

	  always @(posedge clk or negedge reset_n) begin
	    if (reset_n == 1'b0) begin
	      meta <= 1'b0;
	      edg1 <= 1'b0;
	      edg2 <= 1'b0;
	      out <= 1'b0;
	    end
	    else
	      begin
		meta <= in;
		edg1 <= meta;
		edg2 <= edg1;
		out <= (edg1 ^ edg2);
	      end
	  end
	end
	else  begin : genblk1_0 

	  reg			meta;

	  always @(posedge clk or negedge reset_n) begin
	    if (reset_n == 1'b0) begin
	      meta <= 1'b0;
	      out <= 1'b0;
	    end
	    else
	      begin
		meta <= in;
		out <= meta;
	      end
	  end
	end
endmodule

/*
                    instances: 0
                        nodes: 10 (0)
                  node widths: 150 (0)
                        ports: 10 (0)
                        ports: 1 (0)
                 portconnects: 12 (0)
*/


module rx_hold_fifo(rxhfifo_rdata, rxhfifo_rstatus, rxhfifo_rempty,
	rxhfifo_ralmost_empty, clk_xgmii_rx, reset_xgmii_rx_n, rxhfifo_wdata,
	rxhfifo_wstatus, rxhfifo_wen, rxhfifo_ren);
	input			clk_xgmii_rx;
	input			reset_xgmii_rx_n;
	input	[63:0]		rxhfifo_wdata;
	input	[7:0]		rxhfifo_wstatus;
	input			rxhfifo_wen;
	input			rxhfifo_ren;
	output	[63:0]		rxhfifo_rdata;
	output	[7:0]		rxhfifo_rstatus;
	output			rxhfifo_rempty;
	output			rxhfifo_ralmost_empty;
	generic_fifo #(.DWIDTH(72), .AWIDTH(4), .REGISTER_READ(1), .EARLY_READ(
		1), .CLOCK_CROSSING(0), .ALMOST_EMPTY_THRESH(7), .MEM_TYPE(1)) 
		fifo0(
		.wclk				(clk_xgmii_rx), 
		.wrst_n				(reset_xgmii_rx_n), 
		.wen				(rxhfifo_wen), 
		.wdata				({rxhfifo_wstatus,
		rxhfifo_wdata}), .wfull(), .walmost_full(), 
		.rclk				(clk_xgmii_rx), 
		.rrst_n				(reset_xgmii_rx_n), 
		.ren				(rxhfifo_ren), 
		.rdata				({rxhfifo_rstatus,
		rxhfifo_rdata}), 
		.rempty				(rxhfifo_rempty), 
		.ralmost_empty			(rxhfifo_ralmost_empty));
endmodule

/*
                    instances: 0
                        nodes: 13 (0)
                  node widths: 153 (0)
                        ports: 13 (0)
                        ports: 1 (0)
                 portconnects: 12 (0)
*/


module rx_data_fifo(rxdfifo_wfull, rxdfifo_rdata, rxdfifo_rstatus,
	rxdfifo_rempty, rxdfifo_ralmost_empty, clk_xgmii_rx, clk_156m25,
	reset_xgmii_rx_n, reset_156m25_n, rxdfifo_wdata, rxdfifo_wstatus,
	rxdfifo_wen, rxdfifo_ren);
	input			clk_xgmii_rx;
	input			clk_156m25;
	input			reset_xgmii_rx_n;
	input			reset_156m25_n;
	input	[63:0]		rxdfifo_wdata;
	input	[7:0]		rxdfifo_wstatus;
	input			rxdfifo_wen;
	input			rxdfifo_ren;
	output			rxdfifo_wfull;
	output	[63:0]		rxdfifo_rdata;
	output	[7:0]		rxdfifo_rstatus;
	output			rxdfifo_rempty;
	output			rxdfifo_ralmost_empty;
	generic_fifo #(.DWIDTH(72), .AWIDTH(6), .REGISTER_READ(0), .EARLY_READ(
		1), .CLOCK_CROSSING(1), .ALMOST_EMPTY_THRESH(4), .MEM_TYPE(2)) 
		fifo0(
		.wclk				(clk_xgmii_rx), 
		.wrst_n				(reset_xgmii_rx_n), 
		.wen				(rxdfifo_wen), 
		.wdata				({rxdfifo_wstatus,
		rxdfifo_wdata}), 
		.wfull				(rxdfifo_wfull), 
		.walmost_full(), 
		.rclk				(clk_156m25), 
		.rrst_n				(reset_156m25_n), 
		.ren				(rxdfifo_ren), 
		.rdata				({rxdfifo_rstatus,
		rxdfifo_rdata}), 
		.rempty				(rxdfifo_rempty), 
		.ralmost_empty			(rxdfifo_ralmost_empty));
endmodule

/*
                    instances: 0
                        nodes: 17 (0)
                  node widths: 152 (0)
                      process: 1 (0)
                   contassign:  1 (0)
                        ports: 16 (0)
*/


module rx_dequeue(rxdfifo_ren, pkt_rx_data, pkt_rx_val, pkt_rx_sop, pkt_rx_eop,
	pkt_rx_err, pkt_rx_mod, pkt_rx_avail, status_rxdfifo_udflow_tog,
	clk_156m25, reset_156m25_n, rxdfifo_rdata, rxdfifo_rstatus,
	rxdfifo_rempty, rxdfifo_ralmost_empty, pkt_rx_ren);
	input			clk_156m25;
	input			reset_156m25_n;
	input	[63:0]		rxdfifo_rdata;
	input	[7:0]		rxdfifo_rstatus;
	input			rxdfifo_rempty;
	input			rxdfifo_ralmost_empty;
	input			pkt_rx_ren;
	output			rxdfifo_ren;
	output			pkt_rx_avail;

	reg			pkt_rx_avail;
	output	[63:0]		pkt_rx_data;
	reg	[63:0]		pkt_rx_data;
	output			pkt_rx_eop;
	reg			pkt_rx_eop;
	output			pkt_rx_err;
	reg			pkt_rx_err;
	output	[2:0]		pkt_rx_mod;
	reg	[2:0]		pkt_rx_mod;
	output			pkt_rx_sop;
	reg			pkt_rx_sop;
	output			pkt_rx_val;
	reg			pkt_rx_val;
	output			status_rxdfifo_udflow_tog;
	reg			status_rxdfifo_udflow_tog;
	reg			end_eop;

	assign rxdfifo_ren = (((!rxdfifo_rempty) && pkt_rx_ren) && (!end_eop));

	always @(posedge clk_156m25 or negedge reset_156m25_n) begin
	  if (reset_156m25_n == 1'b0) begin
	    pkt_rx_avail <= 1'b0;
	    pkt_rx_data <= 64'b0;
	    pkt_rx_sop <= 1'b0;
	    pkt_rx_eop <= 1'b0;
	    pkt_rx_err <= 1'b0;
	    pkt_rx_mod <= 3'b0;
	    pkt_rx_val <= 1'b0;
	    end_eop <= 1'b0;
	    status_rxdfifo_udflow_tog <= 1'b0;
	  end
	  else
	    begin
	      pkt_rx_avail <= (!rxdfifo_ralmost_empty);
	      pkt_rx_eop <= (rxdfifo_ren && rxdfifo_rstatus[3'd6]);
	      pkt_rx_mod <= ({3 {(rxdfifo_ren & rxdfifo_rstatus[3'd6])}} &
		      rxdfifo_rstatus[2:0]);
	      pkt_rx_val <= rxdfifo_ren;
	      if (rxdfifo_ren) begin
		pkt_rx_data <= {rxdfifo_rdata[7:0], rxdfifo_rdata[15:8],
			rxdfifo_rdata[23:16], rxdfifo_rdata[31:24],
			rxdfifo_rdata[39:32], rxdfifo_rdata[47:40],
			rxdfifo_rdata[55:48], rxdfifo_rdata[63:56]};
	      end
	      if (rxdfifo_ren && rxdfifo_rstatus[3'd7]) begin
		pkt_rx_sop <= 1'b1;
		pkt_rx_err <= 1'b0;
	      end
	      else
		begin
		  pkt_rx_sop <= 1'b0;
		  if ((rxdfifo_rempty && pkt_rx_ren) && (!end_eop)) begin
		    pkt_rx_val <= 1'b1;
		    pkt_rx_eop <= 1'b1;
		    pkt_rx_err <= 1'b1;
		  end
		end
	      if (rxdfifo_ren && (|rxdfifo_rstatus[3'd5])) begin
		pkt_rx_err <= 1'b1;
	      end
	      if (rxdfifo_ren && rxdfifo_rstatus[3'd6]) begin
		end_eop <= 1'b1;
	      end
	      else if (pkt_rx_ren) begin
		end_eop <= 1'b0;
	      end
	      if ((rxdfifo_rempty && pkt_rx_ren) && (!end_eop)) begin
		status_rxdfifo_udflow_tog <= (~status_rxdfifo_udflow_tog);
	      end
	    end
	end
endmodule

/*
                    instances: 0
                        nodes: 68 (0)
                  node widths: 791 (0)
                      process: 6 (0)
                        ports: 25 (0)
*/


module rx_enqueue(rxdfifo_wdata, rxdfifo_wstatus, rxdfifo_wen, rxhfifo_ren,
	rxhfifo_wdata, rxhfifo_wstatus, rxhfifo_wen, local_fault_msg_det,
	remote_fault_msg_det, status_crc_error_tog, status_fragment_error_tog,
	status_lenght_error_tog, status_rxdfifo_ovflow_tog,
	status_pause_frame_rx_tog, rxsfifo_wen, rxsfifo_wdata, clk_xgmii_rx,
	reset_xgmii_rx_n, xgmii_rxd, xgmii_rxc, rxdfifo_wfull, rxhfifo_rdata,
	rxhfifo_rstatus, rxhfifo_rempty, rxhfifo_ralmost_empty);
	input			clk_xgmii_rx;
	input			reset_xgmii_rx_n;
	input	[63:0]		xgmii_rxd;
	input	[7:0]		xgmii_rxc;
	input			rxdfifo_wfull;
	input	[63:0]		rxhfifo_rdata;
	input	[7:0]		rxhfifo_rstatus;
	input			rxhfifo_rempty;
	input			rxhfifo_ralmost_empty;
	output	[1:0]		local_fault_msg_det;

	reg	[1:0]		local_fault_msg_det;
	output	[1:0]		remote_fault_msg_det;
	reg	[1:0]		remote_fault_msg_det;
	output	[63:0]		rxdfifo_wdata;
	reg	[63:0]		rxdfifo_wdata;
	output			rxdfifo_wen;
	reg			rxdfifo_wen;
	output	[7:0]		rxdfifo_wstatus;
	reg	[7:0]		rxdfifo_wstatus;
	output			rxhfifo_ren;
	reg			rxhfifo_ren;
	output	[63:0]		rxhfifo_wdata;
	reg	[63:0]		rxhfifo_wdata;
	output			rxhfifo_wen;
	reg			rxhfifo_wen;
	output	[7:0]		rxhfifo_wstatus;
	reg	[7:0]		rxhfifo_wstatus;
	output	[13:0]		rxsfifo_wdata;
	reg	[13:0]		rxsfifo_wdata;
	output			rxsfifo_wen;
	reg			rxsfifo_wen;
	output			status_crc_error_tog;
	reg			status_crc_error_tog;
	output			status_fragment_error_tog;
	reg			status_fragment_error_tog;
	output			status_lenght_error_tog;
	reg			status_lenght_error_tog;
	output			status_pause_frame_rx_tog;
	reg			status_pause_frame_rx_tog;
	output			status_rxdfifo_ovflow_tog;
	reg			status_rxdfifo_ovflow_tog;
	reg	[63:32]		xgmii_rxd_d1;
	reg	[7:4]		xgmii_rxc_d1;
	reg	[63:0]		xgxs_rxd_barrel;
	reg	[7:0]		xgxs_rxc_barrel;
	reg	[63:0]		xgxs_rxd_barrel_d1;
	reg	[7:0]		xgxs_rxc_barrel_d1;
	reg			barrel_shift;
	reg	[31:0]		crc32_d64;
	reg	[31:0]		crc32_d8;
	reg	[3:0]		crc_bytes;
	reg	[3:0]		next_crc_bytes;
	reg	[63:0]		crc_shift_data;
	reg			crc_start_8b;
	reg			crc_done;
	reg			crc_good;
	reg			crc_clear;
	reg	[31:0]		crc_rx;
	reg	[31:0]		next_crc_rx;
	reg	[2:0]		curr_state;
	reg	[2:0]		next_state;
	reg	[13:0]		curr_byte_cnt;
	reg	[13:0]		next_byte_cnt;
	reg	[13:0]		frame_lenght;
	reg			frame_end_flag;
	reg			next_frame_end_flag;
	reg	[2:0]		frame_end_bytes;
	reg	[2:0]		next_frame_end_bytes;
	reg			fragment_error;
	reg			rxd_ovflow_error;
	reg			lenght_error;
	reg			coding_error;
	reg			next_coding_error;
	reg	[7:0]		addmask;
	reg	[7:0]		datamask;
	reg			pause_frame;
	reg			next_pause_frame;
	reg			pause_frame_hold;
	reg			good_pause_frame;
	reg			drop_data;
	reg			next_drop_data;
	reg			pkt_pending;
	reg			rxhfifo_ren_d1;
	reg			rxhfifo_ralmost_empty_d1;
	parameter [2:0]		SM_IDLE		= 3'b0;
	parameter [2:0]		SM_RX		= 3'b1;

	function [31:0] nextCRC32_D64;
	input logic
		[63:0]		Data;
	input logic
		[31:0]		CRC;

	reg	[63:0]		D;
	reg	[31:0]		C;
	reg	[31:0]		NewCRC;
	begin
	  D = Data;
	  C = CRC;
	  NewCRC[0] = ((((((((((((((((((((((((((((((((((((((((((D[63] ^ D[61]) ^
		  D[60]) ^ D[58]) ^ D[55]) ^ D[54]) ^ D[53]) ^ D[50]) ^ D[48]) ^
		  D[47]) ^ D[45]) ^ D[44]) ^ D[37]) ^ D[34]) ^ D[32]) ^ D[31]) ^
		  D[30]) ^ D[29]) ^ D[28]) ^ D[26]) ^ D[25]) ^ D[24]) ^ D[16]) ^
		  D[12]) ^ D[10]) ^ D[9]) ^ D[6]) ^ D[0]) ^ C[0]) ^ C[2]) ^
		  C[5]) ^ C[12]) ^ C[13]) ^ C[15]) ^ C[16]) ^ C[18]) ^ C[21]) ^
		  C[22]) ^ C[23]) ^ C[26]) ^ C[28]) ^ C[29]) ^ C[31]);
	  NewCRC[1] = ((((((((((((((((((((((((((((((((((((((((((((((((D[63] ^
		  D[62]) ^ D[60]) ^ D[59]) ^ D[58]) ^ D[56]) ^ D[53]) ^ D[51]) ^
		  D[50]) ^ D[49]) ^ D[47]) ^ D[46]) ^ D[44]) ^ D[38]) ^ D[37]) ^
		  D[35]) ^ D[34]) ^ D[33]) ^ D[28]) ^ D[27]) ^ D[24]) ^ D[17]) ^
		  D[16]) ^ D[13]) ^ D[12]) ^ D[11]) ^ D[9]) ^ D[7]) ^ D[6]) ^
		  D[1]) ^ D[0]) ^ C[1]) ^ C[2]) ^ C[3]) ^ C[5]) ^ C[6]) ^ C[12])
		  ^ C[14]) ^ C[15]) ^ C[17]) ^ C[18]) ^ C[19]) ^ C[21]) ^ C[24])
		  ^ C[26]) ^ C[27]) ^ C[28]) ^ C[30]) ^ C[31]);
	  NewCRC[2] = (((((((((((((((((((((((((((((((((((((((((((D[59] ^ D[58])
		  ^ D[57]) ^ D[55]) ^ D[53]) ^ D[52]) ^ D[51]) ^ D[44]) ^ D[39])
		  ^ D[38]) ^ D[37]) ^ D[36]) ^ D[35]) ^ D[32]) ^ D[31]) ^ D[30])
		  ^ D[26]) ^ D[24]) ^ D[18]) ^ D[17]) ^ D[16]) ^ D[14]) ^ D[13])
		  ^ D[9]) ^ D[8]) ^ D[7]) ^ D[6]) ^ D[2]) ^ D[1]) ^ D[0]) ^
		  C[0]) ^ C[3]) ^ C[4]) ^ C[5]) ^ C[6]) ^ C[7]) ^ C[12]) ^
		  C[19]) ^ C[20]) ^ C[21]) ^ C[23]) ^ C[25]) ^ C[26]) ^ C[27]);
	  NewCRC[3] = ((((((((((((((((((((((((((((((((((((((((((((D[60] ^ D[59])
		  ^ D[58]) ^ D[56]) ^ D[54]) ^ D[53]) ^ D[52]) ^ D[45]) ^ D[40])
		  ^ D[39]) ^ D[38]) ^ D[37]) ^ D[36]) ^ D[33]) ^ D[32]) ^ D[31])
		  ^ D[27]) ^ D[25]) ^ D[19]) ^ D[18]) ^ D[17]) ^ D[15]) ^ D[14])
		  ^ D[10]) ^ D[9]) ^ D[8]) ^ D[7]) ^ D[3]) ^ D[2]) ^ D[1]) ^
		  C[0]) ^ C[1]) ^ C[4]) ^ C[5]) ^ C[6]) ^ C[7]) ^ C[8]) ^ C[13])
		  ^ C[20]) ^ C[21]) ^ C[22]) ^ C[24]) ^ C[26]) ^ C[27]) ^ C[28])
		  ;
	  NewCRC[4] = ((((((((((((((((((((((((((((((((((((((((((((((D[63] ^
		  D[59]) ^ D[58]) ^ D[57]) ^ D[50]) ^ D[48]) ^ D[47]) ^ D[46]) ^
		  D[45]) ^ D[44]) ^ D[41]) ^ D[40]) ^ D[39]) ^ D[38]) ^ D[33]) ^
		  D[31]) ^ D[30]) ^ D[29]) ^ D[25]) ^ D[24]) ^ D[20]) ^ D[19]) ^
		  D[18]) ^ D[15]) ^ D[12]) ^ D[11]) ^ D[8]) ^ D[6]) ^ D[4]) ^
		  D[3]) ^ D[2]) ^ D[0]) ^ C[1]) ^ C[6]) ^ C[7]) ^ C[8]) ^ C[9])
		  ^ C[12]) ^ C[13]) ^ C[14]) ^ C[15]) ^ C[16]) ^ C[18]) ^ C[25])
		  ^ C[26]) ^ C[27]) ^ C[31]);
	  NewCRC[5] = ((((((((((((((((((((((((((((((((((((((((((((((D[63] ^
		  D[61]) ^ D[59]) ^ D[55]) ^ D[54]) ^ D[53]) ^ D[51]) ^ D[50]) ^
		  D[49]) ^ D[46]) ^ D[44]) ^ D[42]) ^ D[41]) ^ D[40]) ^ D[39]) ^
		  D[37]) ^ D[29]) ^ D[28]) ^ D[24]) ^ D[21]) ^ D[20]) ^ D[19]) ^
		  D[13]) ^ D[10]) ^ D[7]) ^ D[6]) ^ D[5]) ^ D[4]) ^ D[3]) ^
		  D[1]) ^ D[0]) ^ C[5]) ^ C[7]) ^ C[8]) ^ C[9]) ^ C[10]) ^
		  C[12]) ^ C[14]) ^ C[17]) ^ C[18]) ^ C[19]) ^ C[21]) ^ C[22]) ^
		  C[23]) ^ C[27]) ^ C[29]) ^ C[31]);
	  NewCRC[6] = ((((((((((((((((((((((((((((((((((((((((((((D[62] ^ D[60])
		  ^ D[56]) ^ D[55]) ^ D[54]) ^ D[52]) ^ D[51]) ^ D[50]) ^ D[47])
		  ^ D[45]) ^ D[43]) ^ D[42]) ^ D[41]) ^ D[40]) ^ D[38]) ^ D[30])
		  ^ D[29]) ^ D[25]) ^ D[22]) ^ D[21]) ^ D[20]) ^ D[14]) ^ D[11])
		  ^ D[8]) ^ D[7]) ^ D[6]) ^ D[5]) ^ D[4]) ^ D[2]) ^ D[1]) ^
		  C[6]) ^ C[8]) ^ C[9]) ^ C[10]) ^ C[11]) ^ C[13]) ^ C[15]) ^
		  C[18]) ^ C[19]) ^ C[20]) ^ C[22]) ^ C[23]) ^ C[24]) ^ C[28]) ^
		  C[30]);
	  NewCRC[7] = (((((((((((((((((((((((((((((((((((((((((((((((((((D[60] ^
		  D[58]) ^ D[57]) ^ D[56]) ^ D[54]) ^ D[52]) ^ D[51]) ^ D[50]) ^
		  D[47]) ^ D[46]) ^ D[45]) ^ D[43]) ^ D[42]) ^ D[41]) ^ D[39]) ^
		  D[37]) ^ D[34]) ^ D[32]) ^ D[29]) ^ D[28]) ^ D[25]) ^ D[24]) ^
		  D[23]) ^ D[22]) ^ D[21]) ^ D[16]) ^ D[15]) ^ D[10]) ^ D[8]) ^
		  D[7]) ^ D[5]) ^ D[3]) ^ D[2]) ^ D[0]) ^ C[0]) ^ C[2]) ^ C[5])
		  ^ C[7]) ^ C[9]) ^ C[10]) ^ C[11]) ^ C[13]) ^ C[14]) ^ C[15]) ^
		  C[18]) ^ C[19]) ^ C[20]) ^ C[22]) ^ C[24]) ^ C[25]) ^ C[26]) ^
		  C[28]);
	  NewCRC[8] = ((((((((((((((((((((((((((((((((((((((((((((((((((D[63] ^
		  D[60]) ^ D[59]) ^ D[57]) ^ D[54]) ^ D[52]) ^ D[51]) ^ D[50]) ^
		  D[46]) ^ D[45]) ^ D[43]) ^ D[42]) ^ D[40]) ^ D[38]) ^ D[37]) ^
		  D[35]) ^ D[34]) ^ D[33]) ^ D[32]) ^ D[31]) ^ D[28]) ^ D[23]) ^
		  D[22]) ^ D[17]) ^ D[12]) ^ D[11]) ^ D[10]) ^ D[8]) ^ D[4]) ^
		  D[3]) ^ D[1]) ^ D[0]) ^ C[0]) ^ C[1]) ^ C[2]) ^ C[3]) ^ C[5])
		  ^ C[6]) ^ C[8]) ^ C[10]) ^ C[11]) ^ C[13]) ^ C[14]) ^ C[18]) ^
		  C[19]) ^ C[20]) ^ C[22]) ^ C[25]) ^ C[27]) ^ C[28]) ^ C[31]);
	  NewCRC[9] = (((((((((((((((((((((((((((((((((((((((((((((((((D[61] ^
		  D[60]) ^ D[58]) ^ D[55]) ^ D[53]) ^ D[52]) ^ D[51]) ^ D[47]) ^
		  D[46]) ^ D[44]) ^ D[43]) ^ D[41]) ^ D[39]) ^ D[38]) ^ D[36]) ^
		  D[35]) ^ D[34]) ^ D[33]) ^ D[32]) ^ D[29]) ^ D[24]) ^ D[23]) ^
		  D[18]) ^ D[13]) ^ D[12]) ^ D[11]) ^ D[9]) ^ D[5]) ^ D[4]) ^
		  D[2]) ^ D[1]) ^ C[0]) ^ C[1]) ^ C[2]) ^ C[3]) ^ C[4]) ^ C[6])
		  ^ C[7]) ^ C[9]) ^ C[11]) ^ C[12]) ^ C[14]) ^ C[15]) ^ C[19]) ^
		  C[20]) ^ C[21]) ^ C[23]) ^ C[26]) ^ C[28]) ^ C[29]);
	  NewCRC[10] = ((((((((((((((((((((((((((((((((((((((((((((D[63] ^
		  D[62]) ^ D[60]) ^ D[59]) ^ D[58]) ^ D[56]) ^ D[55]) ^ D[52]) ^
		  D[50]) ^ D[42]) ^ D[40]) ^ D[39]) ^ D[36]) ^ D[35]) ^ D[33]) ^
		  D[32]) ^ D[31]) ^ D[29]) ^ D[28]) ^ D[26]) ^ D[19]) ^ D[16]) ^
		  D[14]) ^ D[13]) ^ D[9]) ^ D[5]) ^ D[3]) ^ D[2]) ^ D[0]) ^
		  C[0]) ^ C[1]) ^ C[3]) ^ C[4]) ^ C[7]) ^ C[8]) ^ C[10]) ^
		  C[18]) ^ C[20]) ^ C[23]) ^ C[24]) ^ C[26]) ^ C[27]) ^ C[28]) ^
		  C[30]) ^ C[31]);
	  NewCRC[11] = ((((((((((((((((((((((((((((((((((((((((((((((((((D[59] ^
		  D[58]) ^ D[57]) ^ D[56]) ^ D[55]) ^ D[54]) ^ D[51]) ^ D[50]) ^
		  D[48]) ^ D[47]) ^ D[45]) ^ D[44]) ^ D[43]) ^ D[41]) ^ D[40]) ^
		  D[36]) ^ D[33]) ^ D[31]) ^ D[28]) ^ D[27]) ^ D[26]) ^ D[25]) ^
		  D[24]) ^ D[20]) ^ D[17]) ^ D[16]) ^ D[15]) ^ D[14]) ^ D[12]) ^
		  D[9]) ^ D[4]) ^ D[3]) ^ D[1]) ^ D[0]) ^ C[1]) ^ C[4]) ^ C[8])
		  ^ C[9]) ^ C[11]) ^ C[12]) ^ C[13]) ^ C[15]) ^ C[16]) ^ C[18])
		  ^ C[19]) ^ C[22]) ^ C[23]) ^ C[24]) ^ C[25]) ^ C[26]) ^ C[27])
		  ;
	  NewCRC[12] = ((((((((((((((((((((((((((((((((((((((((((((((D[63] ^
		  D[61]) ^ D[59]) ^ D[57]) ^ D[56]) ^ D[54]) ^ D[53]) ^ D[52]) ^
		  D[51]) ^ D[50]) ^ D[49]) ^ D[47]) ^ D[46]) ^ D[42]) ^ D[41]) ^
		  D[31]) ^ D[30]) ^ D[27]) ^ D[24]) ^ D[21]) ^ D[18]) ^ D[17]) ^
		  D[15]) ^ D[13]) ^ D[12]) ^ D[9]) ^ D[6]) ^ D[5]) ^ D[4]) ^
		  D[2]) ^ D[1]) ^ D[0]) ^ C[9]) ^ C[10]) ^ C[14]) ^ C[15]) ^
		  C[17]) ^ C[18]) ^ C[19]) ^ C[20]) ^ C[21]) ^ C[22]) ^ C[24]) ^
		  C[25]) ^ C[27]) ^ C[29]) ^ C[31]);
	  NewCRC[13] = (((((((((((((((((((((((((((((((((((((((((((((D[62] ^
		  D[60]) ^ D[58]) ^ D[57]) ^ D[55]) ^ D[54]) ^ D[53]) ^ D[52]) ^
		  D[51]) ^ D[50]) ^ D[48]) ^ D[47]) ^ D[43]) ^ D[42]) ^ D[32]) ^
		  D[31]) ^ D[28]) ^ D[25]) ^ D[22]) ^ D[19]) ^ D[18]) ^ D[16]) ^
		  D[14]) ^ D[13]) ^ D[10]) ^ D[7]) ^ D[6]) ^ D[5]) ^ D[3]) ^
		  D[2]) ^ D[1]) ^ C[0]) ^ C[10]) ^ C[11]) ^ C[15]) ^ C[16]) ^
		  C[18]) ^ C[19]) ^ C[20]) ^ C[21]) ^ C[22]) ^ C[23]) ^ C[25]) ^
		  C[26]) ^ C[28]) ^ C[30]);
	  NewCRC[14] = ((((((((((((((((((((((((((((((((((((((((((((((D[63] ^
		  D[61]) ^ D[59]) ^ D[58]) ^ D[56]) ^ D[55]) ^ D[54]) ^ D[53]) ^
		  D[52]) ^ D[51]) ^ D[49]) ^ D[48]) ^ D[44]) ^ D[43]) ^ D[33]) ^
		  D[32]) ^ D[29]) ^ D[26]) ^ D[23]) ^ D[20]) ^ D[19]) ^ D[17]) ^
		  D[15]) ^ D[14]) ^ D[11]) ^ D[8]) ^ D[7]) ^ D[6]) ^ D[4]) ^
		  D[3]) ^ D[2]) ^ C[0]) ^ C[1]) ^ C[11]) ^ C[12]) ^ C[16]) ^
		  C[17]) ^ C[19]) ^ C[20]) ^ C[21]) ^ C[22]) ^ C[23]) ^ C[24]) ^
		  C[26]) ^ C[27]) ^ C[29]) ^ C[31]);
	  NewCRC[15] = ((((((((((((((((((((((((((((((((((((((((((((D[62] ^
		  D[60]) ^ D[59]) ^ D[57]) ^ D[56]) ^ D[55]) ^ D[54]) ^ D[53]) ^
		  D[52]) ^ D[50]) ^ D[49]) ^ D[45]) ^ D[44]) ^ D[34]) ^ D[33]) ^
		  D[30]) ^ D[27]) ^ D[24]) ^ D[21]) ^ D[20]) ^ D[18]) ^ D[16]) ^
		  D[15]) ^ D[12]) ^ D[9]) ^ D[8]) ^ D[7]) ^ D[5]) ^ D[4]) ^
		  D[3]) ^ C[1]) ^ C[2]) ^ C[12]) ^ C[13]) ^ C[17]) ^ C[18]) ^
		  C[20]) ^ C[21]) ^ C[22]) ^ C[23]) ^ C[24]) ^ C[25]) ^ C[27]) ^
		  C[28]) ^ C[30]);
	  NewCRC[16] = (((((((((((((((((((((((((((((((((D[57] ^ D[56]) ^ D[51])
		  ^ D[48]) ^ D[47]) ^ D[46]) ^ D[44]) ^ D[37]) ^ D[35]) ^ D[32])
		  ^ D[30]) ^ D[29]) ^ D[26]) ^ D[24]) ^ D[22]) ^ D[21]) ^ D[19])
		  ^ D[17]) ^ D[13]) ^ D[12]) ^ D[8]) ^ D[5]) ^ D[4]) ^ D[0]) ^
		  C[0]) ^ C[3]) ^ C[5]) ^ C[12]) ^ C[14]) ^ C[15]) ^ C[16]) ^
		  C[19]) ^ C[24]) ^ C[25]);
	  NewCRC[17] = (((((((((((((((((((((((((((((((((D[58] ^ D[57]) ^ D[52])
		  ^ D[49]) ^ D[48]) ^ D[47]) ^ D[45]) ^ D[38]) ^ D[36]) ^ D[33])
		  ^ D[31]) ^ D[30]) ^ D[27]) ^ D[25]) ^ D[23]) ^ D[22]) ^ D[20])
		  ^ D[18]) ^ D[14]) ^ D[13]) ^ D[9]) ^ D[6]) ^ D[5]) ^ D[1]) ^
		  C[1]) ^ C[4]) ^ C[6]) ^ C[13]) ^ C[15]) ^ C[16]) ^ C[17]) ^
		  C[20]) ^ C[25]) ^ C[26]);
	  NewCRC[18] = ((((((((((((((((((((((((((((((((((D[59] ^ D[58]) ^ D[53])
		  ^ D[50]) ^ D[49]) ^ D[48]) ^ D[46]) ^ D[39]) ^ D[37]) ^ D[34])
		  ^ D[32]) ^ D[31]) ^ D[28]) ^ D[26]) ^ D[24]) ^ D[23]) ^ D[21])
		  ^ D[19]) ^ D[15]) ^ D[14]) ^ D[10]) ^ D[7]) ^ D[6]) ^ D[2]) ^
		  C[0]) ^ C[2]) ^ C[5]) ^ C[7]) ^ C[14]) ^ C[16]) ^ C[17]) ^
		  C[18]) ^ C[21]) ^ C[26]) ^ C[27]);
	  NewCRC[19] = (((((((((((((((((((((((((((((((((((D[60] ^ D[59]) ^
		  D[54]) ^ D[51]) ^ D[50]) ^ D[49]) ^ D[47]) ^ D[40]) ^ D[38]) ^
		  D[35]) ^ D[33]) ^ D[32]) ^ D[29]) ^ D[27]) ^ D[25]) ^ D[24]) ^
		  D[22]) ^ D[20]) ^ D[16]) ^ D[15]) ^ D[11]) ^ D[8]) ^ D[7]) ^
		  D[3]) ^ C[0]) ^ C[1]) ^ C[3]) ^ C[6]) ^ C[8]) ^ C[15]) ^
		  C[17]) ^ C[18]) ^ C[19]) ^ C[22]) ^ C[27]) ^ C[28]);
	  NewCRC[20] = (((((((((((((((((((((((((((((((((((D[61] ^ D[60]) ^
		  D[55]) ^ D[52]) ^ D[51]) ^ D[50]) ^ D[48]) ^ D[41]) ^ D[39]) ^
		  D[36]) ^ D[34]) ^ D[33]) ^ D[30]) ^ D[28]) ^ D[26]) ^ D[25]) ^
		  D[23]) ^ D[21]) ^ D[17]) ^ D[16]) ^ D[12]) ^ D[9]) ^ D[8]) ^
		  D[4]) ^ C[1]) ^ C[2]) ^ C[4]) ^ C[7]) ^ C[9]) ^ C[16]) ^
		  C[18]) ^ C[19]) ^ C[20]) ^ C[23]) ^ C[28]) ^ C[29]);
	  NewCRC[21] = (((((((((((((((((((((((((((((((((((D[62] ^ D[61]) ^
		  D[56]) ^ D[53]) ^ D[52]) ^ D[51]) ^ D[49]) ^ D[42]) ^ D[40]) ^
		  D[37]) ^ D[35]) ^ D[34]) ^ D[31]) ^ D[29]) ^ D[27]) ^ D[26]) ^
		  D[24]) ^ D[22]) ^ D[18]) ^ D[17]) ^ D[13]) ^ D[10]) ^ D[9]) ^
		  D[5]) ^ C[2]) ^ C[3]) ^ C[5]) ^ C[8]) ^ C[10]) ^ C[17]) ^
		  C[19]) ^ C[20]) ^ C[21]) ^ C[24]) ^ C[29]) ^ C[30]);
	  NewCRC[22] = (((((((((((((((((((((((((((((((((((((((((((((((((D[62] ^
		  D[61]) ^ D[60]) ^ D[58]) ^ D[57]) ^ D[55]) ^ D[52]) ^ D[48]) ^
		  D[47]) ^ D[45]) ^ D[44]) ^ D[43]) ^ D[41]) ^ D[38]) ^ D[37]) ^
		  D[36]) ^ D[35]) ^ D[34]) ^ D[31]) ^ D[29]) ^ D[27]) ^ D[26]) ^
		  D[24]) ^ D[23]) ^ D[19]) ^ D[18]) ^ D[16]) ^ D[14]) ^ D[12]) ^
		  D[11]) ^ D[9]) ^ D[0]) ^ C[2]) ^ C[3]) ^ C[4]) ^ C[5]) ^ C[6])
		  ^ C[9]) ^ C[11]) ^ C[12]) ^ C[13]) ^ C[15]) ^ C[16]) ^ C[20])
		  ^ C[23]) ^ C[25]) ^ C[26]) ^ C[28]) ^ C[29]) ^ C[30]);
	  NewCRC[23] = (((((((((((((((((((((((((((((((((((((((((((((D[62] ^
		  D[60]) ^ D[59]) ^ D[56]) ^ D[55]) ^ D[54]) ^ D[50]) ^ D[49]) ^
		  D[47]) ^ D[46]) ^ D[42]) ^ D[39]) ^ D[38]) ^ D[36]) ^ D[35]) ^
		  D[34]) ^ D[31]) ^ D[29]) ^ D[27]) ^ D[26]) ^ D[20]) ^ D[19]) ^
		  D[17]) ^ D[16]) ^ D[15]) ^ D[13]) ^ D[9]) ^ D[6]) ^ D[1]) ^
		  D[0]) ^ C[2]) ^ C[3]) ^ C[4]) ^ C[6]) ^ C[7]) ^ C[10]) ^
		  C[14]) ^ C[15]) ^ C[17]) ^ C[18]) ^ C[22]) ^ C[23]) ^ C[24]) ^
		  C[27]) ^ C[28]) ^ C[30]);
	  NewCRC[24] = ((((((((((((((((((((((((((((((((((((((((((((((D[63] ^
		  D[61]) ^ D[60]) ^ D[57]) ^ D[56]) ^ D[55]) ^ D[51]) ^ D[50]) ^
		  D[48]) ^ D[47]) ^ D[43]) ^ D[40]) ^ D[39]) ^ D[37]) ^ D[36]) ^
		  D[35]) ^ D[32]) ^ D[30]) ^ D[28]) ^ D[27]) ^ D[21]) ^ D[20]) ^
		  D[18]) ^ D[17]) ^ D[16]) ^ D[14]) ^ D[10]) ^ D[7]) ^ D[2]) ^
		  D[1]) ^ C[0]) ^ C[3]) ^ C[4]) ^ C[5]) ^ C[7]) ^ C[8]) ^ C[11])
		  ^ C[15]) ^ C[16]) ^ C[18]) ^ C[19]) ^ C[23]) ^ C[24]) ^ C[25])
		  ^ C[28]) ^ C[29]) ^ C[31]);
	  NewCRC[25] = ((((((((((((((((((((((((((((((((((((((((((((D[62] ^
		  D[61]) ^ D[58]) ^ D[57]) ^ D[56]) ^ D[52]) ^ D[51]) ^ D[49]) ^
		  D[48]) ^ D[44]) ^ D[41]) ^ D[40]) ^ D[38]) ^ D[37]) ^ D[36]) ^
		  D[33]) ^ D[31]) ^ D[29]) ^ D[28]) ^ D[22]) ^ D[21]) ^ D[19]) ^
		  D[18]) ^ D[17]) ^ D[15]) ^ D[11]) ^ D[8]) ^ D[3]) ^ D[2]) ^
		  C[1]) ^ C[4]) ^ C[5]) ^ C[6]) ^ C[8]) ^ C[9]) ^ C[12]) ^
		  C[16]) ^ C[17]) ^ C[19]) ^ C[20]) ^ C[24]) ^ C[25]) ^ C[26]) ^
		  C[29]) ^ C[30]);
	  NewCRC[26] = ((((((((((((((((((((((((((((((((((((((((((((((D[62] ^
		  D[61]) ^ D[60]) ^ D[59]) ^ D[57]) ^ D[55]) ^ D[54]) ^ D[52]) ^
		  D[49]) ^ D[48]) ^ D[47]) ^ D[44]) ^ D[42]) ^ D[41]) ^ D[39]) ^
		  D[38]) ^ D[31]) ^ D[28]) ^ D[26]) ^ D[25]) ^ D[24]) ^ D[23]) ^
		  D[22]) ^ D[20]) ^ D[19]) ^ D[18]) ^ D[10]) ^ D[6]) ^ D[4]) ^
		  D[3]) ^ D[0]) ^ C[6]) ^ C[7]) ^ C[9]) ^ C[10]) ^ C[12]) ^
		  C[15]) ^ C[16]) ^ C[17]) ^ C[20]) ^ C[22]) ^ C[23]) ^ C[25]) ^
		  C[27]) ^ C[28]) ^ C[29]) ^ C[30]);
	  NewCRC[27] = (((((((((((((((((((((((((((((((((((((((((((((((D[63] ^
		  D[62]) ^ D[61]) ^ D[60]) ^ D[58]) ^ D[56]) ^ D[55]) ^ D[53]) ^
		  D[50]) ^ D[49]) ^ D[48]) ^ D[45]) ^ D[43]) ^ D[42]) ^ D[40]) ^
		  D[39]) ^ D[32]) ^ D[29]) ^ D[27]) ^ D[26]) ^ D[25]) ^ D[24]) ^
		  D[23]) ^ D[21]) ^ D[20]) ^ D[19]) ^ D[11]) ^ D[7]) ^ D[5]) ^
		  D[4]) ^ D[1]) ^ C[0]) ^ C[7]) ^ C[8]) ^ C[10]) ^ C[11]) ^
		  C[13]) ^ C[16]) ^ C[17]) ^ C[18]) ^ C[21]) ^ C[23]) ^ C[24]) ^
		  C[26]) ^ C[28]) ^ C[29]) ^ C[30]) ^ C[31]);
	  NewCRC[28] = (((((((((((((((((((((((((((((((((((((((((((((D[63] ^
		  D[62]) ^ D[61]) ^ D[59]) ^ D[57]) ^ D[56]) ^ D[54]) ^ D[51]) ^
		  D[50]) ^ D[49]) ^ D[46]) ^ D[44]) ^ D[43]) ^ D[41]) ^ D[40]) ^
		  D[33]) ^ D[30]) ^ D[28]) ^ D[27]) ^ D[26]) ^ D[25]) ^ D[24]) ^
		  D[22]) ^ D[21]) ^ D[20]) ^ D[12]) ^ D[8]) ^ D[6]) ^ D[5]) ^
		  D[2]) ^ C[1]) ^ C[8]) ^ C[9]) ^ C[11]) ^ C[12]) ^ C[14]) ^
		  C[17]) ^ C[18]) ^ C[19]) ^ C[22]) ^ C[24]) ^ C[25]) ^ C[27]) ^
		  C[29]) ^ C[30]) ^ C[31]);
	  NewCRC[29] = (((((((((((((((((((((((((((((((((((((((((((D[63] ^ D[62])
		  ^ D[60]) ^ D[58]) ^ D[57]) ^ D[55]) ^ D[52]) ^ D[51]) ^ D[50])
		  ^ D[47]) ^ D[45]) ^ D[44]) ^ D[42]) ^ D[41]) ^ D[34]) ^ D[31])
		  ^ D[29]) ^ D[28]) ^ D[27]) ^ D[26]) ^ D[25]) ^ D[23]) ^ D[22])
		  ^ D[21]) ^ D[13]) ^ D[9]) ^ D[7]) ^ D[6]) ^ D[3]) ^ C[2]) ^
		  C[9]) ^ C[10]) ^ C[12]) ^ C[13]) ^ C[15]) ^ C[18]) ^ C[19]) ^
		  C[20]) ^ C[23]) ^ C[25]) ^ C[26]) ^ C[28]) ^ C[30]) ^ C[31]);
	  NewCRC[30] = ((((((((((((((((((((((((((((((((((((((((((D[63] ^ D[61])
		  ^ D[59]) ^ D[58]) ^ D[56]) ^ D[53]) ^ D[52]) ^ D[51]) ^ D[48])
		  ^ D[46]) ^ D[45]) ^ D[43]) ^ D[42]) ^ D[35]) ^ D[32]) ^ D[30])
		  ^ D[29]) ^ D[28]) ^ D[27]) ^ D[26]) ^ D[24]) ^ D[23]) ^ D[22])
		  ^ D[14]) ^ D[10]) ^ D[8]) ^ D[7]) ^ D[4]) ^ C[0]) ^ C[3]) ^
		  C[10]) ^ C[11]) ^ C[13]) ^ C[14]) ^ C[16]) ^ C[19]) ^ C[20]) ^
		  C[21]) ^ C[24]) ^ C[26]) ^ C[27]) ^ C[29]) ^ C[31]);
	  NewCRC[31] = ((((((((((((((((((((((((((((((((((((((((D[62] ^ D[60]) ^
		  D[59]) ^ D[57]) ^ D[54]) ^ D[53]) ^ D[52]) ^ D[49]) ^ D[47]) ^
		  D[46]) ^ D[44]) ^ D[43]) ^ D[36]) ^ D[33]) ^ D[31]) ^ D[30]) ^
		  D[29]) ^ D[28]) ^ D[27]) ^ D[25]) ^ D[24]) ^ D[23]) ^ D[15]) ^
		  D[11]) ^ D[9]) ^ D[8]) ^ D[5]) ^ C[1]) ^ C[4]) ^ C[11]) ^
		  C[12]) ^ C[14]) ^ C[15]) ^ C[17]) ^ C[20]) ^ C[21]) ^ C[22]) ^
		  C[25]) ^ C[27]) ^ C[28]) ^ C[30]);
	  nextCRC32_D64 = NewCRC;
	end
	endfunction

	function [31:0] nextCRC32_D8;
	input logic
		[7:0]		Data;
	input logic
		[31:0]		CRC;

	reg	[7:0]		D;
	reg	[31:0]		C;
	reg	[31:0]		NewCRC;
	begin
	  D = Data;
	  C = CRC;
	  NewCRC[0] = (((D[6] ^ D[0]) ^ C[24]) ^ C[30]);
	  NewCRC[1] = (((((((D[7] ^ D[6]) ^ D[1]) ^ D[0]) ^ C[24]) ^ C[25]) ^
		  C[30]) ^ C[31]);
	  NewCRC[2] = (((((((((D[7] ^ D[6]) ^ D[2]) ^ D[1]) ^ D[0]) ^ C[24]) ^
		  C[25]) ^ C[26]) ^ C[30]) ^ C[31]);
	  NewCRC[3] = (((((((D[7] ^ D[3]) ^ D[2]) ^ D[1]) ^ C[25]) ^ C[26]) ^
		  C[27]) ^ C[31]);
	  NewCRC[4] = (((((((((D[6] ^ D[4]) ^ D[3]) ^ D[2]) ^ D[0]) ^ C[24]) ^
		  C[26]) ^ C[27]) ^ C[28]) ^ C[30]);
	  NewCRC[5] = (((((((((((((D[7] ^ D[6]) ^ D[5]) ^ D[4]) ^ D[3]) ^ D[1])
		  ^ D[0]) ^ C[24]) ^ C[25]) ^ C[27]) ^ C[28]) ^ C[29]) ^ C[30])
		  ^ C[31]);
	  NewCRC[6] = (((((((((((D[7] ^ D[6]) ^ D[5]) ^ D[4]) ^ D[2]) ^ D[1]) ^
		  C[25]) ^ C[26]) ^ C[28]) ^ C[29]) ^ C[30]) ^ C[31]);
	  NewCRC[7] = (((((((((D[7] ^ D[5]) ^ D[3]) ^ D[2]) ^ D[0]) ^ C[24]) ^
		  C[26]) ^ C[27]) ^ C[29]) ^ C[31]);
	  NewCRC[8] = ((((((((D[4] ^ D[3]) ^ D[1]) ^ D[0]) ^ C[0]) ^ C[24]) ^
		  C[25]) ^ C[27]) ^ C[28]);
	  NewCRC[9] = ((((((((D[5] ^ D[4]) ^ D[2]) ^ D[1]) ^ C[1]) ^ C[25]) ^
		  C[26]) ^ C[28]) ^ C[29]);
	  NewCRC[10] = ((((((((D[5] ^ D[3]) ^ D[2]) ^ D[0]) ^ C[2]) ^ C[24]) ^
		  C[26]) ^ C[27]) ^ C[29]);
	  NewCRC[11] = ((((((((D[4] ^ D[3]) ^ D[1]) ^ D[0]) ^ C[3]) ^ C[24]) ^
		  C[25]) ^ C[27]) ^ C[28]);
	  NewCRC[12] = ((((((((((((D[6] ^ D[5]) ^ D[4]) ^ D[2]) ^ D[1]) ^ D[0])
		  ^ C[4]) ^ C[24]) ^ C[25]) ^ C[26]) ^ C[28]) ^ C[29]) ^ C[30]);
	  NewCRC[13] = ((((((((((((D[7] ^ D[6]) ^ D[5]) ^ D[3]) ^ D[2]) ^ D[1])
		  ^ C[5]) ^ C[25]) ^ C[26]) ^ C[27]) ^ C[29]) ^ C[30]) ^ C[31]);
	  NewCRC[14] = ((((((((((D[7] ^ D[6]) ^ D[4]) ^ D[3]) ^ D[2]) ^ C[6]) ^
		  C[26]) ^ C[27]) ^ C[28]) ^ C[30]) ^ C[31]);
	  NewCRC[15] = ((((((((D[7] ^ D[5]) ^ D[4]) ^ D[3]) ^ C[7]) ^ C[27]) ^
		  C[28]) ^ C[29]) ^ C[31]);
	  NewCRC[16] = ((((((D[5] ^ D[4]) ^ D[0]) ^ C[8]) ^ C[24]) ^ C[28]) ^
		  C[29]);
	  NewCRC[17] = ((((((D[6] ^ D[5]) ^ D[1]) ^ C[9]) ^ C[25]) ^ C[29]) ^
		  C[30]);
	  NewCRC[18] = ((((((D[7] ^ D[6]) ^ D[2]) ^ C[10]) ^ C[26]) ^ C[30]) ^
		  C[31]);
	  NewCRC[19] = ((((D[7] ^ D[3]) ^ C[11]) ^ C[27]) ^ C[31]);
	  NewCRC[20] = ((D[4] ^ C[12]) ^ C[28]);
	  NewCRC[21] = ((D[5] ^ C[13]) ^ C[29]);
	  NewCRC[22] = ((D[0] ^ C[14]) ^ C[24]);
	  NewCRC[23] = ((((((D[6] ^ D[1]) ^ D[0]) ^ C[15]) ^ C[24]) ^ C[25]) ^
		  C[30]);
	  NewCRC[24] = ((((((D[7] ^ D[2]) ^ D[1]) ^ C[16]) ^ C[25]) ^ C[26]) ^
		  C[31]);
	  NewCRC[25] = ((((D[3] ^ D[2]) ^ C[17]) ^ C[26]) ^ C[27]);
	  NewCRC[26] = ((((((((D[6] ^ D[4]) ^ D[3]) ^ D[0]) ^ C[18]) ^ C[24]) ^
		  C[27]) ^ C[28]) ^ C[30]);
	  NewCRC[27] = ((((((((D[7] ^ D[5]) ^ D[4]) ^ D[1]) ^ C[19]) ^ C[25]) ^
		  C[28]) ^ C[29]) ^ C[31]);
	  NewCRC[28] = ((((((D[6] ^ D[5]) ^ D[2]) ^ C[20]) ^ C[26]) ^ C[29]) ^
		  C[30]);
	  NewCRC[29] = ((((((D[7] ^ D[6]) ^ D[3]) ^ C[21]) ^ C[27]) ^ C[30]) ^
		  C[31]);
	  NewCRC[30] = ((((D[7] ^ D[4]) ^ C[22]) ^ C[28]) ^ C[31]);
	  NewCRC[31] = ((D[5] ^ C[23]) ^ C[29]);
	  nextCRC32_D8 = NewCRC;
	end
	endfunction

	function [63:0] reverse_64b;
	input logic
		[63:0]		data;

	integer			i;
	begin
	  for (i = 0; (i < 64); i = (i + 1)) begin
	    reverse_64b[i] = data[(63 - i)];
	  end
	end
	endfunction

	function [31:0] reverse_32b;
	input logic
		[31:0]		data;

	integer			i;
	begin
	  for (i = 0; (i < 32); i = (i + 1)) begin
	    reverse_32b[i] = data[(31 - i)];
	  end
	end
	endfunction

	function [7:0] reverse_8b;
	input logic
		[7:0]		data;

	integer			i;
	begin
	  for (i = 0; (i < 8); i = (i + 1)) begin
	    reverse_8b[i] = data[(7 - i)];
	  end
	end
	endfunction

	function [2:0] bit_cnt4;
	input logic
		[3:0]		bits;
	begin
	  case (bits)
	    0:
	      bit_cnt4 = 0;
	    1:
	      bit_cnt4 = 1;
	    2:
	      bit_cnt4 = 1;
	    3:
	      bit_cnt4 = 2;
	    4:
	      bit_cnt4 = 1;
	    5:
	      bit_cnt4 = 2;
	    6:
	      bit_cnt4 = 2;
	    7:
	      bit_cnt4 = 3;
	    8:
	      bit_cnt4 = 1;
	    9:
	      bit_cnt4 = 2;
	    10:
	      bit_cnt4 = 2;
	    11:
	      bit_cnt4 = 3;
	    12:
	      bit_cnt4 = 2;
	    13:
	      bit_cnt4 = 3;
	    14:
	      bit_cnt4 = 3;
	    15:
	      bit_cnt4 = 4;
	  endcase
	end
	endfunction

	function [3:0] bit_cnt8;
	input logic
		[7:0]		bits;
	begin
	  bit_cnt8 = (bit_cnt4(bits[3:0]) + bit_cnt4(bits[7:4]));
	end
	endfunction

	always @(posedge clk_xgmii_rx or negedge reset_xgmii_rx_n) begin
	  if (reset_xgmii_rx_n == 1'b0) begin
	    xgmii_rxd_d1 <= 32'b0;
	    xgmii_rxc_d1 <= 4'b0;
	    xgxs_rxd_barrel <= 64'b0;
	    xgxs_rxc_barrel <= 8'b0;
	    xgxs_rxd_barrel_d1 <= 64'b0;
	    xgxs_rxc_barrel_d1 <= 8'b0;
	    barrel_shift <= 1'b0;
	    local_fault_msg_det <= 2'b0;
	    remote_fault_msg_det <= 2'b0;
	    crc32_d64 <= 32'b0;
	    crc32_d8 <= 32'b0;
	    crc_bytes <= 4'b0;
	    crc_shift_data <= 64'b0;
	    crc_done <= 1'b0;
	    crc_rx <= 32'b0;
	    pause_frame_hold <= 1'b0;
	    status_crc_error_tog <= 1'b0;
	    status_fragment_error_tog <= 1'b0;
	    status_lenght_error_tog <= 1'b0;
	    status_rxdfifo_ovflow_tog <= 1'b0;
	    status_pause_frame_rx_tog <= 1'b0;
	    rxsfifo_wen <= 1'b0;
	    rxsfifo_wdata <= 14'b0;
	    datamask <= 8'b0;
	    lenght_error <= 1'b0;
	  end
	  else
	    begin
	      rxsfifo_wen <= 1'b0;
	      rxsfifo_wdata <= frame_lenght;
	      lenght_error <= 1'b0;
	      local_fault_msg_det[1] <= ((xgmii_rxd[63:32] == {8'b1, 8'b0, 8'b0,
		      8'h9c}) && (xgmii_rxc[7:4] == 4'b1));
	      local_fault_msg_det[0] <= ((xgmii_rxd[31:0] == {8'b1, 8'b0, 8'b0,
		      8'h9c}) && (xgmii_rxc[3:0] == 4'b1));
	      remote_fault_msg_det[1] <= ((xgmii_rxd[63:32] == {8'd2, 8'b0,
		      8'b0, 8'h9c}) && (xgmii_rxc[7:4] == 4'b1));
	      remote_fault_msg_det[0] <= ((xgmii_rxd[31:0] == {8'd2, 8'b0, 8'b0,
		      8'h9c}) && (xgmii_rxc[3:0] == 4'b1));
	      xgmii_rxd_d1[63:32] <= xgmii_rxd[63:32];
	      xgmii_rxc_d1[7:4] <= xgmii_rxc[7:4];
	      if ((xgmii_rxd[7:0] == 8'hfb) && xgmii_rxc[0]) begin
		xgxs_rxd_barrel <= xgmii_rxd;
		xgxs_rxc_barrel <= xgmii_rxc;
		barrel_shift <= 1'b0;
	      end
	      else if ((xgmii_rxd[39:32] == 8'hfb) && xgmii_rxc[4]) begin
		xgxs_rxd_barrel[63:32] <= xgmii_rxd[31:0];
		xgxs_rxc_barrel[7:4] <= xgmii_rxc[3:0];
		if (barrel_shift) begin
		  xgxs_rxd_barrel[31:0] <= xgmii_rxd_d1[63:32];
		  xgxs_rxc_barrel[3:0] <= xgmii_rxc_d1[7:4];
		end
		else
		  begin
		    xgxs_rxd_barrel[31:0] <= 32'h07070707;
		    xgxs_rxc_barrel[3:0] <= 4'hf;
		  end
		barrel_shift <= 1'b1;
	      end
	      else if (barrel_shift) begin
		xgxs_rxd_barrel <= {xgmii_rxd[31:0], xgmii_rxd_d1[63:32]};
		xgxs_rxc_barrel <= {xgmii_rxc[3:0], xgmii_rxc_d1[7:4]};
	      end
	      else
		begin
		  xgxs_rxd_barrel <= xgmii_rxd;
		  xgxs_rxc_barrel <= xgmii_rxc;
		end
	      xgxs_rxd_barrel_d1 <= xgxs_rxd_barrel;
	      xgxs_rxc_barrel_d1 <= xgxs_rxc_barrel;
	      datamask[0] <= addmask[0];
	      datamask[1] <= (&addmask[1:0]);
	      datamask[2] <= (&addmask[2:0]);
	      datamask[3] <= (&addmask[3:0]);
	      datamask[4] <= (&addmask[4:0]);
	      datamask[5] <= (&addmask[5:0]);
	      datamask[6] <= (&addmask[6:0]);
	      datamask[7] <= (&addmask[7:0]);
	      if (crc_start_8b) begin
		pause_frame_hold <= pause_frame;
	      end
	      crc_rx <= next_crc_rx;
	      if (crc_clear) begin
		crc32_d64 <= 32'hffffffff;
	      end
	      else
		begin
		  crc32_d64 <= nextCRC32_D64(reverse_64b(xgxs_rxd_barrel_d1),
			  crc32_d64);
		end
	      if (crc_bytes != 4'b0) begin
		if (crc_bytes == 4'b1) begin
		  crc_done <= 1'b1;
		end
		crc32_d8 <= nextCRC32_D8(reverse_8b(crc_shift_data[7:0]),
			crc32_d8);
		crc_shift_data <= {8'b0, crc_shift_data[63:8]};
		crc_bytes <= (crc_bytes - 4'b1);
	      end
	      else if (crc_bytes == 4'b0) begin
		if (coding_error || next_coding_error) begin
		  crc32_d8 <= (~crc32_d64);
		end
		else
		  begin
		    crc32_d8 <= crc32_d64;
		  end
		crc_done <= 1'b0;
		crc_shift_data <= xgxs_rxd_barrel_d1;
		crc_bytes <= next_crc_bytes;
	      end
	      if (crc_done && (!crc_good)) begin
		status_crc_error_tog <= (~status_crc_error_tog);
	      end
	      if (fragment_error) begin
		status_fragment_error_tog <= (~status_fragment_error_tog);
	      end
	      if (rxd_ovflow_error) begin
		status_rxdfifo_ovflow_tog <= (~status_rxdfifo_ovflow_tog);
	      end
	      if (good_pause_frame) begin
		status_pause_frame_rx_tog <= (~status_pause_frame_rx_tog);
	      end
	      if (frame_end_flag) begin
		rxsfifo_wen <= 1'b1;
	      end
	      if (frame_end_flag && (frame_lenght > 14'd16000)) begin
		lenght_error <= 1'b1;
		status_lenght_error_tog <= (~status_lenght_error_tog);
	      end
	    end
	end
	always @(crc32_d8 or crc_done or crc_rx or pause_frame_hold) begin
	  crc_good = 1'b0;
	  good_pause_frame = 1'b0;
	  if (crc_done) begin
	    if (crc_rx == (~reverse_32b(crc32_d8))) begin
	      crc_good = 1'b1;
	      good_pause_frame = pause_frame_hold;
	    end
	  end
	end
	always @(posedge clk_xgmii_rx or negedge reset_xgmii_rx_n) begin
	  if (reset_xgmii_rx_n == 1'b0) begin
	    curr_state <= SM_IDLE;
	    curr_byte_cnt <= 14'b0;
	    frame_end_flag <= 1'b0;
	    frame_end_bytes <= 3'b0;
	    coding_error <= 1'b0;
	    pause_frame <= 1'b0;
	  end
	  else
	    begin
	      curr_state <= next_state;
	      curr_byte_cnt <= next_byte_cnt;
	      frame_end_flag <= next_frame_end_flag;
	      frame_end_bytes <= next_frame_end_bytes;
	      coding_error <= next_coding_error;
	      pause_frame <= next_pause_frame;
	    end
	end
	always @(coding_error or crc_rx or curr_byte_cnt or curr_state or 
		datamask or frame_end_bytes or pause_frame or xgxs_rxc_barrel or
		xgxs_rxc_barrel_d1 or xgxs_rxd_barrel or xgxs_rxd_barrel_d1) 
		begin
	  next_state = curr_state;
	  rxhfifo_wdata = xgxs_rxd_barrel_d1;
	  rxhfifo_wstatus = 8'b0;
	  rxhfifo_wen = 1'b0;
	  next_crc_bytes = 4'b0;
	  next_crc_rx = crc_rx;
	  crc_start_8b = 1'b0;
	  crc_clear = 1'b0;
	  next_byte_cnt = curr_byte_cnt;
	  next_frame_end_flag = 1'b0;
	  next_frame_end_bytes = 3'b0;
	  fragment_error = 1'b0;
	  frame_lenght = (curr_byte_cnt + {11'b0, frame_end_bytes});
	  next_coding_error = coding_error;
	  next_pause_frame = pause_frame;
	  addmask[0] = (!((xgxs_rxd_barrel[7:0] == 8'hfd) &&
		  xgxs_rxc_barrel[0]));
	  addmask[1] = (!((xgxs_rxd_barrel[15:8] == 8'hfd) &&
		  xgxs_rxc_barrel[1]));
	  addmask[2] = (!((xgxs_rxd_barrel[23:16] == 8'hfd) &&
		  xgxs_rxc_barrel[2]));
	  addmask[3] = (!((xgxs_rxd_barrel[31:24] == 8'hfd) &&
		  xgxs_rxc_barrel[3]));
	  addmask[4] = (!((xgxs_rxd_barrel[39:32] == 8'hfd) &&
		  xgxs_rxc_barrel[4]));
	  addmask[5] = (!((xgxs_rxd_barrel[47:40] == 8'hfd) &&
		  xgxs_rxc_barrel[5]));
	  addmask[6] = (!((xgxs_rxd_barrel[55:48] == 8'hfd) &&
		  xgxs_rxc_barrel[6]));
	  addmask[7] = (!((xgxs_rxd_barrel[63:56] == 8'hfd) &&
		  xgxs_rxc_barrel[7]));
	  case (curr_state)
	    SM_IDLE: begin
	      next_byte_cnt = 14'b0;
	      crc_clear = 1'b1;
	      next_coding_error = 1'b0;
	      next_pause_frame = 1'b0;
	      if ((((((((((((((((xgxs_rxd_barrel_d1[7:0] == 8'hfb) && 
		      xgxs_rxc_barrel_d1[0]) && (xgxs_rxd_barrel_d1[15:8] == 
		      8'h55)) && (!xgxs_rxc_barrel_d1[1])) && (
		      xgxs_rxd_barrel_d1[23:16] == 8'h55)) && (!
		      xgxs_rxc_barrel_d1[2])) && (xgxs_rxd_barrel_d1[31:24] == 
		      8'h55)) && (!xgxs_rxc_barrel_d1[3])) && (
		      xgxs_rxd_barrel_d1[39:32] == 8'h55)) && (!
		      xgxs_rxc_barrel_d1[4])) && (xgxs_rxd_barrel_d1[47:40] == 
		      8'h55)) && (!xgxs_rxc_barrel_d1[5])) && (
		      xgxs_rxd_barrel_d1[55:48] == 8'h55)) && (!
		      xgxs_rxc_barrel_d1[6])) && (xgxs_rxd_barrel_d1[63:56] == 
		      8'hd5)) && (!xgxs_rxc_barrel_d1[7])) begin
		next_state = SM_RX;
	      end
	    end
	    SM_RX: begin
	      rxhfifo_wen = (!pause_frame);
	      if ((((xgxs_rxd_barrel_d1[7:0] == 8'hfb) && xgxs_rxc_barrel_d1[0])
		      && (xgxs_rxd_barrel_d1[63:56] == 8'hd5)) && (!
		      xgxs_rxc_barrel_d1[7])) begin
		next_byte_cnt = 14'b0;
		crc_clear = 1'b1;
		next_coding_error = 1'b0;
		fragment_error = 1'b1;
		rxhfifo_wstatus[3'd5] = 1'b1;
		if (curr_byte_cnt == 14'b0) begin
		  rxhfifo_wen = 1'b0;
		end
		else
		  begin
		    rxhfifo_wstatus[3'd6] = 1'b1;
		  end
	      end
	      else if (curr_byte_cnt > 14'd16100) begin
		fragment_error = 1'b1;
		rxhfifo_wstatus[3'd5] = 1'b1;
		rxhfifo_wstatus[3'd6] = 1'b1;
		next_state = SM_IDLE;
	      end
	      else
		begin
		  if ((curr_byte_cnt == 14'b0) && (xgxs_rxd_barrel_d1[47:0] == 
			  48'h010000c28001)) begin
		    rxhfifo_wen = 1'b0;
		    next_pause_frame = 1'b1;
		  end
		  if (|(xgxs_rxc_barrel_d1 & datamask)) begin
		    next_coding_error = 1'b1;
		  end
		  if (curr_byte_cnt == 14'b0) begin
		    rxhfifo_wstatus[3'd7] = 1'b1;
		  end
		  next_byte_cnt = (curr_byte_cnt + {10'b0,
			  bit_cnt8(datamask[7:0])});
		  if ((xgxs_rxd_barrel[39:32] == 8'hfd) && xgxs_rxc_barrel[4]) 
			  begin
		    rxhfifo_wstatus[3'd6] = 1'b1;
		    rxhfifo_wstatus[2:0] = 3'b0;
		    crc_start_8b = 1'b1;
		    next_crc_bytes = 4'd8;
		    next_crc_rx = xgxs_rxd_barrel[31:0];
		    next_frame_end_flag = 1'b1;
		    next_frame_end_bytes = 3'd4;
		    next_state = SM_IDLE;
		  end
		  if ((xgxs_rxd_barrel[31:24] == 8'hfd) && xgxs_rxc_barrel[3]) 
			  begin
		    rxhfifo_wstatus[3'd6] = 1'b1;
		    rxhfifo_wstatus[2:0] = 3'd7;
		    crc_start_8b = 1'b1;
		    next_crc_bytes = 4'd7;
		    next_crc_rx = {xgxs_rxd_barrel[23:0],
			    xgxs_rxd_barrel_d1[63:56]};
		    next_frame_end_flag = 1'b1;
		    next_frame_end_bytes = 3'd3;
		    next_state = SM_IDLE;
		  end
		  if ((xgxs_rxd_barrel[23:16] == 8'hfd) && xgxs_rxc_barrel[2]) 
			  begin
		    rxhfifo_wstatus[3'd6] = 1'b1;
		    rxhfifo_wstatus[2:0] = 3'd6;
		    crc_start_8b = 1'b1;
		    next_crc_bytes = 4'd6;
		    next_crc_rx = {xgxs_rxd_barrel[15:0],
			    xgxs_rxd_barrel_d1[63:48]};
		    next_frame_end_flag = 1'b1;
		    next_frame_end_bytes = 3'd2;
		    next_state = SM_IDLE;
		  end
		  if ((xgxs_rxd_barrel[15:8] == 8'hfd) && xgxs_rxc_barrel[1]) 
			  begin
		    rxhfifo_wstatus[3'd6] = 1'b1;
		    rxhfifo_wstatus[2:0] = 3'd5;
		    crc_start_8b = 1'b1;
		    next_crc_bytes = 4'd5;
		    next_crc_rx = {xgxs_rxd_barrel[7:0],
			    xgxs_rxd_barrel_d1[63:40]};
		    next_frame_end_flag = 1'b1;
		    next_frame_end_bytes = 3'b1;
		    next_state = SM_IDLE;
		  end
		  if ((xgxs_rxd_barrel[7:0] == 8'hfd) && xgxs_rxc_barrel[0]) 
			  begin
		    rxhfifo_wstatus[3'd6] = 1'b1;
		    rxhfifo_wstatus[2:0] = 3'd4;
		    crc_start_8b = 1'b1;
		    next_crc_bytes = 4'd4;
		    next_crc_rx = xgxs_rxd_barrel_d1[63:32];
		    next_frame_end_flag = 1'b1;
		    next_state = SM_IDLE;
		  end
		  if ((xgxs_rxd_barrel_d1[63:56] == 8'hfd) && 
			  xgxs_rxc_barrel_d1[7]) begin
		    rxhfifo_wstatus[3'd6] = 1'b1;
		    rxhfifo_wstatus[2:0] = 3'd3;
		    crc_start_8b = 1'b1;
		    next_crc_bytes = 4'd3;
		    next_crc_rx = xgxs_rxd_barrel_d1[55:24];
		    next_frame_end_flag = 1'b1;
		    next_state = SM_IDLE;
		  end
		  if ((xgxs_rxd_barrel_d1[55:48] == 8'hfd) && 
			  xgxs_rxc_barrel_d1[6]) begin
		    rxhfifo_wstatus[3'd6] = 1'b1;
		    rxhfifo_wstatus[2:0] = 3'd2;
		    crc_start_8b = 1'b1;
		    next_crc_bytes = 4'd2;
		    next_crc_rx = xgxs_rxd_barrel_d1[47:16];
		    next_frame_end_flag = 1'b1;
		    next_state = SM_IDLE;
		  end
		  if ((xgxs_rxd_barrel_d1[47:40] == 8'hfd) && 
			  xgxs_rxc_barrel_d1[5]) begin
		    rxhfifo_wstatus[3'd6] = 1'b1;
		    rxhfifo_wstatus[2:0] = 3'b1;
		    crc_start_8b = 1'b1;
		    next_crc_bytes = 4'b1;
		    next_crc_rx = xgxs_rxd_barrel_d1[39:8];
		    next_frame_end_flag = 1'b1;
		    next_state = SM_IDLE;
		  end
		end
	    end
	    default: begin
	      next_state = SM_IDLE;
	    end
	  endcase
	end
	always @(posedge clk_xgmii_rx or negedge reset_xgmii_rx_n) begin
	  if (reset_xgmii_rx_n == 1'b0) begin
	    rxhfifo_ralmost_empty_d1 <= 1'b1;
	    drop_data <= 1'b0;
	    pkt_pending <= 1'b0;
	    rxhfifo_ren_d1 <= 1'b0;
	  end
	  else
	    begin
	      rxhfifo_ralmost_empty_d1 <= rxhfifo_ralmost_empty;
	      drop_data <= next_drop_data;
	      pkt_pending <= rxhfifo_ren;
	      rxhfifo_ren_d1 <= rxhfifo_ren;
	    end
	end
	always @(crc_done or crc_good or drop_data or lenght_error or 
		pkt_pending or rxdfifo_wfull or rxhfifo_ralmost_empty_d1 or 
		rxhfifo_rdata or rxhfifo_ren_d1 or rxhfifo_rstatus) begin
	  rxd_ovflow_error = 1'b0;
	  rxdfifo_wdata = rxhfifo_rdata;
	  rxdfifo_wstatus = rxhfifo_rstatus;
	  next_drop_data = drop_data;
	  rxhfifo_ren = ((!rxhfifo_ralmost_empty_d1) || (pkt_pending &&
		  (!rxhfifo_rstatus[3'd6])));
	  if (rxhfifo_ren_d1 && rxhfifo_rstatus[3'd7]) begin
	    next_drop_data = 1'b0;
	  end
	  if ((rxhfifo_ren_d1 && rxdfifo_wfull) && (!next_drop_data)) begin
	    rxd_ovflow_error = 1'b1;
	    next_drop_data = 1'b1;
	  end
	  rxdfifo_wen = (rxhfifo_ren_d1 && (!next_drop_data));
	  if ((crc_done && (!crc_good)) || lenght_error) begin
	    rxdfifo_wstatus[3'd5] = 1'b1;
	  end
	end
endmodule

/*
                    instances: 0
                        nodes: 24 (0)
                  node widths: 32 (0)
                   contassign:  10 (0)
                        ports: 22 (0)
                        ports: 2 (0)
                 portconnects: 8 (0)
*/


module sync_clk_wb(status_crc_error, status_fragment_error, status_lenght_error,
	status_txdfifo_ovflow, status_txdfifo_udflow, status_rxdfifo_ovflow,
	status_rxdfifo_udflow, status_pause_frame_rx, status_local_fault,
	status_remote_fault, wb_clk_i, wb_rst_i, status_crc_error_tog,
	status_fragment_error_tog, status_lenght_error_tog,
	status_txdfifo_ovflow_tog, status_txdfifo_udflow_tog,
	status_rxdfifo_ovflow_tog, status_rxdfifo_udflow_tog,
	status_pause_frame_rx_tog, status_local_fault_crx,
	status_remote_fault_crx);
	input			wb_clk_i;
	input			wb_rst_i;
	input			status_crc_error_tog;
	input			status_fragment_error_tog;
	input			status_lenght_error_tog;
	input			status_txdfifo_ovflow_tog;
	input			status_txdfifo_udflow_tog;
	input			status_rxdfifo_ovflow_tog;
	input			status_rxdfifo_udflow_tog;
	input			status_pause_frame_rx_tog;
	input			status_local_fault_crx;
	input			status_remote_fault_crx;
	output			status_crc_error;
	output			status_fragment_error;
	output			status_lenght_error;
	output			status_txdfifo_ovflow;
	output			status_txdfifo_udflow;
	output			status_rxdfifo_ovflow;
	output			status_rxdfifo_udflow;
	output			status_pause_frame_rx;
	output			status_local_fault;
	output			status_remote_fault;

	wire	[7:0]		sig_out1;
	wire	[1:0]		sig_out2;
	meta_sync #(.DWIDTH(8), .EDGE_DETECT(1)) meta_sync0(
		.out				(sig_out1), 
		.clk				(wb_clk_i), 
		.reset_n			((~wb_rst_i)), 
		.in				({status_lenght_error_tog,
		status_crc_error_tog, status_fragment_error_tog,
		status_txdfifo_ovflow_tog, status_txdfifo_udflow_tog,
		status_rxdfifo_ovflow_tog, status_rxdfifo_udflow_tog,
		status_pause_frame_rx_tog}));
	meta_sync #(.DWIDTH(2), .EDGE_DETECT(0)) meta_sync1(
		.out				(sig_out2), 
		.clk				(wb_clk_i), 
		.reset_n			((~wb_rst_i)), 
		.in				({status_local_fault_crx,
		status_remote_fault_crx}));

	assign status_lenght_error = sig_out1[7];
	assign status_crc_error = sig_out1[6];
	assign status_fragment_error = sig_out1[5];
	assign status_txdfifo_ovflow = sig_out1[4];
	assign status_txdfifo_udflow = sig_out1[3];
	assign status_rxdfifo_ovflow = sig_out1[2];
	assign status_rxdfifo_udflow = sig_out1[1];
	assign status_pause_frame_rx = sig_out1[0];
	assign status_local_fault = sig_out2[1];
	assign status_remote_fault = sig_out2[0];
endmodule

/*
                    instances: 0
                        nodes: 9 (0)
                  node widths: 11 (0)
                   contassign:  3 (0)
                        ports: 8 (0)
                        ports: 1 (0)
                 portconnects: 4 (0)
*/


module sync_clk_xgmii_tx(ctrl_tx_enable_ctx, status_local_fault_ctx,
	status_remote_fault_ctx, clk_xgmii_tx, reset_xgmii_tx_n, ctrl_tx_enable,
	status_local_fault_crx, status_remote_fault_crx);
	input			clk_xgmii_tx;
	input			reset_xgmii_tx_n;
	input			ctrl_tx_enable;
	input			status_local_fault_crx;
	input			status_remote_fault_crx;
	output			ctrl_tx_enable_ctx;
	output			status_local_fault_ctx;
	output			status_remote_fault_ctx;

	wire	[2:0]		sig_out;
	meta_sync #(.DWIDTH(3)) meta_sync0(
		.out				(sig_out), 
		.clk				(clk_xgmii_tx), 
		.reset_n			(reset_xgmii_tx_n), 
		.in				({ctrl_tx_enable,
		status_local_fault_crx, status_remote_fault_crx}));

	assign ctrl_tx_enable_ctx = sig_out[2];
	assign status_local_fault_ctx = sig_out[1];
	assign status_remote_fault_ctx = sig_out[0];
endmodule

/*
                    instances: 0
                        nodes: 12 (0)
                  node widths: 152 (0)
                        ports: 12 (0)
                        ports: 1 (0)
                 portconnects: 12 (0)
*/


module tx_hold_fifo(txhfifo_wfull, txhfifo_walmost_full, txhfifo_rdata,
	txhfifo_rstatus, txhfifo_rempty, txhfifo_ralmost_empty, clk_xgmii_tx,
	reset_xgmii_tx_n, txhfifo_wdata, txhfifo_wstatus, txhfifo_wen,
	txhfifo_ren);
	input			clk_xgmii_tx;
	input			reset_xgmii_tx_n;
	input	[63:0]		txhfifo_wdata;
	input	[7:0]		txhfifo_wstatus;
	input			txhfifo_wen;
	input			txhfifo_ren;
	output			txhfifo_wfull;
	output			txhfifo_walmost_full;
	output	[63:0]		txhfifo_rdata;
	output	[7:0]		txhfifo_rstatus;
	output			txhfifo_rempty;
	output			txhfifo_ralmost_empty;
	generic_fifo #(.DWIDTH(72), .AWIDTH(4), .REGISTER_READ(1), .EARLY_READ(
		1), .CLOCK_CROSSING(0), .ALMOST_EMPTY_THRESH(7), .
		ALMOST_FULL_THRESH(4), .MEM_TYPE(1)) fifo0(
		.wclk				(clk_xgmii_tx), 
		.wrst_n				(reset_xgmii_tx_n), 
		.wen				(txhfifo_wen), 
		.wdata				({txhfifo_wstatus,
		txhfifo_wdata}), 
		.wfull				(txhfifo_wfull), 
		.walmost_full			(txhfifo_walmost_full), 
		.rclk				(clk_xgmii_tx), 
		.rrst_n				(reset_xgmii_tx_n), 
		.ren				(txhfifo_ren), 
		.rdata				({txhfifo_rstatus,
		txhfifo_rdata}), 
		.rempty				(txhfifo_rempty), 
		.ralmost_empty			(txhfifo_ralmost_empty));
endmodule

/*
                    instances: 0
                        nodes: 14 (0)
                  node widths: 154 (0)
                        ports: 14 (0)
                        ports: 1 (0)
                 portconnects: 12 (0)
*/


module tx_data_fifo(txdfifo_wfull, txdfifo_walmost_full, txdfifo_rdata,
	txdfifo_rstatus, txdfifo_rempty, txdfifo_ralmost_empty, clk_xgmii_tx,
	clk_156m25, reset_xgmii_tx_n, reset_156m25_n, txdfifo_wdata,
	txdfifo_wstatus, txdfifo_wen, txdfifo_ren);
	input			clk_xgmii_tx;
	input			clk_156m25;
	input			reset_xgmii_tx_n;
	input			reset_156m25_n;
	input	[63:0]		txdfifo_wdata;
	input	[7:0]		txdfifo_wstatus;
	input			txdfifo_wen;
	input			txdfifo_ren;
	output			txdfifo_wfull;
	output			txdfifo_walmost_full;
	output	[63:0]		txdfifo_rdata;
	output	[7:0]		txdfifo_rstatus;
	output			txdfifo_rempty;
	output			txdfifo_ralmost_empty;
	generic_fifo #(.DWIDTH(72), .AWIDTH(6), .REGISTER_READ(1), .EARLY_READ(
		1), .CLOCK_CROSSING(1), .ALMOST_EMPTY_THRESH(7), .
		ALMOST_FULL_THRESH(12), .MEM_TYPE(2)) fifo0(
		.wclk				(clk_156m25), 
		.wrst_n				(reset_156m25_n), 
		.wen				(txdfifo_wen), 
		.wdata				({txdfifo_wstatus,
		txdfifo_wdata}), 
		.wfull				(txdfifo_wfull), 
		.walmost_full			(txdfifo_walmost_full), 
		.rclk				(clk_xgmii_tx), 
		.rrst_n				(reset_xgmii_tx_n), 
		.ren				(txdfifo_ren), 
		.rdata				({txdfifo_rstatus,
		txdfifo_rdata}), 
		.rempty				(txdfifo_rempty), 
		.ralmost_empty			(txdfifo_ralmost_empty));
endmodule

/*
                    instances: 0
                        nodes: 64 (0)
                  node widths: 905 (0)
                      process: 6 (0)
                        ports: 25 (0)
*/


module tx_dequeue(txdfifo_ren, txhfifo_ren, txhfifo_wdata, txhfifo_wstatus,
	txhfifo_wen, xgmii_txd, xgmii_txc, status_txdfifo_udflow_tog,
	txsfifo_wen, txsfifo_wdata, clk_xgmii_tx, reset_xgmii_tx_n,
	ctrl_tx_enable_ctx, status_local_fault_ctx, status_remote_fault_ctx,
	txdfifo_rdata, txdfifo_rstatus, txdfifo_rempty, txdfifo_ralmost_empty,
	txhfifo_rdata, txhfifo_rstatus, txhfifo_rempty, txhfifo_ralmost_empty,
	txhfifo_wfull, txhfifo_walmost_full);
	input			clk_xgmii_tx;
	input			reset_xgmii_tx_n;
	input			ctrl_tx_enable_ctx;
	input			status_local_fault_ctx;
	input			status_remote_fault_ctx;
	input	[63:0]		txdfifo_rdata;
	input	[7:0]		txdfifo_rstatus;
	input			txdfifo_rempty;
	input			txdfifo_ralmost_empty;
	input	[63:0]		txhfifo_rdata;
	input	[7:0]		txhfifo_rstatus;
	input			txhfifo_rempty;
	input			txhfifo_ralmost_empty;
	input			txhfifo_wfull;
	input			txhfifo_walmost_full;
	output			status_txdfifo_udflow_tog;

	reg			status_txdfifo_udflow_tog;
	output			txdfifo_ren;
	reg			txdfifo_ren;
	output			txhfifo_ren;
	reg			txhfifo_ren;
	output	[63:0]		txhfifo_wdata;
	reg	[63:0]		txhfifo_wdata;
	output			txhfifo_wen;
	reg			txhfifo_wen;
	output	[7:0]		txhfifo_wstatus;
	reg	[7:0]		txhfifo_wstatus;
	output	[13:0]		txsfifo_wdata;
	reg	[13:0]		txsfifo_wdata;
	output			txsfifo_wen;
	reg			txsfifo_wen;
	output	[7:0]		xgmii_txc;
	reg	[7:0]		xgmii_txc;
	output	[63:0]		xgmii_txd;
	reg	[63:0]		xgmii_txd;
	reg	[63:0]		xgxs_txd;
	reg	[7:0]		xgxs_txc;
	reg	[63:0]		next_xgxs_txd;
	reg	[7:0]		next_xgxs_txc;
	reg	[2:0]		curr_state_enc;
	reg	[2:0]		next_state_enc;
	reg	[0:0]		curr_state_pad;
	reg	[0:0]		next_state_pad;
	reg			start_on_lane0;
	reg			next_start_on_lane0;
	reg	[2:0]		ifg_deficit;
	reg	[2:0]		next_ifg_deficit;
	reg			ifg_4b_add;
	reg			next_ifg_4b_add;
	reg			ifg_8b_add;
	reg			next_ifg_8b_add;
	reg			ifg_8b2_add;
	reg			next_ifg_8b2_add;
	reg	[7:0]		eop;
	reg	[7:0]		next_eop;
	reg	[63:32]		xgxs_txd_barrel;
	reg	[7:4]		xgxs_txc_barrel;
	reg	[63:0]		txhfifo_rdata_d1;
	reg	[13:0]		add_cnt;
	reg	[13:0]		byte_cnt;
	reg	[31:0]		crc32_d64;
	reg	[31:0]		crc32_d8;
	reg	[31:0]		crc32_tx;
	reg	[63:0]		shift_crc_data;
	reg	[3:0]		shift_crc_eop;
	reg	[3:0]		shift_crc_cnt;
	reg	[31:0]		crc_data;
	reg			frame_available;
	reg			next_frame_available;
	reg	[63:0]		next_txhfifo_wdata;
	reg	[7:0]		next_txhfifo_wstatus;
	reg			next_txhfifo_wen;
	reg			txdfifo_ren_d1;
	reg			frame_end;
	parameter [2:0]		SM_IDLE		= 3'b0;
	parameter [2:0]		SM_PREAMBLE	= 3'b1;
	parameter [2:0]		SM_TX		= 3'd2;
	parameter [2:0]		SM_EOP		= 3'd3;
	parameter [2:0]		SM_TERM		= 3'd4;
	parameter [2:0]		SM_TERM_FAIL	= 3'd5;
	parameter [2:0]		SM_IFG		= 3'd6;
	parameter [0:0]		SM_PAD_EQ	= 1'b0;
	parameter [0:0]		SM_PAD_PAD	= 1'b1;

	function [31:0] nextCRC32_D64;
	input logic
		[63:0]		Data;
	input logic
		[31:0]		CRC;

	reg	[63:0]		D;
	reg	[31:0]		C;
	reg	[31:0]		NewCRC;
	begin
	  D = Data;
	  C = CRC;
	  NewCRC[0] = ((((((((((((((((((((((((((((((((((((((((((D[63] ^ D[61]) ^
		  D[60]) ^ D[58]) ^ D[55]) ^ D[54]) ^ D[53]) ^ D[50]) ^ D[48]) ^
		  D[47]) ^ D[45]) ^ D[44]) ^ D[37]) ^ D[34]) ^ D[32]) ^ D[31]) ^
		  D[30]) ^ D[29]) ^ D[28]) ^ D[26]) ^ D[25]) ^ D[24]) ^ D[16]) ^
		  D[12]) ^ D[10]) ^ D[9]) ^ D[6]) ^ D[0]) ^ C[0]) ^ C[2]) ^
		  C[5]) ^ C[12]) ^ C[13]) ^ C[15]) ^ C[16]) ^ C[18]) ^ C[21]) ^
		  C[22]) ^ C[23]) ^ C[26]) ^ C[28]) ^ C[29]) ^ C[31]);
	  NewCRC[1] = ((((((((((((((((((((((((((((((((((((((((((((((((D[63] ^
		  D[62]) ^ D[60]) ^ D[59]) ^ D[58]) ^ D[56]) ^ D[53]) ^ D[51]) ^
		  D[50]) ^ D[49]) ^ D[47]) ^ D[46]) ^ D[44]) ^ D[38]) ^ D[37]) ^
		  D[35]) ^ D[34]) ^ D[33]) ^ D[28]) ^ D[27]) ^ D[24]) ^ D[17]) ^
		  D[16]) ^ D[13]) ^ D[12]) ^ D[11]) ^ D[9]) ^ D[7]) ^ D[6]) ^
		  D[1]) ^ D[0]) ^ C[1]) ^ C[2]) ^ C[3]) ^ C[5]) ^ C[6]) ^ C[12])
		  ^ C[14]) ^ C[15]) ^ C[17]) ^ C[18]) ^ C[19]) ^ C[21]) ^ C[24])
		  ^ C[26]) ^ C[27]) ^ C[28]) ^ C[30]) ^ C[31]);
	  NewCRC[2] = (((((((((((((((((((((((((((((((((((((((((((D[59] ^ D[58])
		  ^ D[57]) ^ D[55]) ^ D[53]) ^ D[52]) ^ D[51]) ^ D[44]) ^ D[39])
		  ^ D[38]) ^ D[37]) ^ D[36]) ^ D[35]) ^ D[32]) ^ D[31]) ^ D[30])
		  ^ D[26]) ^ D[24]) ^ D[18]) ^ D[17]) ^ D[16]) ^ D[14]) ^ D[13])
		  ^ D[9]) ^ D[8]) ^ D[7]) ^ D[6]) ^ D[2]) ^ D[1]) ^ D[0]) ^
		  C[0]) ^ C[3]) ^ C[4]) ^ C[5]) ^ C[6]) ^ C[7]) ^ C[12]) ^
		  C[19]) ^ C[20]) ^ C[21]) ^ C[23]) ^ C[25]) ^ C[26]) ^ C[27]);
	  NewCRC[3] = ((((((((((((((((((((((((((((((((((((((((((((D[60] ^ D[59])
		  ^ D[58]) ^ D[56]) ^ D[54]) ^ D[53]) ^ D[52]) ^ D[45]) ^ D[40])
		  ^ D[39]) ^ D[38]) ^ D[37]) ^ D[36]) ^ D[33]) ^ D[32]) ^ D[31])
		  ^ D[27]) ^ D[25]) ^ D[19]) ^ D[18]) ^ D[17]) ^ D[15]) ^ D[14])
		  ^ D[10]) ^ D[9]) ^ D[8]) ^ D[7]) ^ D[3]) ^ D[2]) ^ D[1]) ^
		  C[0]) ^ C[1]) ^ C[4]) ^ C[5]) ^ C[6]) ^ C[7]) ^ C[8]) ^ C[13])
		  ^ C[20]) ^ C[21]) ^ C[22]) ^ C[24]) ^ C[26]) ^ C[27]) ^ C[28])
		  ;
	  NewCRC[4] = ((((((((((((((((((((((((((((((((((((((((((((((D[63] ^
		  D[59]) ^ D[58]) ^ D[57]) ^ D[50]) ^ D[48]) ^ D[47]) ^ D[46]) ^
		  D[45]) ^ D[44]) ^ D[41]) ^ D[40]) ^ D[39]) ^ D[38]) ^ D[33]) ^
		  D[31]) ^ D[30]) ^ D[29]) ^ D[25]) ^ D[24]) ^ D[20]) ^ D[19]) ^
		  D[18]) ^ D[15]) ^ D[12]) ^ D[11]) ^ D[8]) ^ D[6]) ^ D[4]) ^
		  D[3]) ^ D[2]) ^ D[0]) ^ C[1]) ^ C[6]) ^ C[7]) ^ C[8]) ^ C[9])
		  ^ C[12]) ^ C[13]) ^ C[14]) ^ C[15]) ^ C[16]) ^ C[18]) ^ C[25])
		  ^ C[26]) ^ C[27]) ^ C[31]);
	  NewCRC[5] = ((((((((((((((((((((((((((((((((((((((((((((((D[63] ^
		  D[61]) ^ D[59]) ^ D[55]) ^ D[54]) ^ D[53]) ^ D[51]) ^ D[50]) ^
		  D[49]) ^ D[46]) ^ D[44]) ^ D[42]) ^ D[41]) ^ D[40]) ^ D[39]) ^
		  D[37]) ^ D[29]) ^ D[28]) ^ D[24]) ^ D[21]) ^ D[20]) ^ D[19]) ^
		  D[13]) ^ D[10]) ^ D[7]) ^ D[6]) ^ D[5]) ^ D[4]) ^ D[3]) ^
		  D[1]) ^ D[0]) ^ C[5]) ^ C[7]) ^ C[8]) ^ C[9]) ^ C[10]) ^
		  C[12]) ^ C[14]) ^ C[17]) ^ C[18]) ^ C[19]) ^ C[21]) ^ C[22]) ^
		  C[23]) ^ C[27]) ^ C[29]) ^ C[31]);
	  NewCRC[6] = ((((((((((((((((((((((((((((((((((((((((((((D[62] ^ D[60])
		  ^ D[56]) ^ D[55]) ^ D[54]) ^ D[52]) ^ D[51]) ^ D[50]) ^ D[47])
		  ^ D[45]) ^ D[43]) ^ D[42]) ^ D[41]) ^ D[40]) ^ D[38]) ^ D[30])
		  ^ D[29]) ^ D[25]) ^ D[22]) ^ D[21]) ^ D[20]) ^ D[14]) ^ D[11])
		  ^ D[8]) ^ D[7]) ^ D[6]) ^ D[5]) ^ D[4]) ^ D[2]) ^ D[1]) ^
		  C[6]) ^ C[8]) ^ C[9]) ^ C[10]) ^ C[11]) ^ C[13]) ^ C[15]) ^
		  C[18]) ^ C[19]) ^ C[20]) ^ C[22]) ^ C[23]) ^ C[24]) ^ C[28]) ^
		  C[30]);
	  NewCRC[7] = (((((((((((((((((((((((((((((((((((((((((((((((((((D[60] ^
		  D[58]) ^ D[57]) ^ D[56]) ^ D[54]) ^ D[52]) ^ D[51]) ^ D[50]) ^
		  D[47]) ^ D[46]) ^ D[45]) ^ D[43]) ^ D[42]) ^ D[41]) ^ D[39]) ^
		  D[37]) ^ D[34]) ^ D[32]) ^ D[29]) ^ D[28]) ^ D[25]) ^ D[24]) ^
		  D[23]) ^ D[22]) ^ D[21]) ^ D[16]) ^ D[15]) ^ D[10]) ^ D[8]) ^
		  D[7]) ^ D[5]) ^ D[3]) ^ D[2]) ^ D[0]) ^ C[0]) ^ C[2]) ^ C[5])
		  ^ C[7]) ^ C[9]) ^ C[10]) ^ C[11]) ^ C[13]) ^ C[14]) ^ C[15]) ^
		  C[18]) ^ C[19]) ^ C[20]) ^ C[22]) ^ C[24]) ^ C[25]) ^ C[26]) ^
		  C[28]);
	  NewCRC[8] = ((((((((((((((((((((((((((((((((((((((((((((((((((D[63] ^
		  D[60]) ^ D[59]) ^ D[57]) ^ D[54]) ^ D[52]) ^ D[51]) ^ D[50]) ^
		  D[46]) ^ D[45]) ^ D[43]) ^ D[42]) ^ D[40]) ^ D[38]) ^ D[37]) ^
		  D[35]) ^ D[34]) ^ D[33]) ^ D[32]) ^ D[31]) ^ D[28]) ^ D[23]) ^
		  D[22]) ^ D[17]) ^ D[12]) ^ D[11]) ^ D[10]) ^ D[8]) ^ D[4]) ^
		  D[3]) ^ D[1]) ^ D[0]) ^ C[0]) ^ C[1]) ^ C[2]) ^ C[3]) ^ C[5])
		  ^ C[6]) ^ C[8]) ^ C[10]) ^ C[11]) ^ C[13]) ^ C[14]) ^ C[18]) ^
		  C[19]) ^ C[20]) ^ C[22]) ^ C[25]) ^ C[27]) ^ C[28]) ^ C[31]);
	  NewCRC[9] = (((((((((((((((((((((((((((((((((((((((((((((((((D[61] ^
		  D[60]) ^ D[58]) ^ D[55]) ^ D[53]) ^ D[52]) ^ D[51]) ^ D[47]) ^
		  D[46]) ^ D[44]) ^ D[43]) ^ D[41]) ^ D[39]) ^ D[38]) ^ D[36]) ^
		  D[35]) ^ D[34]) ^ D[33]) ^ D[32]) ^ D[29]) ^ D[24]) ^ D[23]) ^
		  D[18]) ^ D[13]) ^ D[12]) ^ D[11]) ^ D[9]) ^ D[5]) ^ D[4]) ^
		  D[2]) ^ D[1]) ^ C[0]) ^ C[1]) ^ C[2]) ^ C[3]) ^ C[4]) ^ C[6])
		  ^ C[7]) ^ C[9]) ^ C[11]) ^ C[12]) ^ C[14]) ^ C[15]) ^ C[19]) ^
		  C[20]) ^ C[21]) ^ C[23]) ^ C[26]) ^ C[28]) ^ C[29]);
	  NewCRC[10] = ((((((((((((((((((((((((((((((((((((((((((((D[63] ^
		  D[62]) ^ D[60]) ^ D[59]) ^ D[58]) ^ D[56]) ^ D[55]) ^ D[52]) ^
		  D[50]) ^ D[42]) ^ D[40]) ^ D[39]) ^ D[36]) ^ D[35]) ^ D[33]) ^
		  D[32]) ^ D[31]) ^ D[29]) ^ D[28]) ^ D[26]) ^ D[19]) ^ D[16]) ^
		  D[14]) ^ D[13]) ^ D[9]) ^ D[5]) ^ D[3]) ^ D[2]) ^ D[0]) ^
		  C[0]) ^ C[1]) ^ C[3]) ^ C[4]) ^ C[7]) ^ C[8]) ^ C[10]) ^
		  C[18]) ^ C[20]) ^ C[23]) ^ C[24]) ^ C[26]) ^ C[27]) ^ C[28]) ^
		  C[30]) ^ C[31]);
	  NewCRC[11] = ((((((((((((((((((((((((((((((((((((((((((((((((((D[59] ^
		  D[58]) ^ D[57]) ^ D[56]) ^ D[55]) ^ D[54]) ^ D[51]) ^ D[50]) ^
		  D[48]) ^ D[47]) ^ D[45]) ^ D[44]) ^ D[43]) ^ D[41]) ^ D[40]) ^
		  D[36]) ^ D[33]) ^ D[31]) ^ D[28]) ^ D[27]) ^ D[26]) ^ D[25]) ^
		  D[24]) ^ D[20]) ^ D[17]) ^ D[16]) ^ D[15]) ^ D[14]) ^ D[12]) ^
		  D[9]) ^ D[4]) ^ D[3]) ^ D[1]) ^ D[0]) ^ C[1]) ^ C[4]) ^ C[8])
		  ^ C[9]) ^ C[11]) ^ C[12]) ^ C[13]) ^ C[15]) ^ C[16]) ^ C[18])
		  ^ C[19]) ^ C[22]) ^ C[23]) ^ C[24]) ^ C[25]) ^ C[26]) ^ C[27])
		  ;
	  NewCRC[12] = ((((((((((((((((((((((((((((((((((((((((((((((D[63] ^
		  D[61]) ^ D[59]) ^ D[57]) ^ D[56]) ^ D[54]) ^ D[53]) ^ D[52]) ^
		  D[51]) ^ D[50]) ^ D[49]) ^ D[47]) ^ D[46]) ^ D[42]) ^ D[41]) ^
		  D[31]) ^ D[30]) ^ D[27]) ^ D[24]) ^ D[21]) ^ D[18]) ^ D[17]) ^
		  D[15]) ^ D[13]) ^ D[12]) ^ D[9]) ^ D[6]) ^ D[5]) ^ D[4]) ^
		  D[2]) ^ D[1]) ^ D[0]) ^ C[9]) ^ C[10]) ^ C[14]) ^ C[15]) ^
		  C[17]) ^ C[18]) ^ C[19]) ^ C[20]) ^ C[21]) ^ C[22]) ^ C[24]) ^
		  C[25]) ^ C[27]) ^ C[29]) ^ C[31]);
	  NewCRC[13] = (((((((((((((((((((((((((((((((((((((((((((((D[62] ^
		  D[60]) ^ D[58]) ^ D[57]) ^ D[55]) ^ D[54]) ^ D[53]) ^ D[52]) ^
		  D[51]) ^ D[50]) ^ D[48]) ^ D[47]) ^ D[43]) ^ D[42]) ^ D[32]) ^
		  D[31]) ^ D[28]) ^ D[25]) ^ D[22]) ^ D[19]) ^ D[18]) ^ D[16]) ^
		  D[14]) ^ D[13]) ^ D[10]) ^ D[7]) ^ D[6]) ^ D[5]) ^ D[3]) ^
		  D[2]) ^ D[1]) ^ C[0]) ^ C[10]) ^ C[11]) ^ C[15]) ^ C[16]) ^
		  C[18]) ^ C[19]) ^ C[20]) ^ C[21]) ^ C[22]) ^ C[23]) ^ C[25]) ^
		  C[26]) ^ C[28]) ^ C[30]);
	  NewCRC[14] = ((((((((((((((((((((((((((((((((((((((((((((((D[63] ^
		  D[61]) ^ D[59]) ^ D[58]) ^ D[56]) ^ D[55]) ^ D[54]) ^ D[53]) ^
		  D[52]) ^ D[51]) ^ D[49]) ^ D[48]) ^ D[44]) ^ D[43]) ^ D[33]) ^
		  D[32]) ^ D[29]) ^ D[26]) ^ D[23]) ^ D[20]) ^ D[19]) ^ D[17]) ^
		  D[15]) ^ D[14]) ^ D[11]) ^ D[8]) ^ D[7]) ^ D[6]) ^ D[4]) ^
		  D[3]) ^ D[2]) ^ C[0]) ^ C[1]) ^ C[11]) ^ C[12]) ^ C[16]) ^
		  C[17]) ^ C[19]) ^ C[20]) ^ C[21]) ^ C[22]) ^ C[23]) ^ C[24]) ^
		  C[26]) ^ C[27]) ^ C[29]) ^ C[31]);
	  NewCRC[15] = ((((((((((((((((((((((((((((((((((((((((((((D[62] ^
		  D[60]) ^ D[59]) ^ D[57]) ^ D[56]) ^ D[55]) ^ D[54]) ^ D[53]) ^
		  D[52]) ^ D[50]) ^ D[49]) ^ D[45]) ^ D[44]) ^ D[34]) ^ D[33]) ^
		  D[30]) ^ D[27]) ^ D[24]) ^ D[21]) ^ D[20]) ^ D[18]) ^ D[16]) ^
		  D[15]) ^ D[12]) ^ D[9]) ^ D[8]) ^ D[7]) ^ D[5]) ^ D[4]) ^
		  D[3]) ^ C[1]) ^ C[2]) ^ C[12]) ^ C[13]) ^ C[17]) ^ C[18]) ^
		  C[20]) ^ C[21]) ^ C[22]) ^ C[23]) ^ C[24]) ^ C[25]) ^ C[27]) ^
		  C[28]) ^ C[30]);
	  NewCRC[16] = (((((((((((((((((((((((((((((((((D[57] ^ D[56]) ^ D[51])
		  ^ D[48]) ^ D[47]) ^ D[46]) ^ D[44]) ^ D[37]) ^ D[35]) ^ D[32])
		  ^ D[30]) ^ D[29]) ^ D[26]) ^ D[24]) ^ D[22]) ^ D[21]) ^ D[19])
		  ^ D[17]) ^ D[13]) ^ D[12]) ^ D[8]) ^ D[5]) ^ D[4]) ^ D[0]) ^
		  C[0]) ^ C[3]) ^ C[5]) ^ C[12]) ^ C[14]) ^ C[15]) ^ C[16]) ^
		  C[19]) ^ C[24]) ^ C[25]);
	  NewCRC[17] = (((((((((((((((((((((((((((((((((D[58] ^ D[57]) ^ D[52])
		  ^ D[49]) ^ D[48]) ^ D[47]) ^ D[45]) ^ D[38]) ^ D[36]) ^ D[33])
		  ^ D[31]) ^ D[30]) ^ D[27]) ^ D[25]) ^ D[23]) ^ D[22]) ^ D[20])
		  ^ D[18]) ^ D[14]) ^ D[13]) ^ D[9]) ^ D[6]) ^ D[5]) ^ D[1]) ^
		  C[1]) ^ C[4]) ^ C[6]) ^ C[13]) ^ C[15]) ^ C[16]) ^ C[17]) ^
		  C[20]) ^ C[25]) ^ C[26]);
	  NewCRC[18] = ((((((((((((((((((((((((((((((((((D[59] ^ D[58]) ^ D[53])
		  ^ D[50]) ^ D[49]) ^ D[48]) ^ D[46]) ^ D[39]) ^ D[37]) ^ D[34])
		  ^ D[32]) ^ D[31]) ^ D[28]) ^ D[26]) ^ D[24]) ^ D[23]) ^ D[21])
		  ^ D[19]) ^ D[15]) ^ D[14]) ^ D[10]) ^ D[7]) ^ D[6]) ^ D[2]) ^
		  C[0]) ^ C[2]) ^ C[5]) ^ C[7]) ^ C[14]) ^ C[16]) ^ C[17]) ^
		  C[18]) ^ C[21]) ^ C[26]) ^ C[27]);
	  NewCRC[19] = (((((((((((((((((((((((((((((((((((D[60] ^ D[59]) ^
		  D[54]) ^ D[51]) ^ D[50]) ^ D[49]) ^ D[47]) ^ D[40]) ^ D[38]) ^
		  D[35]) ^ D[33]) ^ D[32]) ^ D[29]) ^ D[27]) ^ D[25]) ^ D[24]) ^
		  D[22]) ^ D[20]) ^ D[16]) ^ D[15]) ^ D[11]) ^ D[8]) ^ D[7]) ^
		  D[3]) ^ C[0]) ^ C[1]) ^ C[3]) ^ C[6]) ^ C[8]) ^ C[15]) ^
		  C[17]) ^ C[18]) ^ C[19]) ^ C[22]) ^ C[27]) ^ C[28]);
	  NewCRC[20] = (((((((((((((((((((((((((((((((((((D[61] ^ D[60]) ^
		  D[55]) ^ D[52]) ^ D[51]) ^ D[50]) ^ D[48]) ^ D[41]) ^ D[39]) ^
		  D[36]) ^ D[34]) ^ D[33]) ^ D[30]) ^ D[28]) ^ D[26]) ^ D[25]) ^
		  D[23]) ^ D[21]) ^ D[17]) ^ D[16]) ^ D[12]) ^ D[9]) ^ D[8]) ^
		  D[4]) ^ C[1]) ^ C[2]) ^ C[4]) ^ C[7]) ^ C[9]) ^ C[16]) ^
		  C[18]) ^ C[19]) ^ C[20]) ^ C[23]) ^ C[28]) ^ C[29]);
	  NewCRC[21] = (((((((((((((((((((((((((((((((((((D[62] ^ D[61]) ^
		  D[56]) ^ D[53]) ^ D[52]) ^ D[51]) ^ D[49]) ^ D[42]) ^ D[40]) ^
		  D[37]) ^ D[35]) ^ D[34]) ^ D[31]) ^ D[29]) ^ D[27]) ^ D[26]) ^
		  D[24]) ^ D[22]) ^ D[18]) ^ D[17]) ^ D[13]) ^ D[10]) ^ D[9]) ^
		  D[5]) ^ C[2]) ^ C[3]) ^ C[5]) ^ C[8]) ^ C[10]) ^ C[17]) ^
		  C[19]) ^ C[20]) ^ C[21]) ^ C[24]) ^ C[29]) ^ C[30]);
	  NewCRC[22] = (((((((((((((((((((((((((((((((((((((((((((((((((D[62] ^
		  D[61]) ^ D[60]) ^ D[58]) ^ D[57]) ^ D[55]) ^ D[52]) ^ D[48]) ^
		  D[47]) ^ D[45]) ^ D[44]) ^ D[43]) ^ D[41]) ^ D[38]) ^ D[37]) ^
		  D[36]) ^ D[35]) ^ D[34]) ^ D[31]) ^ D[29]) ^ D[27]) ^ D[26]) ^
		  D[24]) ^ D[23]) ^ D[19]) ^ D[18]) ^ D[16]) ^ D[14]) ^ D[12]) ^
		  D[11]) ^ D[9]) ^ D[0]) ^ C[2]) ^ C[3]) ^ C[4]) ^ C[5]) ^ C[6])
		  ^ C[9]) ^ C[11]) ^ C[12]) ^ C[13]) ^ C[15]) ^ C[16]) ^ C[20])
		  ^ C[23]) ^ C[25]) ^ C[26]) ^ C[28]) ^ C[29]) ^ C[30]);
	  NewCRC[23] = (((((((((((((((((((((((((((((((((((((((((((((D[62] ^
		  D[60]) ^ D[59]) ^ D[56]) ^ D[55]) ^ D[54]) ^ D[50]) ^ D[49]) ^
		  D[47]) ^ D[46]) ^ D[42]) ^ D[39]) ^ D[38]) ^ D[36]) ^ D[35]) ^
		  D[34]) ^ D[31]) ^ D[29]) ^ D[27]) ^ D[26]) ^ D[20]) ^ D[19]) ^
		  D[17]) ^ D[16]) ^ D[15]) ^ D[13]) ^ D[9]) ^ D[6]) ^ D[1]) ^
		  D[0]) ^ C[2]) ^ C[3]) ^ C[4]) ^ C[6]) ^ C[7]) ^ C[10]) ^
		  C[14]) ^ C[15]) ^ C[17]) ^ C[18]) ^ C[22]) ^ C[23]) ^ C[24]) ^
		  C[27]) ^ C[28]) ^ C[30]);
	  NewCRC[24] = ((((((((((((((((((((((((((((((((((((((((((((((D[63] ^
		  D[61]) ^ D[60]) ^ D[57]) ^ D[56]) ^ D[55]) ^ D[51]) ^ D[50]) ^
		  D[48]) ^ D[47]) ^ D[43]) ^ D[40]) ^ D[39]) ^ D[37]) ^ D[36]) ^
		  D[35]) ^ D[32]) ^ D[30]) ^ D[28]) ^ D[27]) ^ D[21]) ^ D[20]) ^
		  D[18]) ^ D[17]) ^ D[16]) ^ D[14]) ^ D[10]) ^ D[7]) ^ D[2]) ^
		  D[1]) ^ C[0]) ^ C[3]) ^ C[4]) ^ C[5]) ^ C[7]) ^ C[8]) ^ C[11])
		  ^ C[15]) ^ C[16]) ^ C[18]) ^ C[19]) ^ C[23]) ^ C[24]) ^ C[25])
		  ^ C[28]) ^ C[29]) ^ C[31]);
	  NewCRC[25] = ((((((((((((((((((((((((((((((((((((((((((((D[62] ^
		  D[61]) ^ D[58]) ^ D[57]) ^ D[56]) ^ D[52]) ^ D[51]) ^ D[49]) ^
		  D[48]) ^ D[44]) ^ D[41]) ^ D[40]) ^ D[38]) ^ D[37]) ^ D[36]) ^
		  D[33]) ^ D[31]) ^ D[29]) ^ D[28]) ^ D[22]) ^ D[21]) ^ D[19]) ^
		  D[18]) ^ D[17]) ^ D[15]) ^ D[11]) ^ D[8]) ^ D[3]) ^ D[2]) ^
		  C[1]) ^ C[4]) ^ C[5]) ^ C[6]) ^ C[8]) ^ C[9]) ^ C[12]) ^
		  C[16]) ^ C[17]) ^ C[19]) ^ C[20]) ^ C[24]) ^ C[25]) ^ C[26]) ^
		  C[29]) ^ C[30]);
	  NewCRC[26] = ((((((((((((((((((((((((((((((((((((((((((((((D[62] ^
		  D[61]) ^ D[60]) ^ D[59]) ^ D[57]) ^ D[55]) ^ D[54]) ^ D[52]) ^
		  D[49]) ^ D[48]) ^ D[47]) ^ D[44]) ^ D[42]) ^ D[41]) ^ D[39]) ^
		  D[38]) ^ D[31]) ^ D[28]) ^ D[26]) ^ D[25]) ^ D[24]) ^ D[23]) ^
		  D[22]) ^ D[20]) ^ D[19]) ^ D[18]) ^ D[10]) ^ D[6]) ^ D[4]) ^
		  D[3]) ^ D[0]) ^ C[6]) ^ C[7]) ^ C[9]) ^ C[10]) ^ C[12]) ^
		  C[15]) ^ C[16]) ^ C[17]) ^ C[20]) ^ C[22]) ^ C[23]) ^ C[25]) ^
		  C[27]) ^ C[28]) ^ C[29]) ^ C[30]);
	  NewCRC[27] = (((((((((((((((((((((((((((((((((((((((((((((((D[63] ^
		  D[62]) ^ D[61]) ^ D[60]) ^ D[58]) ^ D[56]) ^ D[55]) ^ D[53]) ^
		  D[50]) ^ D[49]) ^ D[48]) ^ D[45]) ^ D[43]) ^ D[42]) ^ D[40]) ^
		  D[39]) ^ D[32]) ^ D[29]) ^ D[27]) ^ D[26]) ^ D[25]) ^ D[24]) ^
		  D[23]) ^ D[21]) ^ D[20]) ^ D[19]) ^ D[11]) ^ D[7]) ^ D[5]) ^
		  D[4]) ^ D[1]) ^ C[0]) ^ C[7]) ^ C[8]) ^ C[10]) ^ C[11]) ^
		  C[13]) ^ C[16]) ^ C[17]) ^ C[18]) ^ C[21]) ^ C[23]) ^ C[24]) ^
		  C[26]) ^ C[28]) ^ C[29]) ^ C[30]) ^ C[31]);
	  NewCRC[28] = (((((((((((((((((((((((((((((((((((((((((((((D[63] ^
		  D[62]) ^ D[61]) ^ D[59]) ^ D[57]) ^ D[56]) ^ D[54]) ^ D[51]) ^
		  D[50]) ^ D[49]) ^ D[46]) ^ D[44]) ^ D[43]) ^ D[41]) ^ D[40]) ^
		  D[33]) ^ D[30]) ^ D[28]) ^ D[27]) ^ D[26]) ^ D[25]) ^ D[24]) ^
		  D[22]) ^ D[21]) ^ D[20]) ^ D[12]) ^ D[8]) ^ D[6]) ^ D[5]) ^
		  D[2]) ^ C[1]) ^ C[8]) ^ C[9]) ^ C[11]) ^ C[12]) ^ C[14]) ^
		  C[17]) ^ C[18]) ^ C[19]) ^ C[22]) ^ C[24]) ^ C[25]) ^ C[27]) ^
		  C[29]) ^ C[30]) ^ C[31]);
	  NewCRC[29] = (((((((((((((((((((((((((((((((((((((((((((D[63] ^ D[62])
		  ^ D[60]) ^ D[58]) ^ D[57]) ^ D[55]) ^ D[52]) ^ D[51]) ^ D[50])
		  ^ D[47]) ^ D[45]) ^ D[44]) ^ D[42]) ^ D[41]) ^ D[34]) ^ D[31])
		  ^ D[29]) ^ D[28]) ^ D[27]) ^ D[26]) ^ D[25]) ^ D[23]) ^ D[22])
		  ^ D[21]) ^ D[13]) ^ D[9]) ^ D[7]) ^ D[6]) ^ D[3]) ^ C[2]) ^
		  C[9]) ^ C[10]) ^ C[12]) ^ C[13]) ^ C[15]) ^ C[18]) ^ C[19]) ^
		  C[20]) ^ C[23]) ^ C[25]) ^ C[26]) ^ C[28]) ^ C[30]) ^ C[31]);
	  NewCRC[30] = ((((((((((((((((((((((((((((((((((((((((((D[63] ^ D[61])
		  ^ D[59]) ^ D[58]) ^ D[56]) ^ D[53]) ^ D[52]) ^ D[51]) ^ D[48])
		  ^ D[46]) ^ D[45]) ^ D[43]) ^ D[42]) ^ D[35]) ^ D[32]) ^ D[30])
		  ^ D[29]) ^ D[28]) ^ D[27]) ^ D[26]) ^ D[24]) ^ D[23]) ^ D[22])
		  ^ D[14]) ^ D[10]) ^ D[8]) ^ D[7]) ^ D[4]) ^ C[0]) ^ C[3]) ^
		  C[10]) ^ C[11]) ^ C[13]) ^ C[14]) ^ C[16]) ^ C[19]) ^ C[20]) ^
		  C[21]) ^ C[24]) ^ C[26]) ^ C[27]) ^ C[29]) ^ C[31]);
	  NewCRC[31] = ((((((((((((((((((((((((((((((((((((((((D[62] ^ D[60]) ^
		  D[59]) ^ D[57]) ^ D[54]) ^ D[53]) ^ D[52]) ^ D[49]) ^ D[47]) ^
		  D[46]) ^ D[44]) ^ D[43]) ^ D[36]) ^ D[33]) ^ D[31]) ^ D[30]) ^
		  D[29]) ^ D[28]) ^ D[27]) ^ D[25]) ^ D[24]) ^ D[23]) ^ D[15]) ^
		  D[11]) ^ D[9]) ^ D[8]) ^ D[5]) ^ C[1]) ^ C[4]) ^ C[11]) ^
		  C[12]) ^ C[14]) ^ C[15]) ^ C[17]) ^ C[20]) ^ C[21]) ^ C[22]) ^
		  C[25]) ^ C[27]) ^ C[28]) ^ C[30]);
	  nextCRC32_D64 = NewCRC;
	end
	endfunction

	function [31:0] nextCRC32_D8;
	input logic
		[7:0]		Data;
	input logic
		[31:0]		CRC;

	reg	[7:0]		D;
	reg	[31:0]		C;
	reg	[31:0]		NewCRC;
	begin
	  D = Data;
	  C = CRC;
	  NewCRC[0] = (((D[6] ^ D[0]) ^ C[24]) ^ C[30]);
	  NewCRC[1] = (((((((D[7] ^ D[6]) ^ D[1]) ^ D[0]) ^ C[24]) ^ C[25]) ^
		  C[30]) ^ C[31]);
	  NewCRC[2] = (((((((((D[7] ^ D[6]) ^ D[2]) ^ D[1]) ^ D[0]) ^ C[24]) ^
		  C[25]) ^ C[26]) ^ C[30]) ^ C[31]);
	  NewCRC[3] = (((((((D[7] ^ D[3]) ^ D[2]) ^ D[1]) ^ C[25]) ^ C[26]) ^
		  C[27]) ^ C[31]);
	  NewCRC[4] = (((((((((D[6] ^ D[4]) ^ D[3]) ^ D[2]) ^ D[0]) ^ C[24]) ^
		  C[26]) ^ C[27]) ^ C[28]) ^ C[30]);
	  NewCRC[5] = (((((((((((((D[7] ^ D[6]) ^ D[5]) ^ D[4]) ^ D[3]) ^ D[1])
		  ^ D[0]) ^ C[24]) ^ C[25]) ^ C[27]) ^ C[28]) ^ C[29]) ^ C[30])
		  ^ C[31]);
	  NewCRC[6] = (((((((((((D[7] ^ D[6]) ^ D[5]) ^ D[4]) ^ D[2]) ^ D[1]) ^
		  C[25]) ^ C[26]) ^ C[28]) ^ C[29]) ^ C[30]) ^ C[31]);
	  NewCRC[7] = (((((((((D[7] ^ D[5]) ^ D[3]) ^ D[2]) ^ D[0]) ^ C[24]) ^
		  C[26]) ^ C[27]) ^ C[29]) ^ C[31]);
	  NewCRC[8] = ((((((((D[4] ^ D[3]) ^ D[1]) ^ D[0]) ^ C[0]) ^ C[24]) ^
		  C[25]) ^ C[27]) ^ C[28]);
	  NewCRC[9] = ((((((((D[5] ^ D[4]) ^ D[2]) ^ D[1]) ^ C[1]) ^ C[25]) ^
		  C[26]) ^ C[28]) ^ C[29]);
	  NewCRC[10] = ((((((((D[5] ^ D[3]) ^ D[2]) ^ D[0]) ^ C[2]) ^ C[24]) ^
		  C[26]) ^ C[27]) ^ C[29]);
	  NewCRC[11] = ((((((((D[4] ^ D[3]) ^ D[1]) ^ D[0]) ^ C[3]) ^ C[24]) ^
		  C[25]) ^ C[27]) ^ C[28]);
	  NewCRC[12] = ((((((((((((D[6] ^ D[5]) ^ D[4]) ^ D[2]) ^ D[1]) ^ D[0])
		  ^ C[4]) ^ C[24]) ^ C[25]) ^ C[26]) ^ C[28]) ^ C[29]) ^ C[30]);
	  NewCRC[13] = ((((((((((((D[7] ^ D[6]) ^ D[5]) ^ D[3]) ^ D[2]) ^ D[1])
		  ^ C[5]) ^ C[25]) ^ C[26]) ^ C[27]) ^ C[29]) ^ C[30]) ^ C[31]);
	  NewCRC[14] = ((((((((((D[7] ^ D[6]) ^ D[4]) ^ D[3]) ^ D[2]) ^ C[6]) ^
		  C[26]) ^ C[27]) ^ C[28]) ^ C[30]) ^ C[31]);
	  NewCRC[15] = ((((((((D[7] ^ D[5]) ^ D[4]) ^ D[3]) ^ C[7]) ^ C[27]) ^
		  C[28]) ^ C[29]) ^ C[31]);
	  NewCRC[16] = ((((((D[5] ^ D[4]) ^ D[0]) ^ C[8]) ^ C[24]) ^ C[28]) ^
		  C[29]);
	  NewCRC[17] = ((((((D[6] ^ D[5]) ^ D[1]) ^ C[9]) ^ C[25]) ^ C[29]) ^
		  C[30]);
	  NewCRC[18] = ((((((D[7] ^ D[6]) ^ D[2]) ^ C[10]) ^ C[26]) ^ C[30]) ^
		  C[31]);
	  NewCRC[19] = ((((D[7] ^ D[3]) ^ C[11]) ^ C[27]) ^ C[31]);
	  NewCRC[20] = ((D[4] ^ C[12]) ^ C[28]);
	  NewCRC[21] = ((D[5] ^ C[13]) ^ C[29]);
	  NewCRC[22] = ((D[0] ^ C[14]) ^ C[24]);
	  NewCRC[23] = ((((((D[6] ^ D[1]) ^ D[0]) ^ C[15]) ^ C[24]) ^ C[25]) ^
		  C[30]);
	  NewCRC[24] = ((((((D[7] ^ D[2]) ^ D[1]) ^ C[16]) ^ C[25]) ^ C[26]) ^
		  C[31]);
	  NewCRC[25] = ((((D[3] ^ D[2]) ^ C[17]) ^ C[26]) ^ C[27]);
	  NewCRC[26] = ((((((((D[6] ^ D[4]) ^ D[3]) ^ D[0]) ^ C[18]) ^ C[24]) ^
		  C[27]) ^ C[28]) ^ C[30]);
	  NewCRC[27] = ((((((((D[7] ^ D[5]) ^ D[4]) ^ D[1]) ^ C[19]) ^ C[25]) ^
		  C[28]) ^ C[29]) ^ C[31]);
	  NewCRC[28] = ((((((D[6] ^ D[5]) ^ D[2]) ^ C[20]) ^ C[26]) ^ C[29]) ^
		  C[30]);
	  NewCRC[29] = ((((((D[7] ^ D[6]) ^ D[3]) ^ C[21]) ^ C[27]) ^ C[30]) ^
		  C[31]);
	  NewCRC[30] = ((((D[7] ^ D[4]) ^ C[22]) ^ C[28]) ^ C[31]);
	  NewCRC[31] = ((D[5] ^ C[23]) ^ C[29]);
	  nextCRC32_D8 = NewCRC;
	end
	endfunction

	function [63:0] reverse_64b;
	input logic
		[63:0]		data;

	integer			i;
	begin
	  for (i = 0; (i < 64); i = (i + 1)) begin
	    reverse_64b[i] = data[(63 - i)];
	  end
	end
	endfunction

	function [31:0] reverse_32b;
	input logic
		[31:0]		data;

	integer			i;
	begin
	  for (i = 0; (i < 32); i = (i + 1)) begin
	    reverse_32b[i] = data[(31 - i)];
	  end
	end
	endfunction

	function [7:0] reverse_8b;
	input logic
		[7:0]		data;

	integer			i;
	begin
	  for (i = 0; (i < 8); i = (i + 1)) begin
	    reverse_8b[i] = data[(7 - i)];
	  end
	end
	endfunction

	always @(posedge clk_xgmii_tx or negedge reset_xgmii_tx_n) begin
	  if (reset_xgmii_tx_n == 1'b0) begin
	    xgmii_txd <= {8 {8'h07}};
	    xgmii_txc <= 8'hff;
	  end
	  else
	    begin
	      if (status_local_fault_ctx) begin
		xgmii_txd <= {8'd2, 8'b0, 8'b0, 8'h9c, 8'd2, 8'b0, 8'b0, 8'h9c};
		xgmii_txc <= {4'b1, 4'b1};
	      end
	      else if (status_remote_fault_ctx) begin
		xgmii_txd <= {8 {8'h07}};
		xgmii_txc <= 8'hff;
	      end
	      else
		begin
		  xgmii_txd <= xgxs_txd;
		  xgmii_txc <= xgxs_txc;
		end
	    end
	end
	always @(posedge clk_xgmii_tx or negedge reset_xgmii_tx_n) begin
	  if (reset_xgmii_tx_n == 1'b0) begin
	    curr_state_enc <= SM_IDLE;
	    start_on_lane0 <= 1'b1;
	    ifg_deficit <= 3'b0;
	    ifg_4b_add <= 1'b0;
	    ifg_8b_add <= 1'b0;
	    ifg_8b2_add <= 1'b0;
	    eop <= 8'b0;
	    txhfifo_rdata_d1 <= 64'b0;
	    xgxs_txd_barrel <= {4 {8'h07}};
	    xgxs_txc_barrel <= 4'hf;
	    frame_available <= 1'b0;
	    xgxs_txd <= {8 {8'h07}};
	    xgxs_txc <= 8'hff;
	    status_txdfifo_udflow_tog <= 1'b0;
	    txsfifo_wen <= 1'b0;
	    txsfifo_wdata <= 14'b0;
	  end
	  else
	    begin
	      curr_state_enc <= next_state_enc;
	      start_on_lane0 <= next_start_on_lane0;
	      ifg_deficit <= next_ifg_deficit;
	      ifg_4b_add <= next_ifg_4b_add;
	      ifg_8b_add <= next_ifg_8b_add;
	      ifg_8b2_add <= next_ifg_8b2_add;
	      eop <= next_eop;
	      txhfifo_rdata_d1 <= txhfifo_rdata;
	      xgxs_txd_barrel <= next_xgxs_txd[63:32];
	      xgxs_txc_barrel <= next_xgxs_txc[7:4];
	      frame_available <= next_frame_available;
	      txsfifo_wen <= 1'b0;
	      txsfifo_wdata <= byte_cnt;
	      if (next_start_on_lane0) begin
		xgxs_txd <= next_xgxs_txd;
		xgxs_txc <= next_xgxs_txc;
	      end
	      else
		begin
		  xgxs_txd <= {next_xgxs_txd[31:0], xgxs_txd_barrel};
		  xgxs_txc <= {next_xgxs_txc[3:0], xgxs_txc_barrel};
		end
	      if (txdfifo_ren && txdfifo_rempty) begin
		status_txdfifo_udflow_tog <= (~status_txdfifo_udflow_tog);
	      end
	      if (frame_end) begin
		txsfifo_wen <= 1'b1;
	      end
	    end
	end
	always @(crc32_tx or ctrl_tx_enable_ctx or curr_state_enc or eop or 
		frame_available or ifg_4b_add or ifg_8b2_add or ifg_8b_add or 
		ifg_deficit or start_on_lane0 or status_local_fault_ctx or 
		status_remote_fault_ctx or txhfifo_ralmost_empty or 
		txhfifo_rdata_d1 or txhfifo_rempty or txhfifo_rstatus) begin
	  next_state_enc = curr_state_enc;
	  next_start_on_lane0 = start_on_lane0;
	  next_ifg_deficit = ifg_deficit;
	  next_ifg_4b_add = ifg_4b_add;
	  next_ifg_8b_add = ifg_8b_add;
	  next_ifg_8b2_add = ifg_8b2_add;
	  next_eop = eop;
	  next_xgxs_txd = {8 {8'h07}};
	  next_xgxs_txc = 8'hff;
	  txhfifo_ren = 1'b0;
	  next_frame_available = frame_available;
	  case (curr_state_enc)
	    SM_IDLE: begin
	      if (((ctrl_tx_enable_ctx && frame_available) && (!
		      status_local_fault_ctx)) && (!status_remote_fault_ctx)) 
		      begin
		txhfifo_ren = 1'b1;
		next_state_enc = SM_PREAMBLE;
	      end
	      else
		begin
		  next_frame_available = (!txhfifo_ralmost_empty);
		  next_ifg_4b_add = 1'b0;
		end
	    end
	    SM_PREAMBLE: begin
	      if (txhfifo_rstatus[3'd7]) begin
		next_xgxs_txd = {8'hd5, {6 {8'h55}}, 8'hfb};
		next_xgxs_txc = 8'b1;
		txhfifo_ren = 1'b1;
		next_state_enc = SM_TX;
	      end
	      else
		begin
		  next_frame_available = 1'b0;
		  next_state_enc = SM_IDLE;
		end
	      if (ifg_4b_add) begin
		next_start_on_lane0 = 1'b0;
	      end
	      else
		begin
		  next_start_on_lane0 = 1'b1;
		end
	    end
	    SM_TX: begin
	      next_xgxs_txd = txhfifo_rdata_d1;
	      next_xgxs_txc = 8'b0;
	      txhfifo_ren = 1'b1;
	      if (txhfifo_rstatus[3'd6]) begin
		txhfifo_ren = 1'b0;
		next_frame_available = (!txhfifo_ralmost_empty);
		next_state_enc = SM_EOP;
	      end
	      else if (txhfifo_rempty || txhfifo_rstatus[3'd7]) begin
		next_state_enc = SM_TERM_FAIL;
	      end
	      next_eop[0] = (txhfifo_rstatus[2:0] == 3'b1);
	      next_eop[1] = (txhfifo_rstatus[2:0] == 3'd2);
	      next_eop[2] = (txhfifo_rstatus[2:0] == 3'd3);
	      next_eop[3] = (txhfifo_rstatus[2:0] == 3'd4);
	      next_eop[4] = (txhfifo_rstatus[2:0] == 3'd5);
	      next_eop[5] = (txhfifo_rstatus[2:0] == 3'd6);
	      next_eop[6] = (txhfifo_rstatus[2:0] == 3'd7);
	      next_eop[7] = (txhfifo_rstatus[2:0] == 3'b0);
	    end
	    SM_EOP: begin
	      if (eop[0]) begin
		next_xgxs_txd = {{2 {8'h07}}, 8'hfd, crc32_tx[31:0],
			txhfifo_rdata_d1[7:0]};
		next_xgxs_txc = 8'b11100000;
	      end
	      if (eop[1]) begin
		next_xgxs_txd = {8'h07, 8'hfd, crc32_tx[31:0],
			txhfifo_rdata_d1[15:0]};
		next_xgxs_txc = 8'b11000000;
	      end
	      if (eop[2]) begin
		next_xgxs_txd = {8'hfd, crc32_tx[31:0], txhfifo_rdata_d1[23:0]};
		next_xgxs_txc = 8'b10000000;
	      end
	      if (eop[3]) begin
		next_xgxs_txd = {crc32_tx[31:0], txhfifo_rdata_d1[31:0]};
		next_xgxs_txc = 8'b0;
	      end
	      if (eop[4]) begin
		next_xgxs_txd = {crc32_tx[23:0], txhfifo_rdata_d1[39:0]};
		next_xgxs_txc = 8'b0;
	      end
	      if (eop[5]) begin
		next_xgxs_txd = {crc32_tx[15:0], txhfifo_rdata_d1[47:0]};
		next_xgxs_txc = 8'b0;
	      end
	      if (eop[6]) begin
		next_xgxs_txd = {crc32_tx[7:0], txhfifo_rdata_d1[55:0]};
		next_xgxs_txc = 8'b0;
	      end
	      if (eop[7]) begin
		next_xgxs_txd = {txhfifo_rdata_d1[63:0]};
		next_xgxs_txc = 8'b0;
	      end
	      if (!frame_available) begin
		next_ifg_deficit = 3'b0;
	      end
	      else
		begin
		  next_ifg_deficit = (((ifg_deficit + {2'b0, (eop[0] | eop[4])})
			  + {1'b0, (eop[1] | eop[5]), 1'b0}) + {1'b0, (eop[2] |
			  eop[6]), (eop[2] | eop[6])});
		end
	      if (!frame_available) begin
		next_ifg_4b_add = 1'b0;
		next_ifg_8b_add = 1'b0;
		next_ifg_8b2_add = 1'b0;
	      end
	      else if (next_ifg_deficit[2] == ifg_deficit[2]) begin
		next_ifg_4b_add = ((((((((eop[0] & (!start_on_lane0)) | (eop[1]
			& (!start_on_lane0))) | (eop[2] & (!start_on_lane0))) |
			(eop[3] & start_on_lane0)) | (eop[4] & start_on_lane0))
			| (eop[5] & start_on_lane0)) | (eop[6] &
			start_on_lane0)) | (eop[7] & (!start_on_lane0)));
		next_ifg_8b_add = (((((((eop[0] | eop[1]) | eop[2]) | (eop[3] &
			(!start_on_lane0))) | (eop[4] & (!start_on_lane0))) |
			(eop[5] & (!start_on_lane0))) | (eop[6] &
			(!start_on_lane0))) | eop[7]);
		next_ifg_8b2_add = 1'b0;
	      end
	      else
		begin
		  next_ifg_4b_add = ((((((((eop[0] & start_on_lane0) | (eop[1] &
			  start_on_lane0)) | (eop[2] & start_on_lane0)) |
			  (eop[3] & start_on_lane0)) | (eop[4] &
			  (!start_on_lane0))) | (eop[5] & (!start_on_lane0))) |
			  (eop[6] & (!start_on_lane0))) | (eop[7] &
			  (!start_on_lane0)));
		  next_ifg_8b_add = (((((((eop[0] | eop[1]) | eop[2]) | (eop[3]
			  & (!start_on_lane0))) | eop[4]) | eop[5]) | eop[6]) |
			  eop[7]);
		  next_ifg_8b2_add = (((eop[0] & (!start_on_lane0)) | (eop[1] &
			  (!start_on_lane0))) | (eop[2] & (!start_on_lane0)));
		end
	      if (|eop[2:0]) begin
		if (frame_available) begin
		  if (next_ifg_8b2_add) begin
		    next_state_enc = SM_IFG;
		  end
		  else if (next_ifg_8b_add) begin
		    next_state_enc = SM_IDLE;
		  end
		  else
		    begin
		      txhfifo_ren = 1'b1;
		      next_state_enc = SM_PREAMBLE;
		    end
		end
		else
		  begin
		    next_state_enc = SM_IFG;
		  end
	      end
	      if (|eop[7:3]) begin
		next_state_enc = SM_TERM;
	      end
	    end
	    SM_TERM: begin
	      if (eop[3]) begin
		next_xgxs_txd = {{7 {8'h07}}, 8'hfd};
		next_xgxs_txc = 8'b11111111;
	      end
	      if (eop[4]) begin
		next_xgxs_txd = {{6 {8'h07}}, 8'hfd, crc32_tx[31:24]};
		next_xgxs_txc = 8'b11111110;
	      end
	      if (eop[5]) begin
		next_xgxs_txd = {{5 {8'h07}}, 8'hfd, crc32_tx[31:16]};
		next_xgxs_txc = 8'b11111100;
	      end
	      if (eop[6]) begin
		next_xgxs_txd = {{4 {8'h07}}, 8'hfd, crc32_tx[31:8]};
		next_xgxs_txc = 8'b11111000;
	      end
	      if (eop[7]) begin
		next_xgxs_txd = {{3 {8'h07}}, 8'hfd, crc32_tx[31:0]};
		next_xgxs_txc = 8'b11110000;
	      end
	      if (frame_available && (!ifg_8b_add)) begin
		txhfifo_ren = 1'b1;
		next_state_enc = SM_PREAMBLE;
	      end
	      else if (frame_available) begin
		next_state_enc = SM_IDLE;
	      end
	      else
		begin
		  next_state_enc = SM_IFG;
		end
	    end
	    SM_TERM_FAIL: begin
	      next_xgxs_txd = {{7 {8'h07}}, 8'hfd};
	      next_xgxs_txc = 8'b11111111;
	      next_state_enc = SM_IFG;
	    end
	    SM_IFG: begin
	      next_state_enc = SM_IDLE;
	    end
	    default: begin
	      next_state_enc = SM_IDLE;
	    end
	  endcase
	end
	always @(crc32_d64 or next_txhfifo_wstatus or txhfifo_wen or 
		txhfifo_wstatus) begin
	  if (txhfifo_wen && txhfifo_wstatus[3'd7]) begin
	    crc_data = 32'hffffffff;
	  end
	  else
	    begin
	      crc_data = crc32_d64;
	    end
	  if (next_txhfifo_wstatus[3'd6] && (next_txhfifo_wstatus[2:0] != 3'b0))
		  begin
	    add_cnt = {11'b0, next_txhfifo_wstatus[2:0]};
	  end
	  else
	    begin
	      add_cnt = 14'd8;
	    end
	end
	always @(byte_cnt or curr_state_pad or txdfifo_rdata or txdfifo_rempty
		or txdfifo_ren_d1 or txdfifo_rstatus or txhfifo_walmost_full) 
		begin
	  next_state_pad = curr_state_pad;
	  next_txhfifo_wdata = txdfifo_rdata;
	  next_txhfifo_wstatus = txdfifo_rstatus;
	  txdfifo_ren = 1'b0;
	  next_txhfifo_wen = 1'b0;
	  case (curr_state_pad)
	    SM_PAD_EQ: begin
	      if (!txhfifo_walmost_full) begin
		txdfifo_ren = (!txdfifo_rempty);
	      end
	      if (txdfifo_ren_d1) begin
		next_txhfifo_wen = 1'b1;
		if (txdfifo_rstatus[3'd6]) begin
		  if (byte_cnt < 14'd60) begin
		    next_txhfifo_wstatus = 8'b0;
		    txdfifo_ren = 1'b0;
		    next_state_pad = SM_PAD_PAD;
		  end
		  else if ((byte_cnt == 14'd60) && (((txdfifo_rstatus[2:0] == 
			  3'b1) || (txdfifo_rstatus[2:0] == 3'd2)) || (
			  txdfifo_rstatus[2:0] == 3'd3))) begin
		    next_txhfifo_wstatus[2:0] = 3'd4;
		    if (txdfifo_rstatus[2:0] == 3'b1) begin
		      next_txhfifo_wdata[31:8] = 24'b0;
		    end
		    if (txdfifo_rstatus[2:0] == 3'd2) begin
		      next_txhfifo_wdata[31:16] = 16'b0;
		    end
		    if (txdfifo_rstatus[2:0] == 3'd3) begin
		      next_txhfifo_wdata[31:24] = 8'b0;
		    end
		    txdfifo_ren = 1'b0;
		  end
		  else
		    begin
		      txdfifo_ren = 1'b0;
		    end
		end
	      end
	    end
	    SM_PAD_PAD: begin
	      if (!txhfifo_walmost_full) begin
		next_txhfifo_wdata = 64'b0;
		next_txhfifo_wstatus = 8'b0;
		next_txhfifo_wen = 1'b1;
		if (byte_cnt == 14'd60) begin
		  next_txhfifo_wstatus[3'd6] = 1'b1;
		  next_txhfifo_wstatus[2:0] = 3'd4;
		  next_state_pad = SM_PAD_EQ;
		end
	      end
	    end
	    default: begin
	      next_state_pad = SM_PAD_EQ;
	    end
	  endcase
	end
	always @(posedge clk_xgmii_tx or negedge reset_xgmii_tx_n) begin
	  if (reset_xgmii_tx_n == 1'b0) begin
	    curr_state_pad <= SM_PAD_EQ;
	    txdfifo_ren_d1 <= 1'b0;
	    txhfifo_wdata <= 64'b0;
	    txhfifo_wstatus <= 8'b0;
	    txhfifo_wen <= 1'b0;
	    byte_cnt <= 14'b0;
	    shift_crc_data <= 64'b0;
	    shift_crc_eop <= 4'b0;
	    shift_crc_cnt <= 4'b0;
	    crc32_d64 <= 32'b0;
	    crc32_d8 <= 32'b0;
	    crc32_tx <= 32'b0;
	    frame_end <= 1'b0;
	  end
	  else
	    begin
	      curr_state_pad <= next_state_pad;
	      txdfifo_ren_d1 <= txdfifo_ren;
	      txhfifo_wdata <= next_txhfifo_wdata;
	      txhfifo_wstatus <= next_txhfifo_wstatus;
	      txhfifo_wen <= next_txhfifo_wen;
	      frame_end <= 1'b0;
	      if (next_txhfifo_wen) begin
		if (next_txhfifo_wstatus[3'd7]) begin
		  byte_cnt <= 14'd12;
		end
		else
		  begin
		    byte_cnt <= (byte_cnt + add_cnt);
		  end
		frame_end <= next_txhfifo_wstatus[3'd6];
	      end
	      if (txhfifo_wen) begin
		crc32_d64 <= nextCRC32_D64(reverse_64b(txhfifo_wdata), crc_data)
			;
	      end
	      if (txhfifo_wen && txhfifo_wstatus[3'd6]) begin
		crc32_d8 <= crc32_d64;
		shift_crc_data <= txhfifo_wdata;
		shift_crc_cnt <= 4'd9;
		if (txhfifo_wstatus[2:0] == 3'b0) begin
		  shift_crc_eop <= 4'd8;
		end
		else
		  begin
		    shift_crc_eop <= {1'b0, txhfifo_wstatus[2:0]};
		  end
	      end
	      else if (shift_crc_eop != 4'b0) begin
		crc32_d8 <= nextCRC32_D8(reverse_8b(shift_crc_data[7:0]),
			crc32_d8);
		shift_crc_data <= {8'b0, shift_crc_data[63:8]};
		shift_crc_eop <= (shift_crc_eop - 4'b1);
	      end
	      if (shift_crc_cnt == 4'b1) begin
		crc32_tx <= (~reverse_32b(crc32_d8));
	      end
	      else
		begin
		  shift_crc_cnt <= (shift_crc_cnt - 4'b1);
		end
	    end
	end
endmodule

/*
                    instances: 0
                        nodes: 16 (0)
                  node widths: 151 (0)
                      process: 2 (0)
                   contassign:  1 (0)
                        ports: 14 (0)
*/


module tx_enqueue(pkt_tx_full, txdfifo_wdata, txdfifo_wstatus, txdfifo_wen,
	status_txdfifo_ovflow_tog, clk_156m25, reset_156m25_n, pkt_tx_data,
	pkt_tx_val, pkt_tx_sop, pkt_tx_eop, pkt_tx_mod, txdfifo_wfull,
	txdfifo_walmost_full);
	input			clk_156m25;
	input			reset_156m25_n;
	input	[63:0]		pkt_tx_data;
	input			pkt_tx_val;
	input			pkt_tx_sop;
	input			pkt_tx_eop;
	input	[2:0]		pkt_tx_mod;
	input			txdfifo_wfull;
	input			txdfifo_walmost_full;
	output			pkt_tx_full;
	output			status_txdfifo_ovflow_tog;

	reg			status_txdfifo_ovflow_tog;
	output	[63:0]		txdfifo_wdata;
	reg	[63:0]		txdfifo_wdata;
	output			txdfifo_wen;
	reg			txdfifo_wen;
	output	[7:0]		txdfifo_wstatus;
	reg	[7:0]		txdfifo_wstatus;
	reg			txd_ovflow;
	reg			next_txd_ovflow;

	assign pkt_tx_full = txdfifo_walmost_full;

	function [31:0] nextCRC32_D64;
	input logic
		[63:0]		Data;
	input logic
		[31:0]		CRC;

	reg	[63:0]		D;
	reg	[31:0]		C;
	reg	[31:0]		NewCRC;
	begin
	  D = Data;
	  C = CRC;
	  NewCRC[0] = ((((((((((((((((((((((((((((((((((((((((((D[63] ^ D[61]) ^
		  D[60]) ^ D[58]) ^ D[55]) ^ D[54]) ^ D[53]) ^ D[50]) ^ D[48]) ^
		  D[47]) ^ D[45]) ^ D[44]) ^ D[37]) ^ D[34]) ^ D[32]) ^ D[31]) ^
		  D[30]) ^ D[29]) ^ D[28]) ^ D[26]) ^ D[25]) ^ D[24]) ^ D[16]) ^
		  D[12]) ^ D[10]) ^ D[9]) ^ D[6]) ^ D[0]) ^ C[0]) ^ C[2]) ^
		  C[5]) ^ C[12]) ^ C[13]) ^ C[15]) ^ C[16]) ^ C[18]) ^ C[21]) ^
		  C[22]) ^ C[23]) ^ C[26]) ^ C[28]) ^ C[29]) ^ C[31]);
	  NewCRC[1] = ((((((((((((((((((((((((((((((((((((((((((((((((D[63] ^
		  D[62]) ^ D[60]) ^ D[59]) ^ D[58]) ^ D[56]) ^ D[53]) ^ D[51]) ^
		  D[50]) ^ D[49]) ^ D[47]) ^ D[46]) ^ D[44]) ^ D[38]) ^ D[37]) ^
		  D[35]) ^ D[34]) ^ D[33]) ^ D[28]) ^ D[27]) ^ D[24]) ^ D[17]) ^
		  D[16]) ^ D[13]) ^ D[12]) ^ D[11]) ^ D[9]) ^ D[7]) ^ D[6]) ^
		  D[1]) ^ D[0]) ^ C[1]) ^ C[2]) ^ C[3]) ^ C[5]) ^ C[6]) ^ C[12])
		  ^ C[14]) ^ C[15]) ^ C[17]) ^ C[18]) ^ C[19]) ^ C[21]) ^ C[24])
		  ^ C[26]) ^ C[27]) ^ C[28]) ^ C[30]) ^ C[31]);
	  NewCRC[2] = (((((((((((((((((((((((((((((((((((((((((((D[59] ^ D[58])
		  ^ D[57]) ^ D[55]) ^ D[53]) ^ D[52]) ^ D[51]) ^ D[44]) ^ D[39])
		  ^ D[38]) ^ D[37]) ^ D[36]) ^ D[35]) ^ D[32]) ^ D[31]) ^ D[30])
		  ^ D[26]) ^ D[24]) ^ D[18]) ^ D[17]) ^ D[16]) ^ D[14]) ^ D[13])
		  ^ D[9]) ^ D[8]) ^ D[7]) ^ D[6]) ^ D[2]) ^ D[1]) ^ D[0]) ^
		  C[0]) ^ C[3]) ^ C[4]) ^ C[5]) ^ C[6]) ^ C[7]) ^ C[12]) ^
		  C[19]) ^ C[20]) ^ C[21]) ^ C[23]) ^ C[25]) ^ C[26]) ^ C[27]);
	  NewCRC[3] = ((((((((((((((((((((((((((((((((((((((((((((D[60] ^ D[59])
		  ^ D[58]) ^ D[56]) ^ D[54]) ^ D[53]) ^ D[52]) ^ D[45]) ^ D[40])
		  ^ D[39]) ^ D[38]) ^ D[37]) ^ D[36]) ^ D[33]) ^ D[32]) ^ D[31])
		  ^ D[27]) ^ D[25]) ^ D[19]) ^ D[18]) ^ D[17]) ^ D[15]) ^ D[14])
		  ^ D[10]) ^ D[9]) ^ D[8]) ^ D[7]) ^ D[3]) ^ D[2]) ^ D[1]) ^
		  C[0]) ^ C[1]) ^ C[4]) ^ C[5]) ^ C[6]) ^ C[7]) ^ C[8]) ^ C[13])
		  ^ C[20]) ^ C[21]) ^ C[22]) ^ C[24]) ^ C[26]) ^ C[27]) ^ C[28])
		  ;
	  NewCRC[4] = ((((((((((((((((((((((((((((((((((((((((((((((D[63] ^
		  D[59]) ^ D[58]) ^ D[57]) ^ D[50]) ^ D[48]) ^ D[47]) ^ D[46]) ^
		  D[45]) ^ D[44]) ^ D[41]) ^ D[40]) ^ D[39]) ^ D[38]) ^ D[33]) ^
		  D[31]) ^ D[30]) ^ D[29]) ^ D[25]) ^ D[24]) ^ D[20]) ^ D[19]) ^
		  D[18]) ^ D[15]) ^ D[12]) ^ D[11]) ^ D[8]) ^ D[6]) ^ D[4]) ^
		  D[3]) ^ D[2]) ^ D[0]) ^ C[1]) ^ C[6]) ^ C[7]) ^ C[8]) ^ C[9])
		  ^ C[12]) ^ C[13]) ^ C[14]) ^ C[15]) ^ C[16]) ^ C[18]) ^ C[25])
		  ^ C[26]) ^ C[27]) ^ C[31]);
	  NewCRC[5] = ((((((((((((((((((((((((((((((((((((((((((((((D[63] ^
		  D[61]) ^ D[59]) ^ D[55]) ^ D[54]) ^ D[53]) ^ D[51]) ^ D[50]) ^
		  D[49]) ^ D[46]) ^ D[44]) ^ D[42]) ^ D[41]) ^ D[40]) ^ D[39]) ^
		  D[37]) ^ D[29]) ^ D[28]) ^ D[24]) ^ D[21]) ^ D[20]) ^ D[19]) ^
		  D[13]) ^ D[10]) ^ D[7]) ^ D[6]) ^ D[5]) ^ D[4]) ^ D[3]) ^
		  D[1]) ^ D[0]) ^ C[5]) ^ C[7]) ^ C[8]) ^ C[9]) ^ C[10]) ^
		  C[12]) ^ C[14]) ^ C[17]) ^ C[18]) ^ C[19]) ^ C[21]) ^ C[22]) ^
		  C[23]) ^ C[27]) ^ C[29]) ^ C[31]);
	  NewCRC[6] = ((((((((((((((((((((((((((((((((((((((((((((D[62] ^ D[60])
		  ^ D[56]) ^ D[55]) ^ D[54]) ^ D[52]) ^ D[51]) ^ D[50]) ^ D[47])
		  ^ D[45]) ^ D[43]) ^ D[42]) ^ D[41]) ^ D[40]) ^ D[38]) ^ D[30])
		  ^ D[29]) ^ D[25]) ^ D[22]) ^ D[21]) ^ D[20]) ^ D[14]) ^ D[11])
		  ^ D[8]) ^ D[7]) ^ D[6]) ^ D[5]) ^ D[4]) ^ D[2]) ^ D[1]) ^
		  C[6]) ^ C[8]) ^ C[9]) ^ C[10]) ^ C[11]) ^ C[13]) ^ C[15]) ^
		  C[18]) ^ C[19]) ^ C[20]) ^ C[22]) ^ C[23]) ^ C[24]) ^ C[28]) ^
		  C[30]);
	  NewCRC[7] = (((((((((((((((((((((((((((((((((((((((((((((((((((D[60] ^
		  D[58]) ^ D[57]) ^ D[56]) ^ D[54]) ^ D[52]) ^ D[51]) ^ D[50]) ^
		  D[47]) ^ D[46]) ^ D[45]) ^ D[43]) ^ D[42]) ^ D[41]) ^ D[39]) ^
		  D[37]) ^ D[34]) ^ D[32]) ^ D[29]) ^ D[28]) ^ D[25]) ^ D[24]) ^
		  D[23]) ^ D[22]) ^ D[21]) ^ D[16]) ^ D[15]) ^ D[10]) ^ D[8]) ^
		  D[7]) ^ D[5]) ^ D[3]) ^ D[2]) ^ D[0]) ^ C[0]) ^ C[2]) ^ C[5])
		  ^ C[7]) ^ C[9]) ^ C[10]) ^ C[11]) ^ C[13]) ^ C[14]) ^ C[15]) ^
		  C[18]) ^ C[19]) ^ C[20]) ^ C[22]) ^ C[24]) ^ C[25]) ^ C[26]) ^
		  C[28]);
	  NewCRC[8] = ((((((((((((((((((((((((((((((((((((((((((((((((((D[63] ^
		  D[60]) ^ D[59]) ^ D[57]) ^ D[54]) ^ D[52]) ^ D[51]) ^ D[50]) ^
		  D[46]) ^ D[45]) ^ D[43]) ^ D[42]) ^ D[40]) ^ D[38]) ^ D[37]) ^
		  D[35]) ^ D[34]) ^ D[33]) ^ D[32]) ^ D[31]) ^ D[28]) ^ D[23]) ^
		  D[22]) ^ D[17]) ^ D[12]) ^ D[11]) ^ D[10]) ^ D[8]) ^ D[4]) ^
		  D[3]) ^ D[1]) ^ D[0]) ^ C[0]) ^ C[1]) ^ C[2]) ^ C[3]) ^ C[5])
		  ^ C[6]) ^ C[8]) ^ C[10]) ^ C[11]) ^ C[13]) ^ C[14]) ^ C[18]) ^
		  C[19]) ^ C[20]) ^ C[22]) ^ C[25]) ^ C[27]) ^ C[28]) ^ C[31]);
	  NewCRC[9] = (((((((((((((((((((((((((((((((((((((((((((((((((D[61] ^
		  D[60]) ^ D[58]) ^ D[55]) ^ D[53]) ^ D[52]) ^ D[51]) ^ D[47]) ^
		  D[46]) ^ D[44]) ^ D[43]) ^ D[41]) ^ D[39]) ^ D[38]) ^ D[36]) ^
		  D[35]) ^ D[34]) ^ D[33]) ^ D[32]) ^ D[29]) ^ D[24]) ^ D[23]) ^
		  D[18]) ^ D[13]) ^ D[12]) ^ D[11]) ^ D[9]) ^ D[5]) ^ D[4]) ^
		  D[2]) ^ D[1]) ^ C[0]) ^ C[1]) ^ C[2]) ^ C[3]) ^ C[4]) ^ C[6])
		  ^ C[7]) ^ C[9]) ^ C[11]) ^ C[12]) ^ C[14]) ^ C[15]) ^ C[19]) ^
		  C[20]) ^ C[21]) ^ C[23]) ^ C[26]) ^ C[28]) ^ C[29]);
	  NewCRC[10] = ((((((((((((((((((((((((((((((((((((((((((((D[63] ^
		  D[62]) ^ D[60]) ^ D[59]) ^ D[58]) ^ D[56]) ^ D[55]) ^ D[52]) ^
		  D[50]) ^ D[42]) ^ D[40]) ^ D[39]) ^ D[36]) ^ D[35]) ^ D[33]) ^
		  D[32]) ^ D[31]) ^ D[29]) ^ D[28]) ^ D[26]) ^ D[19]) ^ D[16]) ^
		  D[14]) ^ D[13]) ^ D[9]) ^ D[5]) ^ D[3]) ^ D[2]) ^ D[0]) ^
		  C[0]) ^ C[1]) ^ C[3]) ^ C[4]) ^ C[7]) ^ C[8]) ^ C[10]) ^
		  C[18]) ^ C[20]) ^ C[23]) ^ C[24]) ^ C[26]) ^ C[27]) ^ C[28]) ^
		  C[30]) ^ C[31]);
	  NewCRC[11] = ((((((((((((((((((((((((((((((((((((((((((((((((((D[59] ^
		  D[58]) ^ D[57]) ^ D[56]) ^ D[55]) ^ D[54]) ^ D[51]) ^ D[50]) ^
		  D[48]) ^ D[47]) ^ D[45]) ^ D[44]) ^ D[43]) ^ D[41]) ^ D[40]) ^
		  D[36]) ^ D[33]) ^ D[31]) ^ D[28]) ^ D[27]) ^ D[26]) ^ D[25]) ^
		  D[24]) ^ D[20]) ^ D[17]) ^ D[16]) ^ D[15]) ^ D[14]) ^ D[12]) ^
		  D[9]) ^ D[4]) ^ D[3]) ^ D[1]) ^ D[0]) ^ C[1]) ^ C[4]) ^ C[8])
		  ^ C[9]) ^ C[11]) ^ C[12]) ^ C[13]) ^ C[15]) ^ C[16]) ^ C[18])
		  ^ C[19]) ^ C[22]) ^ C[23]) ^ C[24]) ^ C[25]) ^ C[26]) ^ C[27])
		  ;
	  NewCRC[12] = ((((((((((((((((((((((((((((((((((((((((((((((D[63] ^
		  D[61]) ^ D[59]) ^ D[57]) ^ D[56]) ^ D[54]) ^ D[53]) ^ D[52]) ^
		  D[51]) ^ D[50]) ^ D[49]) ^ D[47]) ^ D[46]) ^ D[42]) ^ D[41]) ^
		  D[31]) ^ D[30]) ^ D[27]) ^ D[24]) ^ D[21]) ^ D[18]) ^ D[17]) ^
		  D[15]) ^ D[13]) ^ D[12]) ^ D[9]) ^ D[6]) ^ D[5]) ^ D[4]) ^
		  D[2]) ^ D[1]) ^ D[0]) ^ C[9]) ^ C[10]) ^ C[14]) ^ C[15]) ^
		  C[17]) ^ C[18]) ^ C[19]) ^ C[20]) ^ C[21]) ^ C[22]) ^ C[24]) ^
		  C[25]) ^ C[27]) ^ C[29]) ^ C[31]);
	  NewCRC[13] = (((((((((((((((((((((((((((((((((((((((((((((D[62] ^
		  D[60]) ^ D[58]) ^ D[57]) ^ D[55]) ^ D[54]) ^ D[53]) ^ D[52]) ^
		  D[51]) ^ D[50]) ^ D[48]) ^ D[47]) ^ D[43]) ^ D[42]) ^ D[32]) ^
		  D[31]) ^ D[28]) ^ D[25]) ^ D[22]) ^ D[19]) ^ D[18]) ^ D[16]) ^
		  D[14]) ^ D[13]) ^ D[10]) ^ D[7]) ^ D[6]) ^ D[5]) ^ D[3]) ^
		  D[2]) ^ D[1]) ^ C[0]) ^ C[10]) ^ C[11]) ^ C[15]) ^ C[16]) ^
		  C[18]) ^ C[19]) ^ C[20]) ^ C[21]) ^ C[22]) ^ C[23]) ^ C[25]) ^
		  C[26]) ^ C[28]) ^ C[30]);
	  NewCRC[14] = ((((((((((((((((((((((((((((((((((((((((((((((D[63] ^
		  D[61]) ^ D[59]) ^ D[58]) ^ D[56]) ^ D[55]) ^ D[54]) ^ D[53]) ^
		  D[52]) ^ D[51]) ^ D[49]) ^ D[48]) ^ D[44]) ^ D[43]) ^ D[33]) ^
		  D[32]) ^ D[29]) ^ D[26]) ^ D[23]) ^ D[20]) ^ D[19]) ^ D[17]) ^
		  D[15]) ^ D[14]) ^ D[11]) ^ D[8]) ^ D[7]) ^ D[6]) ^ D[4]) ^
		  D[3]) ^ D[2]) ^ C[0]) ^ C[1]) ^ C[11]) ^ C[12]) ^ C[16]) ^
		  C[17]) ^ C[19]) ^ C[20]) ^ C[21]) ^ C[22]) ^ C[23]) ^ C[24]) ^
		  C[26]) ^ C[27]) ^ C[29]) ^ C[31]);
	  NewCRC[15] = ((((((((((((((((((((((((((((((((((((((((((((D[62] ^
		  D[60]) ^ D[59]) ^ D[57]) ^ D[56]) ^ D[55]) ^ D[54]) ^ D[53]) ^
		  D[52]) ^ D[50]) ^ D[49]) ^ D[45]) ^ D[44]) ^ D[34]) ^ D[33]) ^
		  D[30]) ^ D[27]) ^ D[24]) ^ D[21]) ^ D[20]) ^ D[18]) ^ D[16]) ^
		  D[15]) ^ D[12]) ^ D[9]) ^ D[8]) ^ D[7]) ^ D[5]) ^ D[4]) ^
		  D[3]) ^ C[1]) ^ C[2]) ^ C[12]) ^ C[13]) ^ C[17]) ^ C[18]) ^
		  C[20]) ^ C[21]) ^ C[22]) ^ C[23]) ^ C[24]) ^ C[25]) ^ C[27]) ^
		  C[28]) ^ C[30]);
	  NewCRC[16] = (((((((((((((((((((((((((((((((((D[57] ^ D[56]) ^ D[51])
		  ^ D[48]) ^ D[47]) ^ D[46]) ^ D[44]) ^ D[37]) ^ D[35]) ^ D[32])
		  ^ D[30]) ^ D[29]) ^ D[26]) ^ D[24]) ^ D[22]) ^ D[21]) ^ D[19])
		  ^ D[17]) ^ D[13]) ^ D[12]) ^ D[8]) ^ D[5]) ^ D[4]) ^ D[0]) ^
		  C[0]) ^ C[3]) ^ C[5]) ^ C[12]) ^ C[14]) ^ C[15]) ^ C[16]) ^
		  C[19]) ^ C[24]) ^ C[25]);
	  NewCRC[17] = (((((((((((((((((((((((((((((((((D[58] ^ D[57]) ^ D[52])
		  ^ D[49]) ^ D[48]) ^ D[47]) ^ D[45]) ^ D[38]) ^ D[36]) ^ D[33])
		  ^ D[31]) ^ D[30]) ^ D[27]) ^ D[25]) ^ D[23]) ^ D[22]) ^ D[20])
		  ^ D[18]) ^ D[14]) ^ D[13]) ^ D[9]) ^ D[6]) ^ D[5]) ^ D[1]) ^
		  C[1]) ^ C[4]) ^ C[6]) ^ C[13]) ^ C[15]) ^ C[16]) ^ C[17]) ^
		  C[20]) ^ C[25]) ^ C[26]);
	  NewCRC[18] = ((((((((((((((((((((((((((((((((((D[59] ^ D[58]) ^ D[53])
		  ^ D[50]) ^ D[49]) ^ D[48]) ^ D[46]) ^ D[39]) ^ D[37]) ^ D[34])
		  ^ D[32]) ^ D[31]) ^ D[28]) ^ D[26]) ^ D[24]) ^ D[23]) ^ D[21])
		  ^ D[19]) ^ D[15]) ^ D[14]) ^ D[10]) ^ D[7]) ^ D[6]) ^ D[2]) ^
		  C[0]) ^ C[2]) ^ C[5]) ^ C[7]) ^ C[14]) ^ C[16]) ^ C[17]) ^
		  C[18]) ^ C[21]) ^ C[26]) ^ C[27]);
	  NewCRC[19] = (((((((((((((((((((((((((((((((((((D[60] ^ D[59]) ^
		  D[54]) ^ D[51]) ^ D[50]) ^ D[49]) ^ D[47]) ^ D[40]) ^ D[38]) ^
		  D[35]) ^ D[33]) ^ D[32]) ^ D[29]) ^ D[27]) ^ D[25]) ^ D[24]) ^
		  D[22]) ^ D[20]) ^ D[16]) ^ D[15]) ^ D[11]) ^ D[8]) ^ D[7]) ^
		  D[3]) ^ C[0]) ^ C[1]) ^ C[3]) ^ C[6]) ^ C[8]) ^ C[15]) ^
		  C[17]) ^ C[18]) ^ C[19]) ^ C[22]) ^ C[27]) ^ C[28]);
	  NewCRC[20] = (((((((((((((((((((((((((((((((((((D[61] ^ D[60]) ^
		  D[55]) ^ D[52]) ^ D[51]) ^ D[50]) ^ D[48]) ^ D[41]) ^ D[39]) ^
		  D[36]) ^ D[34]) ^ D[33]) ^ D[30]) ^ D[28]) ^ D[26]) ^ D[25]) ^
		  D[23]) ^ D[21]) ^ D[17]) ^ D[16]) ^ D[12]) ^ D[9]) ^ D[8]) ^
		  D[4]) ^ C[1]) ^ C[2]) ^ C[4]) ^ C[7]) ^ C[9]) ^ C[16]) ^
		  C[18]) ^ C[19]) ^ C[20]) ^ C[23]) ^ C[28]) ^ C[29]);
	  NewCRC[21] = (((((((((((((((((((((((((((((((((((D[62] ^ D[61]) ^
		  D[56]) ^ D[53]) ^ D[52]) ^ D[51]) ^ D[49]) ^ D[42]) ^ D[40]) ^
		  D[37]) ^ D[35]) ^ D[34]) ^ D[31]) ^ D[29]) ^ D[27]) ^ D[26]) ^
		  D[24]) ^ D[22]) ^ D[18]) ^ D[17]) ^ D[13]) ^ D[10]) ^ D[9]) ^
		  D[5]) ^ C[2]) ^ C[3]) ^ C[5]) ^ C[8]) ^ C[10]) ^ C[17]) ^
		  C[19]) ^ C[20]) ^ C[21]) ^ C[24]) ^ C[29]) ^ C[30]);
	  NewCRC[22] = (((((((((((((((((((((((((((((((((((((((((((((((((D[62] ^
		  D[61]) ^ D[60]) ^ D[58]) ^ D[57]) ^ D[55]) ^ D[52]) ^ D[48]) ^
		  D[47]) ^ D[45]) ^ D[44]) ^ D[43]) ^ D[41]) ^ D[38]) ^ D[37]) ^
		  D[36]) ^ D[35]) ^ D[34]) ^ D[31]) ^ D[29]) ^ D[27]) ^ D[26]) ^
		  D[24]) ^ D[23]) ^ D[19]) ^ D[18]) ^ D[16]) ^ D[14]) ^ D[12]) ^
		  D[11]) ^ D[9]) ^ D[0]) ^ C[2]) ^ C[3]) ^ C[4]) ^ C[5]) ^ C[6])
		  ^ C[9]) ^ C[11]) ^ C[12]) ^ C[13]) ^ C[15]) ^ C[16]) ^ C[20])
		  ^ C[23]) ^ C[25]) ^ C[26]) ^ C[28]) ^ C[29]) ^ C[30]);
	  NewCRC[23] = (((((((((((((((((((((((((((((((((((((((((((((D[62] ^
		  D[60]) ^ D[59]) ^ D[56]) ^ D[55]) ^ D[54]) ^ D[50]) ^ D[49]) ^
		  D[47]) ^ D[46]) ^ D[42]) ^ D[39]) ^ D[38]) ^ D[36]) ^ D[35]) ^
		  D[34]) ^ D[31]) ^ D[29]) ^ D[27]) ^ D[26]) ^ D[20]) ^ D[19]) ^
		  D[17]) ^ D[16]) ^ D[15]) ^ D[13]) ^ D[9]) ^ D[6]) ^ D[1]) ^
		  D[0]) ^ C[2]) ^ C[3]) ^ C[4]) ^ C[6]) ^ C[7]) ^ C[10]) ^
		  C[14]) ^ C[15]) ^ C[17]) ^ C[18]) ^ C[22]) ^ C[23]) ^ C[24]) ^
		  C[27]) ^ C[28]) ^ C[30]);
	  NewCRC[24] = ((((((((((((((((((((((((((((((((((((((((((((((D[63] ^
		  D[61]) ^ D[60]) ^ D[57]) ^ D[56]) ^ D[55]) ^ D[51]) ^ D[50]) ^
		  D[48]) ^ D[47]) ^ D[43]) ^ D[40]) ^ D[39]) ^ D[37]) ^ D[36]) ^
		  D[35]) ^ D[32]) ^ D[30]) ^ D[28]) ^ D[27]) ^ D[21]) ^ D[20]) ^
		  D[18]) ^ D[17]) ^ D[16]) ^ D[14]) ^ D[10]) ^ D[7]) ^ D[2]) ^
		  D[1]) ^ C[0]) ^ C[3]) ^ C[4]) ^ C[5]) ^ C[7]) ^ C[8]) ^ C[11])
		  ^ C[15]) ^ C[16]) ^ C[18]) ^ C[19]) ^ C[23]) ^ C[24]) ^ C[25])
		  ^ C[28]) ^ C[29]) ^ C[31]);
	  NewCRC[25] = ((((((((((((((((((((((((((((((((((((((((((((D[62] ^
		  D[61]) ^ D[58]) ^ D[57]) ^ D[56]) ^ D[52]) ^ D[51]) ^ D[49]) ^
		  D[48]) ^ D[44]) ^ D[41]) ^ D[40]) ^ D[38]) ^ D[37]) ^ D[36]) ^
		  D[33]) ^ D[31]) ^ D[29]) ^ D[28]) ^ D[22]) ^ D[21]) ^ D[19]) ^
		  D[18]) ^ D[17]) ^ D[15]) ^ D[11]) ^ D[8]) ^ D[3]) ^ D[2]) ^
		  C[1]) ^ C[4]) ^ C[5]) ^ C[6]) ^ C[8]) ^ C[9]) ^ C[12]) ^
		  C[16]) ^ C[17]) ^ C[19]) ^ C[20]) ^ C[24]) ^ C[25]) ^ C[26]) ^
		  C[29]) ^ C[30]);
	  NewCRC[26] = ((((((((((((((((((((((((((((((((((((((((((((((D[62] ^
		  D[61]) ^ D[60]) ^ D[59]) ^ D[57]) ^ D[55]) ^ D[54]) ^ D[52]) ^
		  D[49]) ^ D[48]) ^ D[47]) ^ D[44]) ^ D[42]) ^ D[41]) ^ D[39]) ^
		  D[38]) ^ D[31]) ^ D[28]) ^ D[26]) ^ D[25]) ^ D[24]) ^ D[23]) ^
		  D[22]) ^ D[20]) ^ D[19]) ^ D[18]) ^ D[10]) ^ D[6]) ^ D[4]) ^
		  D[3]) ^ D[0]) ^ C[6]) ^ C[7]) ^ C[9]) ^ C[10]) ^ C[12]) ^
		  C[15]) ^ C[16]) ^ C[17]) ^ C[20]) ^ C[22]) ^ C[23]) ^ C[25]) ^
		  C[27]) ^ C[28]) ^ C[29]) ^ C[30]);
	  NewCRC[27] = (((((((((((((((((((((((((((((((((((((((((((((((D[63] ^
		  D[62]) ^ D[61]) ^ D[60]) ^ D[58]) ^ D[56]) ^ D[55]) ^ D[53]) ^
		  D[50]) ^ D[49]) ^ D[48]) ^ D[45]) ^ D[43]) ^ D[42]) ^ D[40]) ^
		  D[39]) ^ D[32]) ^ D[29]) ^ D[27]) ^ D[26]) ^ D[25]) ^ D[24]) ^
		  D[23]) ^ D[21]) ^ D[20]) ^ D[19]) ^ D[11]) ^ D[7]) ^ D[5]) ^
		  D[4]) ^ D[1]) ^ C[0]) ^ C[7]) ^ C[8]) ^ C[10]) ^ C[11]) ^
		  C[13]) ^ C[16]) ^ C[17]) ^ C[18]) ^ C[21]) ^ C[23]) ^ C[24]) ^
		  C[26]) ^ C[28]) ^ C[29]) ^ C[30]) ^ C[31]);
	  NewCRC[28] = (((((((((((((((((((((((((((((((((((((((((((((D[63] ^
		  D[62]) ^ D[61]) ^ D[59]) ^ D[57]) ^ D[56]) ^ D[54]) ^ D[51]) ^
		  D[50]) ^ D[49]) ^ D[46]) ^ D[44]) ^ D[43]) ^ D[41]) ^ D[40]) ^
		  D[33]) ^ D[30]) ^ D[28]) ^ D[27]) ^ D[26]) ^ D[25]) ^ D[24]) ^
		  D[22]) ^ D[21]) ^ D[20]) ^ D[12]) ^ D[8]) ^ D[6]) ^ D[5]) ^
		  D[2]) ^ C[1]) ^ C[8]) ^ C[9]) ^ C[11]) ^ C[12]) ^ C[14]) ^
		  C[17]) ^ C[18]) ^ C[19]) ^ C[22]) ^ C[24]) ^ C[25]) ^ C[27]) ^
		  C[29]) ^ C[30]) ^ C[31]);
	  NewCRC[29] = (((((((((((((((((((((((((((((((((((((((((((D[63] ^ D[62])
		  ^ D[60]) ^ D[58]) ^ D[57]) ^ D[55]) ^ D[52]) ^ D[51]) ^ D[50])
		  ^ D[47]) ^ D[45]) ^ D[44]) ^ D[42]) ^ D[41]) ^ D[34]) ^ D[31])
		  ^ D[29]) ^ D[28]) ^ D[27]) ^ D[26]) ^ D[25]) ^ D[23]) ^ D[22])
		  ^ D[21]) ^ D[13]) ^ D[9]) ^ D[7]) ^ D[6]) ^ D[3]) ^ C[2]) ^
		  C[9]) ^ C[10]) ^ C[12]) ^ C[13]) ^ C[15]) ^ C[18]) ^ C[19]) ^
		  C[20]) ^ C[23]) ^ C[25]) ^ C[26]) ^ C[28]) ^ C[30]) ^ C[31]);
	  NewCRC[30] = ((((((((((((((((((((((((((((((((((((((((((D[63] ^ D[61])
		  ^ D[59]) ^ D[58]) ^ D[56]) ^ D[53]) ^ D[52]) ^ D[51]) ^ D[48])
		  ^ D[46]) ^ D[45]) ^ D[43]) ^ D[42]) ^ D[35]) ^ D[32]) ^ D[30])
		  ^ D[29]) ^ D[28]) ^ D[27]) ^ D[26]) ^ D[24]) ^ D[23]) ^ D[22])
		  ^ D[14]) ^ D[10]) ^ D[8]) ^ D[7]) ^ D[4]) ^ C[0]) ^ C[3]) ^
		  C[10]) ^ C[11]) ^ C[13]) ^ C[14]) ^ C[16]) ^ C[19]) ^ C[20]) ^
		  C[21]) ^ C[24]) ^ C[26]) ^ C[27]) ^ C[29]) ^ C[31]);
	  NewCRC[31] = ((((((((((((((((((((((((((((((((((((((((D[62] ^ D[60]) ^
		  D[59]) ^ D[57]) ^ D[54]) ^ D[53]) ^ D[52]) ^ D[49]) ^ D[47]) ^
		  D[46]) ^ D[44]) ^ D[43]) ^ D[36]) ^ D[33]) ^ D[31]) ^ D[30]) ^
		  D[29]) ^ D[28]) ^ D[27]) ^ D[25]) ^ D[24]) ^ D[23]) ^ D[15]) ^
		  D[11]) ^ D[9]) ^ D[8]) ^ D[5]) ^ C[1]) ^ C[4]) ^ C[11]) ^
		  C[12]) ^ C[14]) ^ C[15]) ^ C[17]) ^ C[20]) ^ C[21]) ^ C[22]) ^
		  C[25]) ^ C[27]) ^ C[28]) ^ C[30]);
	  nextCRC32_D64 = NewCRC;
	end
	endfunction

	function [31:0] nextCRC32_D8;
	input logic
		[7:0]		Data;
	input logic
		[31:0]		CRC;

	reg	[7:0]		D;
	reg	[31:0]		C;
	reg	[31:0]		NewCRC;
	begin
	  D = Data;
	  C = CRC;
	  NewCRC[0] = (((D[6] ^ D[0]) ^ C[24]) ^ C[30]);
	  NewCRC[1] = (((((((D[7] ^ D[6]) ^ D[1]) ^ D[0]) ^ C[24]) ^ C[25]) ^
		  C[30]) ^ C[31]);
	  NewCRC[2] = (((((((((D[7] ^ D[6]) ^ D[2]) ^ D[1]) ^ D[0]) ^ C[24]) ^
		  C[25]) ^ C[26]) ^ C[30]) ^ C[31]);
	  NewCRC[3] = (((((((D[7] ^ D[3]) ^ D[2]) ^ D[1]) ^ C[25]) ^ C[26]) ^
		  C[27]) ^ C[31]);
	  NewCRC[4] = (((((((((D[6] ^ D[4]) ^ D[3]) ^ D[2]) ^ D[0]) ^ C[24]) ^
		  C[26]) ^ C[27]) ^ C[28]) ^ C[30]);
	  NewCRC[5] = (((((((((((((D[7] ^ D[6]) ^ D[5]) ^ D[4]) ^ D[3]) ^ D[1])
		  ^ D[0]) ^ C[24]) ^ C[25]) ^ C[27]) ^ C[28]) ^ C[29]) ^ C[30])
		  ^ C[31]);
	  NewCRC[6] = (((((((((((D[7] ^ D[6]) ^ D[5]) ^ D[4]) ^ D[2]) ^ D[1]) ^
		  C[25]) ^ C[26]) ^ C[28]) ^ C[29]) ^ C[30]) ^ C[31]);
	  NewCRC[7] = (((((((((D[7] ^ D[5]) ^ D[3]) ^ D[2]) ^ D[0]) ^ C[24]) ^
		  C[26]) ^ C[27]) ^ C[29]) ^ C[31]);
	  NewCRC[8] = ((((((((D[4] ^ D[3]) ^ D[1]) ^ D[0]) ^ C[0]) ^ C[24]) ^
		  C[25]) ^ C[27]) ^ C[28]);
	  NewCRC[9] = ((((((((D[5] ^ D[4]) ^ D[2]) ^ D[1]) ^ C[1]) ^ C[25]) ^
		  C[26]) ^ C[28]) ^ C[29]);
	  NewCRC[10] = ((((((((D[5] ^ D[3]) ^ D[2]) ^ D[0]) ^ C[2]) ^ C[24]) ^
		  C[26]) ^ C[27]) ^ C[29]);
	  NewCRC[11] = ((((((((D[4] ^ D[3]) ^ D[1]) ^ D[0]) ^ C[3]) ^ C[24]) ^
		  C[25]) ^ C[27]) ^ C[28]);
	  NewCRC[12] = ((((((((((((D[6] ^ D[5]) ^ D[4]) ^ D[2]) ^ D[1]) ^ D[0])
		  ^ C[4]) ^ C[24]) ^ C[25]) ^ C[26]) ^ C[28]) ^ C[29]) ^ C[30]);
	  NewCRC[13] = ((((((((((((D[7] ^ D[6]) ^ D[5]) ^ D[3]) ^ D[2]) ^ D[1])
		  ^ C[5]) ^ C[25]) ^ C[26]) ^ C[27]) ^ C[29]) ^ C[30]) ^ C[31]);
	  NewCRC[14] = ((((((((((D[7] ^ D[6]) ^ D[4]) ^ D[3]) ^ D[2]) ^ C[6]) ^
		  C[26]) ^ C[27]) ^ C[28]) ^ C[30]) ^ C[31]);
	  NewCRC[15] = ((((((((D[7] ^ D[5]) ^ D[4]) ^ D[3]) ^ C[7]) ^ C[27]) ^
		  C[28]) ^ C[29]) ^ C[31]);
	  NewCRC[16] = ((((((D[5] ^ D[4]) ^ D[0]) ^ C[8]) ^ C[24]) ^ C[28]) ^
		  C[29]);
	  NewCRC[17] = ((((((D[6] ^ D[5]) ^ D[1]) ^ C[9]) ^ C[25]) ^ C[29]) ^
		  C[30]);
	  NewCRC[18] = ((((((D[7] ^ D[6]) ^ D[2]) ^ C[10]) ^ C[26]) ^ C[30]) ^
		  C[31]);
	  NewCRC[19] = ((((D[7] ^ D[3]) ^ C[11]) ^ C[27]) ^ C[31]);
	  NewCRC[20] = ((D[4] ^ C[12]) ^ C[28]);
	  NewCRC[21] = ((D[5] ^ C[13]) ^ C[29]);
	  NewCRC[22] = ((D[0] ^ C[14]) ^ C[24]);
	  NewCRC[23] = ((((((D[6] ^ D[1]) ^ D[0]) ^ C[15]) ^ C[24]) ^ C[25]) ^
		  C[30]);
	  NewCRC[24] = ((((((D[7] ^ D[2]) ^ D[1]) ^ C[16]) ^ C[25]) ^ C[26]) ^
		  C[31]);
	  NewCRC[25] = ((((D[3] ^ D[2]) ^ C[17]) ^ C[26]) ^ C[27]);
	  NewCRC[26] = ((((((((D[6] ^ D[4]) ^ D[3]) ^ D[0]) ^ C[18]) ^ C[24]) ^
		  C[27]) ^ C[28]) ^ C[30]);
	  NewCRC[27] = ((((((((D[7] ^ D[5]) ^ D[4]) ^ D[1]) ^ C[19]) ^ C[25]) ^
		  C[28]) ^ C[29]) ^ C[31]);
	  NewCRC[28] = ((((((D[6] ^ D[5]) ^ D[2]) ^ C[20]) ^ C[26]) ^ C[29]) ^
		  C[30]);
	  NewCRC[29] = ((((((D[7] ^ D[6]) ^ D[3]) ^ C[21]) ^ C[27]) ^ C[30]) ^
		  C[31]);
	  NewCRC[30] = ((((D[7] ^ D[4]) ^ C[22]) ^ C[28]) ^ C[31]);
	  NewCRC[31] = ((D[5] ^ C[23]) ^ C[29]);
	  nextCRC32_D8 = NewCRC;
	end
	endfunction

	function [63:0] reverse_64b;
	input logic
		[63:0]		data;

	integer			i;
	begin
	  for (i = 0; (i < 64); i = (i + 1)) begin
	    reverse_64b[i] = data[(63 - i)];
	  end
	end
	endfunction

	function [31:0] reverse_32b;
	input logic
		[31:0]		data;

	integer			i;
	begin
	  for (i = 0; (i < 32); i = (i + 1)) begin
	    reverse_32b[i] = data[(31 - i)];
	  end
	end
	endfunction

	function [7:0] reverse_8b;
	input logic
		[7:0]		data;

	integer			i;
	begin
	  for (i = 0; (i < 8); i = (i + 1)) begin
	    reverse_8b[i] = data[(7 - i)];
	  end
	end
	endfunction

	always @(posedge clk_156m25 or negedge reset_156m25_n) begin
	  if (reset_156m25_n == 1'b0) begin
	    txd_ovflow <= 1'b0;
	    status_txdfifo_ovflow_tog <= 1'b0;
	  end
	  else
	    begin
	      txd_ovflow <= next_txd_ovflow;
	      if (next_txd_ovflow && (!txd_ovflow)) begin
		status_txdfifo_ovflow_tog <= (~status_txdfifo_ovflow_tog);
	      end
	    end
	end
	always @(pkt_tx_data or pkt_tx_eop or pkt_tx_mod or pkt_tx_sop or 
		pkt_tx_val or txd_ovflow or txdfifo_wfull) begin
	  txdfifo_wstatus = 8'b0;
	  txdfifo_wen = pkt_tx_val;
	  next_txd_ovflow = txd_ovflow;
	  txdfifo_wdata = {pkt_tx_data[7:0], pkt_tx_data[15:8],
		  pkt_tx_data[23:16], pkt_tx_data[31:24], pkt_tx_data[39:32],
		  pkt_tx_data[47:40], pkt_tx_data[55:48], pkt_tx_data[63:56]};
	  if (pkt_tx_val && pkt_tx_sop) begin
	    txdfifo_wstatus[3'd7] = 1'b1;
	  end
	  if (pkt_tx_val) begin
	    if (pkt_tx_eop) begin
	      txdfifo_wstatus[2:0] = pkt_tx_mod;
	      txdfifo_wstatus[3'd6] = 1'b1;
	    end
	  end
	  if (pkt_tx_val) begin
	    if (txdfifo_wfull) begin
	      next_txd_ovflow = 1'b1;
	    end
	    else if (pkt_tx_sop) begin
	      next_txd_ovflow = 1'b0;
	    end
	  end
	end
endmodule

/*
                    instances: 0
                        nodes: 42 (0)
                  node widths: 311 (0)
                      process: 2 (0)
                   contassign:  3 (0)
                        ports: 29 (0)
*/


module wishbone_if(wb_dat_o, wb_ack_o, wb_int_o, ctrl_tx_enable,
	clear_stats_tx_octets, clear_stats_tx_pkts, clear_stats_rx_octets,
	clear_stats_rx_pkts, wb_clk_i, wb_rst_i, wb_adr_i, wb_dat_i, wb_we_i,
	wb_stb_i, wb_cyc_i, status_crc_error, status_fragment_error,
	status_lenght_error, status_txdfifo_ovflow, status_txdfifo_udflow,
	status_rxdfifo_ovflow, status_rxdfifo_udflow, status_pause_frame_rx,
	status_local_fault, status_remote_fault, stats_tx_octets, stats_tx_pkts,
	stats_rx_octets, stats_rx_pkts);
	input			wb_clk_i;
	input			wb_rst_i;
	input	[7:0]		wb_adr_i;
	input	[31:0]		wb_dat_i;
	input			wb_we_i;
	input			wb_stb_i;
	input			wb_cyc_i;
	output			wb_ack_o;
	input			status_crc_error;
	input			status_fragment_error;
	input			status_lenght_error;
	input			status_txdfifo_ovflow;
	input			status_txdfifo_udflow;
	input			status_rxdfifo_ovflow;
	input			status_rxdfifo_udflow;
	input			status_pause_frame_rx;
	input			status_local_fault;
	input			status_remote_fault;
	input	[31:0]		stats_tx_octets;
	input	[31:0]		stats_tx_pkts;
	input	[31:0]		stats_rx_octets;
	input	[31:0]		stats_rx_pkts;
	output			ctrl_tx_enable;
	output			clear_stats_rx_octets;

	reg			clear_stats_rx_octets;
	output			clear_stats_rx_pkts;
	reg			clear_stats_rx_pkts;
	output			clear_stats_tx_octets;
	reg			clear_stats_tx_octets;
	output			clear_stats_tx_pkts;
	reg			clear_stats_tx_pkts;
	output	[31:0]		wb_dat_o;
	reg	[31:0]		wb_dat_o;
	output			wb_int_o;
	reg			wb_int_o;
	reg	[31:0]		next_wb_dat_o;
	reg			next_wb_int_o;
	reg	[0:0]		cpureg_config0;
	reg	[0:0]		next_cpureg_config0;
	reg	[9:0]		cpureg_int_pending;
	reg	[9:0]		next_cpureg_int_pending;
	reg	[9:0]		cpureg_int_mask;
	reg	[9:0]		next_cpureg_int_mask;
	reg			cpuack;
	reg			next_cpuack;
	reg			status_remote_fault_d1;
	reg			status_local_fault_d1;
	wire	[9:0]		int_sources;

	assign int_sources = {status_lenght_error, status_fragment_error,
		status_crc_error, status_pause_frame_rx, (status_remote_fault ^
		status_remote_fault_d1), (status_local_fault ^
		status_local_fault_d1), status_rxdfifo_udflow,
		status_rxdfifo_ovflow, status_txdfifo_udflow,
		status_txdfifo_ovflow};
	assign ctrl_tx_enable = cpureg_config0[0];
	assign wb_ack_o = (cpuack && wb_stb_i);

	always @(cpureg_config0 or cpureg_int_mask or cpureg_int_pending or 
		int_sources or stats_rx_octets or stats_rx_pkts or 
		stats_tx_octets or stats_tx_pkts or wb_adr_i or wb_cyc_i or 
		wb_dat_i or wb_dat_o or wb_stb_i or wb_we_i) begin
	  next_wb_dat_o = wb_dat_o;
	  next_wb_int_o = (|(cpureg_int_pending & cpureg_int_mask));
	  next_cpureg_int_pending = (cpureg_int_pending | int_sources);
	  next_cpuack = (wb_cyc_i && wb_stb_i);
	  next_cpureg_config0 = cpureg_config0;
	  next_cpureg_int_mask = cpureg_int_mask;
	  clear_stats_tx_octets = 1'b0;
	  clear_stats_tx_pkts = 1'b0;
	  clear_stats_rx_octets = 1'b0;
	  clear_stats_rx_pkts = 1'b0;
	  if ((wb_cyc_i && wb_stb_i) && (!wb_we_i)) begin
	    case ({wb_adr_i[7:2], 2'b0})
	      8'b0: begin
		next_wb_dat_o = {31'b0, cpureg_config0};
	      end
	      8'h08: begin
		next_wb_dat_o = {22'b0, cpureg_int_pending};
		next_cpureg_int_pending = int_sources;
		next_wb_int_o = 1'b0;
	      end
	      8'h0c: begin
		next_wb_dat_o = {22'b0, int_sources};
	      end
	      8'h10: begin
		next_wb_dat_o = {22'b0, cpureg_int_mask};
	      end
	      8'h80: begin
		next_wb_dat_o = stats_tx_octets;
		clear_stats_tx_octets = 1'b1;
	      end
	      8'h84: begin
		next_wb_dat_o = stats_tx_pkts;
		clear_stats_tx_pkts = 1'b1;
	      end
	      8'h90: begin
		next_wb_dat_o = stats_rx_octets;
		clear_stats_rx_octets = 1'b1;
	      end
	      8'h94: begin
		next_wb_dat_o = stats_rx_pkts;
		clear_stats_rx_pkts = 1'b1;
	      end
	      default: begin
	      end
	    endcase
	  end
	  if ((wb_cyc_i && wb_stb_i) && wb_we_i) begin
	    case ({wb_adr_i[7:2], 2'b0})
	      8'b0: begin
		next_cpureg_config0 = wb_dat_i[0];
	      end
	      8'h08: begin
		next_cpureg_int_pending = ((wb_dat_i[9:0] | cpureg_int_pending)
			| int_sources);
	      end
	      8'h10: begin
		next_cpureg_int_mask = wb_dat_i[9:0];
	      end
	      default: begin
	      end
	    endcase
	  end
	end
	always @(posedge wb_clk_i or posedge wb_rst_i) begin
	  if (wb_rst_i == 1'b1) begin
	    cpureg_config0 <= 1'b1;
	    cpureg_int_pending <= 10'b0;
	    cpureg_int_mask <= 10'b0;
	    wb_dat_o <= 32'b0;
	    wb_int_o <= 1'b0;
	    cpuack <= 1'b0;
	    status_remote_fault_d1 <= 1'b0;
	    status_local_fault_d1 <= 1'b0;
	  end
	  else
	    begin
	      cpureg_config0 <= next_cpureg_config0;
	      cpureg_int_pending <= next_cpureg_int_pending;
	      cpureg_int_mask <= next_cpureg_int_mask;
	      wb_dat_o <= next_wb_dat_o;
	      wb_int_o <= next_wb_int_o;
	      cpuack <= next_cpuack;
	      status_remote_fault_d1 <= status_remote_fault;
	      status_local_fault_d1 <= status_local_fault;
	    end
	end
endmodule

/*
                    instances: 0
                        nodes: 8 (0)
                  node widths: 34 (0)
                        ports: 8 (0)
                        ports: 1 (0)
                 portconnects: 12 (0)
*/


module tx_stats_fifo(txsfifo_rdata, txsfifo_rempty, clk_xgmii_tx,
	reset_xgmii_tx_n, wb_clk_i, wb_rst_i, txsfifo_wdata, txsfifo_wen);
	input			clk_xgmii_tx;
	input			reset_xgmii_tx_n;
	input			wb_clk_i;
	input			wb_rst_i;
	input	[13:0]		txsfifo_wdata;
	input			txsfifo_wen;
	output	[13:0]		txsfifo_rdata;
	output			txsfifo_rempty;
	generic_fifo #(.DWIDTH(14), .AWIDTH(4), .REGISTER_READ(1), .EARLY_READ(
		1), .CLOCK_CROSSING(1), .ALMOST_EMPTY_THRESH(7), .
		ALMOST_FULL_THRESH(12), .MEM_TYPE(1)) fifo0(
		.wclk				(clk_xgmii_tx), 
		.wrst_n				(reset_xgmii_tx_n), 
		.wen				(txsfifo_wen), 
		.wdata				(txsfifo_wdata), .wfull(), 
		.walmost_full(), 
		.rclk				(wb_clk_i), 
		.rrst_n				((~wb_rst_i)), 
		.ren				(1'b1), 
		.rdata				(txsfifo_rdata), 
		.rempty				(txsfifo_rempty), 
		.ralmost_empty());
endmodule

/*
                    instances: 0
                        nodes: 8 (0)
                  node widths: 34 (0)
                        ports: 8 (0)
                        ports: 1 (0)
                 portconnects: 12 (0)
*/


module rx_stats_fifo(rxsfifo_rdata, rxsfifo_rempty, clk_xgmii_rx,
	reset_xgmii_rx_n, wb_clk_i, wb_rst_i, rxsfifo_wdata, rxsfifo_wen);
	input			clk_xgmii_rx;
	input			reset_xgmii_rx_n;
	input			wb_clk_i;
	input			wb_rst_i;
	input	[13:0]		rxsfifo_wdata;
	input			rxsfifo_wen;
	output	[13:0]		rxsfifo_rdata;
	output			rxsfifo_rempty;
	generic_fifo #(.DWIDTH(14), .AWIDTH(4), .REGISTER_READ(1), .EARLY_READ(
		1), .CLOCK_CROSSING(1), .ALMOST_EMPTY_THRESH(7), .
		ALMOST_FULL_THRESH(12), .MEM_TYPE(1)) fifo0(
		.wclk				(clk_xgmii_rx), 
		.wrst_n				(reset_xgmii_rx_n), 
		.wen				(rxsfifo_wen), 
		.wdata				(rxsfifo_wdata), .wfull(), 
		.walmost_full(), 
		.rclk				(wb_clk_i), 
		.rrst_n				((~wb_rst_i)), 
		.ren				(1'b1), 
		.rdata				(rxsfifo_rdata), 
		.rempty				(rxsfifo_rempty), 
		.ralmost_empty());
endmodule

/*
                    instances: 0
                        nodes: 20 (0)
                  node widths: 294 (0)
                      process: 2 (0)
                        ports: 14 (0)
*/


module stats_sm(stats_tx_octets, stats_tx_pkts, stats_rx_octets, stats_rx_pkts,
	wb_clk_i, wb_rst_i, txsfifo_rdata, txsfifo_rempty, rxsfifo_rdata,
	rxsfifo_rempty, clear_stats_tx_octets, clear_stats_tx_pkts,
	clear_stats_rx_octets, clear_stats_rx_pkts);
	input			wb_clk_i;
	input			wb_rst_i;
	input	[13:0]		txsfifo_rdata;
	input			txsfifo_rempty;
	input	[13:0]		rxsfifo_rdata;
	input			rxsfifo_rempty;
	input			clear_stats_tx_octets;
	input			clear_stats_tx_pkts;
	input			clear_stats_rx_octets;
	input			clear_stats_rx_pkts;
	output	[31:0]		stats_rx_octets;

	reg	[31:0]		stats_rx_octets;
	output	[31:0]		stats_rx_pkts;
	reg	[31:0]		stats_rx_pkts;
	output	[31:0]		stats_tx_octets;
	reg	[31:0]		stats_tx_octets;
	output	[31:0]		stats_tx_pkts;
	reg	[31:0]		stats_tx_pkts;
	reg			txsfifo_rempty_d1;
	reg			rxsfifo_rempty_d1;
	reg	[31:0]		next_stats_tx_octets;
	reg	[31:0]		next_stats_tx_pkts;
	reg	[31:0]		next_stats_rx_octets;
	reg	[31:0]		next_stats_rx_pkts;

	always @(posedge wb_clk_i or posedge wb_rst_i) begin
	  if (wb_rst_i == 1'b1) begin
	    txsfifo_rempty_d1 <= 1'b1;
	    rxsfifo_rempty_d1 <= 1'b1;
	    stats_tx_octets <= 32'b0;
	    stats_tx_pkts <= 32'b0;
	    stats_rx_octets <= 32'b0;
	    stats_rx_pkts <= 32'b0;
	  end
	  else
	    begin
	      txsfifo_rempty_d1 <= txsfifo_rempty;
	      rxsfifo_rempty_d1 <= rxsfifo_rempty;
	      stats_tx_octets <= next_stats_tx_octets;
	      stats_tx_pkts <= next_stats_tx_pkts;
	      stats_rx_octets <= next_stats_rx_octets;
	      stats_rx_pkts <= next_stats_rx_pkts;
	    end
	end
	always @(clear_stats_rx_octets or clear_stats_rx_pkts or 
		clear_stats_tx_octets or clear_stats_tx_pkts or rxsfifo_rdata or
		rxsfifo_rempty_d1 or stats_rx_octets or stats_rx_pkts or 
		stats_tx_octets or stats_tx_pkts or txsfifo_rdata or 
		txsfifo_rempty_d1) begin
	  next_stats_tx_octets = ({32 {(~clear_stats_tx_octets)}} &
		  stats_tx_octets);
	  next_stats_tx_pkts = ({32 {(~clear_stats_tx_pkts)}} & stats_tx_pkts);
	  next_stats_rx_octets = ({32 {(~clear_stats_rx_octets)}} &
		  stats_rx_octets);
	  next_stats_rx_pkts = ({32 {(~clear_stats_rx_pkts)}} & stats_rx_pkts);
	  if (!txsfifo_rempty_d1) begin
	    next_stats_tx_octets = (next_stats_tx_octets + {18'b0,
		    txsfifo_rdata});
	    next_stats_tx_pkts = (next_stats_tx_pkts + 32'b1);
	  end
	  if (!rxsfifo_rempty_d1) begin
	    next_stats_rx_octets = (next_stats_rx_octets + {18'b0,
		    rxsfifo_rdata});
	    next_stats_rx_pkts = (next_stats_rx_pkts + 32'b1);
	  end
	end
endmodule

/*
                    instances: 0
                        nodes: 22 (0)
                  node widths: 198 (0)
                        ports: 18 (0)
                        ports: 3 (0)
                 portconnects: 30 (0)
*/


`protected
:9+8RJH\bC@CPW.L@/A]DHQY7^R:<^[c)BR:@Y4)aO3FTOgR+LO+1):,GA@DQ6_.
CWNUaSGfW37?4DO?cfQ>NU\NG6.d^(ZL?3TRb].+?09G#=c,dYNT1+Ec)a\dd^QT
(-LYTR[c<,3XUEgK;]PM++?UCEI>2(0J+>fYX:e>UO(QZ:+2LO[#AX58E7ZaZRRe
(g^2Gf<Q=b4P1O9.8-77O.9H3\\R/VeRZPZ#Ff9DZ;.+;TPEHH:Rb7OW-CWa6]6(
e3Gbg<4FY6]N^:SNF5PFD&J)&?EN8EVOJV-H1e<f.W[-JGYed+9U#VYR,XFG;;9B
fK&)P>OZGHQXVVVW>Z;gfQHS\#cOQF3A(b:=F&B<]C>MV92#G??Ha^g7#;9/=BRI
Ag[O=Y&@3T4M7GJeEd=aTGBWd9eR1T>U>^XA9I2Y/b0I5>5bIeD<U,L1/MV/FN:;
IS(^:_?)AUea0H-4A],>-TZ?V0WGG:>61:G]/9:W8Ig\Rd-g=EW-fUF7/M4[QPIf
QP4&4A>V;e,Y-EDfYOO.H.-K3K(W]E7[<UZ<=NO1^ML\R>#U_GVg;C9NK0\a.7Z4
-;I.++#ee@^YOg<U<]FJ&DNL5Zg)A8e<@b[MbQU=fQ>1NQ2G;S\d_Gd_H<L<?N=D
A(Bb3OgdB^V##4SX?GOP(AYPf2@?9;4\RW:@@BJFF<J=\>dbVL6&M2Kc;^&8.A,F
RUU)f(D+4?Y3@5=H,HMQ&N(eT<2])+Z3&f)01/F\KVJX,T6J=)G&91N8+OKf1B(I
W_TB>E)-dAd=?Z;U1PdR-]8J73[HZ^D5I-TIY5.Z2)b9&F/-.YE#@b[>g:5[cTKa
CQTGH\e^CQ#\O5fIc9E6LF]M?O\_A@D=PC=8#7)=WVBL@e0W\,+gPcK&\N7?f-.)
dH)GVfP4TTZ?/.UVBHRE>N_T3/g1eW<7#T9c<PB>ALUTY60\^/);U\gFFW+.f<E)
HNaLW0(F&X=?@>P]=EV04+Z6HZ911O7K7;gH3_M?]3>Y1Q53NUb[6RO7dD+HPEH/
H+Y3>-1B5gVS3Lc6_d-(-0FHMNYVCL#(@(c@0GZ7+SCFXeUGJEN65=4dR_W[3&XQ
B7#HP>CW(NP<GLe>(<(59E<1P]f#4NIENL7[3FO7-@KXd8XX6e=W#2A?7<a4ZVBT
,BJ,deP35<0IO#AK,@FRa=TJ.g1PIeP>P61=T+CC0W,PdJ1[-R0C(GSTMI[-9FbC
;b@:=/,Uf<-[UOcF:7]<cMDOT+geG60BfVe#N=_\4)-fP[2YSC)0&23g)Z&c6MC9
3\OaHe10ZA_OeZe^EQ\Z?@LR:>&3d+PK&EZG4_a;E?HXS:dABT,R-@<aP)ffKGY9
cB^XWAA^eI_SUL4DINHI^cGIdPA5ZD]a_FeT8&?)UA?MH6<^]2c[I?ePYY2Q,7J7
S2QD_UJb.\YVG?d&&NV[(;-1QQ:2cYOY&6BZd0.gZ;Vd5_<)+>6>Wa,X]M<MDW#C
-Bb2X?Gg@V?c\KCg#A-VgHF8<DDXe],F6Jd#/Da?c5CR;OSIU\^01L#QIZRcUXX0
\c?6FQ_a_SQ1J5USDU5gKXHL.PPNRHd_C6)d87NeKY[]N?A#1EUDYBcL_R<,=<@3
R06XU-U\3APHC;.?[^>3L&;KA0P=8(ALJcT2ES>N-./20J?(CVTOC&-\EL&<ESXT
T57EXQ,g2FZON_2VSNP61Q+4a6L53;8]5K9=]_,=SL>+LK]-><\O((bDAPMI\#M]
>^g4V3UVHf8dH>&(E<1Q(HCESd)>W_P#8L\7gO-;4[=HW/R[4SN;Z)f>Jf\=5faA
&1(S&OXVa7/O2SL3Od#d.ZPZ17Yf(UF0;+CLQ;L?O_V//\JQ0g^&;\6UMM/<)Ja9
/;OKbJ>F<XVV4-0;OQ<;[P/KR?]7LcFN7G3JZOGZf?YM8ZS(B]5.=_R3]eV^,-Ea
KL);J:#7XP@;g?g[8LPK.O=OS.0Se&.&D>FRSbJ_^6DaM,&BSeaV3;>929bP]O&W
:M^:63cc,aG:\E,+&3W2@?/295HJ;;bZe49>D.OJa8[f;1bITZ6#WIaU7.b&-aMD
cRP?9EAd0:1,^?=5^39H/Z=aH9F3:Ga>5V3_/6>1WP/a#N/-ZGe^YBWW/2T]C?CI
ObA9gaK/QOe5F#@T=CQCaXHIX@+UW-gNM^7KQ]WOQcP1:XX@Q:c6MR.gIe8CP[K3
XeX].C]Vf0;Qb@<W?,LcR>5F[6R+7F=24U-I6:LS1AH/L9(5d&WPaJ\CW9/VU6]R
109f6HDUP#)Eg=#EM0>dG.SOa19&2Jg\WIM=afa8TZ)aV39Bf]_UMX6Q,XH[_EF6
M:J/FOeNYJQFDa)eTI)5,HaX+0IDYQ;<gRJd[;1(XPg,:HDRXM&J^N8@e[X(#XF=
\N-YH6.N&=0,+>0F@6C-,\dH46ZbS#JJf7X>HA6Z5:/E@,D#fa&QT&1F<E-=,@J3
PG&ZKdUfe1;+2M+CN2ZS58S2Fd.8OEV>7&XY.M:g_abM;.-P7P:J^a7?YY(#C6Rd
V22U0P[E8^LQOHG,;J0G46S0f>S6M4:-6:7fXQeD/8UPA2cY^IRFg>_9f,@Fa(5W
>9J;D;T8,A]X^AYDfV8:b8WfYf_]<&;QR;7KFSB4-/?X@,M^#NgZe9#&LAI\QUE&
X:gI#Aa+\EC?gH8XP\PTAQ/VbBbRQ^7g</D7Bg&V6>a_[A6]/-,OA]Qg96]7.A3I
aF69TT7=OFa8W(A]NE@T.Vc[00EbG4X#H^V^+?(,[(8?A1HKTf)4&=HUNH&NH[W;
6&S62A>U)9f0Z.<7bUW/#/T[,)S0Ag3d/(0ZNEF8[_JJaYdS8Q>K,JH+782E&1_W
+Xcd1:KBe1B:CG?Y^Q.A8UfZIEa@=9RKZTNE3(U-3_4-Nc)_-E1XSGQR&Taa/E<P
9g[BIU<\DfM)IMcF;9LL<KKG:?A./L:\9?88DP=<#WaHA[H]62\R/2\4PA]ZReN8
(^\23Tf>8,-#?.GD\RD9ZN+ePW:DJCOH)E;O?H-48T>O4&&1B-7L.2?ZEgHGP1f&
/(0O\4]2X9KYLPA[G(&_d>,6=L=<XYRVAP?5NYb,FJ1;?\H)]](dSGf8JcV?V5E@
OD\-20>JFAfQDG;(9L?[DY<30,:-cUAQ6O]3LAYBZD6.OY957@gUKO=F9:Pa572(
N)>.+E63?59U[f2=&I:ADgb-\S:S>,T?<+B#eUNO)-3Q@@g]XBRWWMVA-5NDYAB^
4[FM-7CPLJCg9E68f)HE:DY[<]8<OCdWUeS+a2X\A>U4F\F205V26P-?3,B,KH<F
[N)6?(Scd63C,G]eCE9#&U^-0/5Z&[ZH6)?LeR+GK]TWE6U@f0+._MgbD<=,:F0>
6-Fec[^CS=CLREa0C=EBUK21X:M1+=f#1OJO_&<cTZ;B&X1,9FYfDGcP-.OYG&B=
G2GR2R:;@0[B2_b?dBE)&Q\UCCQ3II919M(PdFc6cE/?E+<5Sd6/#61[TKR,A,\]
^9CY.B@=VGPR\<<<W^Z:6a4OLfd8E/8[+K4=DIH#+HN<\0S(e8);+)5XOA&M^F;&
:dZ(Gc@PWcDYS#YZ?;9/5L:5cAa>dY0XcPa&)[;9fY2M2T</^deJ/_(3]YbTgYIW
6Y>3(R7(BE^BQ2L)2=62(AZN//L-Te-)Xf&_^P4W^=T_V]EN6,LC(&5(T7JD47Bc
=d;?I?JF_<\=^_Mg3A5d6LE.(;5:(TXbc601\O,Caaa>JM,>[D+L/X-5=dVZ?15Q
J@7/P,>1aI<\Z2d.e79U5ad5PSAMaQKB;F.He9-D32E,3fVPVMcGK(+MBa)K-9g/
c<-4@/D-1RA:9[Z9@5aNbU_5A?^NZ;J]C\8_M0b9]^=LC8+FV)T>_HCa-DLJW2^]
T7aQD-=:1C.EH<07/(ZTF+2c-;N0GZPO<BPa521/L__K[<Z<ZXI.>f9OVVG]:0e9
+IS^3b[],RRL,1&bH8Z#-ZF#5@bM&cA]12a^Y/agH>1e<Q^0LBAfA2(]S]:<JWY/
T]UHE\,<Y:OZ\c@E:)@(<^MI\,1,9gU#dBTe3#06SN^SH:V9(,-9=ON@CT:6?36?
W)Mb54-7T,6Y5H,a[F91]KR3H_C:MS9.,S28G(U@JYJF,C]W4#b),Da,Wa/I)3HP
be2)6f)QS95XSGRXJEFfW6P1I]T3-]bMBcB9_[S;9Xae7G32TJ=F&CNO<&T=0,GH
IXVN+]\(]_+IWKXZCHS5g>1G)4FAS.TI1?1[A5d.#?AZ6Fc)gaNEWTQg2-fV>5?B
gB8O\]?2d,0UB@GX^:1#85.N?S.+:/094Yg(X0G7E?6eQP-J0)1ZY;RJ-1[Z-XG;
9]=Y/beb;,1&G2B)dRC2HT#a1CFE=WK0WD)E=X/E15=3LP9D^SBTP#(fR=Bdb/Tg
/:+a,LGRA8c^9)]P6.+eD9(A8+/5E9@/:&T3D??+KP9,^eNF(fI:fg+cBLGBM<:-
DMH^1YO0T+?:JI5Vf(bcN_5D,ZB=+V5=[^,\#LT-J-(N9V&BF#Y07)1Eg<@BQAGH
1XbOJ1HRGT4)eG1Oc>9UO]\.A4T:f1>g)0R-aIXB1d@REG+3S=TfFGb,a^EL\.88
IDZ^],7KS<cg4B:=C/@a&8dU6I5UdRaVZMTf2&;>.)?&JC=@())>_3[VOCAR0/5a
;#5a?S4+a(;ecL/b60K,,72fd#?W+45gLO)F/aEH#.<a:[B6-bbS^a(9bWed&.B8
VRdgL;N)9Aac]#K1OXaV)KPYf+0:9JZ6&U2>[J1RMS[TP<?&B<LN#B,Y&CZ#cGH9
FFQK&Qd8=8gA9Mb][>RH:\.P4+-IW=NAgV2RVW=^Jf/-fZZea],R[^WMF4D&-E2b
O,=H.-\K,J]d5S#AVFb&5Db9;PHUf-69e\C/TZ:4:UAKM:O=#A,#[7-WQ&aP@+db
E.:ef80cTf&EfgR</bT9-SNe(e).CQ+]?QPR6AOA#Ibe\AZ8cQ2eJ;Q]G=^fY3>>
..A/W/W>\OB&Z.Db]Pc(/B7[@-Q\Q<bGfM[D5IZ9>VSNM(1/+Q4V\C:FaHDBff0a
?RX<T7a<b[(#4QCe7.A&R^7RfXRL;f;0[[+.OOKT7H4N@GITG5-T^V,Z,4^#2)Z#
,VKaXDb+XQCP_(4^^[N&ZDFG60O1Q8BZf2@cZ7(WE(\+AM9[L\b&5)H^bc&;:TD8
@OK,VQEKHYLX_0J7MT)G.S<H[0Q<2NJ/2U?VMG<45IODFLO;1YJR:=GJ1(a5>7M5
J],=SHD25eA(YE3(0;c+X>L_b0>35092OISK9EYR=W0/Ua7X)HZ;T2fI_M.C,O#=
5UJ=SF&ECANX[0&(AZ7f3X>=N)_=_^\:g:AP<#&&@-GT(792eZOH_2FBU1DgAV9P
a)JEbfT8@J2Q8BG.=#M^5:#USNQKMZd#]\<#SE<=dZb6VUbEV#SX=De68>:gf-7g
fJ>52[](eDQ8S9Y(NA:B>8NZW_2bD>WXCN9LCQY(^?M=F=gM+\)Y:[bBV&^)T.WJ
PRQB9d04],C#bAU=9=K3c3SY8]5/]&d/&L5HWIYNFYLa7_V_9?/^RC-CcT\[dTe7
=J6Z820bBL2T:,H\IBH\9+&cN>O0F\Ib:ZZTW)BLX5H=E2DDM5[)D#O09ULe)V_7
J?FN,,S^Ob2We@-LWUa/4g5BIdR,<0Y(N9AEMKO0HHb_d]GI5,+H?4a-OKS.fNCF
_#E<_-?1ZFIH7OP;deZINQe&c]4.W,e2Ta(WT\a66D]6FGT6g116T0(5:_]D^eHQ
VAOW;4E:fM4EIM]TgH)(bZ[=EXN:[(g\HJ]<ULA7ZF6:\=NE^5>[:>T8gF@D)-)/
.^&<)2Ib:Q)eR<?V#M@6X(+92dNT#YV=aeJMV1\/0Z.(SI,c_((4&+H0c[>.K^E;
OA:CV;)DUeU\A)(&D^5e;VJ[>eWLX#DV<41De<_+VcC.P1Q;b&>G6d4I)c>R[_/e
&a\g,BP1/#_,3Ob1DLeAG0O.YU\<&F9dKAKB]M?B8c?Z.J@G#JV50);Na+BTCKG&
&I_/c=Y:-T9>>26D,80A__,\SgIZ6bRM_\?.)/BK.)5?LdZSE-?WIO_?L-3@&9BQ
)6ERK@6\<d6?<=UYKR04X;RB#<^Z^=XaG?-bMZF-&>XBH?@N?#_WR#ESY:X;eKLe
ND=d/H9]^Cg6QG)-@A?a.+3.;+V5K-J01&eXdTCcXePY3HY_D]gZVTT??SBP\J-\
JSATC6GJJN9_?WJ<:ZIC_>CS.8.dB6)EOe9=VLG)eeWK9<V6b\D7:PPI]::W:NVA
CTNL[GIT4IX^PfT4018)6-H]C2U)67Og;_)L5?CDMSa@Gb/HRDe]Y).I:KK<(d]\
f_(,Q@,VGD-^<&YdAEN;6=]&QKYf182fD:F,VQWA>CK)0@b\-U7d+H-<J\gFXV^A
84,ZZ.UHID6KFO-d?1HPGMZG8XDIg,1CA#bY2NZEUL<91fcN.:-ZFMIW(9.LLNW6
(e39bKQB8bgP,VWF)C7\bA\O5NYZCT&G@7@-(4\0f/,I<8HOHX3F#2.T(5_/>2]O
BJOJ?&3P1d_G&5D@D,-)Hc=71HEfaCKR+R=R]9:I:eccKD;B3Vb\g\UVY[c?;fd\
)]V:BAM(0N5H]#Lb#VI-10#d.[CBb3P#Rg,QPb);/^+WGXfbdggcK(Wg/aJE3OS1
BL9_=6&XZ/LC,-9(gGZN)YZXbEOA4)OW&,QJ_5+#25?AeJ<1ZT3dX=/K-:1#,9cH
N(65RE.6B+:8b8:L1EM>TEaKN&HLU8d.)+cE)bG08^#\1gCbA)/Va#R>Ub.PTDXY
/B@YaBTOS/\)UO>:MNS]b:De(VN_Ib(+HQ)YIM)Ce@ZOC/^-/;BW)M^[[@IC81PD
^,(-?d^CfC1.Wa(.Te5.dHO/Y/HAHOT(R#F385\:<U)CYQQc0#CW2[,#K,[9ZE@M
7b(d5EDP:&0,M@_9P+&G>,Ig4g6<N[0#]IdSf+3@1NX<)c=cZKHg2H^<g9HgC?]G
FBXAC+RX2-N)I0V51+,(C&,OCS@I\3:J0-(AW2C^U[d6\g_&K9CPFX)RMc,BbV[T
M/7U=QIJ_d1=JOK8@4ddLWcCBAKaMP(<,A3QT+RX4<7EZP^ESA=5ZUg_@&aM\eE3
SY.eFS.7-f1GE7e?EG8A&OXG.XE/<&XgNM,7d]V-N8P4ZI:=X,W74f(/IKJHU[c<
P-UPOVZ=,I.-+Df_RZ6-g5e&;JNdYbT:Mc_)[(eBDZe-=\G0LB(aS,Z#XBH-E[9G
N^f7[J0,1F=ffDPG.CDIWZe&7$
`endprotected

/*
                    instances: 0
                        nodes: 109 (0)
                  node widths: 1160 (0)
                        ports: 34 (0)
                        ports: 13 (0)
                 portconnects: 212 (0)
*/


module xge_mac(xgmii_txd, xgmii_txc, wb_int_o, wb_dat_o, wb_ack_o, pkt_tx_full,
	pkt_rx_val, pkt_rx_sop, pkt_rx_mod, pkt_rx_err, pkt_rx_eop, pkt_rx_data,
	pkt_rx_avail, xgmii_rxd, xgmii_rxc, wb_we_i, wb_stb_i, wb_rst_i,
	wb_dat_i, wb_cyc_i, wb_clk_i, wb_adr_i, reset_xgmii_tx_n,
	reset_xgmii_rx_n, reset_156m25_n, pkt_tx_val, pkt_tx_sop, pkt_tx_mod,
	pkt_tx_eop, pkt_tx_data, pkt_rx_ren, clk_xgmii_tx, clk_xgmii_rx,
	clk_156m25);
	input			clk_156m25;
	input			clk_xgmii_rx;
	input			clk_xgmii_tx;
	input			pkt_rx_ren;
	input	[63:0]		pkt_tx_data;
	input			pkt_tx_eop;
	input	[2:0]		pkt_tx_mod;
	input			pkt_tx_sop;
	input			pkt_tx_val;
	input			reset_156m25_n;
	input			reset_xgmii_rx_n;
	input			reset_xgmii_tx_n;
	input	[7:0]		wb_adr_i;
	input			wb_clk_i;
	input			wb_cyc_i;
	input	[31:0]		wb_dat_i;
	input			wb_rst_i;
	input			wb_stb_i;
	input			wb_we_i;
	input	[7:0]		xgmii_rxc;
	input	[63:0]		xgmii_rxd;
	output			pkt_rx_avail;
	output	[63:0]		pkt_rx_data;
	output			pkt_rx_eop;
	output			pkt_rx_err;
	output	[2:0]		pkt_rx_mod;
	output			pkt_rx_sop;
	output			pkt_rx_val;
	output			pkt_tx_full;
	output			wb_ack_o;
	output	[31:0]		wb_dat_o;
	output			wb_int_o;
	output	[7:0]		xgmii_txc;
	output	[63:0]		xgmii_txd;

	wire			clear_stats_rx_octets;
	wire			clear_stats_rx_pkts;
	wire			clear_stats_tx_octets;
	wire			clear_stats_tx_pkts;
	wire			ctrl_tx_enable;
	wire			ctrl_tx_enable_ctx;
	wire	[1:0]		local_fault_msg_det;
	wire	[1:0]		remote_fault_msg_det;
	wire			rxdfifo_ralmost_empty;
	wire	[63:0]		rxdfifo_rdata;
	wire			rxdfifo_rempty;
	wire			rxdfifo_ren;
	wire	[7:0]		rxdfifo_rstatus;
	wire	[63:0]		rxdfifo_wdata;
	wire			rxdfifo_wen;
	wire			rxdfifo_wfull;
	wire	[7:0]		rxdfifo_wstatus;
	wire			rxhfifo_ralmost_empty;
	wire	[63:0]		rxhfifo_rdata;
	wire			rxhfifo_rempty;
	wire			rxhfifo_ren;
	wire	[7:0]		rxhfifo_rstatus;
	wire	[63:0]		rxhfifo_wdata;
	wire			rxhfifo_wen;
	wire	[7:0]		rxhfifo_wstatus;
	wire	[13:0]		rxsfifo_wdata;
	wire			rxsfifo_wen;
	wire	[31:0]		stats_rx_octets;
	wire	[31:0]		stats_rx_pkts;
	wire	[31:0]		stats_tx_octets;
	wire	[31:0]		stats_tx_pkts;
	wire			status_crc_error;
	wire			status_crc_error_tog;
	wire			status_fragment_error;
	wire			status_fragment_error_tog;
	wire			status_lenght_error;
	wire			status_lenght_error_tog;
	wire			status_local_fault;
	wire			status_local_fault_crx;
	wire			status_local_fault_ctx;
	wire			status_pause_frame_rx;
	wire			status_pause_frame_rx_tog;
	wire			status_remote_fault;
	wire			status_remote_fault_crx;
	wire			status_remote_fault_ctx;
	wire			status_rxdfifo_ovflow;
	wire			status_rxdfifo_ovflow_tog;
	wire			status_rxdfifo_udflow;
	wire			status_rxdfifo_udflow_tog;
	wire			status_txdfifo_ovflow;
	wire			status_txdfifo_ovflow_tog;
	wire			status_txdfifo_udflow;
	wire			status_txdfifo_udflow_tog;
	wire			txdfifo_ralmost_empty;
	wire	[63:0]		txdfifo_rdata;
	wire			txdfifo_rempty;
	wire			txdfifo_ren;
	wire	[7:0]		txdfifo_rstatus;
	wire			txdfifo_walmost_full;
	wire	[63:0]		txdfifo_wdata;
	wire			txdfifo_wen;
	wire			txdfifo_wfull;
	wire	[7:0]		txdfifo_wstatus;
	wire			txhfifo_ralmost_empty;
	wire	[63:0]		txhfifo_rdata;
	wire			txhfifo_rempty;
	wire			txhfifo_ren;
	wire	[7:0]		txhfifo_rstatus;
	wire			txhfifo_walmost_full;
	wire	[63:0]		txhfifo_wdata;
	wire			txhfifo_wen;
	wire			txhfifo_wfull;
	wire	[7:0]		txhfifo_wstatus;
	wire	[13:0]		txsfifo_wdata;
	wire			txsfifo_wen;
	rx_enqueue rx_eq0(
		.rxdfifo_wdata			(rxdfifo_wdata[63:0]), 
		.rxdfifo_wstatus		(rxdfifo_wstatus[7:0]), 
		.rxdfifo_wen			(rxdfifo_wen), 
		.rxhfifo_ren			(rxhfifo_ren), 
		.rxhfifo_wdata			(rxhfifo_wdata[63:0]), 
		.rxhfifo_wstatus		(rxhfifo_wstatus[7:0]), 
		.rxhfifo_wen			(rxhfifo_wen), 
		.local_fault_msg_det		(local_fault_msg_det[1:0]), 
		.remote_fault_msg_det		(remote_fault_msg_det[1:0]), 
		.status_crc_error_tog		(status_crc_error_tog), 
		.status_fragment_error_tog	(status_fragment_error_tog), 
		.status_lenght_error_tog	(status_lenght_error_tog), 
		.status_rxdfifo_ovflow_tog	(status_rxdfifo_ovflow_tog), 
		.status_pause_frame_rx_tog	(status_pause_frame_rx_tog), 
		.rxsfifo_wen			(rxsfifo_wen), 
		.rxsfifo_wdata			(rxsfifo_wdata[13:0]), 
		.clk_xgmii_rx			(clk_xgmii_rx), 
		.reset_xgmii_rx_n		(reset_xgmii_rx_n), 
		.xgmii_rxd			(xgmii_rxd[63:0]), 
		.xgmii_rxc			(xgmii_rxc[7:0]), 
		.rxdfifo_wfull			(rxdfifo_wfull), 
		.rxhfifo_rdata			(rxhfifo_rdata[63:0]), 
		.rxhfifo_rstatus		(rxhfifo_rstatus[7:0]), 
		.rxhfifo_rempty			(rxhfifo_rempty), 
		.rxhfifo_ralmost_empty		(rxhfifo_ralmost_empty));
	rx_dequeue rx_dq0(
		.rxdfifo_ren			(rxdfifo_ren), 
		.pkt_rx_data			(pkt_rx_data[63:0]), 
		.pkt_rx_val			(pkt_rx_val), 
		.pkt_rx_sop			(pkt_rx_sop), 
		.pkt_rx_eop			(pkt_rx_eop), 
		.pkt_rx_err			(pkt_rx_err), 
		.pkt_rx_mod			(pkt_rx_mod[2:0]), 
		.pkt_rx_avail			(pkt_rx_avail), 
		.status_rxdfifo_udflow_tog	(status_rxdfifo_udflow_tog), 
		.clk_156m25			(clk_156m25), 
		.reset_156m25_n			(reset_156m25_n), 
		.rxdfifo_rdata			(rxdfifo_rdata[63:0]), 
		.rxdfifo_rstatus		(rxdfifo_rstatus[7:0]), 
		.rxdfifo_rempty			(rxdfifo_rempty), 
		.rxdfifo_ralmost_empty		(rxdfifo_ralmost_empty), 
		.pkt_rx_ren			(pkt_rx_ren));
	rx_data_fifo rx_data_fifo0(
		.rxdfifo_wfull			(rxdfifo_wfull), 
		.rxdfifo_rdata			(rxdfifo_rdata[63:0]), 
		.rxdfifo_rstatus		(rxdfifo_rstatus[7:0]), 
		.rxdfifo_rempty			(rxdfifo_rempty), 
		.rxdfifo_ralmost_empty		(rxdfifo_ralmost_empty), 
		.clk_xgmii_rx			(clk_xgmii_rx), 
		.clk_156m25			(clk_156m25), 
		.reset_xgmii_rx_n		(reset_xgmii_rx_n), 
		.reset_156m25_n			(reset_156m25_n), 
		.rxdfifo_wdata			(rxdfifo_wdata[63:0]), 
		.rxdfifo_wstatus		(rxdfifo_wstatus[7:0]), 
		.rxdfifo_wen			(rxdfifo_wen), 
		.rxdfifo_ren			(rxdfifo_ren));
	rx_hold_fifo rx_hold_fifo0(
		.rxhfifo_rdata			(rxhfifo_rdata[63:0]), 
		.rxhfifo_rstatus		(rxhfifo_rstatus[7:0]), 
		.rxhfifo_rempty			(rxhfifo_rempty), 
		.rxhfifo_ralmost_empty		(rxhfifo_ralmost_empty), 
		.clk_xgmii_rx			(clk_xgmii_rx), 
		.reset_xgmii_rx_n		(reset_xgmii_rx_n), 
		.rxhfifo_wdata			(rxhfifo_wdata[63:0]), 
		.rxhfifo_wstatus		(rxhfifo_wstatus[7:0]), 
		.rxhfifo_wen			(rxhfifo_wen), 
		.rxhfifo_ren			(rxhfifo_ren));
	tx_enqueue tx_eq0(
		.pkt_tx_full			(pkt_tx_full), 
		.txdfifo_wdata			(txdfifo_wdata[63:0]), 
		.txdfifo_wstatus		(txdfifo_wstatus[7:0]), 
		.txdfifo_wen			(txdfifo_wen), 
		.status_txdfifo_ovflow_tog	(status_txdfifo_ovflow_tog), 
		.clk_156m25			(clk_156m25), 
		.reset_156m25_n			(reset_156m25_n), 
		.pkt_tx_data			(pkt_tx_data[63:0]), 
		.pkt_tx_val			(pkt_tx_val), 
		.pkt_tx_sop			(pkt_tx_sop), 
		.pkt_tx_eop			(pkt_tx_eop), 
		.pkt_tx_mod			(pkt_tx_mod[2:0]), 
		.txdfifo_wfull			(txdfifo_wfull), 
		.txdfifo_walmost_full		(txdfifo_walmost_full));
	tx_dequeue tx_dq0(
		.txdfifo_ren			(txdfifo_ren), 
		.txhfifo_ren			(txhfifo_ren), 
		.txhfifo_wdata			(txhfifo_wdata[63:0]), 
		.txhfifo_wstatus		(txhfifo_wstatus[7:0]), 
		.txhfifo_wen			(txhfifo_wen), 
		.xgmii_txd			(xgmii_txd[63:0]), 
		.xgmii_txc			(xgmii_txc[7:0]), 
		.status_txdfifo_udflow_tog	(status_txdfifo_udflow_tog), 
		.txsfifo_wen			(txsfifo_wen), 
		.txsfifo_wdata			(txsfifo_wdata[13:0]), 
		.clk_xgmii_tx			(clk_xgmii_tx), 
		.reset_xgmii_tx_n		(reset_xgmii_tx_n), 
		.ctrl_tx_enable_ctx		(ctrl_tx_enable_ctx), 
		.status_local_fault_ctx		(status_local_fault_ctx), 
		.status_remote_fault_ctx	(status_remote_fault_ctx), 
		.txdfifo_rdata			(txdfifo_rdata[63:0]), 
		.txdfifo_rstatus		(txdfifo_rstatus[7:0]), 
		.txdfifo_rempty			(txdfifo_rempty), 
		.txdfifo_ralmost_empty		(txdfifo_ralmost_empty), 
		.txhfifo_rdata			(txhfifo_rdata[63:0]), 
		.txhfifo_rstatus		(txhfifo_rstatus[7:0]), 
		.txhfifo_rempty			(txhfifo_rempty), 
		.txhfifo_ralmost_empty		(txhfifo_ralmost_empty), 
		.txhfifo_wfull			(txhfifo_wfull), 
		.txhfifo_walmost_full		(txhfifo_walmost_full));
	tx_data_fifo tx_data_fifo0(
		.txdfifo_wfull			(txdfifo_wfull), 
		.txdfifo_walmost_full		(txdfifo_walmost_full), 
		.txdfifo_rdata			(txdfifo_rdata[63:0]), 
		.txdfifo_rstatus		(txdfifo_rstatus[7:0]), 
		.txdfifo_rempty			(txdfifo_rempty), 
		.txdfifo_ralmost_empty		(txdfifo_ralmost_empty), 
		.clk_xgmii_tx			(clk_xgmii_tx), 
		.clk_156m25			(clk_156m25), 
		.reset_xgmii_tx_n		(reset_xgmii_tx_n), 
		.reset_156m25_n			(reset_156m25_n), 
		.txdfifo_wdata			(txdfifo_wdata[63:0]), 
		.txdfifo_wstatus		(txdfifo_wstatus[7:0]), 
		.txdfifo_wen			(txdfifo_wen), 
		.txdfifo_ren			(txdfifo_ren));
	tx_hold_fifo tx_hold_fifo0(
		.txhfifo_wfull			(txhfifo_wfull), 
		.txhfifo_walmost_full		(txhfifo_walmost_full), 
		.txhfifo_rdata			(txhfifo_rdata[63:0]), 
		.txhfifo_rstatus		(txhfifo_rstatus[7:0]), 
		.txhfifo_rempty			(txhfifo_rempty), 
		.txhfifo_ralmost_empty		(txhfifo_ralmost_empty), 
		.clk_xgmii_tx			(clk_xgmii_tx), 
		.reset_xgmii_tx_n		(reset_xgmii_tx_n), 
		.txhfifo_wdata			(txhfifo_wdata[63:0]), 
		.txhfifo_wstatus		(txhfifo_wstatus[7:0]), 
		.txhfifo_wen			(txhfifo_wen), 
		.txhfifo_ren			(txhfifo_ren));
	fault_sm fault_sm0(
		.status_local_fault_crx		(status_local_fault_crx), 
		.status_remote_fault_crx	(status_remote_fault_crx), 
		.clk_xgmii_rx			(clk_xgmii_rx), 
		.reset_xgmii_rx_n		(reset_xgmii_rx_n), 
		.local_fault_msg_det		(local_fault_msg_det[1:0]), 
		.remote_fault_msg_det		(remote_fault_msg_det[1:0]));
	sync_clk_wb sync_clk_wb0(
		.status_crc_error		(status_crc_error), 
		.status_fragment_error		(status_fragment_error), 
		.status_lenght_error		(status_lenght_error), 
		.status_txdfifo_ovflow		(status_txdfifo_ovflow), 
		.status_txdfifo_udflow		(status_txdfifo_udflow), 
		.status_rxdfifo_ovflow		(status_rxdfifo_ovflow), 
		.status_rxdfifo_udflow		(status_rxdfifo_udflow), 
		.status_pause_frame_rx		(status_pause_frame_rx), 
		.status_local_fault		(status_local_fault), 
		.status_remote_fault		(status_remote_fault), 
		.wb_clk_i			(wb_clk_i), 
		.wb_rst_i			(wb_rst_i), 
		.status_crc_error_tog		(status_crc_error_tog), 
		.status_fragment_error_tog	(status_fragment_error_tog), 
		.status_lenght_error_tog	(status_lenght_error_tog), 
		.status_txdfifo_ovflow_tog	(status_txdfifo_ovflow_tog), 
		.status_txdfifo_udflow_tog	(status_txdfifo_udflow_tog), 
		.status_rxdfifo_ovflow_tog	(status_rxdfifo_ovflow_tog), 
		.status_rxdfifo_udflow_tog	(status_rxdfifo_udflow_tog), 
		.status_pause_frame_rx_tog	(status_pause_frame_rx_tog), 
		.status_local_fault_crx		(status_local_fault_crx), 
		.status_remote_fault_crx	(status_remote_fault_crx));
	sync_clk_xgmii_tx sync_clk_xgmii_tx0(
		.ctrl_tx_enable_ctx		(ctrl_tx_enable_ctx), 
		.status_local_fault_ctx		(status_local_fault_ctx), 
		.status_remote_fault_ctx	(status_remote_fault_ctx), 
		.clk_xgmii_tx			(clk_xgmii_tx), 
		.reset_xgmii_tx_n		(reset_xgmii_tx_n), 
		.ctrl_tx_enable			(ctrl_tx_enable), 
		.status_local_fault_crx		(status_local_fault_crx), 
		.status_remote_fault_crx	(status_remote_fault_crx));
	stats stats0(
		.stats_rx_octets		(stats_rx_octets[31:0]), 
		.stats_rx_pkts			(stats_rx_pkts[31:0]), 
		.stats_tx_octets		(stats_tx_octets[31:0]), 
		.stats_tx_pkts			(stats_tx_pkts[31:0]), 
		.clear_stats_rx_octets		(clear_stats_rx_octets), 
		.clear_stats_rx_pkts		(clear_stats_rx_pkts), 
		.clear_stats_tx_octets		(clear_stats_tx_octets), 
		.clear_stats_tx_pkts		(clear_stats_tx_pkts), 
		.clk_xgmii_rx			(clk_xgmii_rx), 
		.clk_xgmii_tx			(clk_xgmii_tx), 
		.reset_xgmii_rx_n		(reset_xgmii_rx_n), 
		.reset_xgmii_tx_n		(reset_xgmii_tx_n), 
		.rxsfifo_wdata			(rxsfifo_wdata[13:0]), 
		.rxsfifo_wen			(rxsfifo_wen), 
		.txsfifo_wdata			(txsfifo_wdata[13:0]), 
		.txsfifo_wen			(txsfifo_wen), 
		.wb_clk_i			(wb_clk_i), 
		.wb_rst_i			(wb_rst_i));
	wishbone_if wishbone_if0(
		.wb_dat_o			(wb_dat_o[31:0]), 
		.wb_ack_o			(wb_ack_o), 
		.wb_int_o			(wb_int_o), 
		.ctrl_tx_enable			(ctrl_tx_enable), 
		.clear_stats_tx_octets		(clear_stats_tx_octets), 
		.clear_stats_tx_pkts		(clear_stats_tx_pkts), 
		.clear_stats_rx_octets		(clear_stats_rx_octets), 
		.clear_stats_rx_pkts		(clear_stats_rx_pkts), 
		.wb_clk_i			(wb_clk_i), 
		.wb_rst_i			(wb_rst_i), 
		.wb_adr_i			(wb_adr_i[7:0]), 
		.wb_dat_i			(wb_dat_i[31:0]), 
		.wb_we_i			(wb_we_i), 
		.wb_stb_i			(wb_stb_i), 
		.wb_cyc_i			(wb_cyc_i), 
		.status_crc_error		(status_crc_error), 
		.status_fragment_error		(status_fragment_error), 
		.status_lenght_error		(status_lenght_error), 
		.status_txdfifo_ovflow		(status_txdfifo_ovflow), 
		.status_txdfifo_udflow		(status_txdfifo_udflow), 
		.status_rxdfifo_ovflow		(status_rxdfifo_ovflow), 
		.status_rxdfifo_udflow		(status_rxdfifo_udflow), 
		.status_pause_frame_rx		(status_pause_frame_rx), 
		.status_local_fault		(status_local_fault), 
		.status_remote_fault		(status_remote_fault), 
		.stats_tx_octets		(stats_tx_octets[31:0]), 
		.stats_tx_pkts			(stats_tx_pkts[31:0]), 
		.stats_rx_octets		(stats_rx_octets[31:0]), 
		.stats_rx_pkts			(stats_rx_pkts[31:0]));
endmodule

/*
                    instances: 0
                        nodes: 48 (0)
                  node widths: 570 (0)
                      process: 10 (0)
                   contassign:  2 (0)
                        ports: 1 (0)
                 portconnects: 34 (0)
*/


