`include "src/core.v"

`include "../lib/seven_seg.v"
`include "../lib/rm_chatter.v"

module cpu16 (clk, reset, btn, led, a, k);

    input  wire clk;
    input  wire reset;
    input  wire [3:0] btn;
    output wire [3:0] led;
    output wire [3:0] a;
    output wire [6:0] k;

    wire [15:0] debug = 0;
    wire [3:0] btns;
    wire [3:0] leds = 4'h0;
    wire [3:0] as;
    wire [6:0] ks;

    Core Core(clk, rst);

    assign led = ~leds;
    assign a   = ~as;
    assign k   = ~ks;

    SevenSeg4d SevenSeg(clk, debug, as, ks);
    RemoveChatter #(4) buttons (clk, ~btn, btns);

endmodule
