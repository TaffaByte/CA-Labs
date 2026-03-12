module SevenSegmentDecoder (
    input  wire [3:0] D,    // Input nibble (0-F hex)
    output reg  [6:0] S     // Active-low segments (0 = on) for Basys-3 [gfedcba]
);

    // =============================================================
    // Hex decoder with active-low patterns matching .xdc order: [6:0] = g f e d c b a
    // =============================================================
    always @(*) begin
        case (D)
            4'h0: S = 7'b1000000;  // 0
            4'h1: S = 7'b1111001;  // 1
            4'h2: S = 7'b0100100;  // 2
            4'h3: S = 7'b0110000;  // 3
            4'h4: S = 7'b0011001;  // 4
            4'h5: S = 7'b0010010;  // 5
            4'h6: S = 7'b0000010;  // 6
            4'h7: S = 7'b1111000;  // 7
            4'h8: S = 7'b0000000;  // 8
            4'h9: S = 7'b0010000;  // 9
            4'hA: S = 7'b0001000;  // A
            4'hB: S = 7'b0000011;  // b (common hex display for B)
            4'hC: S = 7'b1000110;  // C
            4'hD: S = 7'b0100001;  // d (common hex display for D)
            4'hE: S = 7'b0000110;  // E
            4'hF: S = 7'b0001110;  // F
            default: S = 7'b1111111;  // Blank (all off)
        endcase
    end

endmodule