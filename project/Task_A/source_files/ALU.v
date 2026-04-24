`timescale 1ns / 1ps
// ALU - unchanged from Lab 11

module ALU (
    input  wire [31:0] A, B,
    input  wire [ 3:0] ALUControl,
    output reg  [31:0] ALUResult,
    output wire        zero
);
    always @(*) begin
        case(ALUControl)
            4'b0000: ALUResult = A + B;       // ADD
            4'b0001: ALUResult = A - B;       // SUB
            4'b0010: ALUResult = A & B;       // AND
            4'b0011: ALUResult = A | B;       // OR
            4'b0100: ALUResult = A ^ B;       // XOR
            4'b0101: ALUResult = A << B[4:0]; // SLL
            4'b0110: ALUResult = A >> B[4:0]; // SRL
            default: ALUResult = 32'b0;
        endcase
    end

    assign zero = (ALUResult == 32'b0);
endmodule
