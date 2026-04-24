`timescale 1ns / 1ps
// InstructionMemory - unchanged from Lab 11
//   Loads program from program.mem at simulation/synthesis start.

module InstructionMemory (
    input  wire [31:0] ReadAddress,
    output wire [31:0] Instruction
);
    reg [31:0] memory [0:63];
    wire [5:0] word_addr = ReadAddress[7:2];

    assign Instruction = memory[word_addr];

    initial begin
        $readmemh("program.mem", memory);
    end
endmodule
