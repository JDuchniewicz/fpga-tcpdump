

module pkt_ctrl(input logic new_request,
                input logic clk,
                input logic reset,
                output logic rd_ctrl,
                output logic wr_ctrl,
                output logic register_sth); // TODO: change

    enum logic  { IDLE, READ, PROC, RDY } state, next_state;

    states: always_ff @(posedge clk, negedge reset) begin
        if (reset) begin
            state <= IDLE;
        end
        else begin
            state <= next_state;
        end
    end

    control: always_comb begin
        case (state)
            IDLE:   begin
                    rd_ctrl = 1'b0;
                    wr_ctrl = 1'b0;
                    register_sth = 1'b0;
                    end

            READ:   begin
                    rd_ctrl = 1'b1;
                    wr_ctrl = 1'b0;
                    register_sth = 1'b0;
                    end

            PROC:   begin
                    rd_ctrl = 1'b0;
                    wr_ctrl = 1'b0;
                    register_sth = 1'b0;
                    end

             RDY:   begin
                    rd_ctrl = 1'b0;
                    wr_ctrl = 1'b1;
                    register_sth = 1'b1;
                    end
        endcase
    end

    fsm: always_ff @(posedge state) begin
        case (state)
            IDLE:   begin
                    if (new_request) begin // TODO: is this proper?
                        next_state = READ;
                    else begin
                        next_state = IDLE;
                    end
                    end

            READ:   begin
                    next_state = PROC;
                    end

            PROC:   begin
                    next_state = RDY;
                    end

            PROC:   begin
                    next_state = IDLE;
                    end
        endcase
    end

endmodule : pkt_ctrl

