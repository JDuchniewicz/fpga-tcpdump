module wr_ctrl
               #(parameter BURST_SIZE_WORDS = 4) // TODO: len burst_len
               (input logic clk,
               input logic reset,
               input logic wr_ctrl,
               input logic empty,
               input logic [31:0] fifo_out,
               output logic rd_from_fifo,
               output logic wr_ctrl_rdy,
               input logic [31:0] control,
               input logic [31:0] pkt_begin,
               input logic [31:0] pkt_end,
               input logic [31:0] capt_buf_start,
               input logic [31:0] capt_buf_size,
               input logic [8:0] usedw,
               input logic [31:0] seconds,
               input logic [31:0] nanoseconds,
               output logic [31:0] last_write_addr,
               output logic capt_buf_wrap,
               // avalon (host)master signals
               output logic [31:0] address,
               output logic [31:0] writedata,
               output logic write,
               output logic [15:0] burstcount,
               input logic waitrequest
           );

    enum logic [2:0] { IDLE, PREP, WR_TIMESTAMP, WR_PKT_DATA, DONE } state, state_next;

    logic [31:0] reg_control, reg_pkt_begin, reg_pkt_end,
                 reg_capt_buf_start, reg_capt_buf_size;
    logic done_reading, start_transfer, first_transaction;

    logic [15:0] total_burst_remaining,
                 burst_segment_remaining_count,
                 total_size, BYTES_IN_BURST,
                 burstsize_in_words, WORD_SIZE;

    logic [31:0] bytes_to_buf_end;

    logic [31:0] capt_buf_end;

    logic [15:0] burst_size;
    logic burst_start, burst_end, first_burst_wait_fifo_fill;
    logic skbf1_valid, skbf2_valid, tx_accept, skbf1_ready, skbf2_ready;
    logic [31:0] timestamp_pkt_reg;

    logic [31:0] int_address, int_writedata, fifo_out_d;
    logic [15:0] int_burstcount;
    logic int_write;
    logic [79:0] skbf1_in_data, skbf2_in_data, skbf2_out_data;
    logic skbf1_data_valid;

    logic [2:0] timestamp_pkt_cnt;

    logic [15:0] tx_accept_counter;

    // constants!
    assign WORD_SIZE = 'd4; // LOCALPARAM TODO:
    assign BYTES_IN_BURST = BURST_SIZE_WORDS * WORD_SIZE;

    // constant assignments for bytes to words conversion required by
    // interconnect
    assign capt_buf_end = reg_capt_buf_start + reg_capt_buf_size;
    assign bytes_to_buf_end = first_transaction ? capt_buf_end - capt_buf_start : capt_buf_end - last_write_addr;

    assign burstsize_in_words = burst_size[15:2] + (burst_size[1:0] !== 'h0); // $ceil(burst_size/4.0)

    assign total_size = (reg_pkt_end - reg_pkt_begin);

    assign tx_accept = write && !waitrequest;

    assign timestamp_pkt_reg = (timestamp_pkt_cnt == 'd4) ? seconds :
                               ((timestamp_pkt_cnt == 'd3) ? nanoseconds : total_size);

    assign skbf1_in_data[79:32] = { int_address, int_burstcount };
    assign skbf1_in_data[31:0] = (state == WR_TIMESTAMP) ? timestamp_pkt_reg : int_writedata;

    assign skbf1_data_valid = (state == WR_TIMESTAMP) ? timestamp_pkt_cnt !== '0 : int_write;

    assign int_writedata = skbf1_ready ? fifo_out : fifo_out_d;

    // Avalon MM interface signals
    assign write = skbf2_valid;
    assign address = skbf2_out_data[79:48];
    assign burstcount = skbf2_out_data[47:32];
    assign writedata = skbf2_out_data[31:0];

    assign wr_ctrl_rdy = done_reading;

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
                    if (burst_end && timestamp_pkt_cnt == '0) begin
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
            first_transaction <= '1; // should be done on register writing
            capt_buf_wrap <= 'b0;
        end
        else begin
            if (start_transfer && first_transaction) begin // this is start of every packet, it will overwrite, flag for resetting last_write_addr
                int_address <= reg_capt_buf_start;
                first_transaction <= '0;
            end
            else if (burst_end) begin
                if (int_address + burst_size >= capt_buf_end) begin
                    int_address <= reg_capt_buf_start;
                    capt_buf_wrap <= 'b1;
                end
                else begin
                    int_address <= int_address + burst_size;
                end
                if (state == WR_TIMESTAMP && total_burst_remaining > 'd16) begin
                    if (int_address + 'd16 + BYTES_IN_BURST >= capt_buf_end) begin
                        last_write_addr <= reg_capt_buf_start;
                    end
                    else begin
                        last_write_addr <= int_address + 'd16;
                    end
                end
                else if (state == WR_PKT_DATA && total_burst_remaining > BYTES_IN_BURST) begin
                    if (int_address + 2 * BYTES_IN_BURST >= capt_buf_end) begin
                        last_write_addr <= reg_capt_buf_start;
                    end
                    else begin
                        last_write_addr <= int_address + 2 * BYTES_IN_BURST;
                    end
                end
                else begin
                    last_write_addr <= int_address + burst_size;
                end
            end

            if (start_transfer) begin // TODO: check if proper
                //int_burstcount <= burstsize_in_words; // timestamp
                int_burstcount <= 'h4; // timestamp
            end
            else if (burst_start) begin
                int_burstcount <= burstsize_in_words;
            end

            if (state == WR_PKT_DATA) begin
                if (rd_from_fifo) begin // arm int_write if there was a FIFO read in previous CC (data to be sent)
                    int_write <= 'b1;
                end
                else if (skbf1_ready) begin // clear int_write if the last word has been accepted by skbf1 (rd_from_fifo is already down)
                    int_write <= 'b0;
                end
            end else begin
                int_write <= 'b0;
            end
        end
    end

    always_ff @(posedge clk) begin : start_ctrl
        if (!reset) begin
            reg_control <= '0;
            reg_pkt_begin <= '0;
            reg_pkt_end <= '0;
            reg_capt_buf_start <= '0;
            reg_capt_buf_size <= '0;
        end

        start_transfer <= 'b0;

        if (state == IDLE && state_next == PREP) begin
            start_transfer <= 'b1;
            reg_control <= control;
            reg_pkt_begin <= pkt_begin;
            reg_pkt_end <= pkt_end;
            reg_capt_buf_start <= capt_buf_start;
            reg_capt_buf_size <= capt_buf_size;
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
        else begin
            /*******************************************************/
            /* Set the total burst length at the start of a packet */
            /*******************************************************/
            if (start_transfer) begin
                total_burst_remaining <= total_size + 'd16;
                first_burst_wait_fifo_fill <= 'b1;
                timestamp_pkt_cnt <= 'd4; // seconds, nanoseconds, pkt_len x2
            end
            else if (burst_end) begin
                total_burst_remaining <= total_burst_remaining - (total_burst_remaining < BYTES_IN_BURST ?
                                         total_burst_remaining : burst_size);
            end

            /*****************************/
            /* Mark the start of a burst */
            /*****************************/
            burst_start <= 'b0;

            if (start_transfer) begin
                burst_start <= 'b1;
                burst_size <= (bytes_to_buf_end < 'd16 ? bytes_to_buf_end : 'd16); // first burst is a timestamp
            end

            if (state == WR_TIMESTAMP && burst_end && timestamp_pkt_cnt > '0) begin // don't mix with data
                burst_start <= 'b1;
                burst_size <= timestamp_pkt_cnt * WORD_SIZE; // TODO: parametrize
            end // corner case - packets less than 64 B
            else if (state == WR_PKT_DATA && (first_burst_wait_fifo_fill && usedw >= BURST_SIZE_WORDS /*- 3 fix for very small packets - appears only in 16W burst sizes*/)) begin
                burst_start <= 'b1;
                first_burst_wait_fifo_fill <= 'b0;

                if (bytes_to_buf_end < BYTES_IN_BURST) begin
                    burst_size <= (total_burst_remaining - BYTES_IN_BURST < bytes_to_buf_end) ?
                                   total_burst_remaining - BYTES_IN_BURST : bytes_to_buf_end;
                end
                else begin
                    burst_size <= (total_burst_remaining < BYTES_IN_BURST) ?
                                   total_burst_remaining : BYTES_IN_BURST;
                end
            end
            else if (!first_burst_wait_fifo_fill && burst_end && total_burst_remaining > BYTES_IN_BURST) begin
                burst_start <= 'b1;
                first_burst_wait_fifo_fill <= 'b0;

                if (bytes_to_buf_end < BYTES_IN_BURST) begin
                    burst_size <= (total_burst_remaining - BYTES_IN_BURST < bytes_to_buf_end) ?
                                   total_burst_remaining - BYTES_IN_BURST : bytes_to_buf_end;
                end
                else begin
                    burst_size <= (total_burst_remaining - BYTES_IN_BURST < BYTES_IN_BURST) ?
                                   total_burst_remaining - BYTES_IN_BURST : BYTES_IN_BURST;
                end
            end

            /***************************/
            /* Mark the end of a burst */
            /***************************/
            burst_end <= 'b0;

            if (tx_accept_counter <= 'h4 && tx_accept_counter > 'h0 && tx_accept) begin
                burst_end <= 'b1;
            end

            /************************************************************/
            /* Count the number of timestamp words put into write stage */
            /************************************************************/
            if (state == WR_TIMESTAMP && skbf1_ready && skbf1_data_valid && timestamp_pkt_cnt != '0) begin
                timestamp_pkt_cnt <= timestamp_pkt_cnt - 'b1;
            end

            /************************************************************************************/
            /* Control the number of packet bytes put into write stage within the current burst */
            /************************************************************************************/
            if (burst_start) begin
                burst_segment_remaining_count <= burst_size;
            end
            else if ((state == WR_TIMESTAMP && skbf1_ready) || (state == WR_PKT_DATA && rd_from_fifo)) begin
                if (burst_segment_remaining_count > 'h0) begin
                    if (burst_segment_remaining_count < 'h4) begin
                        burst_segment_remaining_count <= '0;
                    end
                    else begin
                        burst_segment_remaining_count <= burst_segment_remaining_count - 'h4;
                    end
                end
            end

            /********************************************************************/
            /* Control the number of transmitted bytes within the current burst */
            /********************************************************************/
            if (burst_start) begin
                tx_accept_counter <= burst_size;
            end
            else if (tx_accept && tx_accept_counter > '0) begin
                if (tx_accept_counter < 'h4) begin
                    tx_accept_counter <= '0;
                end
                else begin
                    tx_accept_counter <= tx_accept_counter - 'h4;
                end
            end

            /****************************/
            /* Mark the end of a packet */
            /****************************/
            done_reading <= 'b0;

            if (total_burst_remaining <= BYTES_IN_BURST && tx_accept_counter === 0 && burst_end) begin // just trigger it for one cycle
                done_reading <= 'b1;
            end

            /******************************************************************************/
            /* We need to retain last FIFO output in case there is a stall at skbf1 input */
            /******************************************************************************/
            fifo_out_d <= fifo_out;
        end
    end

    always_comb begin : fifo_ctrl
        rd_from_fifo <= '0;

        if (state == WR_PKT_DATA && burst_segment_remaining_count > '0 && !empty && skbf1_ready) begin
            rd_from_fifo <= 'b1;
        end
    end
endmodule
