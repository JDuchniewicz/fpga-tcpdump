module rd_ctrl(input logic clk,
               input logic reset,
               input logic rd_ctrl,
               input logic almost_full,
               input logic [31:0] control,
               input logic [31:0] pkt_begin,
               input logic [31:0] pkt_end,
               output logic [31:0] fifo_in, // here we also need the actual data obtained from mem addr H2F in ctrl regfrom s
               output logic wr_to_fifo,
               output logic rd_ctrl_rdy,
               // avalon (host)master signals
               output logic [31:0] address,
               input logic [31:0] readdata,
               output logic read,
               output logic [15:0] burstcount,
               input logic readdatavalid,
               input logic waitrequest
           );

    enum logic [1:0] { IDLE, RUN, DONE } state, state_next;

    logic [31:0] reg_control, reg_pkt_begin, reg_pkt_end;
    logic [31:0] addr_offset, addr_offset_next;
    logic done_sending, done_sending_next, wr_to_fifo_next;

    logic [15:0] packet_byte_count, burst_index, burst_index_next; // TODO: size? (packet_byte_count??? used???)

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
            addr_offset <= addr_offset_next;
            done_sending <= done_sending_next;
            burst_index <= burst_index_next;
            wr_to_fifo <= wr_to_fifo_next;
        end
    end

    // several always blocks,

    always_comb begin : ctrl
        case (state)
            IDLE:   begin
                        addr_offset_next = '0;
                        done_sending_next = '0;
                        burst_index_next = '0;
                        rd_ctrl_rdy = '0;
                        wr_to_fifo_next = '0;
                    end

            RUN:    begin
                        addr_offset_next = addr_offset;
                        done_sending_next = done_sending;
                        burst_index_next = burst_index;
                        rd_ctrl_rdy = '0;
                        wr_to_fifo_next = 1'b1;

                        if (!almost_full && !waitrequest) begin
                            if (burst_index < burstcount) begin
                                addr_offset_next = addr_offset + 'h4; // don't delay it, just use addr_offset and no next no registering // is equal address_offset + 4 (to trigger comb)
                                burst_index_next += 1'b1;
                            end
                            else begin
                                done_sending_next = 1'b1;
                            end
                        end
                    end

           DONE:    begin
                        addr_offset_next = '0;
                        done_sending_next = '0;
                        burst_index_next = '0;
                        wr_to_fifo_next = '0;
                        rd_ctrl_rdy = 1'b1;
                    end
        endcase
    end

    always_comb begin : fsm
        case (state)
            IDLE:   begin
                    if (rd_ctrl) begin
                        state_next = RUN;
                    end
                    else begin
                        state_next = IDLE;
                    end
                    end

            RUN:    begin
                    if (done_sending) begin
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
        if (state_next === RUN && !almost_full && burstcount !== 0) begin
            address <= reg_pkt_begin + addr_offset;
            read <= 1'b1;
            fifo_in <= readdata;
        end
        else begin
            address <= address;
            read <= 1'b0;
            fifo_in <= fifo_in;
        end
    end
endmodule
