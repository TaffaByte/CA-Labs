`timescale 1ns / 1ps
// immGen - extended for JAL (J-type) and LUI (U-type).
//
// note about B-type immediate:
// In Lab 11, branchAdder does (pc + (imm << 1)). That means immGen
// produces a "halfword" offset rather than a byte offset for branches. To keep
// backward compatibility with the existing BEQ instruction encodings from
// Lab 10, we kept that same convention here (i.e. we do NOT include the
// implicit-zero LSB in the immediate, leaving the <<1 to branchAdder).
//
// For JAL, however, the J-type immediate also has an implicit-zero LSB and
// a similar 2-byte alignment. here we produce the FULL byte offset  (including
// the implicit zero) and use a NEW jumpAdder that adds it directly to PC
// (no extra <<1). This avoids changing branchAdder's behavior.

module immGen (
    input  wire [31:0] inst,
    output reg  [31:0] imm
);
    wire [6:0] opcode = inst[6:0];
    always @(*) begin
        imm = 32'b0;
        case (opcode)
            7'b0010011, // I-Type: ALU
            7'b0000011, // I-Type: Loads
            7'b1100111: // I-Type: JALR
                imm = {{20{inst[31]}}, inst[31:20]};

            7'b0100011: // S-Type: Stores
                imm = {{20{inst[31]}}, inst[31:25], inst[11:7]};

            7'b1100011: // B-Type: Branches (BEQ, BNE)
                // Halfword offset (matches Lab 11 branchAdder which does <<1)
                imm = {{21{inst[31]}}, inst[7], inst[30:25], inst[11:8]};

            7'b1101111: // J-Type: JAL
                // Full byte offset, sign-extended, LSB=0
                imm = {{12{inst[31]}}, inst[19:12], inst[20], inst[30:21], 1'b0};

            7'b0110111: // U-Type: LUI
                imm = {inst[31:12], 12'b0};
        endcase
    end
endmodule
