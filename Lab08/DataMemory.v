`timescale 1ns / 1ps

module DataMemory #(
    parameter ADDR_WIDTH = 8,
    parameter DATA_WIDTH = 32,
    parameter MEM_DEPTH  = 256
)(
    input  logic                    clk, 
    input  logic                    rst, 
    input  logic                    memWrite,
    input  logic [ADDR_WIDTH-1:0]   address,
    input  logic [DATA_WIDTH-1:0]   writeData,
    output logic [DATA_WIDTH-1:0]   readData
);

    logic [DATA_WIDTH-1:0] memory [0:MEM_DEPTH-1];

    always_ff @(posedge clk) begin
        if (rst) begin

            for (int i = 0; i < MEM_DEPTH; i++) begin
                memory[i] <= {DATA_WIDTH{1'b0}};
            end
        end else if (memWrite) begin
            memory[address] <= writeData;
        end
    end


    assign readData = memory[address];

endmodule