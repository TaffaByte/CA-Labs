`timescale 1ns / 1ps

module top (
    input clk,
    input rst,
    input btn,
    input [15:0] sw,
    output [15:0] led_out
);
    wire btn_pulse;
    wire RegWrite, ALUSrc, MemRead, MemWrite, MemtoReg, Branch;
    wire [1:0] ALUOp;
    wire [3:0] ALUControl;
    wire [31:0] sw_data;
    
    reg [6:0] opcode_r;
    reg [2:0] funct3_r;
    reg funct7_r;
    reg sw_re_r, led_we_r;
    
    // FSM states
    localparam IDLE = 2'd0,
               READ = 2'd1,
               LATCH = 2'd2,
               DISPLAY = 2'd3;

    reg [1:0] state;

    debouncer u_db (
        .clk(clk), 
        .pbin(btn), 
        .pbout(btn_pulse)
    );

    switches u_sw (
        .clk(clk),
        .rst(rst),
        .readEnable(sw_re_r),
        .switches(sw),
        .readData(sw_data)
    );

    MainControl u_mc (
        .opcode(opcode_r),
        .RegWrite(RegWrite), .ALUSrc(ALUSrc),
        .MemRead(MemRead),   .MemWrite(MemWrite),
        .MemtoReg(MemtoReg), .Branch(Branch),
        .ALUOp(ALUOp)
    );

    ALUControl u_ac (
        .ALUOp(ALUOp),
        .funct3(funct3_r),
        .funct7(funct7_r),
        .ALUControl(ALUControl)
    );

    wire [31:0] led_data_bus = {20'h0, ALUControl, ALUOp, Branch, MemtoReg, MemWrite, MemRead, ALUSrc, RegWrite};

    leds u_led (
        .clk(clk),
        .rst(rst),
        .writeData(led_data_bus),
        .writeEnable(led_we_r),
        .leds(led_out)
    );

    // State Machine Logic
    always @(posedge clk) begin
        if (rst) begin
            state    <= IDLE;
            opcode_r <= 0; funct3_r <= 0; funct7_r <= 0;
            sw_re_r  <= 0; led_we_r <= 0;
        end else begin
            sw_re_r  <= 0;
            led_we_r <= 0;

            case (state)
                IDLE: begin
                    if (btn_pulse) begin
                        sw_re_r <= 1'b1;
                        state   <= READ;
                    end
                end
                READ:    state <= LATCH;
                LATCH: begin
                    opcode_r <= sw_data[6:0];
                    funct3_r <= sw_data[9:7];
                    funct7_r <= sw_data[10];
                    state    <= DISPLAY;
                end
                DISPLAY: begin
                    led_we_r <= 1'b1;
                    state    <= IDLE;
                end
                default: state <= IDLE;
            endcase
        end
    end
endmodule