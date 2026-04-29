`timescale 1ns / 1ps
// RegisterFile - unchanged from Lab 11
//   x0 hardwired to zero. Synchronous write, asynchronous read.

module RegisterFile (
    input  wire        clk,
    input  wire        rst,
    input  wire        WriteEnable,
    input  wire [ 4:0] rs1,
    input  wire [ 4:0] rs2,
    input  wire [ 4:0] rd,
    input  wire [31:0] WriteData,
    output wire [31:0] readData1,
    output wire [31:0] readData2
);
    reg [31:0] regs [0:31];
    integer i;

    assign readData1 = (rs1 == 5'b0) ? 32'b0 : regs[rs1];
    assign readData2 = (rs2 == 5'b0) ? 32'b0 : regs[rs2];

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < 32; i = i + 1) regs[i] <= 32'b0;
        end else if (WriteEnable && (rd != 5'b0)) begin
            regs[rd] <= WriteData;
        end
    end
endmodule
