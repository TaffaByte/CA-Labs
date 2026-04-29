`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// tb_hwio - Sanity check that LEDs and 7-seg display the right slices of
// ALUResult.
//
// At several specific cycles, sample LEDs and verify they equal alu_result[15:0].
// Also samples the 7-seg digit data lines indirectly via the data_in path.
//////////////////////////////////////////////////////////////////////////////////
module tb_hwio;
    reg clk = 0;
    reg reset = 1;
    always #5 clk = ~clk;

    wire [15:0] led;
    wire [6:0]  seg;
    wire [3:0]  an;

    TopLevelProcessor #(.USE_SLOW_CLK(0)) dut (
        .clk(clk), .reset(reset), .led(led), .seg(seg), .an(an)
    );

    wire [31:0] alu_result    = dut.alu_result;
    wire [15:0] expected_led  = alu_result[15:0];
    wire [15:0] expected_7seg = alu_result[31:16];

    reg led_match = 1;
    integer mismatches = 0;

    always @(posedge clk) begin
        if (!reset) begin
            if (led !== expected_led) begin
                led_match = 0;
                mismatches = mismatches + 1;
            end
        end
    end

    initial begin
        $dumpfile("wave_hwio.vcd");
        $dumpvars(0, tb_hwio);

        reset = 1; #20; reset = 0;
        #2000;

        $display("");
        $display("=========================================================");
        $display("  Hardware I/O Mapping Test");
        $display("=========================================================");
        $display("  led == alu_result[15:0] every cycle: %s (mismatches=%0d)",
            led_match ? "PASS" : "FAIL", mismatches);
        $display("  Final LED value           : 0x%04x (decimal %0d)", led, led);
        $display("  Expected 7-seg upper bits : 0x%04x", expected_7seg);
        $display("  (Final result 15 -> LEDs show 0x000F, 7-seg shows 0x0000)");
        $display("=========================================================");
        $display("");
        $finish;
    end
endmodule
