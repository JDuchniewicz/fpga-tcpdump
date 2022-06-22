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

           // set address just once when sending burst and then increment the
           // address internally only and send new data on every clock cycle
           // if not received waitrequest
               //
               // make sure I read words when fifo is not empty

    enum logic [1:0] { IDLE, RUN, DONE } state, state_next;

    logic [31:0] reg_control, reg_pkt_begin, reg_pkt_end, reg_write_address;
    logic done_reading, start_transfer;
    logic [15:0] remaining_burst_count;

    assign burstcount = (reg_pkt_end - reg_pkt_begin) / 4;

    always_ff @(posedge clk) begin : states
        if (!reset) begin
            state <= IDLE;
        end
        else begin
            state <= state_next;
            reg_control <= control;
            reg_pkt_begin <= pkt_begin;
            reg_pkt_end <= pkt_end;
            reg_write_address <= write_address;
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
        if (state_next === RUN && !empty && burstcount !== 0) begin  // TODO: fifo immediately outputs, almost empty is triggered immediately 5 cycles delay here
            address <= reg_write_address;
            // kickoff the transfer, store bustcount
            // set address on the bus
            // as soon as waitrequest is down, remove address from the bus,
            // set write flag when !empty
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
        wr_ctrl_rdy <= 1'b0;
        done_reading <= 1'b0;
        if (!empty) begin
            write <= 1'b1;
        end
        else begin
            write <= 1'b0;
        end

        if (waitrequest) begin
            writedata <= writedata;
            rd_from_fifo <= 1'b0;
        end
        else begin
            writedata <= fifo_out;
            rd_from_fifo <= 1'b1;
        end

        if (start_transfer) begin
            remaining_burst_count <= burstcount;
        end
        else begin
            if (remaining_burst_count !== 0) begin
                remaining_burst_count <= remaining_burst_count - 16'b1;
            end
            else begin
                remaining_burst_count <= '0;
                wr_ctrl_rdy <= 1'b1;
                done_reading <= 1'b1;
            end
        end
    end
endmodule
