`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// tb_trace - Cycle-by-cycle execution trace
//
// Same observability as tb_top (every important signal mirrored to a
// top-level wire) plus a per-cycle $display in the console showing PC,
// the current instruction, and the most useful registers.
//
// Use this to debug control flow if tb_top reports a failure, or to
// produce a textual trace for your report.
//////////////////////////////////////////////////////////////////////////////////
module tb_trace;
    reg clk = 0;
    reg reset = 1;
    always #5 clk = ~clk;

    wire [15:0] led;
    wire [6:0]  seg;
    wire [3:0]  an;

    TopLevelProcessor #(.USE_SLOW_CLK(0)) dut (
        .clk(clk), .reset(reset), .led(led), .seg(seg), .an(an)
    );

    // ---- Top-level mirrors (so they show in waveform) ----
    wire [31:0] pc           = dut.u_pc.pc_out;
    wire [31:0] instruction  = dut.instruction;
    wire [31:0] alu_result   = dut.alu_result;
    wire        alu_zero     = dut.zero_flag;
    wire [31:0] next_pc      = dut.next_pc;
    wire [31:0] reg_writeback = dut.write_data;

    wire ctrl_Branch   = dut.Branch;
    wire ctrl_BranchNE = dut.BranchNE;
    wire ctrl_Jump     = dut.Jump;
    wire ctrl_LUI      = dut.LUI;
    wire ctrl_RegWrite = dut.RegWrite;
    wire ctrl_MemWrite = dut.MemWrite;

    wire [31:0] x1  = dut.u_reg_file.regs[1];
    wire [31:0] x10 = dut.u_reg_file.regs[10];
    wire [31:0] x11 = dut.u_reg_file.regs[11];
    wire [31:0] x12 = dut.u_reg_file.regs[12];
    wire [31:0] x14 = dut.u_reg_file.regs[14];
    wire [31:0] x18 = dut.u_reg_file.regs[18];

    integer cycle = 0;
    always @(posedge clk) begin
        if (!reset && cycle < 60) begin
            cycle = cycle + 1;
            $display("cyc=%2d  PC=0x%03x  inst=0x%08x  | Br=%b BrNE=%b Jmp=%b LUI=%b RW=%b MW=%b z=%b | x12=%2d x14=%0d x18=0x%08x | next_pc=0x%03x",
                cycle, pc, instruction,
                ctrl_Branch, ctrl_BranchNE, ctrl_Jump, ctrl_LUI, ctrl_RegWrite, ctrl_MemWrite, alu_zero,
                x12, x14, x18, next_pc);
        end
    end

    initial begin
        $dumpfile("wave_trace.vcd");
        $dumpvars(0, tb_trace);

        reset = 1; #20; reset = 0;
        #1500;
        $display("\n[End of trace - final x12 (sum) = %0d, final PC = 0x%03x]", x12, pc);
        $finish;
    end
endmodule
