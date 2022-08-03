
module pkt_ctrl(input logic new_request,
                input logic clk,
                input logic reset,
                input logic rd_ctrl_rdy,
                input logic wr_ctrl_rdy,
                output logic rd_ctrl,
                output logic wr_ctrl,
                output logic [1:0] state_out,
                output logic busy,
                output logic done); // TODO: change

    enum logic [1:0] { IDLE, RUN, RD_DONE, WR_DONE } state, state_next;

    assign state_out = state_next;

    always_ff @(posedge clk) begin : states
        if (!reset) begin
            state <= IDLE;
        end
        else begin
            state <= state_next;
        end
    end

    always_comb begin : fsm
        rd_ctrl = 1'b0;
        wr_ctrl = 1'b0;
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
                    rd_ctrl = 1'b1;
                    wr_ctrl = 1'b1;
                    busy = 1'b1;
                    if (rd_ctrl_rdy) begin
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

