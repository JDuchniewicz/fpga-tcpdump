
module pkt_ctrl(input logic new_request,
                input logic clk,
                input logic reset,
                input logic rd_ctrl_rdy,
                input logic wr_ctrl_rdy,
                output logic rd_ctrl,
                output logic wr_ctrl,
                output logic [1:0] state); // TODO: change

    enum logic [1:0] { IDLE, RUN, DONE } state, next_state;

    always_ff @(posedge clk, negedge reset) begin : states
        if (reset) begin
            state <= IDLE;
        end
        else begin
            state <= next_state;
        end
    end

    always_comb begin : control
        case (state)
            IDLE:   begin
                    rd_ctrl = 1'b0;
                    wr_ctrl = 1'b0;
                    register_sth = 1'b0;
                    end

            RUN:    begin
                    rd_ctrl = 1'b1;
                    wr_ctrl = 1'b0;
                    register_sth = 1'b0;
                    end

           DONE:    begin
                    rd_ctrl = 1'b0;
                    wr_ctrl = 1'b1;
                    register_sth = 1'b1;
                    end
        endcase
    end

    always_ff @(posedge state) begin : fsm
        case (state)
            IDLE:   begin
                    if (new_request) begin // TODO: is this proper?
                        next_state = RUN;
                    end
                    else begin
                        next_state = IDLE;
                    end
                    end

            RUN:    begin
                    if (rd_ctrl_rdy) begin
                        next_state = DONE;
                    end
                    else begin
                        next_state = RUN;
                    end
                    end

            DONE:   begin
                    if (wr_ctrl_rdy) begin
                        next_state = IDLE;
                    end
                    else begin
                        next_state = DONE;
                    end
                    end
        endcase
    end

endmodule : pkt_ctrl

