
// this is the interface for Linux driver via H2F
// it informs about the FPGA program status via register bits
                //input logic [31:0] control, // TODO: decide upon more registers
                //input logic [31:0] start_addr,
                //input logic [31:0] pkt_len,
module register
              #(parameter N = 32)
               (input logic clk,
                input logic reset,
                input logic read,
                input logic write,
                input logic [N-1:0] in,
                output logic [N-1:0] out);

    logic [N-1:0] data;

    always_ff @(posedge clk) begin
        if (!reset) begin
            data <= '0;
        end
        else begin
            if (read) begin
                out <= data;
            end
            if (write) begin
                data <= in;
            end
            else begin
                data <= data;
            end
        end
    end
endmodule

