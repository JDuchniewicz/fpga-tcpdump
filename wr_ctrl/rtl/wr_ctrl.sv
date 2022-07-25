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

    enum logic [1:0] { IDLE, RUN, DONE } state, state_next;

    logic [31:0] reg_control, reg_pkt_begin, reg_pkt_end, reg_write_address;
    logic done_reading, start_transfer;

    logic [15:0] total_burst_remaining,
                 burst_segment_remaining_count,
                 total_size;

    logic [15:0] burst_size;
    logic burst_start, burst_end, write_d, write_no_d;
    logic skbf1_valid, skbf2_valid, tx_accept, rd_from_fifo_d, skbf1_ready, skbf2_ready;
    logic [31:0] skbf1_out, skbf2_out;

    assign total_size = (reg_pkt_end - reg_pkt_begin);
    assign writedata = skbf2_out;

    assign tx_accept = write && !waitrequest;
    assign write = skbf2_valid;

    skidbuffer #(
		.DW(32),
        .OPT_INITIAL(0),
        .OPT_OUTREG(0)
	)
    skbf1 (
		.i_clk(clk),
        .i_reset(~reset),
        // Left
		.i_valid(rd_from_fifo_d),
		.o_ready(skbf1_ready),
		.i_data(fifo_out),
        // Right
		.o_valid(skbf1_valid),
		.i_ready(skbf2_ready),
		.o_data(skbf1_out)
	),

    skbf2 (
		.i_clk(clk),
        .i_reset(~reset),
        // Left
		.i_valid(skbf1_valid),
		.o_ready(skbf2_ready),
		.i_data(skbf1_out),
        // Right
		.o_valid(skbf2_valid),
		.i_ready(tx_accept),
		.o_data(skbf2_out)
	);


    always_ff @(posedge clk) begin : states
        if (!reset) begin
            state <= IDLE;
        end
        else begin
            state <= state_next;
        end
    end

    always_ff @(posedge clk) begin : fsm
        case (state)
            IDLE:   begin
                    if (wr_ctrl) begin
                        state_next = RUN;
                    end
                    else begin
                        state_next = IDLE;
                    end
                    end

            RUN:    begin
                    if (done_reading) begin
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
            address <= reg_write_address;
        end
        else if (burst_end) begin
            address <= address + burst_size;
        end

        //write_d <= write_no_d; // delay the write signal

        //if (burst_segment_remaining_count !== 'b0 && !empty) begin
        //    write_no_d <= 'h1;
        //end
        //else begin
        //    write_no_d <= 'h0;
        //end

        if (burst_start) begin
            burstcount <= burst_size;
        end
    end

    always_ff @(posedge clk) begin : start_ctrl
        start_transfer <= 1'b0;

        if (state == IDLE && state_next == RUN) begin
            start_transfer <= 1'b1;
            reg_control <= control;
            reg_pkt_begin <= pkt_begin;
            reg_pkt_end <= pkt_end;
            reg_write_address <= write_address;
        end
    end

    always_ff @(posedge clk) begin : avalon_mm_tx
        if (start_transfer) begin
            total_burst_remaining <= total_size; // TODO: temp variable name, change
        end
        else if (burst_end) begin
            total_burst_remaining <= total_burst_remaining - burst_size;
        end

        burst_start <= 'b0;

        if (start_transfer) begin
            burst_start <= 'b1;
            burst_size <= total_size < 16 ? total_size : 16; // TODO: at least 64 bytes
        end

        if (burst_end && total_burst_remaining > burst_size) begin
            burst_start <= 'b1;
            burst_size <= total_burst_remaining < 16 ? total_burst_remaining : 16;
        end

        if (burst_start) begin
            burst_segment_remaining_count <= burst_size;
        end
        //else if (write_d) begin
        else if (tx_accept) begin
            if (burst_segment_remaining_count > 'h0) begin
                burst_segment_remaining_count <= burst_segment_remaining_count -'h4;
            end
        end

        burst_end <= 'b0;
        if (burst_segment_remaining_count == 'h4) begin // last 4 symbols (word)
            burst_end <= 'b1;
        end

        wr_ctrl_rdy <= 1'b0;
        done_reading <= 1'b0;

        if (!start_transfer && total_burst_remaining === 0 && !done_reading && state == RUN) begin // just trigger it for one cycle
            wr_ctrl_rdy <= 1'b1;
            done_reading <= 1'b1;
        end
    end

    always_ff @(posedge clk) begin : fifo_ctrl
        // TODO: add delay of 1 cycle
        //if (write_d) begin
        //    writedata <= fifo_out;
        //end
        rd_from_fifo_d <= rd_from_fifo;

        if (burst_segment_remaining_count > 'h0 && !empty) begin // TODO: change conditions
            rd_from_fifo <= skbf2_ready;
        end
        else begin
            rd_from_fifo <= 1'b0;
        end
    end
endmodule
