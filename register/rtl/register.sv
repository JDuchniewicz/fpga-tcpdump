
// this is the interface for Linux driver via H2F
// it informs about the FPGA program status via register bits
                //input logic [31:0] control, // TODO: decide upon more registers
                //input logic [31:0] start_addr,
                //input logic [31:0] pkt_len,
module register
              #(parameter N = 32)
               (input logic clk,
                input logic reset,
                input logic [2:0] address,
                input logic read,
                input logic write,
                input logic [N-1:0] in,
                input logic [1:0] state,
                output logic [N-1:0] out); // TODO: how to read necessary configuration parts for other control modules?

    logic [N-1:0] control, pkt_addr, pkt_len; // TODO: is this all? maybe more registers? pkt_len or end_add?

    always_ff @(posedge clk) begin
        if (!reset) begin
            control <= '0;
            pkt_addr <= '0;
            pkt_len <= '0;
            out <= '0;
        end
        else begin
            control <= { control[N-1: 1], state }; // state is 2 LSB's
            pkt_addr <= pkt_addr;
            pkt_len <= pkt_len;

            if (write) begin
                case (address) begin
                    3'b000 : control <= in;
                    3'b001 : pkt_addr <= in;
                    3'b010 : pkt_len <= in;
                endcase
            end

            if (read) begin
                case (address) begin
                    3'b000 : out <= control;
                    3'b001 : out <= pkt_addr;
                    3'b010 : out <= pkt_len;
                endcase
            end
        end
    end
endmodule

