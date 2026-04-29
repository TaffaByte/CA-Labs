`timescale 1ns / 1ps

// mux2 - unchanged from Lab 11

module mux2 #(parameter WIDTH = 32) (
    input  wire [WIDTH-1:0] d0,
    input  wire [WIDTH-1:0] d1,
    input  wire             sel,
    output wire [WIDTH-1:0] y
);
    assign y = sel ? d1 : d0;
endmodule
