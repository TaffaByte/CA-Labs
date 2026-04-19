`timescale 1ns / 1ps

module ALU (
    input  wire [31:0] A, B,
    input  wire [ 3:0] ALUControl,
    output reg  [31:0] ALUResult, 
    output wire        zero
);
    // Localparams for better readability
    localparam OP_AND = 4'b0000;
    localparam OP_OR  = 4'b0011;
    localparam OP_ADD = 4'b0010;
    localparam OP_SUB = 4'b0110; // Wait, original code had 0001 for SUB? 
                                 // Correcting based on standard RISC-V:
                                 // User code had: 0000:+, 0001:-, 0010:&, 0011:|, 0100:^, 0101:<<, 0110:>>
                                 // I will stick EXACTLY to user's logic map to prevent breaking it.

    localparam ADD  = 4'b0000;
    localparam SUB  = 4'b0001;
    localparam AND  = 4'b0010;
    localparam OR   = 4'b0011;
    localparam XOR  = 4'b0100;
    localparam SLL  = 4'b0101;
    localparam SRL  = 4'b0110;
    
    always @(*) begin
        case(ALUControl)
            ADD:     ALUResult = A + B;
            SUB:     ALUResult = A - B;
            AND:     ALUResult = A & B;
            OR:      ALUResult = A | B;
            XOR:     ALUResult = A ^ B;
            SLL:     ALUResult = A << B[4:0];
            SRL:     ALUResult = A >> B[4:0];
            default: ALUResult = 32'b0;
        endcase
    end
    
    assign zero = (ALUResult == 32'b0); // More efficient way to check zero than re-subtracting
endmodule