`timescale 1ns/1ns
module tb_top;
    logic clk = 1'b0;
    logic reset = 1'b0;

    always #10 clk = ~clk;

    logic wr_ctrl, empty, wr_ctrl_rdy, waitrequest, rd_from_fifo,
          almost_full, wrreq, capt_buf_wrap;
    logic [31:0] control, pkt_begin, pkt_end, capt_buf_start, capt_buf_size,
                 last_write_addr_in, last_write_addr_out, fifo_out, fifo_in;

    logic [8:0] usedw;
    logic [31:0] seconds, nanoseconds;

    logic [31:0] address;
    logic [31:0] writedata, data_out;
    logic write;
    logic waitrequest_d;

    logic [15:0] burstcount;

    int j = 0;

    wr_ctrl dut(.clk,
                .reset,
                .wr_ctrl,
                .empty,
                .control,
                .pkt_begin,
                .pkt_end,
                .capt_buf_start,
                .capt_buf_size,
                .last_write_addr_in,
                .fifo_out,
                .rd_from_fifo,
                .wr_ctrl_rdy,
                .last_write_addr_out,
                .capt_buf_wrap,
                .usedw,
                .seconds,
                .nanoseconds,
                .address,
                .writedata,
                .write,
                .burstcount,
                .waitrequest);

    fifo fifo_sim(.clock(clk),
                  .data(fifo_in),
                  .rdreq(rd_from_fifo),
                  .sclr(~reset),
                  .wrreq(wrreq),
                  .empty(empty),
                  .almost_full,
                  .q(fifo_out),
                  .usedw);

    timestamp #(.FREQ(50)) ts(.clk,
                              .reset_n(reset),
                              .seconds,
                              .nanoseconds);

    assign waitrequest = waitrequest_d || !write;

    initial begin
        wr_ctrl <= '0;

        control <= '0;
        pkt_begin <= '0;
        pkt_end <= 'hf4;
        capt_buf_start <= 'h8000;
        capt_buf_size <= 'h80;
        last_write_addr_in <= 'h8000;

        data_out <= '0;

        reset <= 1'b0;
        #20
        reset <= 1'b1;

        // pre-fill fifo with some data
        $display("[WR_CTRL_prefill_fifo] T= %t filling fifo", $time);
        for (int i = 0; i < pkt_end; ++i) begin // TODO: if symbols and not words then probably reduce the widths on busses
            wrreq <= 1'b1;
            fifo_in <= i + 'd10;
            #20;
        end
        wrreq <= 1'b0;
        $display("[WR_CTRL_prefill_fifo] T= %t Done filling fifo", $time);

        // Initialize the component: 6 cycles of delay for initialization
        // after wr_ctrl
        // writing to FIFO
        wr_ctrl <= 1'b1;

        #20
        wr_ctrl <= 1'b0;

        #120 // wait for stabilization

        for(int i = 0; i < pkt_end / 4; ++i) begin
            #20
            $display("[WR_CTRL_normal] T= %t fifo_out: %d, received: %d, burstcount: %d, write_address: %x", $time, fifo_out, data_out, burstcount, address);
        end
        #20
        $display("[WR_CTRL_normal] T= %t fifo_out: %d, received: %d, write_address: %x", $time, fifo_out, data_out, address);

        #20
        $display("[WR_CTRL_normal] T= %t after wr_ctrl=0 received: %d, write_address: %x", $time, data_out, address);

        #20
        // second packet
        pkt_begin <= '0;
        pkt_end <= 'hf4;


        #20
        wr_ctrl <= 1'b1;
        for(int i = 0; i < pkt_end / 4; ++i) begin
            #20
            $display("[WR_CTRL_normal] T= %t fifo_out: %d, received: %d, burstcount: %d, write_address: %x", $time, fifo_out, data_out, burstcount, address);
        end
        #20
        $display("[WR_CTRL_normal] T= %t fifo_out: %d, received: %d, write_address: %x", $time, fifo_out, data_out, address);
        #20
        // add additional tests for bursting
        // assert queue empty
        //reset <= 1'b0;
        //#20
        //reset <= 1'b1;
        //$display("[WR_CTRL_prefill_fifo_2] T= %t filling fifo", $time);
        //for (int i = 0; i < pkt_end / 4; ++i) begin
        //    wrreq <= 1'b1;
        //    fifo_in <= i + 'd10;
        //    #20;
        //end
        //wrreq <= 1'b0;
        //$display("[WR_CTRL_prefill_fifo_2] T= %t Done filling fifo", $time);


        /* Cannot simulate a stall with a real hw
        wr_ctrl <= 1'b1;

        for(j = 0; j < pkt_end / 8; ++j) begin
            #20
            $display("[WR_CTRL_stall] T= %t fifo_out: %d, received: %d, empty: %d, write_address: %x", $time, fifo_out, data_out, empty, address);
        end

        // stall one cycle of sending
        if (j == pkt_end / 8) begin
            empty <= 1'b1;
        end

        #20
        $display("[WR_CTRL_stall] T= %t fifo_out: %d, received: %d, empty: %d, write_address: %x", $time, fifo_out, data_out, empty, address);

        for(int i = j; i < pkt_end / 4; ++i) begin
            #20
            $display("[WR_CTRL_stall] T= %t fifo_out: %d, received: %d, empty: %d, write_address: %x", $time, fifo_out, data_out, empty, address);
        end

        #20
        $display("[WR_CTRL_stall] T= %t fifo_out: %d, received: %d, write_address: %x", $time, fifo_out, data_out, address);

        #20
        wr_ctrl <= 1'b0;

        #20
        $display("[WR_CTRL_stall] T= %t after wr_ctrl=0 received: %d, write_address: %x", $time, data_out, address);
        */
       /*

        #20
        // empty burst check
        pkt_end <= '0;
        wr_ctrl <= 1'b1;
        #20
        wr_ctrl <= 1'b0;

        #120 // wait for stabilization

        // TODO: prefill?
        for(int i = 0; i < 4; ++i) begin
            #20
            $display("[WR_CTRL_empty] T= %t fifo_out: %d, received: %d, write_address: %x", $time, fifo_out, data_out, address);
        end

        #20
        $display("[WR_CTRL_empty] T= %t fifo_out: %d, received: %d, write_address: %x", $time, fifo_out, data_out, address);

        #20
        $display("[WR_CTRL] T= %t after wr_ctrl=0 received: %d, write_address: %x", $time, data_out, address);
        $display("[WR_CTRL_prefill_fifo_2] T= %t filling fifo", $time);
        for (int i = 0; i < pkt_end / 4; ++i) begin
            wrreq <= 1'b1;
            fifo_in <= i + 'd10;
            #20;
        end
        wrreq <= 1'b0;
        $display("[WR_CTRL_prefill_fifo_2] T= %t Done filling fifo", $time);
/*
        control <= '0;
        pkt_begin <= '0;
        pkt_end <= 'd32; // 8 words
        write_address <= 'h8000;
        wr_ctrl <= 1'b1;
        #120 // wait for stabilization

        for(int i = 0; i < pkt_end / 4; ++i) begin
            //waitrequest <= 1'b0;
            //if (i == 2 || i == 5) begin
            //    waitrequest <= 1'b1;
            //end
            #20
            $display("[WR_CTRL_waitrequest] T= %t fifo_out: %d, received: %d, burstcount: %d, write_address: %x, waitrequest: %x",
                        $time, fifo_out, data_out, burstcount, address, waitrequest);
        end
        #20
        $display("[WR_CTRL_waitrequest] T= %t fifo_out: %d, received: %d, write_address: %x, waitrequest: %x",
                    $time, fifo_out, data_out, address, waitrequest);
        #20
        wr_ctrl <= 1'b0;

*/
       @(posedge wr_ctrl_rdy);

        #20
        $display("[WR_CTRL_waitrequest] T= %t after wr_ctrl=0 received: %d, write_address: %x, waitrequest: %x", $time, data_out, address, waitrequest);

        #20
        $display("[WR_CTRL] T= %t Ending simulation...\n", $time);
        $exit;
    end

    always @(posedge clk) begin
        waitrequest_d <= '1;
        if (write) begin
            waitrequest_d <= '0;
        end
    end

    always @(negedge clk) begin
        if (write) begin
            data_out <= writedata;
        end
    end
endmodule
