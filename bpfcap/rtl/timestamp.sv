// Freerun counter that returns number of nanoseconds elapsed since start of
// the program.
module timestamp
                #(parameter FREQ = 50) // in MHz // TODO: how to calculate increment without division?
                (input logic clk,
                 input logic reset_n,
                 output logic[31:0] seconds,
                 output logic[31:0] nanoseconds);

    logic [31:0] ctr_nanoseconds;
    logic [31:0] ctr_seconds;

    assign seconds = ctr_seconds;
    assign nanoseconds = ctr_nanoseconds;

    always_ff @(posedge clk) begin
        if (!reset_n) begin
            ctr_nanoseconds <= '0;
            ctr_seconds <= '0;
        end else begin
            if (ctr_nanoseconds === 'd1_000 - 'd20) begin//_000_000) begin
                ctr_seconds <= ctr_seconds + 'b1;
                ctr_nanoseconds <= '0;
            end
            else begin
                ctr_nanoseconds <= ctr_nanoseconds + 'd20; // TODO: hardcoded 50MHz clock
            end
        end
    end
endmodule: timestamp
