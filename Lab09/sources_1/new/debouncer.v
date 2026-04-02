`timescale 1ns / 1ps

module debouncer (
    input clk, input pbin, output pbout
);
    reg [1:0] sync = 0;
    reg [17:0] count = 0;
    reg [2:0] history = 0;
    reg prev_stable = 0;

    always @(posedge clk) begin
        sync <= {sync[0], pbin};
        if (count >= 18'd249999) begin
            count <= 0;
            history <= {history[1:0], sync[1]};
        end else count <= count + 1;
        prev_stable <= &history;
    end
    assign pbout = (&history) & ~prev_stable;
endmodule