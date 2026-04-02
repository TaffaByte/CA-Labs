`timescale 1ns / 1ps

module leds (
    input clk, 
    input rst, 
    input [31:0] writeData,
    input writeEnable, 
    output [15:0] leds
);

    reg [15:0] led_reg;
    always @(posedge clk) begin
        if (rst) led_reg <= 16'h0;
        else if (writeEnable) led_reg <= writeData[15:0];
    end
    assign leds = led_reg;
endmodule