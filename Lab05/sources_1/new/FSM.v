`timescale 1ns / 1ps

module FSM (
    input  wire clk,
    input  wire reset,
    input  wire [31:0] switches,
    output wire [31:0] leds
);

    localparam IDLE = 1'b0;
    localparam COUNTING = 1'b1;

    reg state = IDLE;        
    reg [15:0] latched_value = 16'b0;
    reg load;

    wire [15:0]  counter;
    downCounter c (
        clk,
        reset,
        state, 
        load,
        latched_value,
        counter
    );

    assign leds = (state == COUNTING) ? {16'b0, counter} : 32'b0;

    always @(posedge clk) begin
        if (reset) begin
            state <= IDLE;
            load <= 1'b0;
            latched_value <= 16'b0;
        end
        else begin
            load <= 1'b0;

            case (state)
                IDLE: begin
                    if (switches[15:0] != 16'b0) begin
                        state <= COUNTING;
                        latched_value <= switches[15:0];
                        load <= 1'b1;   
                    end
                end

                COUNTING: begin
                    if (counter == 16'b0) begin
                        state <= IDLE;
                    end
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule