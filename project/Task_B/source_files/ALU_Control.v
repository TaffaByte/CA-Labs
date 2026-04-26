`timescale 1ns / 1ps
// ALU_Control - unchanged from Lab 11
//   For branches (ALUOp == 01), produces SUB so the ALU's zero flag indicates
//   equality. This works for both BEQ and BNE; the difference is only in how
//   the branch decision logic uses zero (handled in MainControl + TopLevel).

module ALU_Control (
    input  wire [1:0] ALUOp,
    input  wire [2:0] funct3,
    input  wire [6:0] funct7,
    output reg  [3:0] ALUControl
);
    always @(*) begin
        ALUControl = 4'b0000;
        case (ALUOp)
            2'b00: ALUControl = 4'b0000; // ADD (Load/Store)
            2'b01: ALUControl = 4'b0001; // SUB (Branch - works for BEQ and BNE)

            2'b10: begin // R-type
                case (funct3)
                    3'b000: ALUControl = (funct7 == 7'b0100000) ? 4'b0001 : 4'b0000;
                    3'b001: ALUControl = 4'b0101; // SLL
                    3'b100: ALUControl = 4'b0100; // XOR
                    3'b101: ALUControl = 4'b0110; // SRL
                    3'b110: ALUControl = 4'b0011; // OR
                    3'b111: ALUControl = 4'b0010; // AND
                    default: ALUControl = 4'b0000;
                endcase
            end

            2'b11: ALUControl = 4'b0000; // I-type ALU (ADDI)
            default: ALUControl = 4'b0000;
        endcase
    end
endmodule
