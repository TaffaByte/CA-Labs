`timescale 1ns / 1ps

module TopLevelProcessor (
    input wire clk,
    input wire reset,
    output wire [15:0] led
);
    // Program Flow
    wire [31:0] pc_out, pc_plus_4, branch_target, next_pc, instruction;
    
    // Control Signals
    wire Branch, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite, PCSrc, zero_flag;
    wire [1:0]  ALUOp;
    wire [3:0]  ALU_operation; 
    
    // Data Path
    wire [31:0] imm_extended, read_data1, read_data2, alu_input_b, alu_result, memory_read_data, write_data;

    // --- Output Assignments ---
    assign PCSrc = Branch & zero_flag;
    
    // Wire the lower 16 bits of the PC to the Basys 3 LEDs
    assign led = pc_out[15:0]; 

    // --- Module Instantiations ---
    ProgramCounter u_pc (.clk(clk), .reset(reset), .pc_in(next_pc), .pc_out(pc_out));
    pcAdder        u_pcAdder (.pc(pc_out), .pc_next(pc_plus_4));
    branchAdder    u_branchAdder (.pc(pc_out), .imm(imm_extended), .branch_target(branch_target));
    
    mux2 #(32) u_mux_pc_select (.d0(pc_plus_4), .d1(branch_target), .sel(PCSrc), .y(next_pc));

    InstructionMemory u_imem (.ReadAddress(pc_out), .Instruction(instruction));

    MainControl u_main_ctrl (
        .opcode(instruction[6:0]), .RegWrite(RegWrite), .ALUOp(ALUOp), 
        .MemRead(MemRead), .MemWrite(MemWrite), .ALUSrc(ALUSrc), 
        .MemtoReg(MemtoReg), .Branch(Branch)
    );

    ALU_Control u_alu_ctrl (
        .ALUOp(ALUOp), .funct3(instruction[14:12]), .funct7(instruction[31:25]), .ALUControl(ALU_operation)
    );

    RegisterFile u_reg_file (
        .clk(clk), .rst(reset), .WriteEnable(RegWrite), 
        .rs1(instruction[19:15]), .rs2(instruction[24:20]), .rd(instruction[11:7]), 
        .WriteData(write_data), .readData1(read_data1), .readData2(read_data2)
    );

    immGen u_immGen (.inst(instruction), .imm(imm_extended));

    mux2 #(32) u_mux_alu_src (.d0(read_data2), .d1(imm_extended), .sel(ALUSrc), .y(alu_input_b));

    ALU u_alu (
        .A(read_data1), .B(alu_input_b), .ALUControl(ALU_operation), 
        .ALUResult(alu_result), .zero(zero_flag)
    );

    DataMemory u_dmem (
        .clk(clk), .rst(reset), .memWrite(MemWrite), 
        .address(alu_result[7:0]), .writeData(read_data2), .readData(memory_read_data)
    );

    mux2 #(32) u_mux_writeback (.d0(alu_result), .d1(memory_read_data), .sel(MemtoReg), .y(write_data));

endmodule