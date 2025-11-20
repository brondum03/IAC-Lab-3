module f1_fsm (
    input   logic       rst,
    input   logic       en,
    input   logic       clk,
    input   logic       trigger,
    output  logic [7:0] data_out,
    output  logic       cmd_seq,
    output  logic       cmd_delay
);

// define our states
typedef enum  { S0, S1, S2, S3, S4, S5, S6, S7, S8 } my_state;
my_state current_state, next_state;

// state registers
always_ff @(posedge clk or posedge trigger) begin
    if(rst)     current_state <= S0;
    else if(current_state == S0)        
        if(trigger) current_state <= next_state;        //FSM can only be triggered again once trigger signal returns to zero
        else    current_state <= current_state;
    else        current_state <= next_state;
end
// next state logic
always_comb begin
    case(current_state)
        S0:     if(en)  next_state = S1;     //require trigger to be high to begin the countdown
                else    next_state = current_state;
        S1:     if(en)  next_state = S2;
                else    next_state = current_state;
        S2:     if(en)  next_state = S3;
                else    next_state = current_state;
        S3:     if(en)  next_state = S4;
                else    next_state = current_state;
        S4:     if(en)  next_state = S5;
                else    next_state = current_state;
        S5:     if(en)  next_state = S6;
                else    next_state = current_state;
        S6:     if(en)  next_state = S7;
                else    next_state = current_state;
        S7:     if(en)  next_state = S8;
                else    next_state = current_state;
        S8:     if(en)  next_state = S0;
                else    next_state = current_state;
        default: next_state = S0;
    endcase
end

//output logic
always_comb
case (current_state)    //cmd seqeunce must be high from 8'b1 to 8b'11111111 (so that mux selects one second delay between each light)
    S0:     data_out = 8'b0;
            cmd_seq = 1'b0;
            cmd_delay = 1b'0;
    S1:     data_out = 8'b1;
            cmd_seq = 1'b1;  
            cmd_delay = 1b'0;  
    S2:     data_out = 8'b11;
            cmd_seq = 1'b1;
            cmd_delay = 1b'0;
    S3:     data_out = 8'b111;
            cmd_seq = 1'b1;
            cmd_delay = 1b'0;
    S4:     data_out = 8'b1111;
            cmd_seq = 1'b1;
            cmd_delay = 1b'0;
    S5:     data_out = 8'b11111;
            cmd_seq = 1'b1;
            cmd_delay = 1b'0;
    S6:     data_out = 8'b111111;
            cmd_seq = 1'b1;
            cmd_delay = 1b'0;
    S7:     data_out = 8'b1111111;
            cmd_seq = 1'b1;
            cmd_delay = 1b'0;
    S8:     data_out = 8'b11111111;
            cmd_seq = 1'b0;     //before the lights go out, trigger the delay module such that a random time is selected before the lights go out
            cmd_delay = 1b'1;   
    default: begin
        data_out = 8'b0;
        cmd_seq = 1'b1;
        cmd_delay = 1b'0;
    end
endcase

endmodule
