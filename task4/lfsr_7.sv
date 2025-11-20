module lfsr_7 (
    input   logic       clk,
    input   logic       rst,
    output  logic [6:0] data_out
);

logic [6:0] sreg = 7'b1;

always_ff @ (posedge clk)
    if(rst)
        sreg <= 7'b1;
    else
     sreg <= {sreg[5:0], sreg[6] ^ sreg[2]};

assign data_out = sreg;

endmodule
