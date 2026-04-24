`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// tb_partA - Tests the unmodified Lab 10 program on the extended processor.
//
// Lab 10 program:
//   addi x2, x0, 7      ; x2 = 7
//   addi x3, x0, 5      ; x3 = 5
//   add  x4, x2, x3     ; ALUResult = 12
//   sub  x4, x2, x3     ; ALUResult = 2
//   xor  x4, x2, x3     ; ALUResult = 2
//   or   x4, x2, x3     ; ALUResult = 7
//   and  x4, x2, x3     ; ALUResult = 5
//
// This testbench captures the ALUResult value at each cycle so you can
// verify all 6 ALU ops on the waveform. It uses a dedicated mem file
// (program_partA.mem) loaded by overriding the InstructionMemory contents
// at time 0.
//
// Note: to actually run the Lab 10 program in Vivado, replace the
// contents of program.mem with the seven Lab 10 hex words. In simulation
// you can also $readmemh a different file directly into dut.u_imem.memory
// after time 0 (done below).
//////////////////////////////////////////////////////////////////////////////////
module tb_partA;
    reg clk = 0;
    reg reset = 1;
    always #5 clk = ~clk;

    wire [15:0] led;
    wire [6:0]  seg;
    wire [3:0]  an;

    TopLevelProcessor #(.USE_SLOW_CLK(0)) dut (
        .clk(clk), .reset(reset), .led(led), .seg(seg), .an(an)
    );

    // ---- Top-level mirrors ----
    wire [31:0] pc          = dut.u_pc.pc_out;
    wire [31:0] instruction = dut.instruction;
    wire [31:0] alu_result  = dut.alu_result;
    wire [31:0] x2          = dut.u_reg_file.regs[2];
    wire [31:0] x3          = dut.u_reg_file.regs[3];
    wire [31:0] x4          = dut.u_reg_file.regs[4];

    // ---- Capture ALU result at each cycle (for waveform clarity) ----
    reg [31:0] alu_at_cyc1 = 0;  // addi x2 -> 7
    reg [31:0] alu_at_cyc2 = 0;  // addi x3 -> 5
    reg [31:0] alu_at_cyc3 = 0;  // add  -> 12
    reg [31:0] alu_at_cyc4 = 0;  // sub  -> 2
    reg [31:0] alu_at_cyc5 = 0;  // xor  -> 2
    reg [31:0] alu_at_cyc6 = 0;  // or   -> 7
    reg [31:0] alu_at_cyc7 = 0;  // and  -> 5

    reg pass_addi_x2 = 0, pass_addi_x3 = 0;
    reg pass_add = 0, pass_sub = 0, pass_xor = 0, pass_or = 0, pass_and = 0;
    reg test_passed = 0;

    integer cycle = 0;
    always @(posedge clk) begin
        if (!reset) begin
            cycle = cycle + 1;
            case (cycle)
                1: begin alu_at_cyc1 <= alu_result; if (alu_result == 32'd7)  pass_addi_x2 <= 1; end
                2: begin alu_at_cyc2 <= alu_result; if (alu_result == 32'd5)  pass_addi_x3 <= 1; end
                3: begin alu_at_cyc3 <= alu_result; if (alu_result == 32'd12) pass_add <= 1; end
                4: begin alu_at_cyc4 <= alu_result; if (alu_result == 32'd2)  pass_sub <= 1; end
                5: begin alu_at_cyc5 <= alu_result; if (alu_result == 32'd2)  pass_xor <= 1; end
                6: begin alu_at_cyc6 <= alu_result; if (alu_result == 32'd7)  pass_or  <= 1; end
                7: begin alu_at_cyc7 <= alu_result; if (alu_result == 32'd5)  pass_and <= 1; end
            endcase
        end
    end

    initial begin
        $dumpfile("wave_partA.vcd");
        $dumpvars(0, tb_partA);

        // Override instruction memory with Lab 10 program (no need to
        // swap files on disk).
        dut.u_imem.memory[0] = 32'h00700113; // addi x2, x0, 7
        dut.u_imem.memory[1] = 32'h00500193; // addi x3, x0, 5
        dut.u_imem.memory[2] = 32'h00310233; // add  x4, x2, x3
        dut.u_imem.memory[3] = 32'h40310233; // sub  x4, x2, x3
        dut.u_imem.memory[4] = 32'h00317233; // and  ... (lab10 file order)
        dut.u_imem.memory[5] = 32'h00316233; // or
        dut.u_imem.memory[6] = 32'h00314233; // xor
        // (Note: order matches your Lab 10 file - last 3 are AND/OR/XOR)

        reset = 1;
        #20;
        reset = 0;

        #200;

        if (pass_addi_x2 && pass_addi_x3 && pass_add && pass_sub)
            test_passed <= 1;

        $display("");
        $display("=========================================================");
        $display("  Part A Test Results (Lab 10 program on extended CPU)");
        $display("=========================================================");
        $display("  cyc1 ALU = %0d  (addi x2,x0,7  -> 7)   %s", alu_at_cyc1, pass_addi_x2 ? "PASS" : "FAIL");
        $display("  cyc2 ALU = %0d  (addi x3,x0,5  -> 5)   %s", alu_at_cyc2, pass_addi_x3 ? "PASS" : "FAIL");
        $display("  cyc3 ALU = %0d  (add  x4,x2,x3 -> 12)  %s", alu_at_cyc3, pass_add ? "PASS" : "FAIL");
        $display("  cyc4 ALU = %0d  (sub  x4,x2,x3 -> 2)   %s", alu_at_cyc4, pass_sub ? "PASS" : "FAIL");
        $display("  cyc5 ALU = %0d  (and  x4,x2,x3 -> 5)   %s", alu_at_cyc5, alu_at_cyc5 == 5 ? "PASS" : "FAIL");
        $display("  cyc6 ALU = %0d  (or   x4,x2,x3 -> 7)   %s", alu_at_cyc6, alu_at_cyc6 == 7 ? "PASS" : "FAIL");
        $display("  cyc7 ALU = %0d  (xor  x4,x2,x3 -> 2)   %s", alu_at_cyc7, alu_at_cyc7 == 2 ? "PASS" : "FAIL");
        $display("---------------------------------------------------------");
        $display("  x2 = %0d, x3 = %0d, x4(final) = %0d", x2, x3, x4);
        $display("=========================================================");
        $display("");

        $finish;
    end
endmodule
