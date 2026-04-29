`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// tb_taskC - Main project testbench (Part C: array summation)
//
// This testbench:
//   (1) Drives the CPU at full clock speed (USE_SLOW_CLK = 0).
//   (2) Runs long enough for the program to reach the halt loop.
//   (3) Surfaces ALL key values as TOP-LEVEL named signals so they are
//       directly visible in the Vivado XSim waveform window when you
//       "Add Signals" from the tb_taskC scope.
//   (4) Drives a one-bit  test_passed  flag that goes HIGH when the
//       expected register/memory state has been observed.
//
// In Vivado: Run Simulation -> the simulation will auto-stop at $finish
// without you having to type 'run 25us'. Then expand 'tb_taskC' in the
// Scope window and add the signals to the waveform.
//////////////////////////////////////////////////////////////////////////////////
module tb_taskC;
    // ---------- Clock & Reset ----------
    reg clk = 0;
    reg reset = 1;
    always #5 clk = ~clk;   // 100 MHz

    // ---------- Outputs from DUT ----------
    wire [15:0] led;
    wire [6:0]  seg;
    wire [3:0]  an;

    // ---------- DUT ----------
    TopLevelProcessor #(.USE_SLOW_CLK(0)) dut (
        .clk(clk), .reset(reset),
        .led(led), .seg(seg), .an(an)
    );

    // =====================================================================
    //  WAVEFORM-VISIBLE OBSERVATION SIGNALS
    //  Every important value is mirrored to a top-level wire/reg here so it
    //  shows up directly under tb_taskC in the Scope window.
    // =====================================================================

    // ---- Program Counter & Instruction ----
    wire [31:0] pc          = dut.u_pc.pc_out;
    wire [31:0] instruction = dut.instruction;

    // ---- Control Signals ----
    wire        ctrl_RegWrite = dut.RegWrite;
    wire        ctrl_MemRead  = dut.MemRead;
    wire        ctrl_MemWrite = dut.MemWrite;
    wire        ctrl_ALUSrc   = dut.ALUSrc;
    wire        ctrl_MemtoReg = dut.MemtoReg;
    wire        ctrl_Branch   = dut.Branch;     // BEQ
    wire        ctrl_BranchNE = dut.BranchNE;   // BNE   <-- new
    wire        ctrl_Jump     = dut.Jump;       // JAL   <-- new
    wire        ctrl_LUI      = dut.LUI;        // LUI   <-- new
    wire [1:0]  ctrl_ALUOp    = dut.ALUOp;

    // ---- Datapath ----
    wire [31:0] alu_result    = dut.alu_result;
    wire        alu_zero      = dut.zero_flag;
    wire [31:0] reg_writeback = dut.write_data;
    wire [31:0] imm_extended  = dut.imm_extended;
    wire [31:0] branch_target = dut.branch_target;
    wire [31:0] jump_target   = dut.jump_target;
    wire [31:0] next_pc       = dut.next_pc;

    // ---- Register file mirrors ----
    wire [31:0] x1_ra         = dut.u_reg_file.regs[1];   // JAL link reg
    wire [31:0] x5            = dut.u_reg_file.regs[5];   // array[0] = 1
    wire [31:0] x6            = dut.u_reg_file.regs[6];   // array[1] = 2
    wire [31:0] x7            = dut.u_reg_file.regs[7];   // array[2] = 3
    wire [31:0] x10_base      = dut.u_reg_file.regs[10];
    wire [31:0] x11_N         = dut.u_reg_file.regs[11];
    wire [31:0] x12_sum       = dut.u_reg_file.regs[12];  // running sum
    wire [31:0] x13_result    = dut.u_reg_file.regs[13];  // final copy
    wire [31:0] x14_i         = dut.u_reg_file.regs[14];  // loop index
    wire [31:0] x18_lui       = dut.u_reg_file.regs[18];  // LUI result
    wire [31:0] x28           = dut.u_reg_file.regs[28];
    wire [31:0] x29           = dut.u_reg_file.regs[29];

    // ---- Data memory mirrors (array values stored by SW) ----
    wire [31:0] dmem_addr0  = dut.u_dmem.memory[0];
    wire [31:0] dmem_addr4  = dut.u_dmem.memory[4];
    wire [31:0] dmem_addr8  = dut.u_dmem.memory[8];
    wire [31:0] dmem_addr12 = dut.u_dmem.memory[12];
    wire [31:0] dmem_addr16 = dut.u_dmem.memory[16];

    // =====================================================================
    //  INSTRUCTION MARKERS - pulse high during specific events
    //  Useful for spotting JAL/BNE/LUI in the waveform at a glance.
    // =====================================================================
    wire is_LUI_inst = (instruction[6:0] == 7'b0110111);
    wire is_JAL_inst = (instruction[6:0] == 7'b1101111);
    wire is_BNE_inst = (instruction[6:0] == 7'b1100011) && (instruction[14:12] == 3'b001);
    wire is_BEQ_inst = (instruction[6:0] == 7'b1100011) && (instruction[14:12] == 3'b000);

    // =====================================================================
    //  TEST RESULT FLAGS (visible in waveform)
    //   * Each flag goes high once its expected value has been observed.
    //   * test_passed pulses high once ALL conditions are met.
    //   * test_failed goes high if simulation ends and not all met.
    // =====================================================================
    reg pass_x5    = 0;
    reg pass_x6    = 0;
    reg pass_x7    = 0;
    reg pass_x28   = 0;
    reg pass_x29   = 0;
    reg pass_x18   = 0;     // LUI
    reg pass_x1    = 0;     // JAL link
    reg pass_x12   = 0;     // sum from BNE loop
    reg pass_x13   = 0;     // final ALU output copy
    reg pass_pc    = 0;     // halted at 0x68
    reg pass_dmem  = 0;     // array stored correctly

    reg test_passed = 0;
    reg test_failed = 0;

    always @(posedge clk) begin
        if (!reset) begin
            if (x5         == 32'd1)         pass_x5   <= 1;
            if (x6         == 32'd2)         pass_x6   <= 1;
            if (x7         == 32'd3)         pass_x7   <= 1;
            if (x28        == 32'd4)         pass_x28  <= 1;
            if (x29        == 32'd5)         pass_x29  <= 1;
            if (x18_lui    == 32'h00010000)  pass_x18  <= 1;
            if (x1_ra      == 32'h00000044)  pass_x1   <= 1;
            if (x12_sum    == 32'd15)        pass_x12  <= 1;
            if (x13_result == 32'd15)        pass_x13  <= 1;
            if (pc == 32'h00000068 || pc == 32'h0000006C)  pass_pc <= 1;
            if (dmem_addr0  == 32'd1 &&
                dmem_addr4  == 32'd2 &&
                dmem_addr8  == 32'd3 &&
                dmem_addr12 == 32'd4 &&
                dmem_addr16 == 32'd5)        pass_dmem <= 1;

            if (pass_x5 && pass_x6 && pass_x7 && pass_x28 && pass_x29 &&
                pass_x18 && pass_x1 && pass_x12 && pass_x13 && pass_pc &&
                pass_dmem)
                test_passed <= 1;
        end
    end

    // =====================================================================
    //  SIMULATION CONTROL
    // =====================================================================
    initial begin
        // Optional VCD dump for non-Vivado simulators (Icarus, ModelSim)
        $dumpfile("wave.vcd");
        $dumpvars(0, tb_taskC);

        // Apply reset for 2 cycles
        reset = 1;
        #20;
        reset = 0;

        // Run long enough for the program to reach the halt loop and
        // for test_passed to assert.
        #2000;

        // ---- Console output for those who want it ----
        $display("");
        $display("=========================================================");
        $display("  Part C Test Results (sum-of-array using LUI/JAL/BNE)");
        $display("=========================================================");
        $display("  x5  = %0d        (expected 1)   %s", x5,         pass_x5  ? "PASS" : "FAIL");
        $display("  x6  = %0d        (expected 2)   %s", x6,         pass_x6  ? "PASS" : "FAIL");
        $display("  x7  = %0d        (expected 3)   %s", x7,         pass_x7  ? "PASS" : "FAIL");
        $display("  x28 = %0d        (expected 4)   %s", x28,        pass_x28 ? "PASS" : "FAIL");
        $display("  x29 = %0d        (expected 5)   %s", x29,        pass_x29 ? "PASS" : "FAIL");
        $display("  x18 = 0x%08x  (expected 0x00010000 - LUI)   %s", x18_lui, pass_x18 ? "PASS" : "FAIL");
        $display("  x1  = 0x%08x  (expected 0x00000044 - JAL ra) %s", x1_ra,  pass_x1  ? "PASS" : "FAIL");
        $display("  x12 = %0d       (expected 15 - BNE sum)        %s", x12_sum,    pass_x12 ? "PASS" : "FAIL");
        $display("  x13 = %0d       (expected 15 - copy on LEDs)   %s", x13_result, pass_x13 ? "PASS" : "FAIL");
        $display("  PC  = 0x%08x  (expected 0x00000068 or 0x6C - halt loop) %s", pc, pass_pc ? "PASS" : "FAIL");
        $display("  Data memory array stored correctly:           %s",     pass_dmem ? "PASS" : "FAIL");
        $display("---------------------------------------------------------");
        if (test_passed) begin
            $display("  *** ALL CHECKS PASSED ***");
        end else begin
            test_failed = 1;
            $display("  *** TEST FAILED ***");
        end
        $display("=========================================================");
        $display("");

        #20 $finish;
    end
endmodule
