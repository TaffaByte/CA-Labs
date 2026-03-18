`timescale 1ns / 1ps

module AddressDecoder(
    input [1:0] address,
    input writeData,
    input readData,
    output dataMemWrite,
    output dataMemRead,
    output LEDWrite,
    output switchReadEnable
);

    assign dataMemWrite      = (address == 2'b00) && writeData;
    assign dataMemRead       = (address == 2'b00) && readData;
    assign LEDWrite          = (address == 2'b01) && writeData;
    assign switchReadEnable  = (address == 2'b10) && readData;

endmodule