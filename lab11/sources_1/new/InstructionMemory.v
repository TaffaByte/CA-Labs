`timescale 1ns / 1ps

module InstructionMemory (
    input  wire [31:0] ReadAddress,
    output wire [31:0] Instruction
);
    reg [31:0] memory [0:63]; 
    wire [5:0] word_addr = ReadAddress[7:2];
    
    assign Instruction = memory[word_addr];

    initial begin
        $readmemh("C:/Uni_Stuff/CA/Lab11/program.hex", memory);
    end
endmodule