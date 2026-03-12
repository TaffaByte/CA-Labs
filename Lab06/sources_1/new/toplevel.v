`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/05/2026 07:29:43 AM
// Design Name: 
// Module Name: toplevel
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


module toplevel(
    input  wire        clk,
    input  wire        btn_reset,
    input  wire [15:0] sw,
    output reg  [3:0]  displayPower,   // Active-low anodes
    output wire [6:0]  segments,       // Active-low segments
    output wire [15:0] leds
);


    wire clean_reset;

    debouncer db_inst (
        .clk(clk),
        .pbin(btn_reset),
        .pbout(clean_reset)
    );

    wire [31:0] sw_readData;

    switches sw_inst (
        .clk(clk),
        .rst(clean_reset),
        .btns(16'b0),
        .writeData(32'b0),
        .writeEnable(1'b0),
        .readEnable(1'b1),
        .memAddress(30'b0),
        .switches(sw),
        .readData(sw_readData)
    );

    wire [31:0] Result;
    wire Zero;

    ALU alu_inst (
        .A(32'h10101010),
        .B(32'h01010101),
        .ALUControl(sw_readData[6:3]),
        .ALUResult(Result),
        .Zero(Zero)
    );


    assign leds[15]   = Zero;
    assign leds[14:0] = 15'b0;


    reg [18:0] refresh_counter;

    always @(posedge clk or posedge clean_reset) begin
        if (clean_reset)
            refresh_counter <= 19'd0;
        else
            refresh_counter <= refresh_counter + 1;
    end

    wire [15:0] display_value;

    assign display_value = (sw_readData[7]) ? 
                           Result[31:16] : 
                           Result[15:0];


    reg [3:0] current_nibble;

    always @(*) begin
        displayPower   = 4'b1111;
        current_nibble = 4'b0000;

        case (refresh_counter[18:17])

            2'b00: begin
                displayPower   = 4'b1110;
                current_nibble = display_value[3:0];
            end

            2'b01: begin
                displayPower   = 4'b1101;
                current_nibble = display_value[7:4];
            end

            2'b10: begin
                displayPower   = 4'b1011;
                current_nibble = display_value[11:8];
            end

            2'b11: begin
                displayPower   = 4'b0111;
                current_nibble = display_value[15:12];
            end

        endcase
    end

 
    SevenSegmentDecoder seg_dec_inst (
        .D(current_nibble),
        .S(segments)
    );

endmodule
