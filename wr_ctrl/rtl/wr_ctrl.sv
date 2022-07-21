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

    logic [31:0] reg_control, reg_pkt_begin, reg_pkt_end, reg_write_address,
                fifo_out_d1, fifo_out_d2;
    logic done_reading, start_transfer, empty_d1, empty_d2, empty_d3; // it is asserted immediately
    logic [15:0] remaining_burst_count;
    logic [3:0] transfer_delay;

    assign burstcount = (reg_pkt_end - reg_pkt_begin);
    assign address = reg_write_address;

    always_ff @(posedge clk) begin : states
        if (!reset) begin
            state <= IDLE;
            fifo_out_d1 <= '0;
            fifo_out_d2 <= '0;
            empty_d1 <= '0;
            empty_d2 <= '0;
            empty_d3 <= '0;
        end
        else begin
            state <= state_next;
            fifo_out_d1 <= fifo_out;
            fifo_out_d2 <= fifo_out_d1;
            empty_d1 <= empty;
            empty_d2 <= empty_d1;
            empty_d3 <= empty_d2;
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
        if (state == IDLE && state_next == RUN) begin
            start_transfer <= 1'b1;
            reg_control <= control;
            reg_pkt_begin <= pkt_begin;
            reg_pkt_end <= pkt_end;
            reg_write_address <= write_address;
        end
        else begin
            start_transfer <= 1'b0;
        end
    end

    always_ff @(posedge clk) begin : avalon_mm_tx
        wr_ctrl_rdy <= 1'b0;
        done_reading <= 1'b0;
        if (state == RUN && !empty_d3) begin //&& transfer_delay >= 4) begin
            write <= 1'b1; // might delay  to synchronize them with with fifo _d1 _d2 and then delay them as much as need
        end
        else begin
            write <= 1'b0;
        end

        if (state == RUN && !waitrequest && remaining_burst_count !== 0) begin // or state_next == RUN? (optimization)
            writedata <= fifo_out;//fifo_out_d2; // 2 cycles of delay because fifo is first signalled and then it has a delay to output q
            rd_from_fifo <= 1'b1;
        end
        else begin
            writedata <= writedata;
            rd_from_fifo <= 1'b0;
        end

        //if (state == RUN) begin // TODO: revert this if and try other logic, cause currently no data transfer is happening
            if (state == RUN && start_transfer) begin
                remaining_burst_count <= burstcount;
                //transfer_delay <= 1;
            end
            else begin
                //transfer_delay <= transfer_delay + 1;
                //if (transfer_delay >= 4) begin
                //    transfer_delay <= 4;
                //end

                if (remaining_burst_count !== 0) begin // TODO: should I partition it into smaller bursts as in read?
                    if (!waitrequest) begin //&& transfer_delay >= 4) begin
                        remaining_burst_count <= remaining_burst_count - 'h4;
                    end
                end
                else if (state == RUN) begin
                    wr_ctrl_rdy <= 1'b1; // TODO: probably triggering wrongly here, we have nothing in the module yet we signal rdy
                    done_reading <= 1'b1;
                end
            end
        //end
    end
endmodule
