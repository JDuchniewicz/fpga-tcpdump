
module rd_ctrl(input logic clk,
               input logic reset,
               input logic rd_ctrl,
               input logic almost_full,
               input logic [31:0] control,
               input logic [31:0] pkt_addr,
               input logic [31:0] pkt_len,
               output logic [31:0] fifo_in, // here we also need the actual data obtained from mem addr H2F in ctrl regfrom s
               output logic rd_ctrl_rdy
           ); // TODO: add Avalon MM for reading the data from memory addresses

    enum logic [1:0] { IDLE, RUN, DONE } state, state_next;

    logic [31:0] reg_control, reg_pkt_addr, reg_pkt_len,
                 control_next, pkt_addr_next, pkt_len_next;
    logic [31:0] addr_offset, addr_offset_next;
    logic done_sending, done_sending_next;

    always_ff @(posedge clk) begin : states
        if (!reset) begin
            state <= IDLE;
        end
        else begin
            state <= state_next;
            reg_control <= control_next;
            reg_pkt_addr <= pkt_addr_next;
            reg_pkt_len <= pkt_len_next;
            addr_offset <= addr_offset_next;
            done_sending <= done_sending_next;
        end
    end

    always_comb begin : ctrl
        case (state)
            IDLE:   begin
                        control_next = control;
                        pkt_addr_next = pkt_addr;
                        pkt_len_next = pkt_len;
                        addr_offset_next = '0;
                        done_sending_next = '0;
                    end

            RUN:    begin
                        // TODO: change, we need to load data from Avalon MM if here
                        if (!almost_full) begin
                            if ((pkt_addr + addr_offset) <= pkt_addr) begin // TODO: this should probably operate on real data so we can put it in the queue however it would be quite much??? MTU 1500 bytes, it probably does not matter as we are sending either 4 byte data or 4 byte addresses to data
                                fifo_in = pkt_addr + addr_offset;
                                addr_offset_next += 32'h4;
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

    always_ff @(posedge state) begin : fsm
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

endmodule
