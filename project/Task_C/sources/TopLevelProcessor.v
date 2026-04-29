`timescale 1ns / 1ps

// TopLevelProcessor
//   - Added JAL (J-type), BNE (B-type), LUI (U-type)
//   - Maps full 32-bit ALU result to FPGA hardware:
//        led[15:0]   <- ALUResult[15:0]   (lower 16 bits)
//        seg/an      <- ALUResult[31:16]  (upper 16 bits, on 4 7-seg digits)
//   - Asked Claude for this ->  Drives a built-in slow clock divider so the Basys3 100MHz crystal
//     can be slowed down enough for visible execution. Set USE_SLOW_CLK=0
//     for simulation, =1 for hardware.

module TopLevelProcessor #(
    parameter USE_SLOW_CLK = 1   // set to 0 for simulation, 1 for FPGA
)(
    input  wire        clk,       // 100 MHz Basys3 board clock
    input  wire        reset,
    output wire [15:0] led,       // 16 LEDs  -> ALUResult[15:0]
    output wire [6:0]  seg,       // 7-seg cathodes (active-low)
    output wire [3:0]  an         // 7-seg anodes    (active-low)
);
    // Optional clock divider so the CPU runs slowly enough to watch
    reg [25:0] clk_div;
    wire cpu_clk;

    always @(posedge clk or posedge reset) begin
        if (reset) clk_div <= 26'b0;
        else       clk_div <= clk_div + 1'b1;
    end

    // ~1.5 Hz on a 100 MHz board (bit 25 toggles every ~0.67 s)
    assign cpu_clk = USE_SLOW_CLK ? clk_div[25] : clk;

    // Program flow
    wire [31:0] pc_out, pc_plus_4, branch_target, jump_target, next_pc, instruction;
    wire [31:0] pc_after_branch;

    // Control Signals
    wire Branch, BranchNE, Jump, LUI;
    wire MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite;
    wire PCSrc, BranchTaken, zero_flag;
    wire [1:0] ALUOp;
    wire [3:0] ALU_operation;

    // Data path
    wire [31:0] imm_extended, read_data1, read_data2, alu_input_b, alu_result, memory_read_data;
    wire [31:0] mem_or_alu, write_data;

    // Branch / Jump decision logic
    //   BranchTaken =  (BEQ AND zero) OR (BNE AND NOT zero)
    //   PCSrc       =  BranchTaken                          (chooses branch target)
    //   Jump        =  unconditional, overrides everything   (chooses jump target)
    assign BranchTaken = (Branch & zero_flag) | (BranchNE & ~zero_flag);
    assign PCSrc       = BranchTaken;

    // PC + datapath modules
    ProgramCounter u_pc (.clk(cpu_clk), .reset(reset), .pc_in(next_pc), .pc_out(pc_out));
    pcAdder        u_pcAdder    (.pc(pc_out), .pc_next(pc_plus_4));
    branchAdder    u_branchAdder(.pc(pc_out), .imm(imm_extended), .branch_target(branch_target));
    jumpAdder      u_jumpAdder  (.pc(pc_out), .imm(imm_extended), .jump_target(jump_target));

    // PC mux 1: branch vs PC+4
    mux2 #(32) u_mux_pc_select (.d0(pc_plus_4), .d1(branch_target), .sel(PCSrc), .y(pc_after_branch));
    // PC mux 2: jump overrides
    mux2 #(32) u_mux_jump      (.d0(pc_after_branch), .d1(jump_target), .sel(Jump), .y(next_pc));

    InstructionMemory u_imem (.ReadAddress(pc_out), .Instruction(instruction));

    MainControl u_main_ctrl (
        .opcode(instruction[6:0]),
        .funct3(instruction[14:12]),
        .RegWrite(RegWrite), .ALUOp(ALUOp),
        .MemRead(MemRead),   .MemWrite(MemWrite),
        .ALUSrc(ALUSrc),     .MemtoReg(MemtoReg),
        .Branch(Branch),     .BranchNE(BranchNE),
        .Jump(Jump),         .LUI(LUI)
    );

    // ALU control gets funct3/funct7 plus a hint for BNE (funct3 differs from BEQ)
    ALU_Control u_alu_ctrl (
        .ALUOp(ALUOp),
        .funct3(instruction[14:12]),
        .funct7(instruction[31:25]),
        .ALUControl(ALU_operation)
    );

    RegisterFile u_reg_file (
        .clk(cpu_clk), .rst(reset),
        .WriteEnable(RegWrite),
        .rs1(instruction[19:15]),
        .rs2(instruction[24:20]),
        .rd (instruction[11:7]),
        .WriteData(write_data),
        .readData1(read_data1),
        .readData2(read_data2)
    );

    immGen u_immGen (.inst(instruction), .imm(imm_extended));

    mux2 #(32) u_mux_alu_src (.d0(read_data2), .d1(imm_extended), .sel(ALUSrc), .y(alu_input_b));

    ALU u_alu (
        .A(read_data1), .B(alu_input_b),
        .ALUControl(ALU_operation),
        .ALUResult(alu_result), .zero(zero_flag)
    );

    DataMemory u_dmem (
        .clk(cpu_clk), .rst(reset),
        .memWrite(MemWrite),
        .address(alu_result[7:0]),
        .writeData(read_data2),
        .readData(memory_read_data)
    );

    // Writeback mux chain:
    //   step 1: choose ALU result vs memory read   (MemtoReg)
    //   step 2: if LUI,  override with immediate   (LUI)
    //   step 3: if JAL,  override with PC+4        (Jump)   <- last so it wins

    wire [31:0] wb_after_lui;
    mux2 #(32) u_mux_wb1 (.d0(alu_result),  .d1(memory_read_data), .sel(MemtoReg), .y(mem_or_alu));
    mux2 #(32) u_mux_wb2 (.d0(mem_or_alu),  .d1(imm_extended),     .sel(LUI),      .y(wb_after_lui));
    mux2 #(32) u_mux_wb3 (.d0(wb_after_lui),.d1(pc_plus_4),        .sel(Jump),     .y(write_data));

    // FPGA hardware output mapping
    //   - full 32-bit ALU output observable on hw.
    //   - Lower 16 bits  -> 16 LEDs
    //   - Upper 16 bits  -> 4-digit 7-segment display (4 hex digits)

    assign led = alu_result[15:0];

    sevenSegDriver u_sevenSeg (
        .clk(clk),                 
        .reset(reset),
        .data_in(alu_result[31:16]),
        .seg(seg),
        .an(an)
    );

endmodule
