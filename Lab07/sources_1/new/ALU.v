`timescale 1ns / 1ps
module ALU(
    input [31:0] A, B,
    input [3:0] ALUControl,
    output reg [31:0] ALUResult,
    output zero
);
    always @(*) begin
        case (ALUControl)
            4'b0000: ALUResult = A + B;
            4'b0001: ALUResult = A - B;
            4'b0010: ALUResult = A & B;
            4'b0011: ALUResult = A | B;
            4'b0100: ALUResult = A ^ B;
            4'b0101: ALUResult = A << B[4:0];  // Shift amount is 5 bits
            4'b0110: ALUResult = A >> B[4:0];
            default: ALUResult = 32'b0;
        endcase
    end
    assign zero = (ALUResult == 32'b0);
endmodule