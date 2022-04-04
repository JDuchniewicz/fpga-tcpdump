module wr_ctrl(input logic clk,
               input logic reset,
               input logic wr_ctrl,
               input logic almost_empty,
               input logic [31:0] fifo_out,
               output logic wr_ctrl_rdy,
               input logic [31:0] control,
               input logic [31:0] pkt_addr,
               input logic [31:0] pkt_len
           );

    enum logic [1:0] { IDLE, RUN, DONE } state, next_state;

    logic [31:0] reg_control, reg_pkt_addr, reg_pkt_len;
    logic [31:0] addr_offset;
    logic done_reading;

    always_ff @(posedge clk) begin : states
        if (!reset) begin
            state <= IDLE;
            reg_control <= '0;
            reg_pkt_addr <= '0;
            reg_pkt_len <= '0;
            addr_offset <= '0;
            done_reading <= '0;
        end

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
                        reg_control = control;
                        reg_pkt_addr = pkt_addr;
                        reg_pkt_len = pkt_len;
                        addr_offset = '0;
                        done_reading = '0;
                    end

            RUN:    begin
                    if (!almost_empty) begin // TODO: what when we exhaust the FIFO too early?
                        if (pkt_addr + addr_offset <= pkt_len) begin
                            // TODO: write current data to memory address
                            // configured in the regs
                            addr_offset += 32'b4;
                        end
                        else begin
                            done_reading = 1'b1;
                        end
                    end
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
                    if (done_reading) begin
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
