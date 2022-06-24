
module tb_top;
    logic clk = 1'b0;
    logic reset = 1'b0;

    always #10 clk = ~clk;

    logic rd_ctrl, almost_full, rd_ctrl_rdy;
    logic [31:0] control, pkt_begin, pkt_end, fifo_in;

    logic [31:0] address;
    logic [31:0] readdata, dummy_data;
    logic read, readdatavalid, readdatavalid_t, waitrequest;

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
                .rd_ctrl_rdy,
                .address,
                .readdata,
                .readdatavalid,
                .waitrequest,
                .read,
                .burstcount);

    initial begin
        rd_ctrl <= '0;
        almost_full <= '0;
        readdata <= '0;

        control <= '0;
        pkt_begin <= '0;
        pkt_end <= 'd32; // 8 words 32 bytes
        waitrequest <= 1'b0;
        readdatavalid_t <= 1'b1;

        reset <= 1'b0;
        #20
        reset <= 1'b1;

        // start the proper testbench, load data
        // add always block that models the slave mm
        // wait for read and return some data

        // Initialize the component: 1 cycle delay between sending and
        // writing to FIFO
        rd_ctrl <= 1'b1;

        for(int i = 0; i < pkt_end; ++i) begin
            dummy_data <= i + 'd10;
            #20
            $display("[RD_CTRL_normal] T= %t sent: %d, received: %d", $time, dummy_data, readdata);
        end
        #20
        $display("[RD_CTRL_normal] T= %t sent: %d, received: %d", $time, dummy_data, readdata);

        #20
        rd_ctrl <= 1'b0;

        #20
        $display("[RD_CTRL_normal] T= %t after rd_ctrl=0 received: %d", $time, readdata);

        #100 // need to wait several cycles as the system just finished processing
        // add additional tests for bursting
        // assert queue almost_full
        //reset <= 1'b0;
        //#20
        //reset <= 1'b1;

        rd_ctrl <= 1'b1;

        for(j = 0; j < pkt_end / 2; ++j) begin
            dummy_data <= j + 'd10;
            #20
            $display("[RD_CTRL_stall] T= %t dummy_data: %d, received: %d, almost_full: %d", $time, dummy_data, readdata, almost_full);
        end

        // stall one cycle of sending
        if (j == pkt_end / 2) begin
            almost_full <= 1'b1;
        end

        #20
        $display("[RD_CTRL_stall] T= %t dummy_data: %d, received: %d, almost_full: %d", $time, dummy_data, readdata, almost_full);

        almost_full <= 1'b0;

        for(int i = j; i < pkt_end / 2; ++i) begin
            dummy_data <= i + 'd10;
            #20
            $display("[RD_CTRL_stall] T= %t dummy_data: %d, received: %d, almost_full: %d", $time, dummy_data, readdata, almost_full);
        end

        #20
        $display("[RD_CTRL_stall] T= %t dummy_data: %d, received: %d", $time, dummy_data, readdata);

        #20
        rd_ctrl <= 1'b0;

        #20
        $display("[RD_CTRL_stall] T= %t after rd_ctrl=0 received: %d", $time, readdata);

        #200
        // empty burst check
        pkt_end <= '0;
        rd_ctrl <= 1'b1;

        for(int i = 0; i < 2; ++i) begin
            dummy_data <= i + 'd10;
            #20
            $display("[RD_CTRL_empty] T= %t dummy_data: %d, received: %d", $time, dummy_data, readdata);
        end

        #20
        $display("[RD_CTRL_empty] T= %t dummy_data: %d, received: %d", $time, dummy_data, readdata);

        rd_ctrl <= '0;
        #200
        rd_ctrl <= 1'b1;

        control <= '0;
        pkt_begin <= '0;
        pkt_end <= 'd32; // 8 words 32 bytes
        #20

        for(j = 0; j < 8; ++j) begin
            dummy_data <= j + 'd10;
            waitrequest <= 1'b0;
            if (j == 4) begin
                waitrequest <= 1'b1;
            end
            #20
            $display("[RD_CTRL_waitrequest] T= %t sent: %d, received: %d, waitrequest: %d", $time, dummy_data, readdata, waitrequest);
        end

        // readdatavalid is down
        readdatavalid_t <= 1'b0;
        dummy_data <= j + 'd10;
        ++j;
        #20
        $display("[RD_CTRL_readdatavalid] T= %t sent: %d, received: %d, readdatavalid_t: %d", $time, dummy_data, readdata, readdatavalid_t);

        #20
        $display("[RD_CTRL_readdatavalid] T= %t sent: %d, received: %d, readdatavalid_t: %d", $time, dummy_data, readdata, readdatavalid_t);

        readdatavalid_t <= 1'b1;

        for(j = j; j < 20; ++j) begin
            dummy_data <= j + 'd10;
            waitrequest <= 1'b0;
            if (j == 12) begin
                waitrequest <= 1'b1;
            end
            #20
            $display("[RD_CTRL_waitrequest] T= %t sent: %d, received: %d, waitrequest: %d", $time, dummy_data, readdata, waitrequest);
        end

        // readdatavalid is down
        readdatavalid_t <= 1'b0;
        dummy_data <= j + 'd10;
        ++j;
        #20
        $display("[RD_CTRL_readdatavalid] T= %t sent: %d, received: %d, readdatavalid_t: %d", $time, dummy_data, readdata, readdatavalid_t);

        #20
        $display("[RD_CTRL_readdatavalid] T= %t sent: %d, received: %d, readdatavalid_t: %d", $time, dummy_data, readdata, readdatavalid_t);

        readdatavalid_t <= 1'b1;
        for(j = j; j < pkt_end; ++j) begin
            dummy_data <= j + 'd10;
            #20
            $display("[RD_CTRL_waitrequest] T= %t sent: %d, received: %d, waitrequest: %d", $time, dummy_data, readdata, waitrequest);
        end

        #20
        $display("[RD_CTRL_waitrequest] T= %t sent: %d, received: %d, waitrequest: %d", $time, dummy_data, readdata, waitrequest);

        #20
        rd_ctrl <= 1'b0;

        #20
        $display("[RD_CTRL] T= %t after rd_ctrl=0 received: %d", $time, readdata);

        #20
        $display("[RD_CTRL] T= %t Ending simulation...\n", $time);
        $exit;
    end

    always @(negedge clk) begin
        readdatavalid <= 1'b0;
        if (read) begin
            readdata <= dummy_data;
            readdatavalid <= readdatavalid_t;
        end
    end
endmodule
