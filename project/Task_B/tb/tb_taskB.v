`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// tb_taskB - Dedicated Task B verification testbench
//
// Verifies each of the three NEW instructions added in Task B in isolation,
// independently of the Task C array-sum program.
//
// The testbench injects a small custom instruction stream directly into the
// instruction memory and checks the resulting register / PC behaviour. This
// way each new instruction (LUI, JAL, BNE) has its own pass/fail flag visible
// in both the Tcl Console AND the waveform window.
//
// Test program:
//   PC      Instruction                Tests
//   0x000   addi x10, x0, 5            (setup: x10 = 5)
//   0x004   addi x11, x0, 5            (setup: x11 = 5)
//   0x008   addi x12, x0, 7            (setup: x12 = 7)
//   ----------------------------------------------------------------
//   0x00C   LUI  x20, 0xABCDE          TEST 1: LUI -> x20 = 0xABCDE000
//   ----------------------------------------------------------------
//   0x010   JAL  x1, +12               TEST 2: JAL -> x1 = 0x014, PC -> 0x01C
//   0x014   addi x21, x0, 99           (this should be SKIPPED)
//   0x018   addi x21, x0, 99           (this should be SKIPPED)
//   0x01C   addi x22, x0, 1            (landing point - x22 = 1 proves jump)
//   ----------------------------------------------------------------
//   0x020   BNE  x10, x11, +8          TEST 3a: BNE x10==x11 -> NOT taken
//   0x024   addi x23, x0, 1            (executes, x23 = 1 proves not taken)
//   0x028   BNE  x10, x12, +8          TEST 3b: BNE x10!=x12 -> TAKEN
//   0x02C   addi x24, x0, 99           (this should be SKIPPED)
//   0x030   addi x25, x0, 1            (landing point - x25 = 1 proves taken)
//   ----------------------------------------------------------------
//   0x034   JAL x0, 0                  (halt)
//
//////////////////////////////////////////////////////////////////////////////////
module tb_taskB;
    reg clk = 0;
    reg reset = 1;
    always #5 clk = ~clk;

    wire [15:0] led;
    wire [6:0]  seg;
    wire [3:0]  an;

    TopLevelProcessor #(.USE_SLOW_CLK(0)) dut (
        .clk(clk), .reset(reset), .led(led), .seg(seg), .an(an)
    );

    // ---- Top-level signal mirrors (visible in waveform) ----
    wire [31:0] pc          = dut.u_pc.pc_out;
    wire [31:0] instruction = dut.instruction;
    wire [31:0] alu_result  = dut.alu_result;

    wire        ctrl_LUI      = dut.LUI;
    wire        ctrl_Jump     = dut.Jump;
    wire        ctrl_BranchNE = dut.BranchNE;
    wire        ctrl_Branch   = dut.Branch;

    // Register mirrors for each test
    wire [31:0] x1_jal_link  = dut.u_reg_file.regs[1];   // JAL stores PC+4 here
    wire [31:0] x20_lui_dst  = dut.u_reg_file.regs[20];  // LUI destination
    wire [31:0] x21_skipped  = dut.u_reg_file.regs[21];  // JAL should skip these
    wire [31:0] x22_jal_land = dut.u_reg_file.regs[22];  // JAL landing point
    wire [31:0] x23_bne_nt   = dut.u_reg_file.regs[23];  // BNE not-taken proof
    wire [31:0] x24_bne_skip = dut.u_reg_file.regs[24];  // BNE skipped
    wire [31:0] x25_bne_land = dut.u_reg_file.regs[25];  // BNE landing point

    // =====================================================================
    //  PASS FLAGS - one per Task B instruction, visible in waveform
    // =====================================================================
    reg pass_LUI       = 0;
    reg pass_JAL_link  = 0;
    reg pass_JAL_jump  = 0;
    reg pass_BNE_nt    = 0;     // BNE not-taken when equal
    reg pass_BNE_t     = 0;     // BNE taken when not equal
    reg taskB_passed   = 0;

    always @(posedge clk) begin
        if (!reset) begin
            // LUI: x20 should be 0xABCDE000
            if (x20_lui_dst == 32'hABCDE000) pass_LUI <= 1;

            // JAL link: x1 should hold PC+4 of the JAL instruction (0x014)
            if (x1_jal_link == 32'h00000014) pass_JAL_link <= 1;

            // JAL jump: x22 = 1 (landing executed) AND x21 = 0 (skipped)
            if (x22_jal_land == 32'd1 && x21_skipped == 32'd0) pass_JAL_jump <= 1;

            // BNE not-taken: x10 == x11, so x23 = 1 should execute
            if (x23_bne_nt == 32'd1) pass_BNE_nt <= 1;

            // BNE taken: x10 != x12, x25 = 1 (landing) AND x24 = 0 (skipped)
            if (x25_bne_land == 32'd1 && x24_bne_skip == 32'd0) pass_BNE_t <= 1;

            if (pass_LUI && pass_JAL_link && pass_JAL_jump &&
                pass_BNE_nt && pass_BNE_t)
                taskB_passed <= 1;
        end
    end

    initial begin
        $dumpfile("wave_taskB.vcd");
        $dumpvars(0, tb_taskB);

        // --------- Inject the custom Task B test program ---------
        // Setup
        dut.u_imem.memory[0]  = 32'h00500513; // addi x10, x0, 5
        dut.u_imem.memory[1]  = 32'h00500593; // addi x11, x0, 5
        dut.u_imem.memory[2]  = 32'h00700613; // addi x12, x0, 7

        // ---- TEST 1: LUI x20, 0xABCDE ----
        // Encoding: imm=0xABCDE, rd=20 (10100), opcode=0110111
        // = ABCDE_A_37
        dut.u_imem.memory[3]  = 32'hABCDEA37; // lui x20, 0xABCDE

        // ---- TEST 2: JAL x1, +12 (skip 0x014, 0x018, land at 0x01C) ----
        // Standard J-type encoding: target offset = +12 (0xC)
        // imm[20|10:1|11|19:12] = 0|0000000110|0|00000000
        // = 00C0_00EF
        dut.u_imem.memory[4]  = 32'h00C000EF; // jal x1, +12
        dut.u_imem.memory[5]  = 32'h06300A93; // addi x21, x0, 99 (skipped)
        dut.u_imem.memory[6]  = 32'h06300A93; // addi x21, x0, 99 (skipped)
        dut.u_imem.memory[7]  = 32'h00100B13; // addi x22, x0, 1  (landing)

        // ---- TEST 3a: BNE x10, x11, +8 (NOT taken since x10==x11) ----
        // BNE encoding: opcode=1100011, funct3=001, rs1=10, rs2=11, offset=+8
        // = 00B 51 4 63 ; let's hand-build
        // imm[12|10:5|4:1|11] for offset 8 = 0|000000|0100|0
        dut.u_imem.memory[8]  = 32'h00B51463; // bne x10, x11, +8

        dut.u_imem.memory[9]  = 32'h00100B93; // addi x23, x0, 1 (executes - not skipped)

        // ---- TEST 3b: BNE x10, x12, +8 (TAKEN since x10!=x12) ----
        dut.u_imem.memory[10] = 32'h00C51463; // bne x10, x12, +8
        dut.u_imem.memory[11] = 32'h06300C13; // addi x24, x0, 99 (skipped)
        dut.u_imem.memory[12] = 32'h00100C93; // addi x25, x0, 1  (landing)

        // halt
        dut.u_imem.memory[13] = 32'h0000006F; // jal x0, 0

        reset = 1; #20; reset = 0;

        #500;

        $display("");
        $display("=========================================================");
        $display("  Task B Verification - 3 new instructions in isolation");
        $display("=========================================================");
        $display("");
        $display("  -- LUI (U-type) --");
        $display("    lui x20, 0xABCDE  ->  x20 = 0x%08x", x20_lui_dst);
        $display("    Expected: 0xABCDE000                          [%s]",
            pass_LUI ? "PASS" : "FAIL");
        $display("");
        $display("  -- JAL (J-type) --");
        $display("    jal x1, +12       ->  x1  = 0x%08x", x1_jal_link);
        $display("    Expected x1 = 0x14 (return addr = PC+4)       [%s]",
            pass_JAL_link ? "PASS" : "FAIL");
        $display("    Skipped instructions did not execute:");
        $display("      x21 = %0d (expected 0 - skipped)            [%s]",
            x21_skipped, x21_skipped == 0 ? "PASS" : "FAIL");
        $display("    Landing point reached:");
        $display("      x22 = %0d (expected 1 - executed)           [%s]",
            x22_jal_land, x22_jal_land == 1 ? "PASS" : "FAIL");
        $display("");
        $display("  -- BNE (B-type) --");
        $display("    bne x10, x11, ...  (x10==x11, not taken)");
        $display("      x23 = %0d (expected 1 - fell through)       [%s]",
            x23_bne_nt, pass_BNE_nt ? "PASS" : "FAIL");
        $display("    bne x10, x12, ...  (x10!=x12, TAKEN)");
        $display("      x24 = %0d (expected 0 - skipped)            [%s]",
            x24_bne_skip, x24_bne_skip == 0 ? "PASS" : "FAIL");
        $display("      x25 = %0d (expected 1 - landed)             [%s]",
            x25_bne_land, x25_bne_land == 1 ? "PASS" : "FAIL");
        $display("");
        $display("---------------------------------------------------------");
        if (taskB_passed)
            $display("  *** TASK B: ALL 3 NEW INSTRUCTIONS VERIFIED ***");
        else
            $display("  *** TASK B FAILED - check signals above ***");
        $display("=========================================================");
        $display("");
        $finish;
    end
endmodule
