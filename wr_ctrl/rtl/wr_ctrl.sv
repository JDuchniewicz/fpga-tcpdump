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

           // ethernet packets are at least 64 bytes long
           // but this holds true only for the first burst transaction
           //
           // set address just once when sending burst and then increment the
           // address internally only and send new data on every clock cycle
           // if not received waitrequest
               //
               // make sure I read words when fifo is not empty

    enum logic [2:0] { IDLE, PREP, WR_TIMESTAMP, WR_PKT_DATA, DONE } state, state_next;

    logic [31:0] reg_control, reg_pkt_begin, reg_pkt_end, reg_write_address;
    logic done_reading, start_transfer;

    logic [15:0] total_burst_remaining,
                 burst_segment_remaining_count,
                 total_size;

    logic [15:0] burst_size;
    logic burst_start, burst_end, first_burst, first_burst_wait_fifo_fill, timestamp_accept;
    logic skbf1_valid, skbf2_valid, tx_accept, rd_from_fifo_d, skbf1_ready, skbf2_ready;
    logic [31:0] timestamp_pkt_reg;

    logic [31:0] int_address, int_writedata;
    logic [15:0] int_burstcount;
    logic int_write, int_write_d;
    logic [80:0] skbf1_in_data, skbf2_in_data, skbf2_out_data;
    logic skbf1_data_valid;

    logic [2:0] timestamp_pkt_cnt;
    logic [1:0] word_alignment_remainder;

    assign word_alignment_remainder = 4 - (total_burst_remaining % 4);

    assign total_size = (reg_pkt_end - reg_pkt_begin);
    // assign writedata = timestamp_accept ? timestamp_pkt_reg : skbf2_out_data[31:0];

    //assign tx_accept = write && !waitrequest;
    assign tx_accept = (waitrequest == '1) ? !write : write;
    assign timestamp_accept = (timestamp_pkt_cnt > '0 && !waitrequest);
    // assign write = (timestamp_pkt_cnt > '0) ? 1'b1 : (!first_burst ? skbf2_valid : 'b0); // this sometimes fails for the first packet (it gets stuck in timestamp counting), due to waitrequest arriving too soon?

    assign timestamp_pkt_reg = (timestamp_pkt_cnt == 'd4) ? seconds :
                               ((timestamp_pkt_cnt == 'd3) ? nanoseconds : total_size);

    assign skbf1_in_data = { int_write_d, int_address, int_burstcount, int_writedata};

    //assign skbf1_data_valid = (state == WR_TIMESTAMP) ? int_write :
    //                            int_write_d;
    assign skbf1_data_valid = int_write_d;

    // Avalon MM interface signals
    assign write = skbf2_out_data[80];
    assign address = skbf2_out_data[79:48];
    assign burstcount = skbf2_out_data[47:32];
    assign writedata = skbf2_out_data[31:0];

    skidbuffer #(
		.DW(81),
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
		.i_ready(tx_accept),
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
                    if (timestamp_pkt_cnt <= 1 && skbf1_ready) begin
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
            int_writedata <= '0;
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

        if (state == WR_TIMESTAMP) begin
            int_write <= 1'b1;
            int_writedata <= timestamp_pkt_reg;
        end
        else if (state == WR_PKT_DATA) begin
            int_write <= rd_from_fifo;
            int_writedata <= fifo_out;
        end

        int_write_d <= int_write;
    end

    always_ff @(posedge clk) begin : start_ctrl
        if (!reset) begin
            reg_control <= '0;
            reg_pkt_begin <= '0;
            reg_pkt_end <= '0;
            reg_write_address <= '0;
        end

        start_transfer <= 1'b0;

        if (state == IDLE && state_next == PREP) begin
            start_transfer <= 1'b1;
            reg_control <= control;
            reg_pkt_begin <= pkt_begin;
            reg_pkt_end <= pkt_end;
            reg_write_address <= write_address;
        end
    end

    always_ff @(posedge clk) begin : avalon_mm_tx
        if (!reset) begin
            first_burst <= 'b1;
            first_burst_wait_fifo_fill <= 'b0;
            total_burst_remaining <= '0;
            burst_segment_remaining_count <= '0;
            timestamp_pkt_cnt <= '0;
        end

        if (start_transfer) begin
            total_burst_remaining <= total_size + 'd16; // add fixed size of timestamping info
        end
        else if (burst_end) begin
            total_burst_remaining <= total_burst_remaining - (total_burst_remaining < 16 ? total_burst_remaining : 16);
        end

        burst_start <= 'b0;

        if (start_transfer) begin
           // if (first_burst) begin
                first_burst_wait_fifo_fill <= 'b1;
            //end else begin
                burst_start <= 'b1;
                burst_size <= total_size < 16 ? total_size : 16; // TODO: at least 64 bytes
            //end
                timestamp_pkt_cnt <= 'd4; // seconds, nanoseconds, pkt_len x2
        end

        if (first_burst_wait_fifo_fill && usedw >= 16) begin // TODO: do we need usedw here?
                burst_start <= 'b1;
                burst_size <= total_size < 16 ? total_size : 16;
                first_burst <= 'b0;
                first_burst_wait_fifo_fill <= 'b0;
                //timestamp_pkt_cnt <= 'd4; // seconds, nanoseconds, pkt_len x2
        end

        //if (timestamp_accept) begin
        if (skbf1_ready  && skbf1_data_valid && state == WR_TIMESTAMP) begin
            timestamp_pkt_cnt <= timestamp_pkt_cnt - 'b1;
        end

        if (burst_end && total_burst_remaining > 0) begin
            burst_start <= 'b1;
            burst_size <= total_burst_remaining < 16 ? (total_burst_remaining + word_alignment_remainder) : 16;
        end

        if (state == WR_TIMESTAMP) begin
            if (burst_start) begin
                burst_segment_remaining_count <= burst_size;
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
        //else if (rd_from_fifo || timestamp_accept) begin
        //    if (burst_segment_remaining_count > 'h0) begin
        //        if (burst_segment_remaining_count < 'h4) begin
        //            burst_segment_remaining_count <= (total_burst_remaining + word_alignment_remainder);
        //        end
        //        else begin
        //            burst_segment_remaining_count <= burst_segment_remaining_count -'h4;
        //        end
        //    end
        //end

        burst_end <= 'b0;
        if (burst_segment_remaining_count <= 'h4 && burst_segment_remaining_count > 'h0 && skbf1_ready) begin // last 4 symbols (word)
            burst_end <= 'b1;
        end

        wr_ctrl_rdy <= 1'b0;
        done_reading <= 1'b0;

        if (!start_transfer && total_burst_remaining === 0 && burst_segment_remaining_count === 0 && burst_end && !done_reading && state == WR_PKT_DATA) begin // just trigger it for one cycle
            wr_ctrl_rdy <= 1'b1;
            done_reading <= 1'b1;
            first_burst <= 'b1; // reset the "at-least 16 words in fifo" condition
        end
    end

    always_ff @(posedge clk) begin : fifo_ctrl
        if (!reset) begin
            rd_from_fifo <= '0;
        end

        rd_from_fifo_d <= rd_from_fifo; // TODO: to remove

        rd_from_fifo <= '0;

        if (state == WR_PKT_DATA) begin
            if (burst_segment_remaining_count >= 'h4 && !empty && !first_burst && timestamp_pkt_cnt == '0) begin // TODO: maybe remove first_burst
                //if (write && waitrequest || burst_segment_remaining_count <= 'h4) begin
                if (!skbf1_ready || (skbf1_ready && burst_segment_remaining_count <= 'h4)) begin
                    rd_from_fifo <= 1'b0;
                end else begin
                    rd_from_fifo <= 1'b1;
                end
            end
        end
    end
endmodule
