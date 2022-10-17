// Freerun counter that returns number of nanoseconds elapsed since start of
// the program.
module timestamp
                #(parameter FREQ = 50) // in MHz
                (input logic clk,
                 input logic reset_n,
                 output logic[31:0] seconds,
                 output logic[31:0] nanoseconds);

    logic [63:0] counter;
    logic[6:0] increment;

    assign increment = (1 * 1000 ) / FREQ;
    assign seconds = counter / 1_000_000_000;
    assign nanoseconds = counter % 1_000_000_000;

    always_ff @(posedge clk) begin
        if (!reset_n) begin
            counter <= '0;
        end else begin
            counter <= counter + increment;
        end
    end
endmodule: timestamp
