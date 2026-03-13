`timescale 1ns / 1ps

module top_lab7(
    input clk, btn_reset,
    input [15:0] sw,
    output [15:0] led,
    output [3:0] an,
    output [6:0] seg
);
    // 1. Debouncing & Edge Detection
    wire clean_reset, clean_sw15;
    reg sw15_delay;
    
    debouncer db_rst (.clk(clk), .pbin(btn_reset), .pbout(clean_reset));
    debouncer db_sw  (.clk(clk), .pbin(sw[15]),    .pbout(clean_sw15));

    always @(posedge clk) sw15_delay <= clean_reset ? 1'b0 : clean_sw15;
    wire write_pulse = clean_sw15 & ~sw15_delay;

    // 2. Data Path
    reg rf_we;
    reg [4:0] rs1, rs2, rd;
    reg [31:0] WriteData;
    wire [31:0] ReadData1, ReadData2, alu_result;
    wire zero_flag;

    RegisterFile rf (
        .clk(clk), .rst(clean_reset), .WriteEnable(rf_we),
        .rs1(rs1), .rs2(rs2), .rd(rd), .WriteData(WriteData),
        .readData1(ReadData1), .readData2(ReadData2)
    );

    ALU alu_inst (
        .A(ReadData1), .B(ReadData2), .ALUControl(sw[3:0]),
        .ALUResult(alu_result), .zero(zero_flag)
    );

    SevenSegmentDriver ssd (
        .clk(clk), .reset(clean_reset), .hex_data(alu_result[15:0]),
        .an(an), .seg(seg)
    );

    // 3. Finite State Machine
    localparam INIT_A  = 2'd0, INIT_B  = 2'd1, COMPUTE = 2'd2;
    reg [1:0] state, next_state;

    always @(posedge clk) state <= clean_reset ? INIT_A : next_state;

    always @(*) begin
        // Defaults to avoid latches
        rf_we = 0; rd = 0; rs1 = 0; rs2 = 0; WriteData = 0;
        next_state = state;

        case (state)
            INIT_A: begin
                rf_we = 1; rd = 5'd1; WriteData = 32'h1111;
                next_state = INIT_B;
            end
            INIT_B: begin
                rf_we = 1; rd = 5'd2; WriteData = 32'h2222;
                next_state = COMPUTE;
            end
            COMPUTE: begin
                rs1 = sw[8:4];
                rs2 = sw[13:9];
                if (write_pulse) begin
                    rf_we = 1;
                    rd = 5'd3;
                    WriteData = alu_result;
                end
            end
        endcase
    end

    assign led = {zero_flag, alu_result[14:0]};
endmodule