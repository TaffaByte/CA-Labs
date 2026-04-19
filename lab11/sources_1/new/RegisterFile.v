`timescale 1ns / 1ps

module RegisterFile (
    input  wire        clk, rst, WriteEnable,
    input  wire [ 4:0] rs1, rs2, rd,
    input  wire [31:0] WriteData,
    output wire [31:0] readData1, readData2
);
    reg [31:0] regs [0:31]; 
    integer i;
    
    // Register 0 is hardwired to 0
    assign readData1 = (rs1 == 5'b0) ? 32'b0 : regs[rs1];
    assign readData2 = (rs2 == 5'b0) ? 32'b0 : regs[rs2];

    always @(posedge clk) begin
        if (rst) begin
            for (i = 0; i < 32; i = i + 1) begin
                regs[i] <= 32'b0; 
            end
        end else if (WriteEnable && (rd != 5'b0)) begin
            regs[rd] <= WriteData;
        end
    end
endmodule