`timescale 1ns / 1ps

module downCounter (
    input wire clk,
    input wire reset,
    input wire enable,
    input wire load,
    input wire [15:0] value,
    output reg [15:0] counter
);

    localparam DIV_WIDTH = 24;

    reg [DIV_WIDTH-1:0] prescaler = 0; 
    wire slow_tick = (prescaler == 0);

    always @(posedge clk) begin
        if (reset) begin
            prescaler <= 0;
            counter <= 0;
        end
        else begin
            prescaler <= prescaler + 1;

            if (load) begin
                counter <= value;
            end
            else if (enable && (counter > 0) && slow_tick) begin
                counter <= counter - 1;
            end
        end
    end

endmodule