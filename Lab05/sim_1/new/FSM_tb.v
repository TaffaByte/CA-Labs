`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/05/2026 06:43:26 AM
// Design Name: 
// Module Name: FSM_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module FSM_tb;
    reg clk, reset;
    reg [31:0] switches;
    wire [31:0] leds;
    
    FSM uut(.clk(clk), .reset(reset),
    .switches(switches), .leds(leds));
    
    always #5 clk = ~clk;
        initial begin
        clk = 0; reset = 0; switches = 0;
        #10 reset = 1;
        #10 reset = 0;
        #50;
        switches = 5;
        #30; switches = 0;
        #150;
        switches = 3;
        #30; switches = 0;
        #30; reset = 1;
        #10; reset = 0;
        #50;
        $finish;
    end
endmodule
