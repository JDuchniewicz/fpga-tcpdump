// the top module, responsible for capturing (nor now) the incoming packets
// from the network interface
module bpfcap_top #(parameter BURST_SIZE_WORDS = 4)
                  (input logic clk,
                  input logic reset,
                  // 1 secondary (register accessed from the OS)
                  input logic [2:0] avs_s0_address,
                  input logic [31:0] avs_s0_writedata,
                  input logic avs_s0_write,
                  input logic avs_s0_read,
                  output logic [31:0] avs_s0_readdata, // register out
                  // first host (rd_ctrl)
                  output logic [31:0] avs_m0_address,
                  input logic [31:0] avs_m0_readdata,
                  output logic avs_m0_read,
                  output logic [15:0] avs_m0_burstcount,
                  input logic avs_m0_readdatavalid,
                  input logic avs_m0_waitrequest,
                  // second host (wr_ctrl)
                  output logic [31:0] avs_m1_address,
                  output logic [31:0] avs_m1_writedata,
                  output logic avs_m1_write,
                  output logic [15:0] avs_m1_burstcount,
                  input logic avs_m1_waitrequest
                  );

    logic rd_ctrl_rdy, wr_ctrl_rdy, rd_ctrl, wr_ctrl, new_request;
    logic [1:0] state;
    logic busy, done, capt_buf_wrap;
    logic [31:0] out_control, out_pkt_begin, out_pkt_end, out_capt_buf_start,
                 out_capt_buf_size, last_write_addr,
                 seconds, nanoseconds;

    logic [8:0] usedw;
    logic empty, almost_full, rd_from_fifo, wr_to_fifo;
    logic [31:0] fifo_in, fifo_out;

    register_bank #(.N(32)) regs(.clk,
                                 .reset,
                                 .address(avs_s0_address),
                                 .read(avs_s0_read),
                                 .write(avs_s0_write),
                                 .readdata(avs_s0_readdata),
                                 .state,
                                 .busy,
                                 .done,
                                 .capt_buf_wrap,
                                 .writedata(avs_s0_writedata),
                                 .out_control,
                                 .out_pkt_begin,
                                 .out_pkt_end,
                                 .out_capt_buf_start,
                                 .out_capt_buf_size,
                                 .last_write_addr);

    pkt_ctrl packet_control (.new_request,
                             .clk,
                             .reset,
                             .rd_ctrl_rdy,
                             .wr_ctrl_rdy,
                             .rd_ctrl,
                             .wr_ctrl,
                             .state_out(state),
                             .busy,
                             .done); // TODO: how do we want to store current state  of FSM (as bits in the register of course)

    // read ctrl reads packets from memory and puts them in FIFO
    rd_ctrl #(.BURST_SIZE_WORDS(BURST_SIZE_WORDS)) read_control (.clk,
                                                  .reset,
                                                  .almost_full,
                                                  .rd_ctrl,
                                                  .control(out_control),
                                                  .pkt_begin(out_pkt_begin),
                                                  .pkt_end(out_pkt_end),
                                                  .fifo_in,
                                                  .wr_to_fifo,
                                                  .rd_ctrl_rdy,
                                                  .address(avs_m0_address),
                                                  .readdata(avs_m0_readdata),
                                                  .read(avs_m0_read),
                                                  .burstcount(avs_m0_burstcount),
                                                  .readdatavalid(avs_m0_readdatavalid),
                                                  .waitrequest(avs_m0_waitrequest));

    // this reads from FIFO and transfers the data to be written in SDRAM/HPS
    wr_ctrl #(.BURST_SIZE_WORDS(BURST_SIZE_WORDS)) write_control(.clk,
                                                  .reset,
                                                  .empty,
                                                  .wr_ctrl,
                                                  .control(out_control),
                                                  .pkt_begin(out_pkt_begin),
                                                  .pkt_end(out_pkt_end),
                                                  .capt_buf_start(out_capt_buf_start),
                                                  .capt_buf_size(out_capt_buf_size),
                                                  .last_write_addr,
                                                  .capt_buf_wrap,
                                                  .fifo_out,
                                                  .rd_from_fifo,
                                                  .wr_ctrl_rdy,
                                                  .usedw,
                                                  .seconds,
                                                  .nanoseconds,
                                                  .address(avs_m1_address),
                                                  .writedata(avs_m1_writedata),
                                                  .write(avs_m1_write),
                                                  .burstcount(avs_m1_burstcount),
                                                  .waitrequest(avs_m1_waitrequest));

    fifo fifo_i (.clock(clk),
                 .data(fifo_in),
                 .rdreq(rd_from_fifo), // reversed signals here, we read mem and write data to fifo
                 .sclr(~reset),
                 .wrreq(wr_to_fifo), // read fifo and write to mem
                 .empty(empty), // need to have them explicitly connected
                 .almost_full(almost_full),
                 .q(fifo_out),
                 .usedw(usedw));

    timestamp #(.FREQ(50)) ts
                           (.clk,
                            .reset_n(reset), // invert?
                            .seconds,
                            .nanoseconds);


    always_ff @(posedge clk) begin
        if (!reset) begin
            new_request <= '0;
        end
        else begin
            new_request <= 1'b0;
            if (avs_s0_address == 32'h2 && avs_s0_write && avs_s0_writedata !== '0) begin // upon a soft-reset of the system do not trigger new_request
                new_request <= 1'b1;
            end
        end
    end

endmodule : bpfcap_top

