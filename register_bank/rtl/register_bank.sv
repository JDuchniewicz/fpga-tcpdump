
// this is the interface for Linux driver via H2F
// it informs about the FPGA program status via register bits
                //input logic [31:0] control, // TODO: decide upon more registers
                //input logic [31:0] start_addr,
                //input logic [31:0] pkt_len,
                //write_address <= where to save the captured packet in SDRAM
                //(for now set up by the driver program as a unmapped memory
                //buffer)
module register_bank
              #(parameter N = 32)
               (input logic clk,
                input logic reset,
                input logic [2:0] address,
                input logic read,
                input logic write,
                output logic [N-1:0] readdata,
                input logic [1:0] state,
                input logic busy,
                input logic done,
                input logic [N-1:0] writedata,
                output logic [N-1:0] out_control,
                output logic [N-1:0] out_pkt_begin,
                output logic [N-1:0] out_pkt_end,
                output logic [N-1:0] out_write_address);

    logic [N-1:0] control, pkt_begin, pkt_end, write_address;

    assign out_control = control;
    assign out_pkt_begin = pkt_begin;
    assign out_pkt_end = pkt_end;
    assign out_write_address = write_address;

    always_ff @(posedge clk) begin
        if (!reset) begin
            control <= '0;
            pkt_begin <= '0;
            pkt_end <= '0;
            write_address <= '0;
        end
        else begin
            // control: MSB - BUSY, MSB-1 - DONE, ..., LSB+1, LSB - state
            control <= { busy, done, control[N-3: 2], state }; // state is 2 LSB's
            pkt_begin <= pkt_begin;
            pkt_end <= pkt_end;
            write_address <= write_address;
            readdata <= readdata;

            if (write) begin
                case (address)
                    3'b000 : control <= writedata;
                    3'b001 : pkt_begin <= writedata;
                    3'b010 : pkt_end <= writedata;
                    3'b011 : write_address <= writedata;
                endcase
            end

            if (read) begin
                case (address)
                    3'b000 : readdata <= control;
                    3'b001 : readdata <= pkt_begin;
                    3'b010 : readdata <= pkt_end;
                    3'b011 : readdata <= write_address;
                endcase
            end
        end
    end
endmodule : register_bank

