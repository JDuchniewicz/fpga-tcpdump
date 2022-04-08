
module tb_top;
    logic clk = 1'b0;
    logic reset = 1'b1;

    always #10 clk = ~clk;

    logic rd_ctrl, almost_full, rd_ctrl_rdy;
    logic [31:0] control, pkt_begin, pkt_end, fifo_in;

    logic [31:0] address;
    logic [31:0] readdata, dummy_data;
    logic read;


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
                .read);

    initial begin
        rd_ctrl <= '0;
        almost_full <= '0;
        readdata <= '0;

        control <= '0;
        pkt_begin <= '0;
        pkt_end <= 'd32; // 8 words


        #20
        reset <= 1'b0;

        // start the proper testbench, load data
        // add always block that models the slave mm
        // wait for read and return some data

        $display("[RD_CTRL] T= %t Starting simulation...\n", $time);
        rd_ctrl <= 1'b1;

        for(int i = 0; i < pkt_end / 4; ++i) begin
            dummy_data <= i + 'd10;
            #10
            $display("[RD_CTRL] T= %t sent: %d, received: %d", $time, dummy_data, readdata);
        end
    end

    always @(negedge clk) begin
        if (read) begin
            readdata <= dummy_data;
        end
    end
endmodule
