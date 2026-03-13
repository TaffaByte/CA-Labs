module SevenSegmentDriver(
    input clk, reset,
    input [15:0] hex_data,
    output reg [3:0] an,
    output [6:0] seg
);
    reg [18:0] refresh_counter;
    reg [3:0]  current_digit;

    always @(posedge clk or posedge reset) begin
        if(reset) refresh_counter <= 0;
        else      refresh_counter <= refresh_counter + 1;
    end

    always @(*) begin
        case(refresh_counter[18:17])
            2'b00: begin an = 4'b1110; current_digit = hex_data[3:0];   end
            2'b01: begin an = 4'b1101; current_digit = hex_data[7:4];   end
            2'b10: begin an = 4'b1011; current_digit = hex_data[11:8];  end
            2'b11: begin an = 4'b0111; current_digit = hex_data[15:12]; end
        endcase
    end

    SevenSegmentDecoder decoder_inst (.D(current_digit), .S(seg));
endmodule