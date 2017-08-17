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

    wire [15:0] rd, p;

    wire rst = ~reset;

    // wire [15:0] debug = btns[0] ? 2 : 3;
    wire [3:0] btns;
    wire [3:0] leds = {1'b0, btns[1], rst, clock[22]};
    wire [3:0] as;
    wire [6:0] ks;

    wire [15:0] debug = btns[0] ? rd : p;

    reg [24:0] clock = 0;

    always @ (posedge clk) begin
        if (btns[1]) clock <= clock + 1;
        else         clock <= clock + 16;
    end

    Core Core(clock[22], rst, p, rd);

    assign led = ~leds;
    assign a   = ~as;
    assign k   = ~ks;

    SevenSeg4d SevenSeg(clk, debug, as, ks);
    RemoveChatter #(4) buttons (clk, ~btn, btns);

endmodule
