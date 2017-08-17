`include "alu.v"

module Processor (clk, rst, p, p_addr, r_data, w_data, d_addr, we);
    input clk, rst;

    input  [23:0] p;      // program read
    output [15:0] p_addr; // program address
    input  [15:0] r_data; // data read
    output [15:0] w_data; // data write
    output [15:0] d_addr; // data address
    output we;            // write enable


    // registers ---------------------------------------------------------------

    reg [15:0] BP; // base pointer
    reg [15:0] SP; // stack pointer
    reg [15:0] IP; // instruction pointer
    reg [15:0] RP; // return base pointer
    reg [8:0]  AS; // argument stack pointer

    reg stop = 0;

    // I/O ---------------------------------------------------------------------

    assign p_addr = IP;

    reg [15:0] w_data;
    reg [15:0] d_addr;
    reg we;


    // control -----------------------------------------------------------------

    reg [3:0] i_kind; // instruction kind
    parameter NOP       = 4'h0,
              HALT      = 4'h1,
              ARITH     = 4'h2,
              ARITHIM   = 4'h3,
              IMMEDIATE = 4'h4,
              JUMP      = 4'h5,
              JUMPIM    = 4'h6,
              BRANCH    = 4'h7,
              BRANCHIM  = 4'h8,
              CALL      = 4'h9,
              CALLIM    = 4'ha,
              PUSH      = 4'hb,
              RETURN    = 4'hc,
              LEAVE     = 4'hd;

    reg [3:0] i_count; // instruction cycle count
    reg [1:0] i_count_max;
    reg [7:0] push; // push size
    reg [16:0] next_IP;

    // instruction -------------------------------------------------------------

    wire [7:0] op    = p[23:16];
    wire [7:0] arg_a = p[15:8];
    wire [7:0] arg_b = p[7:0];
    //
    // wire i_arith      = op[7];
    // wire i_arith_args = op[6]; // argument number, 1 / 2
    //
    // wire i_im16 = op == `IM16; // 16bit immediate
    //
    // wire i_jump             = op[7:5] == 3'b011; // jump
    // wire i_jump_type        = op[4];             // jump type (immediate / memory)
    // wire i_jump_im          = i_jump && ~i_jump_type;
    // wire i_jump_p           = i_jump && i_jump_type;
    // wire [3:0] i_jump_op    = op[3:0];
    // wire [15:0] i_jump_cond = i_jump_type ? a_buff : r_data;
    // wire [15:0] i_jump_to   = i_jump_type ? r_data : {{8{arg_b[7]}}, arg_b};
    //
    // wire i_call_im        = op[7:1] == 8'b0011000; // call
    // wire [15:0] i_call_to = {arg_a, arg_b};
    //
    // wire push = i_arith || i_im16;
    //
    // reg [8:0] r_addr; // data read address (relative)
    //
    // always @ (posedge clk) begin
    //     case (i_state)
    //         I_LOAD: a_buff <= r_data;
    //     endcase
    // end

    // state -------------------------------------------------------------------

    reg [15:0] buffers [2:0]; // read memory buffers
    integer i;
    initial begin
        for (i = 0; i < 3; i = i + 1) begin
            buffers[i] = 0;
        end
    end

    reg [15:0] arith_a;
    reg [15:0] arith_b;
    wire [15:0] alu_out;

    wire [3:0] branch_op = op[3:0];

    reg call;
    wire [3:0] call_size = op[3:0];

    wire [7:0] push_size = arg_a;

    always @ (posedge clk or posedge rst) begin
        if (rst) begin
            BP <= 0;
            SP <= 0;
            IP <= 0;
            RP <= 0;
            AS <= 0;

            stop <= 0;

            i_count <= 0;
        end
        else if (~stop) begin
            if (i_count < i_count_max) begin
                i_count <= i_count + 1;
                buffers[i_count] <= r_data;
            end
            else begin
                IP <= next_IP;
                SP <= SP + push;
                i_count <= 0;

                if (call) begin
                    BP <= BP + SP + call_size + 2;
                    SP <= AS;
                    RP <= BP;
                    AS <= 0;
                end
                else if (i_kind == PUSH || i_kind == RETURN)
                    AS <= AS + 1;
                else if (i_kind == LEAVE) begin
                    BP <= RP;
                    SP <= BP - RP - 2;
                    RP <= r_data;
                    AS <= 0;
                end
                else if (i_kind == HALT) stop <= 1;
            end
        end
    end

    always @ (*) begin
        // fetch instruction
        casez(op)
            8'b00000001: begin
                i_kind <= HALT;
                i_count_max <= 0;
                push <= 0;
            end
            8'b10zzzzzz: begin
                i_kind <= ARITHIM;
                i_count_max <= 2;
                push <= 1;
            end
            8'b11zzzzzz: begin
                i_kind <= ARITH;
                i_count_max <= 3;
                push <= 1;
            end
            8'b00100000: begin
                i_kind <= IMMEDIATE;
                i_count_max <= 1;
                push <= 1;
            end
            8'b01100000: begin
                i_kind <= JUMPIM;
                i_count_max <= 1;
                push <= 0;
            end
            8'b01110zzz: begin
                i_kind <= BRANCHIM;
                i_count_max <= 2;
                push <= 0;
            end
            8'b0011zzzz: begin
                i_kind <= CALLIM;
                i_count_max <= 2;
                push <= call_size + 2;
            end
            8'b01010010: begin
                i_kind <= PUSH;
                i_count_max <= 2;
                push <= 0;
            end
            8'b01010011: begin
                i_kind <= RETURN;
                i_count_max <= 2;
                push <= 0;
            end
            8'b01010001: begin
                i_kind <= LEAVE;
                i_count_max <= 3;
                push <= 0;
            end
            default: begin
                i_kind <= NOP;
                i_count_max <= 0;
                push <= 0;
            end
        endcase

        case (i_kind)
            ARITH: begin
                case (i_count)
                    1: begin // load A
                        d_addr <= BP + arg_a;
                        we <= 0;
                    end
                    2: begin // load B
                        d_addr <= BP + arg_b;
                        we <= 0;
                    end
                    3: begin // exec and store
                        d_addr <= BP + SP;
                        we <= 1;
                    end
                    default: begin
                        d_addr <= 0;
                        we <= 0;
                    end
                endcase
                w_data <= alu_out;
            end
            ARITHIM: begin
                case (i_count)
                    1: begin
                        d_addr <= BP + arg_a;
                        we <= 0;
                    end
                    2: begin // exec and store
                        d_addr <= BP + SP;
                        we <= 1;
                    end
                    default: begin
                        d_addr <= 0;
                        we <= 0;
                    end
                endcase
                w_data <= alu_out;
            end
            IMMEDIATE: begin
                case (i_count)
                    1: begin
                        d_addr <= BP + SP;
                        we <= 1;
                    end
                    default: begin
                        d_addr <= 0;
                        we <= 0;
                    end
                endcase
                w_data <= {arg_a, arg_b};
            end
            BRANCHIM: begin
                d_addr <= BP + arg_a;
                we <= 0;
                w_data <= 0;
            end
            CALLIM: begin
                case (i_count)
                    1: begin
                        d_addr <= BP + SP + call_size;
                        w_data <= IP + 1;
                        we <= 1;
                    end
                    2: begin
                        d_addr <= BP + SP + call_size + 1;
                        w_data <= RP;
                        we <= 1;
                    end
                    default: begin
                        d_addr <= 0;
                        w_data <= 0;
                        we <= 0;
                    end
                endcase
            end
            PUSH: begin
                case (i_count)
                    1: begin
                        d_addr <= BP + arg_b;
                        we <= 0;
                    end
                    2: begin
                        d_addr <= BP + SP + push_size + 2 + AS;
                        we <= 1;
                    end
                    default: begin
                        d_addr <= 0;
                        we <= 0;
                    end
                endcase
                w_data <= r_data;
            end
            RETURN: begin
                case (i_count)
                    1: begin
                        d_addr <= BP + arg_b;
                        we <= 0;
                    end
                    2: begin
                        d_addr <= BP - push_size - 2 + AS;
                        we <= 1;
                    end
                    default: begin
                        d_addr <= 0;
                        we <= 0;
                    end
                endcase
                w_data <= r_data;
            end
            LEAVE: begin
                case (i_count)
                    1:       d_addr <= BP - 2;
                    2:       d_addr <= BP - 1;
                    default: d_addr <= 0;
                endcase
                w_data <= 0;
                we <= 0;
            end
            default: begin // JUMPIM, other
                d_addr <= 0;
                we <= 0;
                w_data <= 0;
            end
        endcase

        case (i_kind)
            ARITH: begin
                arith_a <= buffers[2];
                arith_b <= r_data;
            end
            ARITHIM: begin
                arith_a <= {{8{arg_b[7]}}, arg_b};
                arith_b <= r_data;
            end
            default: begin
                arith_a <= 0;
                arith_b <= 0;
            end
        endcase

        case (i_kind)
            JUMPIM:   next_IP <= IP + {arg_a, arg_b};
            BRANCHIM: next_IP <= judgeJump(branch_op, r_data) ?
                                     IP + {{8{arg_b[7]}}, arg_b} : IP + 1;
            CALLIM:   next_IP <= {arg_a, arg_b};
            LEAVE:    next_IP <= buffers[2];
            default:  next_IP <= IP + 1;
        endcase

        case (i_kind)
            CALLIM:  call <= 1;
            default: call <= 0;
        endcase
    end

    ALU ALU (op[5:0], arith_a, arith_b, alu_out);

    function judgeJump(input [3:0] op, input signed [15:0] c);
    begin
        case (op)
            4'h0: judgeJump = c == 0;
            4'h1: judgeJump = c != 0;
            4'h2: judgeJump = c <  0;
            4'h3: judgeJump = c <= 0;
            4'h4: judgeJump = c >  0;
            4'h5: judgeJump = c >= 0;
            default: judgeJump = 0;
        endcase
    end
    endfunction

endmodule
