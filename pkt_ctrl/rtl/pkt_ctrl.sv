
module pkt_ctrl(input logic new_request,
                input logic clk,
                input logic reset,
                input logic rd_ctrl_rdy,
                input logic wr_ctrl_rdy,
                output logic rd_ctrl,
                output logic wr_ctrl,
                output logic [1:0] state_out); // TODO: change

    enum logic [1:0] { IDLE, RUN, RD_DONE, WR_DONE } state, state_next;

    always_ff @(posedge clk) begin : states
        if (!reset) begin
            state <= IDLE;
        end
        else begin
            state <= state_next;
        end
    end

    always_comb begin : control
        case (state)
            IDLE:   begin
                    rd_ctrl = 1'b0;
                    wr_ctrl = 1'b0;
                    state_out = IDLE;
                    end

            RUN:    begin // TODO: can write in 1 line
                    rd_ctrl = 1'b1;
                    wr_ctrl = 1'b1;
                    state_out = RUN;
                    end

        RD_DONE:    begin
                    rd_ctrl = 1'b0;
                    wr_ctrl = 1'b0;
                    state_out = RD_DONE;
                    end

        WR_DONE:    begin
                    rd_ctrl = 1'b0;
                    wr_ctrl = 1'b0;
                    state_out = WR_DONE;
                    end

        endcase
    end

    always_comb begin : fsm // TODO: had to remove clocking as otherwise it would oscillate between idle and run due to new_request being 1 then 0
        case (state)
            IDLE:   begin
                    if (new_request) begin
                        state_next = RUN;
                    end
                    else begin
                        state_next = IDLE;
                    end
                    end

            RUN:    begin
                    if (rd_ctrl_rdy) begin
                        state_next = RD_DONE;
                    end
                    else begin
                        state_next = RUN;
                    end
                    end

         RD_DONE:   begin
                    if (wr_ctrl_rdy) begin
                        state_next = WR_DONE;
                    end
                    else begin
                        state_next = RD_DONE;
                    end
                    end

         WR_DONE:   begin
                        state_next = IDLE;
                    end

        endcase
    end

endmodule : pkt_ctrl

