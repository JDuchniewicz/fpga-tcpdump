
module rd_ctrl(input logic clk,
               input logic reset,
               input logic rd_ctrl,
               input logic almost_full,
               input logic [31:0] control,
               input logic [31:0] pkt_begin,
               input logic [31:0] pkt_end,
               output logic [31:0] fifo_in, // here we also need the actual data obtained from mem addr H2F in ctrl regfrom s
               output logic rd_ctrl_rdy,
               // avalon (host)master signals
               output logic [31:0] address,
               input logic [31:0] readdata,
               output logic read
                // TODO: add bursts
           );

    enum logic [1:0] { IDLE, RUN, DONE } state, state_next;

    logic [31:0] reg_control, reg_pkt_begin, reg_pkt_end,
                 control_next, pkt_begin_next, pkt_end_next;
    logic [31:0] addr_offset, addr_offset_next;
    logic done_sending, done_sending_next;

    always_ff @(posedge clk) begin : states
        if (!reset) begin
            state <= IDLE;
        end
        else begin
            state <= state_next;
            reg_control <= control_next;
            reg_pkt_begin <= pkt_begin_next;
            reg_pkt_end <= pkt_end_next;
            addr_offset <= addr_offset_next;
            done_sending <= done_sending_next;
        end
    end

    always_comb begin : ctrl
        case (state)
            IDLE:   begin
                        control_next = control;
                        pkt_begin_next = pkt_begin;
                        pkt_end_next = pkt_end;
                        addr_offset_next = '0;
                        done_sending_next = '0;
                    end

            RUN:    begin
                        if (!almost_full) begin
                            if ((pkt_begin + addr_offset) <= pkt_end) begin // TODO: decide if we want packet end or ending address of the packet (probably the latter)
                                addr_offset_next += 'h4;
                            end
                            else begin
                                done_sending_next = 1'b1;
                            end
                        end
                    end

           DONE:    begin
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
        if (state === RUN && !almost_full) begin // this reads cycle by cycle TODO: add burst support
            address <= pkt_begin + addr_offset;
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
