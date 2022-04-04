
module rd_ctrl(input logic clk,
               input logic reset,
               input logic rd_ctrl,
               input logic almost_full,
               // the actual data from phy address
               // convert it to fifo_in
               output logic [31:0] fifo_in, // here we also need the actual data obtained from mem addr H2F in ctrl regfrom s
               output logic rd_ctrl_rdy
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
                       // TODO: latch inputs
                    end

            RUN:    begin
                        if (!almost_full) begin
                            // send yet another byte
                            //fifo_in = // move data
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
                    if (rd_ctrl_rdy && wr_ctrl_rdy) begin
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
