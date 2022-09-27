module wr_ctrl(input logic clk,
               input logic reset,
               input logic wr_ctrl,
               input logic empty,
               input logic [31:0] fifo_out,
               output logic rd_from_fifo,
               output logic wr_ctrl_rdy,
               input logic [31:0] control,
               input logic [31:0] pkt_begin,
               input logic [31:0] pkt_end,
               input logic [31:0] write_address,
               input logic [8:0] usedw,
               input logic [31:0] seconds,
               input logic [31:0] nanoseconds,
               // avalon (host)master signals
               output logic [31:0] address,
               output logic [31:0] writedata,
               output logic write,
               output logic [15:0] burstcount,
               input logic waitrequest
           );

    enum logic [2:0] { IDLE, PREP, WR_TIMESTAMP, WR_PKT_DATA, DONE } state, state_next;

    logic [31:0] reg_control, reg_pkt_begin, reg_pkt_end, reg_write_address;
    logic done_reading, start_transfer;

    logic [15:0] total_burst_remaining,
                 burst_segment_remaining_count,
                 total_size;

    logic [15:0] burst_size;
    logic burst_start, burst_end, first_burst_wait_fifo_fill, timestamp_accept;
    logic skbf1_valid, skbf2_valid, tx_accept, skbf1_ready, skbf2_ready, tx_allowed;
    logic [31:0] timestamp_pkt_reg;

    logic [31:0] int_address, int_writedata, fifo_out_d;
    logic [15:0] int_burstcount;
    logic int_write, int_write_d;
    logic [79:0] skbf1_in_data, skbf2_in_data, skbf2_out_data;
    logic skbf1_data_valid;

    logic [2:0] timestamp_pkt_cnt;
    logic [1:0] word_alignment_remainder;

    logic [15:0] tx_accept_counter;

    assign word_alignment_remainder = 4 - (total_burst_remaining % 4);

    assign total_size = (reg_pkt_end - reg_pkt_begin);

    assign tx_accept = write && !waitrequest;
    assign timestamp_accept = (timestamp_pkt_cnt > '0 && !waitrequest);

    assign timestamp_pkt_reg = (timestamp_pkt_cnt == 'd4) ? seconds :
                               ((timestamp_pkt_cnt == 'd3) ? nanoseconds : total_size);

    assign skbf1_in_data[79:32] = { int_address, int_burstcount };
    assign skbf1_in_data[31:0] = (state == WR_TIMESTAMP) ? timestamp_pkt_reg : int_writedata;

    assign skbf1_data_valid = (state == WR_TIMESTAMP) ? timestamp_pkt_cnt !== '0 : int_write;

    assign int_writedata = skbf1_ready ? fifo_out : fifo_out_d;

    // Avalon MM interface signals
    assign write = skbf2_valid && tx_allowed && !burst_end;
    assign address = skbf2_out_data[79:48];
    assign burstcount = skbf2_out_data[47:32];
    assign writedata = skbf2_out_data[31:0];

    skidbuffer #(
		.DW(80),
        .OPT_INITIAL(0),
        .OPT_OUTREG(0)
	)
    skbf1 (
		.i_clk(clk),
        .i_reset(~reset),
        // Left
		.i_valid(skbf1_data_valid),
		.o_ready(skbf1_ready),
		.i_data(skbf1_in_data),
        // Right
		.o_valid(skbf1_valid),
		.i_ready(skbf2_ready),
		.o_data(skbf2_in_data)
	),

    skbf2 (
		.i_clk(clk),
        .i_reset(~reset),
        // Left
		.i_valid(skbf1_valid),
		.o_ready(skbf2_ready),
		.i_data(skbf2_in_data),
        // Right
		.o_valid(skbf2_valid),
		.i_ready(!waitrequest),
		.o_data(skbf2_out_data)
	);


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
                    if (wr_ctrl) begin
                        state_next = PREP;
                    end
                    else begin
                        state_next = IDLE;
                    end
                    end

            PREP:   begin
                        state_next = WR_TIMESTAMP;
                    end

    WR_TIMESTAMP:   begin
                    if (burst_end) begin
                        state_next = WR_PKT_DATA;
                    end
                    else begin
                        state_next = WR_TIMESTAMP;
                    end
                    end

     WR_PKT_DATA:   begin
                    if (done_reading) begin
                        state_next = DONE;
                    end
                    else begin
                        state_next = WR_PKT_DATA;
                    end
                    end

            DONE:   begin
                        state_next = IDLE;
                    end
        endcase
    end

    always_ff @(posedge clk) begin : avalon_mm_ctrl
        if (!reset) begin
            int_address <= '0;
            int_burstcount <= '0;
            int_write <= '0;
            int_write_d <= '0;
        end
        else if (start_transfer) begin
            int_address <= reg_write_address;
        end
        else if (burst_end) begin
            int_address <= address + burst_size;
        end

        if (burst_start) begin
            int_burstcount <= burst_size;
        end

        if (state == WR_PKT_DATA) begin
            if (rd_from_fifo) begin
                int_write <= 'b1;
            end
            else if (skbf1_ready) begin
                int_write <= 'b0;
            end
        end else begin
            int_write <= 'b0;
        end

        fifo_out_d <= fifo_out; // TODO: cleanup move to another proc

        int_write_d <= int_write;
    end

    always_ff @(posedge clk) begin : start_ctrl
        if (!reset) begin
            reg_control <= '0;
            reg_pkt_begin <= '0;
            reg_pkt_end <= '0;
            reg_write_address <= '0;
        end

        start_transfer <= 'b0;

        if (state == IDLE && state_next == PREP) begin
            start_transfer <= 'b1;
            reg_control <= control;
            reg_pkt_begin <= pkt_begin;
            reg_pkt_end <= pkt_end;
            reg_write_address <= write_address;
        end
    end

    always_ff @(posedge clk) begin : avalon_mm_tx
        if (!reset) begin
            first_burst_wait_fifo_fill <= 'b0;
            total_burst_remaining <= '0;
            burst_segment_remaining_count <= '0;
            timestamp_pkt_cnt <= '0;
            tx_accept_counter <= '0;
        end

        if (start_transfer) begin
            total_burst_remaining <= total_size + 'd16; // add fixed size of timestamping info
        end
        else if (burst_end) begin
            total_burst_remaining <= total_burst_remaining - (total_burst_remaining < 16 ? total_burst_remaining : 16);
            tx_allowed <= '0;
        end

        burst_start <= 'b0;

        if (start_transfer) begin
            first_burst_wait_fifo_fill <= 'b1;
            burst_start <= 'b1;
            burst_size <= 16; // first burst is a timestamp
            timestamp_pkt_cnt <= 'd4; // seconds, nanoseconds, pkt_len x2
        end

        if (state == WR_PKT_DATA && first_burst_wait_fifo_fill && usedw >= 16) begin // TODO: do we need usedw here?
            burst_start <= 'b1;
            burst_size <= total_size < 16 ? total_size : 16;
            first_burst_wait_fifo_fill <= 'b0;
        end

        if (skbf1_ready && skbf1_data_valid && state == WR_TIMESTAMP && timestamp_pkt_cnt != '0) begin
            timestamp_pkt_cnt <= timestamp_pkt_cnt - 'b1;
        end

        if (state == WR_PKT_DATA && burst_end && total_burst_remaining > 0) begin
            burst_start <= 'b1;
            burst_size <= total_burst_remaining < 16 ? (total_burst_remaining + word_alignment_remainder) : 16;
        end

        if (state == WR_TIMESTAMP) begin
            if (burst_start) begin
                burst_segment_remaining_count <= burst_size;
                tx_allowed <= 'b1;
            end
            else if (skbf1_ready) begin
                if (burst_segment_remaining_count > 'h0) begin
                    if (burst_segment_remaining_count < 'h4) begin
                        burst_segment_remaining_count <= (total_burst_remaining + word_alignment_remainder);
                    end
                    else begin
                        burst_segment_remaining_count <= burst_segment_remaining_count -'h4;
                    end
                end
            end
        end
        else if (state == WR_PKT_DATA) begin
            if (burst_start) begin
                burst_segment_remaining_count <= burst_size;
                tx_allowed <= 'b1;
            end
            else if (rd_from_fifo) begin
                if (burst_segment_remaining_count > 'h0) begin
                    if (burst_segment_remaining_count < 'h4) begin
                        burst_segment_remaining_count <= (total_burst_remaining + word_alignment_remainder);
                    end
                    else begin
                        burst_segment_remaining_count <= burst_segment_remaining_count -'h4;
                    end
                end
            end
        end

        burst_end <= 'b0;
        if (tx_accept_counter <= 'h4 && tx_accept_counter > 'h0 && tx_accept) begin
            burst_end <= 'b1;
        end

        wr_ctrl_rdy <= 'b0;
        done_reading <= 'b0;

        if (burst_start) begin
            tx_accept_counter <= burst_size;
        end
        else if (tx_accept && tx_accept_counter > '0) begin
            if (tx_accept_counter < 'h4) begin
                tx_accept_counter <= (total_burst_remaining + word_alignment_remainder);
            end
            else begin
                tx_accept_counter <= tx_accept_counter -'h4;
            end
        end

        if (total_burst_remaining === 0 && tx_accept_counter === 0 && burst_end && !done_reading && state == WR_PKT_DATA) begin // just trigger it for one cycle
            wr_ctrl_rdy <= 'b1;
            done_reading <= 'b1;
        end
    end

    always_comb begin : fifo_ctrl
        rd_from_fifo <= '0;

        if (state == WR_PKT_DATA && burst_segment_remaining_count > '0 && !empty && skbf1_ready) begin
            rd_from_fifo <= 'b1;
        end
    end
endmodule
