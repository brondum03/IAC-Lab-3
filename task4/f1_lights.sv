module f1_lights #(
    parameter WIDTH = 7     //no. of bits in delay counter from lfsr
)(
    input logic[15:0] N,     //clock divider value
    input logic clk,
    input logic rst,
    input logic trigger,
    output logic [7:0] data_out
);
    logic tick;
    logic time_out;
    logic en;
    logic [WIDTH-1:0] K;
    logic cmd_seq;
    logic cmd_delay;

    clktick second_timer(   //second timer module
        .clk(clk),
        .N(N),
        .en(cmd_seq),
        .rst(rst),
        .tick(tick)
    );
    lfsr_7 random_delay(    //random delay generator
        .clk(clk),
        .rst(rst),
        .data_out(K)
    );
    delay delay(    //counts down the random delay
        .n(K),
        .trigger(cmd_delay),
        .rst(rst),
        .clk(clk),
        .time_out(time_out)
    );
    f1_fsm fsm(     //state machine
        .rst(rst),
        .en(en),
        .clk(clk),
        .trigger(trigger),
        .data_out(data_out),
        .cmd_seq(cmd_seq),
        .cmd_delay(cmd_delay)
    );
    assign en = cmd_seq ? tick : time_out;  //multiplexer
endmodule
