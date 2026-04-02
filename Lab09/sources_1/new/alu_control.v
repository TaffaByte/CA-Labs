`timescale 1ns / 1ps

module ALUControl (
    input [1:0] ALUOp,
    input [2:0] funct3,
    input funct7,
    output reg [3:0] ALUControl
);
    always @(*) begin
        case (ALUOp)
            2'b00: ALUControl = 4'b0000; // ADD
            2'b01: ALUControl = 4'b0001; // SUB
            2'b10: begin // R-type
                case (funct3)
                    3'b000:  ALUControl = funct7 ? 4'b0001 : 4'b0000; // SUB/ADD
                    3'b001:  ALUControl = 4'b0010; // SLL
                    3'b101:  ALUControl = 4'b0011; // SRL
                    3'b111:  ALUControl = 4'b0100; // AND
                    3'b110:  ALUControl = 4'b0101; // OR
                    3'b100:  ALUControl = 4'b0110; // XOR
                    default: ALUControl = 4'b0000;
                endcase
            end
            default: ALUControl = 4'b0000;
        endcase
    end
endmodule