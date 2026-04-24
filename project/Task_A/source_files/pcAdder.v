`timescale 1ns / 1ps
// pcAdder - unchanged from Lab 11

module pcAdder (
    input  wire [31:0] pc,
    output wire [31:0] pc_next
);
    assign pc_next = pc + 32'd4;
endmodule
