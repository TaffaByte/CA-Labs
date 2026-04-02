`timescale 1ns / 1ps

module tb_control;

    reg [6:0] opcode;
    reg [2:0] funct3;
    reg       funct7;

    wire       RegWrite, ALUSrc, MemRead, MemWrite, MemtoReg, Branch;
    wire [1:0] ALUOp;
    wire [3:0] ALUControl;

    MainControl u_mc (
        .opcode   (opcode),
        .RegWrite (RegWrite), .ALUSrc  (ALUSrc),
        .MemRead  (MemRead),  .MemWrite(MemWrite),
        .MemtoReg (MemtoReg), .Branch  (Branch),
        .ALUOp    (ALUOp)
    );

    ALUControl u_ac (
        .ALUOp      (ALUOp),
        .funct3     (funct3),
        .funct7     (funct7),
        .ALUControl (ALUControl)
    );

    integer pass_cnt = 0, fail_cnt = 0;

    task check;
        input [63:0] name;          // 8-char label packed into 64 bits
        input exp_RegWrite, exp_ALUSrc, exp_MemRead, exp_MemWrite,
              exp_MemtoReg, exp_Branch;
        input [1:0]  exp_ALUOp;
        input [3:0]  exp_ALUCtrl;
        begin
            #5; // let combinational settle
            if (RegWrite  !== exp_RegWrite  ||
                ALUSrc    !== exp_ALUSrc    ||
                MemRead   !== exp_MemRead   ||
                MemWrite  !== exp_MemWrite  ||
                Branch    !== exp_Branch    ||
                ALUOp     !== exp_ALUOp     ||
                ALUControl !== exp_ALUCtrl)
            begin
                $display("FAIL  %-8s | got RW=%b AS=%b MR=%b MW=%b M2R=%b BR=%b OP=%b AC=%b",
                    name[63:0],
                    RegWrite, ALUSrc, MemRead, MemWrite,
                    MemtoReg, Branch, ALUOp, ALUControl);
                fail_cnt = fail_cnt + 1;
            end else begin
                $display("PASS  %-8s | RW=%b AS=%b MR=%b MW=%b M2R=%b BR=%b OP=%b AC=%b",
                    name[63:0],
                    RegWrite, ALUSrc, MemRead, MemWrite,
                    MemtoReg, Branch, ALUOp, ALUControl);
                pass_cnt = pass_cnt + 1;
            end
        end
    endtask

    initial begin
        $display("=======================================================");
        $display("  Lab 9 Control Path Testbench");
        $display("  Fmt: RW=RegWrite AS=ALUSrc MR=MemRead MW=MemWrite");
        $display("       M2R=MemtoReg BR=Branch OP=ALUOp AC=ALUControl");
        $display("=======================================================");

        // ADD  funct3=000 funct7=0
        opcode=7'b0110011; funct3=3'b000; funct7=1'b0;
        check("ADD     ", 1,0,0,0,0,0, 2'b10, 4'b0000);
        #10;

        // SUB  funct3=000 funct7=1 (bit 30 set)
        opcode=7'b0110011; funct3=3'b000; funct7=1'b1;
        check("SUB     ", 1,0,0,0,0,0, 2'b10, 4'b0001);
        #10;

        // SLL  funct3=001
        opcode=7'b0110011; funct3=3'b001; funct7=1'b0;
        check("SLL     ", 1,0,0,0,0,0, 2'b10, 4'b0010);
        #10;

        // SRL  funct3=101 funct7=0
        opcode=7'b0110011; funct3=3'b101; funct7=1'b0;
        check("SRL     ", 1,0,0,0,0,0, 2'b10, 4'b0011);
        #10;

        // AND  funct3=111
        opcode=7'b0110011; funct3=3'b111; funct7=1'b0;
        check("AND     ", 1,0,0,0,0,0, 2'b10, 4'b0100);
        #10;

        // OR   funct3=110
        opcode=7'b0110011; funct3=3'b110; funct7=1'b0;
        check("OR      ", 1,0,0,0,0,0, 2'b10, 4'b0101);
        #10;

        // XOR  funct3=100
        opcode=7'b0110011; funct3=3'b100; funct7=1'b0;
        check("XOR     ", 1,0,0,0,0,0, 2'b10, 4'b0110);
        #10;

        // ADDI funct3=000
        opcode=7'b0010011; funct3=3'b000; funct7=1'b0;
        check("ADDI    ", 1,1,0,0,0,0, 2'b00, 4'b0000);
        #10;

        // LW funct3=010
        opcode=7'b0000011; funct3=3'b010; funct7=1'b0;
        check("LW      ", 1,1,1,0,1,0, 2'b00, 4'b0000);
        #10;

        // LH funct3=001
        opcode=7'b0000011; funct3=3'b001; funct7=1'b0;
        check("LH      ", 1,1,1,0,1,0, 2'b00, 4'b0000);
        #10;

        // LB funct3=000
        opcode=7'b0000011; funct3=3'b000; funct7=1'b0;
        check("LB      ", 1,1,1,0,1,0, 2'b00, 4'b0000);
        #10;

        // SW funct3=010
        opcode=7'b0100011; funct3=3'b010; funct7=1'b0;
        check("SW      ", 0,1,0,1,0,0, 2'b00, 4'b0000);
        #10;

        // SH funct3=001
        opcode=7'b0100011; funct3=3'b001; funct7=1'b0;
        check("SH      ", 0,1,0,1,0,0, 2'b00, 4'b0000);
        #10;

        // SB funct3=000
        opcode=7'b0100011; funct3=3'b000; funct7=1'b0;
        check("SB      ", 0,1,0,1,0,0, 2'b00, 4'b0000);
        #10;

        // BEQ funct3=000
        opcode=7'b1100011; funct3=3'b000; funct7=1'b0;
        check("BEQ     ", 0,0,0,0,0,1, 2'b01, 4'b0001);
        #10;

        $display("=======================================================");
        $display("  Results: %0d PASS  |  %0d FAIL", pass_cnt, fail_cnt);
        $display("=======================================================");
        $finish;
    end

    // Optional waveform dump for external viewer
    initial begin
        $dumpfile("tb_control.vcd");
        $dumpvars(0, tb_control);
    end
endmodule