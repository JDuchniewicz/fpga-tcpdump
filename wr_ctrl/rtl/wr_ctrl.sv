module wr_ctrl(input logic clk,
               input logic reset,
               input logic wr_ctrl,
               input logic almost_empty,
               input logic [31:0] fifo_out,
               output logic wr_ctrl_rdy
           );

    enum logic [1:0] { IDLE, RUN, DONE } state, next_state;

    always_ff @(posedge clk) begin : states
        if (!reset) begin
            state <= IDLE;
        end
        else begin
            state <= next_state;
        end
    end

    always_comb begin : control
        case (state)
            IDLE:   begin
                    end

            RUN:    begin
                    end

           DONE:    begin
                    wr_ctrl_rdy = 1'b1;
                    end
        endcase
    end

    always_ff @(posedge state) begin : fsm
        case (state)
            IDLE:   begin
                    if (wr_ctrl) begin
                        next_state = RUN;
                    end
                    else begin
                        next_state = IDLE;
                    end
                    end

            RUN:    begin
                    if (done_sending) begin // finish writing when no data in queue?
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
