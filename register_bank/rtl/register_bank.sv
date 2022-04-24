
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
                output logic [N-1:0] readdata,
                input logic [1:0] state,
                input logic [N-1:0] writedata,
                output logic [N-1:0] out_control,
                output logic [N-1:0] out_pkt_begin,
                output logic [N-1:0] out_pkt_end);

    logic [N-1:0] control, pkt_begin, pkt_end; // TODO: is this all? maybe more registers? pkt_end or end_add?

    assign out_control = control;
    assign out_pkt_begin = pkt_begin;
    assign out_pkt_end = pkt_end;

    always_ff @(posedge clk) begin
        if (!reset) begin
            control <= '0;
            pkt_begin <= '0;
            pkt_end <= '0;
        end
        else begin
            control <= { control[N-1: 1], state }; // state is 2 LSB's
            pkt_begin <= pkt_begin;
            pkt_end <= pkt_end;
            readdata <= readdata;

            if (write) begin
                case (address)
                    3'b000 : control <= writedata; // TODO: somehow they are not updated (faulty case statement??!)
                    3'b001 : pkt_begin <= writedata;
                    3'b010 : pkt_end <= writedata;
                endcase
            end

            if (read) begin
                case (address)
                    3'b000 : readdata <= control;
                    3'b001 : readdata <= pkt_begin;
                    3'b010 : readdata <= pkt_end;
                endcase
            end
        end
    end
endmodule : register_bank

