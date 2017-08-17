`include "processor.v"
`include "../../lib/ram.v"

module Core (clk, rst, pa, rd);
    input clk, rst;
    output [15:0] pa, rd;

    wire [23:0] p;
    wire [15:0] p_addr;
    wire [15:0] r_data;
    wire [15:0] w_data;
    wire [15:0] d_addr;
    wire d_we;

    assign pa = p_addr;
    assign rd = r_data;



    RAM #(.DataWidth(24), .AddrWidth(8), .DataFile("../cpu16/src/pm.hex"))
        PM (clk, p_addr[7:0], 24'h01, 1'b0, p);
    RAM #(.DataWidth(16), .AddrWidth(8), .DataFile("../cpu16/src/sm.hex"))
        SM (clk, d_addr[7:0], w_data, d_we, r_data);
    Processor Processor (clk, rst, p, p_addr, r_data, w_data, d_addr, d_we);

endmodule
