
module tb_top;
    logic clk = 1'b0;
    logic reset = 1'b0;

    always #10 clk = ~clk;

    logic wr_ctrl, empty, wr_ctrl_rdy, waitrequest, rd_from_fifo;
    logic [31:0] control, pkt_begin, pkt_end, write_address, fifo_out;

    logic [31:0] address;
    logic [31:0] writedata, data_out;
    logic write;

    logic [15:0] burstcount;

    int j = 0;

    wr_ctrl dut(.clk,
                .reset,
                .wr_ctrl,
                .empty,
                .control,
                .pkt_begin,
                .pkt_end,
                .write_address,
                .fifo_out,
                .rd_from_fifo,
                .wr_ctrl_rdy,
                .address,
                .writedata,
                .write,
                .burstcount,
                .waitrequest);

    initial begin
        wr_ctrl <= '0;
        empty <= '0;
        waitrequest <= '0;

        control <= '0;
        pkt_begin <= '0;
        pkt_end <= 'd32; // 8 words
        write_address <= 'h8000;

        data_out <= '0;

        reset <= 1'b0;
        #20
        reset <= 1'b1;

        // Initialize the component: 1 cycle delay between sending and
        // writing to FIFO
        wr_ctrl <= 1'b1;

        for(int i = 0; i < pkt_end / 4; ++i) begin
            fifo_out <= i + 'd10;
            #20
            $display("[WR_CTRL_normal] T= %t fifo_out: %d, received: %d, burstcount: %d, write_address: %x", $time, fifo_out, data_out, burstcount, address);
        end
        #20
        $display("[WR_CTRL_normal] T= %t fifo_out: %d, received: %d, write_address: %x", $time, fifo_out, data_out, address);

        #20
        wr_ctrl <= 1'b0;

        #20
        $display("[WR_CTRL_normal] T= %t after wr_ctrl=0 received: %d, write_address: %x", $time, data_out, address);

        #20
        // add additional tests for bursting
        // assert queue empty
        //reset <= 1'b0;
        //#20
        //reset <= 1'b1;

        wr_ctrl <= 1'b1;

        for(j = 0; j < pkt_end / 8; ++j) begin
            fifo_out <= j + 'd10;
            #20
            $display("[WR_CTRL_stall] T= %t fifo_out: %d, received: %d, empty: %d, write_address: %x", $time, fifo_out, data_out, empty, address);
        end

        // stall one cycle of sending
        if (j == pkt_end / 8) begin
            empty <= 1'b1;
        end

        #20
        $display("[WR_CTRL_stall] T= %t fifo_out: %d, received: %d, empty: %d, write_address: %x", $time, fifo_out, data_out, empty, address);

        empty <= 1'b0;

        for(int i = j; i < pkt_end / 4; ++i) begin
            fifo_out <= i + 'd10;
            #20
            $display("[WR_CTRL_stall] T= %t fifo_out: %d, received: %d, empty: %d, write_address: %x", $time, fifo_out, data_out, empty, address);
        end

        #20
        $display("[WR_CTRL_stall] T= %t fifo_out: %d, received: %d, write_address: %x", $time, fifo_out, data_out, address);

        #20
        wr_ctrl <= 1'b0;

        #20
        $display("[WR_CTRL_stall] T= %t after wr_ctrl=0 received: %d, write_address: %x", $time, data_out, address);

        #20
        // empty burst check
        pkt_end <= '0;
        wr_ctrl <= 1'b1;

        for(int i = 0; i < 4; ++i) begin
            fifo_out <= i + 'd10;
            #20
            $display("[WR_CTRL_empty] T= %t fifo_out: %d, received: %d, write_address: %x", $time, fifo_out, data_out, address);
        end

        #20
        $display("[WR_CTRL_empty] T= %t fifo_out: %d, received: %d, write_address: %x", $time, fifo_out, data_out, address);

        #20
        wr_ctrl <= 1'b0;

        #20
        $display("[WR_CTRL] T= %t after wr_ctrl=0 received: %d, write_address: %x", $time, data_out, address);

        control <= '0;
        pkt_begin <= '0;
        pkt_end <= 'd32; // 8 words
        write_address <= 'h8000;
        wr_ctrl <= 1'b1;
        #20

        for(int i = 0; i < pkt_end / 4; ++i) begin
            fifo_out <= i + 'd10;
            waitrequest <= 1'b0;
            if (i == 2 || i == 5) begin
                waitrequest <= 1'b1;
            end
            #20
            $display("[WR_CTRL_waitrequest] T= %t fifo_out: %d, received: %d, burstcount: %d, write_address: %x, waitrequest: %x",
                        $time, fifo_out, data_out, burstcount, address, waitrequest);
        end
        #20
        $display("[WR_CTRL_waitrequest] T= %t fifo_out: %d, received: %d, write_address: %x, waitrequest: %x",
                    $time, fifo_out, data_out, address, waitrequest);

        #20
        wr_ctrl <= 1'b0;

        #20
        $display("[WR_CTRL_waitrequest] T= %t after wr_ctrl=0 received: %d, write_address: %x, waitrequest: %x", $time, data_out, address, waitrequest);

        #20
        $display("[WR_CTRL] T= %t Ending simulation...\n", $time);
        $exit;
    end

    always @(negedge clk) begin
        if (write) begin
            data_out <= writedata;
        end
    end
endmodule
