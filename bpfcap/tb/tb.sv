`timescale 1 ns / 1 ns
module tb_top;
    logic clk = 1'b0;
    logic reset = 1'b0;

    logic [2:0] avs_s0_address;
    logic [31:0] avs_s0_writedata, avs_s0_readdata, avs_m0_address,
                 avs_m0_readdata, avs_m1_address, avs_m1_writedata;
    logic [15:0] avs_m0_burstcount, avs_m1_burstcount;
    logic avs_s0_write, avs_s0_read, avs_m0_read, avs_m1_write,
          avs_m0_readdatavalid, avs_m0_waitrequest, avs_m1_waitrequest;


    logic [31:0] writedata, readdata;

    always #10 clk = ~clk;

    // avalon mm if
    avalon_mm_if mm_if(.reset,
                       .clock(clk));

    bpfcap_top dut(.*);

    initial begin
        avs_s0_address <= '0;
        avs_s0_writedata <= '0;
        avs_m0_readdata <= '0;
        avs_s0_write <= '0;
        avs_s0_read <= '0;

        avs_m0_waitrequest <= '0;
        avs_m1_waitrequest <= '0;
        avs_m0_readdatavalid <= '1;

        mm_if.wait_for_reset();
        mm_if.clear_bus();

        #20
        reset <= 1'b1;

        // start the proper testbench, load data
        // add always block that models the slaves for data receiving and
        // register reading
        // wait for read and return some data

        // read data just after the reset
        avs_s0_address <= 3'h0;
        avs_s0_read <= 1'b1;

        #20
        $display("[Reset] T= %t control reg: %d", $time, avs_s0_readdata);

        // display them right after filling with data
        // first load the data to control registers as avalon master
        // addresses:
        // 0x0 -> control
        // 0x1 -> pkt_begin
        // 0x2 -> pkt_end
        // 0x3 -> write_address
        avs_s0_address <= 3'h0;
        avs_s0_writedata <= '0;
        avs_s0_write <= 1'b1;

        #40
        $display("[Loading control_reg] T= %t control_reg", $time, avs_s0_readdata);

        avs_s0_address <= 3'h1;
        avs_s0_writedata <= 32'h00;

        #40
        $display("[Loading pkt_begin] T= %t pkt_begin: %d", $time, avs_s0_readdata);

        avs_s0_address <= 3'h2;
        avs_s0_writedata <= 32'h800; // 512 words

        #40
        $display("[Loading pkt_end] T= %t pkt_end: %d", $time, avs_s0_readdata);

        avs_s0_address <= 3'h3;
        avs_s0_writedata <= 32'h8000; // arbitrary address

        #40
        $display("[Loading write_address] T= %t write_address: %x", $time, avs_s0_readdata);

        avs_s0_write <= 1'b0;
        avs_s0_read <= 1'b0;

        #20
        // then supply data driving the control signals
        // ??
        // wait for 8 cycles for the data to arrive
        //avs_m0_read <= 1'b1;
        for (int i = 0; i < 512; ++i) begin
            readdata <= 10 + i;
            #20
            $display("[Processing] T= %t sent: %d recevied: %d, write_address: %x", $time, readdata, writedata, avs_m1_address);
        end

        $exit;
    end

    always @(negedge clk) begin
        if (avs_m0_read) begin
            avs_m0_readdata <= readdata;
        end
        if (avs_m1_write) begin
            writedata <= avs_m1_writedata;
        end
    end
endmodule
