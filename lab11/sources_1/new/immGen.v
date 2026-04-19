`timescale 1ns / 1ps

module immGen (
    input  wire [31:0] inst,
    output reg  [31:0] imm
);
    wire [6:0] opcode = inst[6:0];

    always @(*) begin
        imm = 32'b0; // Default assignment
        case (opcode)
            7'b0010011, // I-Type: ALU
            7'b0000011, // I-Type: Loads
            7'b1100111: // I-Type: JALR
                imm = {{20{inst[31]}}, inst[31:20]};
                
            7'b0100011: // S-Type: Stores
                imm = {{20{inst[31]}}, inst[31:25], inst[11:7]};
                
            7'b1100011: // B-Type: Branches
                imm = {{21{inst[31]}}, inst[7], inst[30:25], inst[11:8]};
        endcase
    end
endmodule