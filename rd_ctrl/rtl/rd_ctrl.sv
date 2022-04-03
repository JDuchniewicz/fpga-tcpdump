
module rd_ctrl(input logic clk,
               input logic reset,
               input logic rd_ctrl,
               input logic almost_full,
               // the actual data from phy address
               // convert it to fifo_in
               output logic [31:0] fifo_in, // here we also need the actual data obtained from mem addr H2F in ctrl regfrom s
               output logic rd_ctrl_rdy
           );

    always_ff @(posedge clk) begin
        if (reset) begin
            rd_ctrl_rdy <= '0;
        end
        else begin

        end
    end

endmodule
