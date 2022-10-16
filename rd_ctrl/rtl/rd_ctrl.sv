module rd_ctrl
               #(parameter BURST_SIZE_WORDS = 4)
               (input logic clk,
               input logic reset,
               input logic rd_ctrl,
               input logic almost_full,
               input logic [31:0] control,
               input logic [31:0] pkt_begin,
               input logic [31:0] pkt_end,
               output logic [31:0] fifo_in,
               output logic wr_to_fifo,
               output logic rd_ctrl_rdy,
               // avalon (host)master signals
               output logic [31:0] address,
               input logic [31:0] readdata,
               output logic read,
               output logic [15:0] burstcount,
               input logic readdatavalid,
               input logic waitrequest
           );

    enum logic [1:0] { IDLE, RUN, DONE } state, state_next;

    logic [31:0] reg_control, reg_pkt_begin, reg_pkt_end;
    logic done_sending, start_transfer;

    logic [15:0] total_burst_remaining,
                 burst_segment_remaining_count,
                 total_size, BYTES_IN_BURST;

    logic [15:0] burst_size;
    logic burst_start, burst_end;

    assign BYTES_IN_BURST = BURST_SIZE_WORDS * 'h4;
    assign total_size = (reg_pkt_end - reg_pkt_begin);

    assign rd_ctrl_rdy = done_sending;

    always_ff @(posedge clk) begin : states
        if (!reset) begin
            state <= IDLE;
        end
        else begin
            state <= state_next;
        end
    end

    always_comb begin : fsm
        case (state)
            IDLE:   begin
                    if (rd_ctrl) begin
                        state_next = RUN;
                    end
                    else begin
                        state_next = IDLE;
                    end
                    end

            RUN:    begin
                    if (done_sending) begin
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

    always_ff @(posedge clk) begin : avalon_mm_ctrl
        if (start_transfer) begin
            address <= reg_pkt_begin;
        end
        else if (burst_end) begin
            address <= address + burst_size;
        end

        if (burst_start) begin
            read <= 'h1;
        end
        else if (waitrequest == 'b0) begin
            read <= 'h0;
        end

        if (burst_start) begin
            burstcount <= burst_size[15:2] + (burst_size[1:0] !== 'h0);
        end
    end

    always_ff @(posedge clk) begin : start_ctrl
        start_transfer <= 1'b0;

        if (state == IDLE && state_next == RUN) begin
            start_transfer <= 1'b1;
            reg_control <= control;
            reg_pkt_begin <= pkt_begin;
            reg_pkt_end <= pkt_end;
        end
    end

    always_ff @(posedge clk) begin : burst_ctrl
        if (start_transfer) begin
            total_burst_remaining <= total_size; // TODO: temp variable name, change
        end
        else if (burst_end) begin
            total_burst_remaining <= total_burst_remaining - (total_burst_remaining < BYTES_IN_BURST ?
                                     total_burst_remaining : burst_size);
        end

        burst_start <= 'b0;

        if (start_transfer) begin
            burst_start <= 'b1;
            burst_size <= total_size < BYTES_IN_BURST ? total_size : BYTES_IN_BURST; // TODO: at least 64 bytes
        end

        if (burst_end && total_burst_remaining > BYTES_IN_BURST) begin
            burst_start <= 'b1;
            burst_size <= (total_burst_remaining - BYTES_IN_BURST < BYTES_IN_BURST) ?
                           total_burst_remaining - BYTES_IN_BURST : BYTES_IN_BURST;
        end

        if (burst_start) begin
            burst_segment_remaining_count <= burst_size;
        end
        else if (readdatavalid) begin
            if (burst_segment_remaining_count > 'h0) begin
                if (burst_segment_remaining_count < 'h4) begin
                    burst_segment_remaining_count <= '0;
                end
                else begin
                    burst_segment_remaining_count <= burst_segment_remaining_count - 'h4;
                end
            end
        end

        burst_end <= 'b0;
        if (burst_segment_remaining_count <= 'h4 && burst_segment_remaining_count > 'h0) begin // last 4 symbols (word) or less
            burst_end <= 'b1;
        end

        done_sending <= 1'b0;

        if (!start_transfer && total_burst_remaining <= BYTES_IN_BURST  && burst_segment_remaining_count === 0 && burst_end && !done_sending && state == RUN) begin // just trigger it for one cycle
            done_sending <= 1'b1;
        end
    end

    always_ff @(posedge clk) begin : fifo_ctrl
        fifo_in <= readdata;

        if (state == RUN && readdatavalid) begin
            wr_to_fifo <= 1'b1;
        end
        else begin
            wr_to_fifo <= 1'b0;
        end
    end
endmodule
