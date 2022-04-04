
module rd_ctrl(input logic clk,
               input logic reset,
               input logic rd_ctrl,
               input logic almost_full,
               input logic [31:0] control,
               input logic [31:0] pkt_addr,
               input logic [31:0] pkt_len,
               output logic [31:0] fifo_in, // here we also need the actual data obtained from mem addr H2F in ctrl regfrom s
               output logic rd_ctrl_rdy
           );

    enum logic [1:0] { IDLE, RUN, DONE } state, next_state;

    logic [31:0] reg_control, reg_pkt_addr, reg_pkt_len;
    logic [31:0] addr_offset;
    logic done_sending;

    always_ff @(posedge clk) begin : states
        if (!reset) begin
            state <= IDLE;
            reg_control <= '0;
            reg_pkt_addr <= '0;
            reg_pkt_len <= '0;
            addr_offset <= '0;
            done_sending <= '0;
        end
        else begin
            state <= next_state;
        end
    end

    always_comb begin : control
        case (state)
            IDLE:   begin
                        reg_control = control;
                        reg_pkt_addr = pkt_addr;
                        reg_pkt_len = pkt_len;
                        addr_offset = '0;
                        done_sending = '0;
                    end

            RUN:    begin
                        if (!almost_full) begin
                            if ((pkt_addr + addr_offset) <= pkt_addr) begin
                                fifo_in = pkt_addr + addr_offset;
                                addr_offset += 32'b4;
                            end
                            else begin
                                done_sending = 1'b1;
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
                        next_state = RUN;
                    end
                    else begin
                        next_state = IDLE;
                    end
                    end

            RUN:    begin
                // TODO: transfer to DONE upon last word
                    if (done_sending) begin
                        next_state = DONE;
                    end
                    else begin
                        next_state = RUN;
                    end
                    end

            DONE:   begin
                        next_state = IDLE;
                    end
        endcase
    end

endmodule
