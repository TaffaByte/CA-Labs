`timescale 1ns / 1ps

// data_in[15:12] -> leftmost digit (an[3])
// data_in[11:8]  -> an[2]
// data_in[7:4]   -> an[1]
// data_in[3:0]   -> rightmost digit (an[0])

module sevenSegDriver (
    input  wire        clk,        
    input  wire        reset,
    input  wire [15:0] data_in,
    output reg  [6:0]  seg,        
    output reg  [3:0]  an          
);
    reg [16:0] refresh_cnt;
    always @(posedge clk or posedge reset) begin
        if (reset) refresh_cnt <= 17'b0;
        else       refresh_cnt <= refresh_cnt + 1'b1;
    end

    wire [1:0] digit_sel = refresh_cnt[16:15];
    reg  [3:0] nibble;

    always @(*) begin
        case (digit_sel)
            2'b00: begin an = 4'b1110; nibble = data_in[3:0];   end
            2'b01: begin an = 4'b1101; nibble = data_in[7:4];   end
            2'b10: begin an = 4'b1011; nibble = data_in[11:8];  end
            2'b11: begin an = 4'b0111; nibble = data_in[15:12]; end
        endcase
    end

    // Hex -> 7-seg (active-low, segments a..g)
    always @(*) begin
        case (nibble)
            4'h0: seg = 7'b1000000;
            4'h1: seg = 7'b1111001;
            4'h2: seg = 7'b0100100;
            4'h3: seg = 7'b0110000;
            4'h4: seg = 7'b0011001;
            4'h5: seg = 7'b0010010;
            4'h6: seg = 7'b0000010;
            4'h7: seg = 7'b1111000;
            4'h8: seg = 7'b0000000;
            4'h9: seg = 7'b0010000;
            4'hA: seg = 7'b0001000;
            4'hB: seg = 7'b0000011;
            4'hC: seg = 7'b1000110;
            4'hD: seg = 7'b0100001;
            4'hE: seg = 7'b0000110;
            4'hF: seg = 7'b0001110;
            default: seg = 7'b1111111;
        endcase
    end
endmodule
