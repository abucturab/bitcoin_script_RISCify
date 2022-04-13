//TODO review code and Document the Spec
module check_sig_msg(
    input logic clk,
    input logic rst,
    input logic put,
    input logic [511:0] pkt,
    input logic [255:0] check_sig_msg,
    output logic pop_req,
    output logic multsig_fail,
    output logic multsig_pass
);

enum logic [3:0] {GET_NUM_KEY, GET_KEYS, GET_NUM_SIG, GET_SIG, CHECK_SIG, INVALID, DONE, INIT} State, Next_State;
logic [1:0] num_key;
logic start_checksig, sig_done, sig_error;
logic [511:0] sig_input;
logic [255:0] sig_msg;
logic [511:0] pub_key;
logic [2:0] key_cnt, num_sig,num_verif,sig_cnt;
logic [2:0][511:0] key_store;
logic [2:0][511:0] sig_store;

ecsda_verify ecdsa_unit(
    .clk(clk),
    .reset(rst),
    .init_verify(start_checksig),
    .my_signature(sig_input),
    .message(sig_msg),
    .pub_key(pub_key),
    .done_verify(sig_done),
    .invalid_error(sig_error)
);

logic [2:0] key_iter, sig_iter;

always_ff @(posedge clk) begin
	if(rst) begin
		num_verif <= 0;
	end
    else if(sig_done & State==CHECK_SIG) begin
        key_iter<=key_iter-1;
        sig_iter<=sig_iter-1;
        num_verif<=num_verif+1;
    end
    else if(sig_error & State==CHECK_SIG) begin
        key_iter<=key_iter-1;
    end
end

always_comb multsig_pass = State==DONE ? 1 : 0;
always_comb multsig_fail = State==INVALID ? 1 : 0;

//State machine behavior
always_ff @ (posedge clk)
begin
	if(rst) begin
        State <= INIT;
        //num_verif=0;
	end
    else
        State <= Next_State;
end

always_comb begin
    casez(State)
        INIT:
        begin
            if(put)
            begin
                Next_State = GET_KEYS;
                num_key = pkt;
                key_cnt = num_key;
                key_iter = num_key;
            end
            else
                Next_State = INIT;
        end
        GET_KEYS:
        begin
            pop_req = key_cnt!=0 ? 1 : 0; //Implement key counter to decrement when state is in GET_KEYS
            key_store[key_cnt-1] = pkt;
            if(key_cnt==1)
                Next_State = GET_NUM_SIG;
            else
                Next_State = GET_KEYS;
        end
        GET_NUM_SIG:
        begin
            if(put)
            begin
                Next_State=GET_SIG;
                num_sig = pkt;
                sig_cnt = num_sig;
                sig_iter=num_sig;
            end
            else
                Next_State=GET_NUM_SIG;
        end
        GET_SIG:
        begin
            pop_req = sig_cnt!=0 ? 1 : 0; //Implement sig counter to decrement when state is in GET_SIG
            sig_store[sig_cnt-1] = pkt;
            if(sig_cnt==1)
                Next_State = CHECK_SIG;
            else
                Next_State = GET_SIG;            
        end
        CHECK_SIG:
        begin
            sig_msg = check_sig_msg;
            pub_key = key_store[key_iter]; //TODO define key_iter
            sig_input = sig_store[sig_iter];
            start_checksig = 1;
            if(num_sig==num_verif)
                Next_State = DONE;
            else if(key_iter+sig_iter<num_sig && num_sig!=num_verif)
                Next_State = INVALID;
            else
                Next_State = CHECK_SIG;
        end
        DONE: Next_State = INIT;
        INVALID: Next_State = INIT;
        default: Next_State = State;
    endcase
end

endmodule
