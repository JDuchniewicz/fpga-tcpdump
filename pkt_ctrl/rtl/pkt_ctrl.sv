
module pkt_ctrl(input logic new_request,
                input logic clk,
                input logic reset,
                input logic rd_ctrl_rdy,
                input logic wr_ctrl_rdy,
                output logic rd_ctrl,
                output logic wr_ctrl,
                output logic [1:0] state_out); // TODO: change

    enum logic [1:0] { IDLE, RUN, DONE } state, state_next;

    always_ff @(posedge clk) begin : states
        if (!reset) begin
            state <= IDLE;
            //state_next <= IDLE;
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

            RUN:    begin
                    rd_ctrl = 1'b1;
                    wr_ctrl = 1'b1;
                    state_out = RUN;
                    end

           DONE:    begin
                    rd_ctrl = 1'b0;
                    wr_ctrl = 1'b0;
                    state_out = DONE;
                    end
        endcase
    end

    always_comb begin : fsm // TODO: had to remove clocking as otherwise it would oscillate between idle and run due to new_request being 1 then 0
        case (state)
            IDLE:   begin
                    if (new_request) begin // TODO: is this proper? (will it react)?
                        state_next = RUN;
                    end
                    else begin
                        state_next = IDLE;
                    end
                    end

            RUN:    begin
                    if (rd_ctrl_rdy && wr_ctrl_rdy) begin
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

endmodule : pkt_ctrl

