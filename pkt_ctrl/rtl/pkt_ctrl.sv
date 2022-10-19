
module pkt_ctrl(input logic new_request,
                input logic clk,
                input logic reset,
                input logic rd_ctrl_rdy,
                input logic wr_ctrl_rdy,
                output logic rd_ctrl,
                output logic wr_ctrl,
                output logic [1:0] state_out,
                output logic busy,
                output logic done,
                output logic [31:0] processing_cc);

    enum logic [1:0] { IDLE, RUN, RD_DONE, WR_DONE } state, state_next;

    assign state_out = state_next;
    logic [31:0] cc_ctr;

    always_ff @(posedge clk) begin : states
        if (!reset) begin
            state <= IDLE;
            cc_ctr <= '0;
        end
        else begin
            state <= state_next;

            rd_ctrl <= 1'b0;
            wr_ctrl <= 1'b0;
            if (state == IDLE && state_next == RUN) begin
                rd_ctrl <= 1'b1;
                wr_ctrl <= 1'b1;
            end

            if (state == RUN || state == RD_DONE) begin
                cc_ctr <= cc_ctr + 'b1;
            end
            else if (state == WR_DONE) begin
                processing_cc <= cc_ctr;
                cc_ctr <= '0;
            end
        end
    end

    always_comb begin : fsm
        busy = 1'b0;
        done = 1'b0;
        case (state)
            IDLE:   begin
                    done = 1'b1;
                    if (new_request) begin
                        state_next = RUN;
                    end
                    else begin
                        state_next = IDLE;
                    end
                    end

            RUN:    begin
                    busy = 1'b1;
                    // handle corner case where they both finish in the same cycle
                    if (rd_ctrl_rdy && wr_ctrl_rdy) begin
                        state_next = WR_DONE;
                    end
                    else if (rd_ctrl_rdy) begin
                        state_next = RD_DONE;
                    end
                    else begin
                        state_next = RUN;
                    end
                    end

         RD_DONE:   begin
                    busy = 1'b1;
                    if (wr_ctrl_rdy) begin
                        state_next = WR_DONE;
                    end
                    else begin
                        state_next = RD_DONE;
                    end
                    end

         WR_DONE:   begin
                    done = 1'b1;
                    state_next = IDLE;
                    end

        endcase
    end

endmodule : pkt_ctrl

