module lfsr_7 (
    input   logic       clk,
    output  logic [6:0] data_out
);

logic [6:0] sreg = 7'b1;

always_ff @ (posedge clk)
        
        sreg <= {sreg[5:0], sreg[6] ^ sreg[2]};

assign data_out = sreg;

endmodule
