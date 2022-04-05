
// this is the interface for Linux driver via H2F
// it informs about the FPGA program status via register bits
                //input logic [31:0] control, // TODO: decide upon more registers
                //input logic [31:0] start_addr,
                //input logic [31:0] pkt_len,
module register_bank
              #(parameter N = 32)
               (input logic clk,
                input logic reset,
                input logic [2:0] address,
                input logic read,
                input logic write,
                input logic [N-1:0] readdata,
                input logic [1:0] state,
                output logic [N-1:0] writedata
                output logic [N-1:0] out_control,
                output logic [N-1:0] out_pkt_addr,
                output logic [N-1:0] out_pkt_len);

    logic [N-1:0] control, pkt_addr, pkt_len; // TODO: is this all? maybe more registers? pkt_len or end_add?

    assign out_control = control;
    assign out_pkt_addr = pkt_addr;
    assign out_pkt_len = pkt_len;

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
                    3'b000 : control <= readdata,
                    3'b001 : pkt_addr <= readdata,
                    3'b010 : pkt_len <= readdata,
                endcase
            end

            if (read) begin
                case (address) begin
                    3'b000 : writedata <= control;
                    3'b001 : writedata <= pkt_addr;
                    3'b010 : writedata <= pkt_len;
                endcase
            end
        end
    end
endmodule : register_bank
