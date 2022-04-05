// the top module, responsible for capturing (nor now) the incoming packets
// from the network interface
module bpfcap_top(input logic clk,
                  input logic reset
                  input logic [2:0] avs_s0_address,
                  input logic [31:0] avs_s0_writedata,
                  input logic avs_s0_write,
                  input logic avs_s0_read,
                  output logic [31:0] avs_s0_readdata, // register out
                  output logic [31:0] data_out, // write to SDRAM
                  );

    logic rd_ctrl_rdy, wr_ctrl_rdy, rd_ctrl, wr_ctrl;
    logic [1:0] state;
    logic [31:0] out_control, out_pkt_addr, out_pkt_len;

    logic [8:0] usedw; // unused
    logic almost_empty, almost_full;
    logic [31:0] fifo_in, fifo_out;

    register_bank #(.N(32)) regs(.clk,
                                 .reset,
                                 .address(avs_s0_address),
                                 .read(avs_s0_read),
                                 .write(avs_s0_write),
                                 .readdata(avs_s0_readdata),
                                 .state
                                 .writedata(avs_s0_writedata),
                                 .out_control,
                                 .out_pkt_addr,
                                 .out_pkt_len);

    pkt_ctrl packet_control (.new_request(avs_s0_write),
                             .clk,
                             .reset,
                             .rd_ctrl_rdy,
                             .wr_ctrl_rdy,
                             .rd_ctrl,
                             .wr_ctrl,
                             .state); // TODO: how do we want to store current state  of FSM (as bits in the register of course)

    // read ctrl reads packets from memory and puts them in FIFO
    rd_ctrl read_control (.clk,
                          .reset
                          .rd_ctrl,
                          .rd_ctrl_rdy,
                          .almost_full,
                          .fifo_in,
                          .control(out_control),
                          .pkt_addr(out_pkt_addr),
                          .pkt_len(out_pkt_len));

    // this reads from FIFO and transfers the data to be written in SDRAM/HPS
    wr_ctrl write_control(.clk,
                          .reset
                          .wr_ctrl,
                          .wr_ctrl_rdy,
                          .almost_empty,
                          .fifo_out,
                          .control(out_control),
                          .pkt_addr(out_pkt_addr),
                          .pkt_len(out_pkt_len));

    fifo fifo_i (.clock(clk),
                 .data(fifo_in),
                 .rdreq(wr_ctrl_rd), // reversed signals here, we read mem and write data to fifo
                 .sclr(~reset),
                 .wrreq(rd_ctrl_rdy), // read fifo and write to mem
                 .almost_empty,
                 .almost_full,
                 .q(fifo_out),
                 .usedw);

endmodule : bpfcap_top

