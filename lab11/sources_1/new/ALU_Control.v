`timescale 1ns / 1ps

module ALU_Control (
    input  wire [1:0] ALUOp, 
    input  wire [2:0] funct3,
    input  wire [6:0] funct7,
    output reg  [3:0] ALUControl
);
    // Using user's specific opcodes
    localparam ADD = 4'b0010; // Following original logic where ADDI defaulted to 0010
    localparam SUB = 4'b0110; 
    
    always @(*) begin
        ALUControl = 4'b0000; // Default

        case (ALUOp)
            2'b00: ALUControl = ADD; // Load / Store
            2'b01: ALUControl = SUB; // Branch
            
            2'b10: begin // R-type
                case (funct3)
                    3'b000: ALUControl = (funct7 == 7'b0100000) ? SUB : ADD;
                    3'b001: ALUControl = 4'b0101; // SLL
                    3'b100: ALUControl = 4'b0100; // XOR
                    3'b101: ALUControl = 4'b0111; // SRL
                    3'b110: ALUControl = 4'b0001; // OR
                    3'b111: ALUControl = 4'b0000; // AND
                    default: ALUControl = 4'b0000;
                endcase
            end
            
            2'b11: begin // I-type ALU
                if (funct3 == 3'b000) ALUControl = ADD;
                else ALUControl = ADD; // Default to ADD for other formats
            end
        endcase
    end
endmodule