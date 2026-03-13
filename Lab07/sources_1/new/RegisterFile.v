`timescale 1ns / 1ps
module RegisterFile(
    input clk, rst, WriteEnable,
    input [4:0] rs1, rs2, rd,
    input [31:0] WriteData,
    output [31:0] readData1, readData2
);
    reg [31:0] regs [31:0];

    // Asynchronous read: x0 is always 0
    assign readData1 = (rs1 == 5'b0) ? 32'b0 : regs[rs1];
    assign readData2 = (rs2 == 5'b0) ? 32'b0 : regs[rs2];

    integer i;
    always @(posedge clk) begin
        if (rst) begin
            for (i = 0; i < 32; i = i + 1) regs[i] <= 32'b0;
        end else if (WriteEnable && rd != 5'b0) begin
            regs[rd] <= WriteData;
        end
    end
endmodule