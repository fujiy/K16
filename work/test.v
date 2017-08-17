`timescale 1ns / 1ps

`include "../src/processor.v"

module test;

    reg clk;
    reg rst;

    Core Core (clk, rst);

    always begin
        clk = 1; #20;
        clk = 0; #20;
    end

    initial begin
        rst = 1; #100;
        rst = 0;
    end

endmodule
