module AluScript(
    input logic                     clk,
    input logic                     rst,
    input logic [7:0]               opcode, 
    input logic                     put_alu_in1,
    input logic [511:0]             data_alu_in1,
    input logic                     put_alu_in2,
    input logic [511:0]             data_alu_in2,
    input logic [255:0]             check_sig_msg,
    output logic                    put_alu_out1,
    output logic [511:0]            data_alu_out1,
    output logic                    put_alu_out2,
    output logic [511:0]            data_alu_out2,
    output logic                    pop_req,
    output logic                    done,
    output logic                    error
    //TODO
);

logic [511:0] sha_256_msg;
logic [255:0] sha_256_output;
logic sha_256_ready;

logic [511:0] ripemd_160_msg;
logic [255:0] ripemd_160_output;
logic ripemd_160_ready;

sha_256 sha_unit(
    .clk(clk),
    .rst(rst),
    .message(sha_256_msg),
    .hashed(sha_256_output),
    .done(sha_256_ready)
);

ripemd_160 ripemd_160_unit(
    .clk(clk),
    .rst(rst),
    .message(ripemd_160_msg),
    .hashed(ripemd_160_output),
    .done(ripemd_160_ready)
);

ecsda ecdsa_unit(
    .clk(clk),
    .rst(rst),
    .init_verify(start_checksig),
    .my_signature(sig_input),
    .message(sig_msg),
    .pub_key(pub_key),
    .done_verify(sig_done),
    .invalid_error(sig_error)
);

check_sig_msg p2ms(
    .clk(clk),
    .rst(rst),
    .put(put_multisig), //Define in multisig opcode case
    .pkt(data_alu_in1),
    .check_sig_msg(check_sig_msg),
    .pop_req(pop_multisig), //Connect to output port in case
    .multsig_pass(multsig_pass),
    .multsig_fail(multsig_fail)
);

always_comb begin
    casez(opcode)
        OP_0: begin
            put_alu_out1 = 1;
            data_alu_out1 = '0;
            done = 1;
        end
        OP_DUP: begin
            put_alu_out1 = 1;
            data_alu_out1 = data_alu_in1;
            put_alu_out2 = 1;
            data_alu_out2 = data_alu_in1;
            done = 1;
        end
        OP_HASH160: begin
            sha_256_msg = data_alu_in1;
            ripemd_160_msg = sha_256_ready ? sha_256_output : 'x;
            done = ripemd_160_ready;
            put_alu_out1 = done;
            data_alu_out1 = ripemd_160_output;
        end
        OP_EQUALVERIFY: begin
            error = data_alu_in1 != data_alu_in2;
            done = 1;
        end
        OP_EQUAL: begin
            done = 1;
            put_alu_out1 = 1;
            data_alu_out1 = (put_alu_in1 & put_alu_in2) & (data_alu_in1==data_alu_in2);
        end
        OP_CHECKSIG: begin
            pub_key=data_alu_in1;
            sig_input=data_alu_in2;
            start_checksig=1;
            sig_msg = check_sig_msg;
            done = sig_done;
            put_alu_out1 = done;
            data_alu_out1 = sig_done & !sig_error ? 1 : 0;
        end
        OP_2: begin
            done = 1;
            put_alu_out1=1;
            data_alu_out1=2;
        end
        OP_3: begin
            done=1;
            put_alu_out1=1;
            data_alu_out1=3;
        end
        OP_4: begin
            done=1;
            put_alu_out1=1;
            data_alu_out1=4;
        end
        OP_5: begin
            done=1;
            put_alu_out1=1;
            data_alu_out1=5;
        end
        OP_6: begin
            done=1;
            put_alu_out1=1;
            data_alu_out1=6;
        end
        OP_7: begin
            done=1;
            put_alu_out1=1;
            data_alu_out1=7;
        end
        OP_8: begin
            done=1;
            put_alu_out1=1;
            data_alu_out1=8;
        end
        OP_9: begin
            done=1;
            put_alu_out1=1;
            data_alu_out1=9;
        end
        OP_10: begin
            done=1;
            put_alu_out1=1;
            data_alu_out1=10;
        end
        OP_11: begin
            done=1;
            put_alu_out1=1;
            data_alu_out1=11;
        end
        OP_12: begin
            done=1;
            put_alu_out1=1;
            data_alu_out1=12;
        end
        OP_13: begin
            done=1;
            put_alu_out1=1;
            data_alu_out1=13;
        end
        OP_14: begin
            done=1;
            put_alu_out1=1;
            data_alu_out1=14;
        end
        OP_15: begin
            done=1;
            put_alu_out1=1;
            data_alu_out1=15;
        end
        OP_16: begin
            done=1;
            put_alu_out1=1;
            data_alu_out1=16;
        end
        OP_CHECKMULTISIG: begin
            put_multisig = put_alu_in1;
            pop_req = pop_multisig;
            done = multsig_pass;
            error = multsig_fail;
            put_alu_out1 = done;
            data_alu_out1 = 'h1;
        end
        
    endcase

end
    
endmodule