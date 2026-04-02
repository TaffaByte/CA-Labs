`timescale 1ns / 1ps

module MainControl (
    input  [6:0] opcode,
    output reg   RegWrite,
    output reg   ALUSrc,
    output reg   MemRead,
    output reg   MemWrite,
    output reg   MemtoReg,
    output reg   Branch,
    output reg [1:0] ALUOp
);
    // Opcode constants
    localparam R_TYPE = 7'b0110011; 
    localparam I_ALU  = 7'b0010011; 
    localparam I_LOAD = 7'b0000011; 
    localparam S_TYPE = 7'b0100011; 
    localparam B_TYPE = 7'b1100011; 

    always @(*) begin
        {RegWrite, ALUSrc, MemRead, MemWrite, MemtoReg, Branch} = 6'b000000;
        ALUOp = 2'b00;

        case (opcode)
            R_TYPE: begin RegWrite = 1; ALUOp = 2'b10; end
            I_ALU:  begin RegWrite = 1; ALUSrc = 1; end
            I_LOAD: begin RegWrite = 1; ALUSrc = 1; MemRead = 1; MemtoReg = 1; end
            S_TYPE: begin ALUSrc   = 1; MemWrite = 1; end
            B_TYPE: begin Branch   = 1; ALUOp = 2'b01; end
            default:;
        endcase
    end
endmodule