// the top module, responsible for capturing (nor now) the incoming packets
// from the network interface
module bpfcap_top(input logic clk,
                  logic reset
                  //output logic[
                  );
    logic control_rd, control_wr;

    logic [31:0] control_in, control_out;
    // instatiate several registers
    register #(.N(32)) control (.clk,
                                .reset,
                                .read(control_rd),
                                .write(control_wr),
                                .in(control_in),
                                .out(control_out));

                            // TODO: add more registers



endmodule

