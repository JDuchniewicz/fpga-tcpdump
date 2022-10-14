`timescale 1ns/1ns
module tb_top;
    logic clk = 1'b0;
    logic reset = 1'b0;

    always #10 clk = ~clk;

    logic rd_ctrl, almost_full, rd_ctrl_rdy, empty, rdreq, wr_to_fifo;
    logic [31:0] control, pkt_begin, pkt_end, fifo_in, fifo_out;

    logic [8:0] usedw; // unused

    logic [31:0] address;
    logic [31:0] readdata, dummy_data;
    logic read, readdatavalid;
    logic waitrequest;

    logic [15:0] burstcount;

    int i, j;

    rd_ctrl dut(.clk,
                .reset,
                .rd_ctrl,
                .almost_full,
                .control,
                .pkt_begin,
                .pkt_end,
                .fifo_in,
                .wr_to_fifo,
                .rd_ctrl_rdy,
                .address,
                .readdata,
                .readdatavalid,
                .waitrequest,
                .read,
                .burstcount);

    fifo fifo_sim(.clock(clk),
                  .data(fifo_in),
                  .rdreq(rdreq),
                  .sclr(~reset),
                  .wrreq(wr_to_fifo),
                  .empty(empty),
                  .almost_full,
                  .q(fifo_out),
                  .usedw);


    initial begin
        rd_ctrl <= '0;
        almost_full <= '0;
        readdata <= '0;

        control <= '0;
        pkt_begin <= '0;
        pkt_end <= 'h75; // 8 words 32 bytes
        waitrequest <= 1'b0;

        reset <= 1'b0;
        @(posedge clk); // TODO: change @(posedge clk)
        reset <= 1'b1;

        // start the proper testbench, load data
        // add always block that models the slave mm
        // wait for read and return some data

        // Initialize the component: 1 cycle delay between sending and
        // writing to FIFO
        rd_ctrl <= 1'b1;

//        for(int i = 0; i < pkt_end; ++i) begin
//            dummy_data <= i + 'd10;
//            @(posedge clk);
//            $display("[RD_CTRL_normal] T= %t sent: %d, received: %d", $time, dummy_data, readdata);
//        end
//        @(posedge clk);
//        $display("[RD_CTRL_normal] T= %t sent: %d, received: %d", $time, dummy_data, readdata);

        @(posedge clk);
        rd_ctrl <= 1'b0;

        @(posedge clk);
        $display("[RD_CTRL_normal] T= %t after rd_ctrl=0 received: %d", $time, readdata);

        repeat(5) @(posedge clk); // need to wait several cycles as the system just finished processing
        // repeat 10 @(posedge clk); TODO:
        //
        // add additional tests for bursting
        // assert queue almost_full
        //reset <= 1'b0;
        //@(posedge clk);
        //reset <= 1'b1;

        @(posedge rd_ctrl_rdy);
        repeat(5) @(posedge clk);

        $display("[RD_CTRL] T= %t LOG1...\n", $time);
        rd_ctrl <= 1'b1;
        @(posedge clk);
        rd_ctrl <= 1'b0;
        $display("[RD_CTRL] T= %t LOG2...\n", $time);
/*
        for(j = 0; j < pkt_end / 2; ++j) begin
            dummy_data <= j + 'd10;
            @(posedge clk);
            $display("[RD_CTRL_stall] T= %t dummy_data: %d, received: %d, almost_full: %d", $time, dummy_data, readdata, almost_full);
        end

        // stall one cycle of sending
        if (j == pkt_end / 2) begin
            almost_full <= 1'b1;
        end

        @(posedge clk);
        $display("[RD_CTRL_stall] T= %t dummy_data: %d, received: %d, almost_full: %d", $time, dummy_data, readdata, almost_full);

        almost_full <= 1'b0;

        for(int i = j; i < pkt_end / 2; ++i) begin
            dummy_data <= i + 'd10;
            @(posedge clk);
            $display("[RD_CTRL_stall] T= %t dummy_data: %d, received: %d, almost_full: %d", $time, dummy_data, readdata, almost_full);
        end

        @(posedge clk);
        $display("[RD_CTRL_stall] T= %t dummy_data: %d, received: %d", $time, dummy_data, readdata);

        @(posedge clk);
        rd_ctrl <= 1'b0;

        @(posedge clk);
        $display("[RD_CTRL_stall] T= %t after rd_ctrl=0 received: %d", $time, readdata);

        @(posedge clk);0
        // empty burst check
        pkt_end <= '0;
        rd_ctrl <= 1'b1;

        for(int i = 0; i < 2; ++i) begin
            dummy_data <= i + 'd10;
            @(posedge clk);
            $display("[RD_CTRL_empty] T= %t dummy_data: %d, received: %d", $time, dummy_data, readdata);
        end

        @(posedge clk);
        $display("[RD_CTRL_empty] T= %t dummy_data: %d, received: %d", $time, dummy_data, readdata);

        rd_ctrl <= '0;
        @(posedge clk);0
        rd_ctrl <= 1'b1;

        control <= '0;
        pkt_begin <= '0;
        pkt_end <= 'd32; // 8 words 32 bytes
        @(posedge clk);

        for(j = 0; j < 8; ++j) begin
            dummy_data <= j + 'd10;
            waitrequest <= 1'b0;
            if (j == 4) begin
                waitrequest <= 1'b1;
            end
            @(posedge clk);
            $display("[RD_CTRL_waitrequest] T= %t sent: %d, received: %d, waitrequest: %d", $time, dummy_data, readdata, waitrequest);
        end

        // readdatavalid is down
        readdatavalid_t <= 1'b0;
        dummy_data <= j + 'd10;
        ++j;
        @(posedge clk);
        $display("[RD_CTRL_readdatavalid] T= %t sent: %d, received: %d, readdatavalid_t: %d", $time, dummy_data, readdata, readdatavalid_t);

        @(posedge clk);
        $display("[RD_CTRL_readdatavalid] T= %t sent: %d, received: %d, readdatavalid_t: %d", $time, dummy_data, readdata, readdatavalid_t);

        readdatavalid_t <= 1'b1;

        for(j = j; j < 20; ++j) begin
            dummy_data <= j + 'd10;
            waitrequest <= 1'b0;
            if (j == 12) begin
                waitrequest <= 1'b1;
            end
            @(posedge clk);
            $display("[RD_CTRL_waitrequest] T= %t sent: %d, received: %d, waitrequest: %d", $time, dummy_data, readdata, waitrequest);
        end

        // readdatavalid is down
        readdatavalid_t <= 1'b0;
        dummy_data <= j + 'd10;
        ++j;
        @(posedge clk);
        $display("[RD_CTRL_readdatavalid] T= %t sent: %d, received: %d, readdatavalid_t: %d", $time, dummy_data, readdata, readdatavalid_t);

        @(posedge clk);
        $display("[RD_CTRL_readdatavalid] T= %t sent: %d, received: %d, readdatavalid_t: %d", $time, dummy_data, readdata, readdatavalid_t);

        readdatavalid_t <= 1'b1;
        for(j = j; j < pkt_end; ++j) begin
            dummy_data <= j + 'd10;
            @(posedge clk);
            $display("[RD_CTRL_waitrequest] T= %t sent: %d, received: %d, waitrequest: %d", $time, dummy_data, readdata, waitrequest);
        end

        @(posedge clk);
        $display("[RD_CTRL_waitrequest] T= %t sent: %d, received: %d, waitrequest: %d", $time, dummy_data, readdata, waitrequest);

        @(posedge clk);
        rd_ctrl <= 1'b0;

        @(posedge clk);
        $display("[RD_CTRL] T= %t after rd_ctrl=0 received: %d", $time, readdata);
*/
        @(posedge clk);
        $display("[RD_CTRL] T= %t Ending simulation...\n", $time);
        $exit;
    end

    //always @(negedge clk) begin
    initial forever begin
        readdatavalid <= 1'b0;
        waitrequest <= 1'b1;
        @(posedge read);
        //if (read) begin // if burstactive TODO: change
            waitrequest <= 1'b0;
            repeat(2) @(posedge clk);
            for (int i = 0; i < burstcount; ++i) begin
                readdata <= i + 'd10;
                readdatavalid <= 1'b1;
                @(posedge clk);
            end
            // wait for read, if read is 1 then get burstcount and wait for
            // burstcount cycles if found read, handle dummy_data here
            // if read_d1 is rising -> waitrequest = 1, then it goes down (or
                // waitrequest is a random signal -> probably do it randomly
        //end
    end
endmodule
