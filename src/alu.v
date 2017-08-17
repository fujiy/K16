`define ADD 6'b000000
`define SUB 6'b000001

module ALU (op, a, b, out);
    input  [5:0]  op;   // opcode
    input  [15:0] a, b;
    output [15:0] out;

    reg [15:0] out;

    always @ (*) begin
        case (op)
            `ADD: out = a + b;
            `SUB: out = a - b;
            default: out = 0;
        endcase
    end


    // always @ (posedge clk or posedge rst) begin
    //     if (rst) begin
    //         a  <= 0;
    //         oe <= 0;
    //     end
    //     else begin
    //         if (op[6]) begin // two operand
    //             if (a) begin
    //                 out <= arith(op[5:0], a, in);
    //                 oe <= 1;
    //                 a <= 0;
    //             end
    //             else a <= 1;
    //         end
    //         else begin // one operand
    //             out <= 0;
    //             oe <= 1;
    //         end
    //         if (oe) oe <= 0;
    //     end
    // end

endmodule
