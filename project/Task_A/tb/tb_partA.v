`timescale 1ns / 1ps
module tb_partA;
    reg clk = 0;
    reg reset = 1;
    wire [15:0] led;
    wire [6:0]  seg;
    wire [3:0]  an;

    TopLevelProcessor #(.USE_SLOW_CLK(0)) dut (
        .clk(clk), .reset(reset), .led(led), .seg(seg), .an(an)
    );
    always #5 clk = ~clk;

    integer cyc = 0;
    always @(posedge clk) if (!reset && cyc < 12) begin
        cyc = cyc + 1;
        $display("cyc=%0d PC=0x%02x inst=0x%08x  | x2=%0d x3=%0d x4=%0d",
            cyc, dut.u_pc.pc_out, dut.instruction,
            dut.u_reg_file.regs[2], dut.u_reg_file.regs[3], dut.u_reg_file.regs[4]);
    end

    initial begin
        #20 reset = 0;
        #200;
        $finish;
    end
endmodule
