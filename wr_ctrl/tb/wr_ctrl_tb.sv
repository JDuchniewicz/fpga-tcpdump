
module tb_top;
    logic clk = 1'b0;
    logic reset = 1'b1;

    always #10 clk = ~clk;

    logic wr_ctrl, almost_empty, wr_ctrl_rdy;
    logic [31:0] control, pkt_begin, pkt_end, fifo_out;

    logic [31:0] address;
    logic [31:0] writedata, data_out;
    logic write;

    logic [15:0] burstcount;


    wr_ctrl dut(.clk,
                .reset,
                .wr_ctrl,
                .almost_empty,
                .control,
                .pkt_begin,
                .pkt_end,
                .fifo_out,
                .wr_ctrl_rdy,
                .address,
                .writedata,
                .write,
                .burstcount);

    initial begin
        wr_ctrl <= '0;
        almost_empty <= '0;

        control <= '0;
        pkt_begin <= '0;
        pkt_end <= 'd32; // 8 words

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
            $display("[RD_CTRL] T= %t fifo_out: %d, received: %d, burstcount: %d", $time, fifo_out, data_out, burstcount);
        end
        #20
        $display("[RD_CTRL] T= %t fifo_out: %d, received: %d", $time, fifo_out, data_out);

        #20
        wr_ctrl <= 1'b0;

        #20
        $display("[RD_CTRL] T= %t after wr_ctrl=0 received: %d", $time, data_out);

        // add additional tests for bursting


        // assert queue almost_empty

        // empty burst check

        $display("[RD_CTRL] T= %t Ending simulation...\n", $time);
        $exit;
    end

    always @(negedge clk) begin
        if (write) begin
            data_out <= writedata;
        end
    end
endmodule
