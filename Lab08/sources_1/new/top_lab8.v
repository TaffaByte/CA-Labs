`timescale 1ns / 1ps

module top_lab8 (
    input         clk,
    input         btn_reset,
    input  [15:0] sw,
    output [15:0] led
);

    // Signal Declarations
    wire        clean_reset;
    wire        clean_sw15;
    wire        trigger_pulse;
    reg         sw15_delay;
    
    // Memory Interface Signals
    reg  [31:0] address;
    reg         readEnable;
    reg         writeEnable;
    reg  [31:0] writeData;
    wire [31:0] readData;
    reg  [31:0] captured_read;

    // Debouncing and Pulse Generation 
    debouncer db_reset (
        .clk   (clk),
        .pbin  (btn_reset),
        .pbout (clean_reset)
    );

    debouncer db_trigger (
        .clk   (clk),
        .pbin  (sw[15]),
        .pbout (clean_sw15)
    );

    always @(posedge clk) begin
        if (clean_reset)
            sw15_delay <= 1'b0;
        else
            sw15_delay <= clean_sw15;
    end

    assign trigger_pulse = clean_sw15 & ~sw15_delay;

    // Memory System Instance 
    AddressDecoderTOP mem_sys (
        .clk         (clk),
        .rst         (clean_reset),
        .address     (address),
        .readEnable  (readEnable),
        .writeEnable (writeEnable),
        .writeData   (writeData),
        .switches    (sw),          
        .readData    (readData),
        .leds        (led)          
    );

    // FSM State Definitions 
    localparam IDLE      = 3'b000;
    localparam WRITE_DM  = 3'b001;
    localparam READ_DM   = 3'b010;
    localparam WAIT_READ = 3'b011; 
    localparam SHOW_LEDS = 3'b100;

    reg [2:0] state, next_state;

    // State Register & Read Capture 
    always @(posedge clk) begin
        if (clean_reset) begin
            state         <= IDLE;
            captured_read <= 32'h0;
        end else begin
            state <= next_state;
            if (state == WAIT_READ) begin
                captured_read <= readData;
            end
        end
    end

    // FSM Next State and Output Logic
    always @(*) begin
        // Default assignments to prevent latches
        next_state  = state;
        address     = 32'h0;
        readEnable  = 1'b0;
        writeEnable = 1'b0;
        writeData   = 32'h0;

        case (state)
            IDLE: begin
                if (trigger_pulse)
                    next_state = (sw[13] == 1'b0) ? WRITE_DM : READ_DM;
            end

            WRITE_DM: begin
                // Address: [9:8]=00, Offset=[4:0]=sw[12:8]
                address     = {19'b0, 3'b0, 2'b00, 3'b0, sw[12:8]};
                writeData   = {24'h0, sw[7:0]};
                writeEnable = 1'b1;
                next_state  = SHOW_LEDS;
            end

            READ_DM: begin
                address    = {19'b0, 3'b0, 2'b00, 3'b0, sw[12:8]};
                readEnable = 1'b1;
                next_state = WAIT_READ;
            end

            WAIT_READ: begin
                // Hold signals for stabilization
                address    = {19'b0, 3'b0, 2'b00, 3'b0, sw[12:8]};
                readEnable = 1'b1;
                next_state = SHOW_LEDS;
            end

            SHOW_LEDS: begin
                // Address: [9:8]=01
                address     = 32'h00000100; 
                writeData   = (sw[13] == 1'b0) ? {24'h0, sw[7:0]} : captured_read;
                writeEnable = 1'b1;
                next_state  = IDLE;
            end

            default: next_state = IDLE;
        endcase
    end

endmodule
