
module tb_top;
    logic clk = 1'b0;
    logic reset = 1'b1;

    always #10 clk = ~clk;

    // avalon mm if
    avalon_mm_if mm_if(clk);

    initial begin
        mm_if.wait_for_reset();
        mm_if.clear_bus();

        #20
        reset <= 1'b0;

        // start the proper testbench, load data
    end

endmodule
