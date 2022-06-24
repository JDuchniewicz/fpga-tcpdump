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

    enum logic [1:0] { IDLE, RUN, DONE } state, state_next;

    logic [31:0] reg_control, reg_pkt_begin, reg_pkt_end;
    logic done_sending, start_transfer;

    logic [15:0] total_burst_count, total_burst_remaining,
                 burst_segment_remaining_count;

    assign total_burst_count = (reg_pkt_end - reg_pkt_begin);
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
            reg_control <= control;
            reg_pkt_begin <= pkt_begin;
            reg_pkt_end <= pkt_end;
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
        if (state_next === RUN && !almost_full && total_burst_remaining !== 0) begin
            address <= reg_pkt_begin; // address should be incremented on every fragmented transaction
        end
        else begin
            address <= address;
        end

        if (state == IDLE && state_next == RUN) begin
            start_transfer <= 1'b1;
        end
        else begin
            start_transfer <= 1'b0;
        end
    end

    always_ff @(posedge clk) begin : avalon_mm_tx
        rd_ctrl_rdy <= 1'b0;
        done_sending <= 1'b0;
        if (state == RUN && !almost_full) begin
            read <= 1'b1;
        end
        else begin
            read <= 1'b0;
        end

        if (state == RUN && readdatavalid) begin
            wr_to_fifo <= 1'b1;
            fifo_in <= readdata;
        end
        else begin
            wr_to_fifo <= 1'b0;
            fifo_in <= fifo_in;
        end

        if (start_transfer) begin
            total_burst_remaining <= total_burst_count;
            if (total_burst_count < 16) begin
                burstcount <= total_burst_count;
                burst_segment_remaining_count <= total_burst_count;
            end
            else begin
                burstcount <= 16;
                burst_segment_remaining_count <= 16;
            end
        end
        else begin
            if (burst_segment_remaining_count !== 0) begin
                total_burst_remaining <= total_burst_remaining;
                burst_segment_remaining_count <= burst_segment_remaining_count - 16'b1;
            end
            else begin
                total_burst_remaining <= total_burst_remaining - burstcount;
                if (total_burst_remaining - burstcount < 16 && total_burst_remaining !== 0) begin
                    burstcount <= total_burst_remaining - burstcount;
                    burst_segment_remaining_count <= total_burst_remaining - burstcount;
                end
                else begin
                    burstcount <= 16;
                    burst_segment_remaining_count <= 16;
                end
            end

            if (total_burst_remaining === 0 && !done_sending && state == RUN) begin // just trigger it for one cycle
                rd_ctrl_rdy <= 1'b1;
                done_sending <= 1'b1;
            end
        end
    end
endmodule
