module wr_ctrl(input logic clk,
               input logic reset,
               input logic wr_ctrl,
               input logic empty,
               input logic [31:0] fifo_out,
               output logic rd_from_fifo,
               output logic wr_ctrl_rdy,
               input logic [31:0] control,
               input logic [31:0] pkt_begin,
               input logic [31:0] pkt_end,
               input logic [31:0] write_address,
               // avalon (host)master signals
               output logic [31:0] address,
               output logic [31:0] writedata,
               output logic write,
               output logic [15:0] burstcount,
               input logic waitrequest
           );

    enum logic [1:0] { IDLE, RUN, DONE } state, state_next;

    logic [31:0] reg_control, reg_pkt_begin, reg_pkt_end, reg_write_address;
    logic [31:0] addr_offset, addr_offset_next;
    logic done_reading, done_reading_next, rd_from_fifo_next;

    logic [15:0] packet_byte_count, burst_index, burst_index_next; // TODO: size?

    assign burstcount = (reg_pkt_end - reg_pkt_begin) / 4;

    always_ff @(posedge clk) begin : states
        if (!reset) begin
            state <= IDLE;
        end
        else begin
            state <= state_next;
            reg_control <= control;
            reg_pkt_begin <= pkt_begin;
            reg_pkt_end <= pkt_end;
            reg_write_address <= write_address;
            addr_offset <= addr_offset_next;
            done_reading <= done_reading_next;
            burst_index <= burst_index_next;
            rd_from_fifo <= rd_from_fifo_next;
        end
    end

    always_comb begin : ctrl
        case (state)
            IDLE:   begin
                        addr_offset_next = '0;
                        done_reading_next = '0;
                        burst_index_next = '0;
                        wr_ctrl_rdy = '0;
                        rd_from_fifo_next = '0;
                    end

            RUN:    begin
                        addr_offset_next = addr_offset;
                        done_reading_next = done_reading;
                        burst_index_next = burst_index;
                        wr_ctrl_rdy = '0;
                        rd_from_fifo_next = 1'b1;
                        if (!empty && !waitrequest) begin
                            if (burst_index < burstcount) begin
                                addr_offset_next = addr_offset + 'h4;
                                burst_index_next += 1'b1;
                            end
                            else begin
                                done_reading_next = 1'b1;
                            end
                        end
                    end

           DONE:    begin
                        addr_offset_next = addr_offset;
                        done_reading_next = done_reading;
                        burst_index_next = burst_index;
                        rd_from_fifo_next = '0;
                        wr_ctrl_rdy = 1'b1;
                    end
        endcase
    end

    always_ff @(posedge clk) begin : fsm
        case (state)
            IDLE:   begin
                    if (wr_ctrl) begin
                        state_next = RUN;
                    end
                    else begin
                        state_next = IDLE;
                    end
                    end

            RUN:    begin
                    if (done_reading) begin
                        state_next = DONE;
                    end
                    else begin
                        state_next = RUN;
                    end
                    end

            DONE:   begin
                        state_next = IDLE;
                    end
        endcase
    end

    always_ff @(posedge clk) begin : avalon_mm
        if (state_next === RUN && !empty && burstcount !== 0) begin  // TODO: fifo immediately outputs, almost empty is triggered immediately 5 cycles delay here
            address <= reg_write_address + addr_offset; // output the data to a buffer that we mapped and provided
            write <= 1'b1;
            writedata <= fifo_out;
        end
        else begin
            address <= address;
            write <= 1'b0;
            writedata <= writedata;
        end
    end
endmodule
