// the top module, responsible for capturing (nor now) the incoming packets
// from the network interface
module bpfcap_top(input logic clk,
                  logic reset
                  output logic [31:0] data_out,
                  );
    logic control_rd, control_wr;
    logic rd_ctrl_rdy, wr_ctrl_rdy, rd_ctrl, wr_ctrl;
    logic [1:0] state;

    logic [8:0] usedw; // unused
    logic almost_empty, almost_full;
    logic [31:0] fifo_in, fifo_out;

    logic [31:0] control_in, control_out;
    // instatiate several registers
    register #(.N(32)) control (.clk,
                                .reset,
                                .read(control_rd),
                                .write(control_wr),
                                .in(control_in),
                                .out(control_out));

                            // TODO: add more registers
    pkt_ctrl packet_control (.new_request(),
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
                          .fifo_in);

    // this reads from FIFO and transfers the data to be written in SDRAM/HPS
    wr_ctrl write_control(.clk,
                          .reset
                          .wr_ctrl,
                          .wr_ctrl_rdy,
                          .almost_empty,
                          .fifo_out);

    fifo fifo_i (.clock(clk),
                 .data(fifo_in),
                 .rdreq(wr_ctrl_rd), // reversed signals here, we read mem and write data to fifo
                 .sclr(reset),
                 .wrreq(rd_ctrl_rdy), // read fifo and write to mem
                 .almost_empty,
                 .almost_full,
                 .q(fifo_out),
                 .usedw);

endmodule

