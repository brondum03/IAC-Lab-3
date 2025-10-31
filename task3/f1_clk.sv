module f1_clk #(
    parameter WIDTH = 16
)(
    input logic [WIDTH-1:0] N,
    input logic en,
    input logic rst,
    input logic clk,
    output  logic [7:0] data_out
);

logic tick; //interconnect


clktick second_timer (
    .clk(clk),
    .rst(rst),
    .en(en),
    .N(N),
    .tick(tick)
);

f1_fsm lights (
    .rst(rst),
    .clk(clk),
    .en(tick),
    .data_out(data_out)
);

endmodule
