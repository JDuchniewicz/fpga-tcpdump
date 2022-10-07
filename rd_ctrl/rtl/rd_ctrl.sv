module rd_ctrl(input logic clk,
               input logic reset,
               input logic rd_ctrl,
               input logic almost_full,
               input logic [31:0] control,
               input logic [31:0] pkt_begin,
               input logic [31:0] pkt_end,
               output logic [31:0] fifo_in, // here we also need the actual data obtained from mem addr H2F in ctrl regfrom s
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

           // TODO: introduce a dynamic param width equal to readdata'width/
           // symbol'width == 4
    enum logic [1:0] { IDLE, RUN, DONE } state, state_next;

    logic [31:0] reg_control, reg_pkt_begin, reg_pkt_end;
    logic done_sending, start_transfer;

    logic [15:0] total_burst_remaining,
                 burst_segment_remaining_count,
                 total_size;

    logic [15:0] burst_size;
    logic [1:0] word_alignment_remainder;
    logic burst_start, burst_end;

    assign total_size = (reg_pkt_end - reg_pkt_begin);
    assign word_alignment_remainder = 4 - (total_burst_remaining % 4);

    assign rd_ctrl_rdy = done_sending;

    // counter that counts number of words left to be read (decremented until
    // 0)
    // decrement the counter by burstcount until zero
    // set up max burstcount 256 (or 16)
    // burscount = max(16, nr_of_words)
    // everything in bytes
    // another counter that counts the number of bytes left in one burst
    // transaction
    // add separate clocked process

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
                        state_next = IDLE; // TODO: debug why states oscillate several times here
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
            total_burst_remaining <= total_burst_remaining - (total_burst_remaining < 'd16 ? total_burst_remaining : burst_size);
        end

        burst_start <= 'b0;

        if (start_transfer) begin
            burst_start <= 'b1;
            burst_size <= total_size < 'd16 ? total_size : 'd16; // TODO: at least 64 bytes
        end

        if (burst_end && total_burst_remaining > 'd16) begin
            burst_start <= 'b1;
            burst_size <= total_burst_remaining < 'd16 ? (total_burst_remaining + word_alignment_remainder) : 'd16;
        end

        if (burst_start) begin
            burst_segment_remaining_count <= burst_size;
        end
        else if (readdatavalid) begin
            if (burst_segment_remaining_count > 'h0) begin
                if (burst_segment_remaining_count < 'h4) begin
                    burst_segment_remaining_count <= (total_burst_remaining + word_alignment_remainder);
                end
                else begin
                    burst_segment_remaining_count <= burst_segment_remaining_count -'h4;
                end
            end
        end

        burst_end <= 'b0;
        if (burst_segment_remaining_count <= 'h4 && burst_segment_remaining_count > 'h0) begin // last 4 symbols (word) or less
            burst_end <= 'b1;
        end

        done_sending <= 1'b0;

        if (!start_transfer && total_burst_remaining <= 'd16  && burst_segment_remaining_count === 0 && burst_end && !done_sending && state == RUN) begin // just trigger it for one cycle
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
