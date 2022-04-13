module ripemd160
(
    input logic clk,
    input logic rst,
    input logic valid_in,
    output logic valid_out,
    input logic [439:0] message,
    output logic [159:0] Hash_result
);

parameter H0 = 32'h67452301;
parameter H1 = 32'hefcdab89;
parameter H2 = 32'h98badcfe;
parameter H3 = 32'h10325476;
parameter H4 = 32'hc3d2e1f0;
parameter K0 = 32'h0;
parameter K1 = 32'h5A827999;
parameter K2 = 32'h6ED9EBA1;
parameter K3 = 32'h8F1BBCDC;
parameter K4 = 32'hA953FD4E;
parameter K0_1 = 32'h50A28BE6;
parameter K1_1 = 32'h5C4DD124;
parameter K2_1 = 32'h6D703EF3;
parameter K3_1 = 32'h7A6D76E9;
parameter K4_1 = 32'h0;

// function logic [159:0] sub_block_left(input logic [159:0] data_in, input logic [31:0] m, input logic [7:0] s, input logic [31:0] K, input logic [3:0] t);
    
//     /*
//         A=data_in[159:128];
//         B=data_in[127:96];
//         C=data_in[95:64];
//         D=data_in[63:32];
//         E=data_in[31:0];
//     */
//     logic [31:0] temp;
//     logic [31:0] f_out;
//     logic A,B,C,D,E;
//     always_comb begin
        
//         A=data_in[159:128];
//         B=data_in[127:96];
//         C=data_in[95:64];
//         D=data_in[63:32];
//         E=data_in[31:0];

//         sub_block_left[31:0] = D; //E=D
//         sub_block_left[63:32] = {C[21:0],C[31:22]}; //D = C<<10
//         sub_block_left[95:64] = B; //C = B
//         unique casez(t)
//             4'h0: f_out = F5(data_in[127:96], data_in[95:64], data_in[63:32]);
//             4'h1: f_out = F4(data_in[127:96], data_in[95:64], data_in[63:32]);
//             4'h2: f_out = F3(data_in[127:96], data_in[95:64], data_in[63:32]);
//             4'h3: f_out = F2(data_in[127:96], data_in[95:64], data_in[63:32]);
//             4'h4: f_out = F1(data_in[127:96], data_in[95:64], data_in[63:32]);
//             default: f_out = 'x;
//         endcase
//         temp = A + m + K + f_out;
//         sub_block_left[127:96] = {temp[31-s:0],temp[31:32-s]}+E;
//         sub_block_left[159:128] = E; //A=E
//     end
    
// endfunction

// function logic [159:0] sub_block_right(input logic [159:0] data_in, input logic [31:0] m, input logic [7:0] s, input logic [31:0] K, input logic [3:0] t);
    
//     /*
//         A=data_in[159:128];
//         B=data_in[127:96];
//         C=data_in[95:64];
//         D=data_in[63:32];
//         E=data_in[31:0];
//     */
//     logic [31:0] temp;
//     logic [31:0] f_out;
//     logic A,B,C,D,E;
//     always_comb begin
        
//         A=data_in[159:128];
//         B=data_in[127:96];
//         C=data_in[95:64];
//         D=data_in[63:32];
//         E=data_in[31:0];

//         sub_block_right[31:0] = D; //E=D
//         sub_block_right[63:32] = {C[21:0],C[31:22]}; //D = C<<10
//         sub_block_right[95:64] = B; //C = B
//         unique casez(t)
//             4'h0: f_out = F1(data_in[127:96], data_in[95:64], data_in[63:32]);
//             4'h1: f_out = F2(data_in[127:96], data_in[95:64], data_in[63:32]);
//             4'h2: f_out = F3(data_in[127:96], data_in[95:64], data_in[63:32]);
//             4'h3: f_out = F4(data_in[127:96], data_in[95:64], data_in[63:32]);
//             4'h4: f_out = F5(data_in[127:96], data_in[95:64], data_in[63:32]);
//             default: f_out = 'x;
//         endcase
//         temp = A + m + K + f_out;
//         sub_block_right[127:96] = {temp[31-s:0],temp[31:32-s]}+E;
//         sub_block_right[159:128] = E; //A=E
//     end
    
// endfunction

logic [7:0] sub_block_iter_counter;
logic [2:0] stage;
logic [4:0][31:0] round_out;
enum logic [1:0] {INIT, START_HASH, END} state, next_state;
logic [159:0] sub_block_left_datain;
logic [159:0] sub_block_right_datain;
logic [31:0] sub_block_left_message_in;
logic [31:0] sub_block_right_message_in;
logic [7:0] sub_block_left_shift_amount;
logic [7:0] sub_block_right_shift_amount;
logic [31:0] sub_block_left_K_val;
logic [31:0] sub_block_right_K_val;
logic [159:0] sub_block_left_out;
logic [159:0] sub_block_right_out;
logic [511:0] chunk;
logic [15:0][31:0] padded_msg;

sub_block_left left_combo(
    .data_in    (sub_block_left_datain),
    .m          (sub_block_left_message_in),
    .s          (sub_block_left_shift_amount),
    .K          (sub_block_left_K_val),
    .t          (stage),
    .left_out   (sub_block_left_out)
);

sub_block_right right_combo(
    .data_in    (sub_block_right_datain),
    .m          (sub_block_right_message_in),
    .s          (sub_block_right_shift_amount),
    .K          (sub_block_right_K_val),
    .t          (stage),
    .right_out  (sub_block_right_out)
);

always_comb begin
    for(int i=0;i<16;i++) begin
        padded_msg[i] = chunk[32*i +: 32];
    end
end

always_ff @(posedge clk) begin:ripemd_statemachine
    if (rst) begin:reset
        state <= INIT;
    end:reset
    else begin
        if(valid_in & state==INIT) begin
            state <= START_HASH;
            chunk <= {message[408:0], {8'b10000000}, {55'b0,9'b110111000}, {32'b0}};
        end
        if(state==START_HASH && stage==4 && sub_block_iter_counter==15)
            state <= END;
        // else
        //     state <= INIT;
    end
end:ripemd_statemachine

always_ff @(posedge clk) begin
    if (state==INIT) begin: initialize_counter_stage
        sub_block_iter_counter=0;
        stage=0;
        sub_block_left_datain={H0,H1,H2,H3,H4};
        sub_block_right_datain={H0,H1,H2,H3,H4};
    end: initialize_counter_stage
    if(state==START_HASH) begin
        sub_block_left_datain <= sub_block_left_out;
        sub_block_right_datain <= sub_block_right_out;
        stage <= sub_block_iter_counter == 15 ? stage+1 : stage;
        sub_block_iter_counter <= sub_block_iter_counter==15 ? 0 : sub_block_iter_counter+1;
    end
    // else if(state==END) begin
    //     Hash_result = { H1^sub_block_left_datain[95:64]^sub_block_right_datain[63:32],
    //                     H2^sub_block_left_datain[63:32]^sub_block_right_datain[31:0],
    //                     H3^sub_block_left_datain[31:0]^sub_block_right_datain[159:128],
    //                     H4^sub_block_left_datain[159:128]^sub_block_right_datain[127:96],
    //                     H0^sub_block_left_datain[127:96]^sub_block_right_datain[95:64]};
    //     valid_out = 1;
    // end
end
always_comb begin
    if(state==END) begin
        Hash_result = { H1^sub_block_left_datain[95:64]^sub_block_right_datain[63:32],
                        H2^sub_block_left_datain[63:32]^sub_block_right_datain[31:0],
                        H3^sub_block_left_datain[31:0]^sub_block_right_datain[159:128],
                        H4^sub_block_left_datain[159:128]^sub_block_right_datain[127:96],
                        H0^sub_block_left_datain[127:96]^sub_block_right_datain[95:64]};
        valid_out = 1;
    end
    else begin
        Hash_result = 'x;
        valid_out = 0;
    end
end

always_comb begin
    if(state==START_HASH) begin
        if(stage==0) begin
            sub_block_left_K_val = K0;
            sub_block_right_K_val = K0_1;
            unique casez(sub_block_iter_counter)
                8'd0: begin
                    sub_block_left_message_in = padded_msg[0];
                    sub_block_left_shift_amount = 'd11;
                    sub_block_right_message_in = padded_msg[5];
                    sub_block_right_shift_amount = 'd8;
                end
                8'd1: begin
                    sub_block_left_message_in = padded_msg[1];
                    sub_block_left_shift_amount = 'd4;
                    sub_block_right_message_in = padded_msg[14];
                    sub_block_right_shift_amount = 'd9;
                end
                8'd2: begin
                    sub_block_left_message_in = padded_msg[2];
                    sub_block_left_shift_amount = 'd15;
                    sub_block_right_message_in = padded_msg[7];
                    sub_block_right_shift_amount = 'd9;
                end
                8'd3: begin
                    sub_block_left_message_in = padded_msg[3];
                    sub_block_left_shift_amount = 'd12;
                    sub_block_right_message_in = padded_msg[0];
                    sub_block_right_shift_amount = 'd11;
                end
                8'd4: begin
                    sub_block_left_message_in = padded_msg[4];
                    sub_block_left_shift_amount = 'd5;
                    sub_block_right_message_in = padded_msg[9];
                    sub_block_right_shift_amount = 'd13;
                end
                8'd5: begin
                    sub_block_left_message_in = padded_msg[5];
                    sub_block_left_shift_amount = 'd8;
                    sub_block_right_message_in = padded_msg[2];
                    sub_block_right_shift_amount = 'd15;
                end
                8'd6: begin
                    sub_block_left_message_in = padded_msg[6];
                    sub_block_left_shift_amount = 'd7;
                    sub_block_right_message_in = padded_msg[11];
                    sub_block_right_shift_amount = 'd15;
                end
                8'd7: begin
                    sub_block_left_message_in = padded_msg[7];
                    sub_block_left_shift_amount = 'd9;
                    sub_block_right_message_in = padded_msg[4];
                    sub_block_right_shift_amount = 'd5;
                end
                8'd8: begin
                    sub_block_left_message_in = padded_msg[8];
                    sub_block_left_shift_amount = 'd11;
                    sub_block_right_message_in = padded_msg[13];
                    sub_block_right_shift_amount = 'd7;
                end
                8'd9: begin
                    sub_block_left_message_in = padded_msg[9];
                    sub_block_left_shift_amount = 'd13;
                    sub_block_right_message_in = padded_msg[6];
                    sub_block_right_shift_amount = 'd7;
                end
                8'd10: begin
                    sub_block_left_message_in = padded_msg[10];
                    sub_block_left_shift_amount = 'd14;
                    sub_block_right_message_in = padded_msg[15];
                    sub_block_right_shift_amount = 'd8;
                end
                8'd11: begin
                    sub_block_left_message_in = padded_msg[11];
                    sub_block_left_shift_amount = 'd15;
                    sub_block_right_message_in = padded_msg[8];
                    sub_block_right_shift_amount = 'd11;
                end
                8'd12: begin
                    sub_block_left_message_in = padded_msg[12];
                    sub_block_left_shift_amount = 'd6;
                    sub_block_right_message_in = padded_msg[1];
                    sub_block_right_shift_amount = 'd14;
                end
                8'd13: begin
                    sub_block_left_message_in = padded_msg[13];
                    sub_block_left_shift_amount = 'd7;
                    sub_block_right_message_in = padded_msg[10];
                    sub_block_right_shift_amount = 'd14;
                end
                8'd14: begin
                    sub_block_left_message_in = padded_msg[14];
                    sub_block_left_shift_amount = 'd9;
                    sub_block_right_message_in = padded_msg[3];
                    sub_block_right_shift_amount = 'd12;
                end
                8'd15: begin
                    sub_block_left_message_in = padded_msg[15];
                    sub_block_left_shift_amount = 'd8;
                    sub_block_right_message_in = padded_msg[12];
                    sub_block_right_shift_amount = 'd6;
                end
                default: begin
                    sub_block_left_message_in='x;
                    sub_block_left_shift_amount='x;
                    sub_block_right_message_in='x;
                    sub_block_right_shift_amount='x;
                end
            endcase
        end
        if(stage==1) begin
            sub_block_left_K_val = K1;
            sub_block_right_K_val = K1_1;
            unique casez(sub_block_iter_counter)
                8'd0: begin
                    sub_block_left_message_in = padded_msg[7];
                    sub_block_left_shift_amount = 'd7;
                    sub_block_right_message_in = padded_msg[6];
                    sub_block_right_shift_amount = 'd9;
                end
                8'd1: begin
                    sub_block_left_message_in = padded_msg[4];
                    sub_block_left_shift_amount = 'd6;
                    sub_block_right_message_in = padded_msg[11];
                    sub_block_right_shift_amount = 'd13;
                end
                8'd2: begin
                    sub_block_left_message_in = padded_msg[13];
                    sub_block_left_shift_amount = 'd8;
                    sub_block_right_message_in = padded_msg[3];
                    sub_block_right_shift_amount = 'd15;
                end
                8'd3: begin
                    sub_block_left_message_in = padded_msg[1];
                    sub_block_left_shift_amount = 'd13;
                    sub_block_right_message_in = padded_msg[7];
                    sub_block_right_shift_amount = 'd7;
                end
                8'd4: begin
                    sub_block_left_message_in = padded_msg[10];
                    sub_block_left_shift_amount = 'd11;
                    sub_block_right_message_in = padded_msg[0];
                    sub_block_right_shift_amount = 'd12;
                end
                8'd5: begin
                    sub_block_left_message_in = padded_msg[6];
                    sub_block_left_shift_amount = 'd9;
                    sub_block_right_message_in = padded_msg[13];
                    sub_block_right_shift_amount = 'd8;
                end
                8'd6: begin
                    sub_block_left_message_in = padded_msg[15];
                    sub_block_left_shift_amount = 'd7;
                    sub_block_right_message_in = padded_msg[5];
                    sub_block_right_shift_amount = 'd9;
                end
                8'd7: begin
                    sub_block_left_message_in = padded_msg[3];
                    sub_block_left_shift_amount = 'd15;
                    sub_block_right_message_in = padded_msg[10];
                    sub_block_right_shift_amount = 'd11;
                end
                8'd8: begin
                    sub_block_left_message_in = padded_msg[12];
                    sub_block_left_shift_amount = 'd7;
                    sub_block_right_message_in = padded_msg[14];
                    sub_block_right_shift_amount = 'd7;
                end
                8'd9: begin
                    sub_block_left_message_in = padded_msg[0];
                    sub_block_left_shift_amount = 'd12;
                    sub_block_right_message_in = padded_msg[15];
                    sub_block_right_shift_amount = 'd7;
                end
                8'd10: begin
                    sub_block_left_message_in = padded_msg[9];
                    sub_block_left_shift_amount = 'd15;
                    sub_block_right_message_in = padded_msg[8];
                    sub_block_right_shift_amount = 'd12;
                end
                8'd11: begin
                    sub_block_left_message_in = padded_msg[5];
                    sub_block_left_shift_amount = 'd9;
                    sub_block_right_message_in = padded_msg[12];
                    sub_block_right_shift_amount = 'd7;
                end
                8'd12: begin
                    sub_block_left_message_in = padded_msg[2];
                    sub_block_left_shift_amount = 'd11;
                    sub_block_right_message_in = padded_msg[4];
                    sub_block_right_shift_amount = 'd6;
                end
                8'd13: begin
                    sub_block_left_message_in = padded_msg[14];
                    sub_block_left_shift_amount = 'd7;
                    sub_block_right_message_in = padded_msg[9];
                    sub_block_right_shift_amount = 'd15;
                end
                8'd14: begin
                    sub_block_left_message_in = padded_msg[11];
                    sub_block_left_shift_amount = 'd13;
                    sub_block_right_message_in = padded_msg[1];
                    sub_block_right_shift_amount = 'd13;
                end
                8'd15: begin
                    sub_block_left_message_in = padded_msg[8];
                    sub_block_left_shift_amount = 'd12;
                    sub_block_right_message_in = padded_msg[2];
                    sub_block_right_shift_amount = 'd11;
                end
                default: begin
                    sub_block_left_message_in='x;
                    sub_block_left_shift_amount='x;
                    sub_block_right_message_in='x;
                    sub_block_right_shift_amount='x;
                end
            endcase
        end
        if(stage==2) begin
            sub_block_left_K_val = K2;
            sub_block_right_K_val = K2_1;
            unique casez(sub_block_iter_counter)
                8'd0: begin
                    sub_block_left_message_in = padded_msg[3];
                    sub_block_left_shift_amount = 'd11;
                    sub_block_right_message_in = padded_msg[15];
                    sub_block_right_shift_amount = 'd9;
                end
                8'd1: begin
                    sub_block_left_message_in = padded_msg[10];
                    sub_block_left_shift_amount = 'd13;
                    sub_block_right_message_in = padded_msg[5];
                    sub_block_right_shift_amount = 'd7;
                end
                8'd2: begin
                    sub_block_left_message_in = padded_msg[14];
                    sub_block_left_shift_amount = 'd6;
                    sub_block_right_message_in = padded_msg[1];
                    sub_block_right_shift_amount = 'd15;
                end
                8'd3: begin
                    sub_block_left_message_in = padded_msg[4];
                    sub_block_left_shift_amount = 'd7;
                    sub_block_right_message_in = padded_msg[3];
                    sub_block_right_shift_amount = 'd11;
                end
                8'd4: begin
                    sub_block_left_message_in = padded_msg[9];
                    sub_block_left_shift_amount = 'd14;
                    sub_block_right_message_in = padded_msg[7];
                    sub_block_right_shift_amount = 'd8;
                end
                8'd5: begin
                    sub_block_left_message_in = padded_msg[15];
                    sub_block_left_shift_amount = 'd9;
                    sub_block_right_message_in = padded_msg[14];
                    sub_block_right_shift_amount = 'd6;
                end
                8'd6: begin
                    sub_block_left_message_in = padded_msg[8];
                    sub_block_left_shift_amount = 'd13;
                    sub_block_right_message_in = padded_msg[6];
                    sub_block_right_shift_amount = 'd6;
                end
                8'd7: begin
                    sub_block_left_message_in = padded_msg[1];
                    sub_block_left_shift_amount = 'd15;
                    sub_block_right_message_in = padded_msg[9];
                    sub_block_right_shift_amount = 'd14;
                end
                8'd8: begin
                    sub_block_left_message_in = padded_msg[2];
                    sub_block_left_shift_amount = 'd14;
                    sub_block_right_message_in = padded_msg[11];
                    sub_block_right_shift_amount = 'd12;
                end
                8'd9: begin
                    sub_block_left_message_in = padded_msg[7];
                    sub_block_left_shift_amount = 'd8;
                    sub_block_right_message_in = padded_msg[8];
                    sub_block_right_shift_amount = 'd13;
                end
                8'd10: begin
                    sub_block_left_message_in = padded_msg[0];
                    sub_block_left_shift_amount = 'd13;
                    sub_block_right_message_in = padded_msg[12];
                    sub_block_right_shift_amount = 'd5;
                end
                8'd11: begin
                    sub_block_left_message_in = padded_msg[6];
                    sub_block_left_shift_amount = 'd6;
                    sub_block_right_message_in = padded_msg[2];
                    sub_block_right_shift_amount = 'd14;
                end
                8'd12: begin
                    sub_block_left_message_in = padded_msg[13];
                    sub_block_left_shift_amount = 'd4;
                    sub_block_right_message_in = padded_msg[10];
                    sub_block_right_shift_amount = 'd13;
                end
                8'd13: begin
                    sub_block_left_message_in = padded_msg[11];
                    sub_block_left_shift_amount = 'd12;
                    sub_block_right_message_in = padded_msg[0];
                    sub_block_right_shift_amount = 'd13;
                end
                8'd14: begin
                    sub_block_left_message_in = padded_msg[5];
                    sub_block_left_shift_amount = 'd7;
                    sub_block_right_message_in = padded_msg[4];
                    sub_block_right_shift_amount = 'd7;
                end
                8'd15: begin
                    sub_block_left_message_in = padded_msg[12];
                    sub_block_left_shift_amount = 'd5;
                    sub_block_right_message_in = padded_msg[13];
                    sub_block_right_shift_amount = 'd5;
                end
                default: begin
                    sub_block_left_message_in='x;
                    sub_block_left_shift_amount='x;
                    sub_block_right_message_in='x;
                    sub_block_right_shift_amount='x;
                end
            endcase
        end
        if(stage==3) begin
            sub_block_left_K_val = K3;
            sub_block_right_K_val = K3_1;
            unique casez(sub_block_iter_counter)
                8'd0: begin
                    sub_block_left_message_in = padded_msg[1];
                    sub_block_left_shift_amount = 'd11;
                    sub_block_right_message_in = padded_msg[8];
                    sub_block_right_shift_amount = 'd15;
                end
                8'd1: begin
                    sub_block_left_message_in = padded_msg[9];
                    sub_block_left_shift_amount = 'd12;
                    sub_block_right_message_in = padded_msg[6];
                    sub_block_right_shift_amount = 'd5;
                end
                8'd2: begin
                    sub_block_left_message_in = padded_msg[11];
                    sub_block_left_shift_amount = 'd14;
                    sub_block_right_message_in = padded_msg[4];
                    sub_block_right_shift_amount = 'd8;
                end
                8'd3: begin
                    sub_block_left_message_in = padded_msg[10];
                    sub_block_left_shift_amount = 'd15;
                    sub_block_right_message_in = padded_msg[1];
                    sub_block_right_shift_amount = 'd11;
                end
                8'd4: begin
                    sub_block_left_message_in = padded_msg[0];
                    sub_block_left_shift_amount = 'd14;
                    sub_block_right_message_in = padded_msg[3];
                    sub_block_right_shift_amount = 'd14;
                end
                8'd5: begin
                    sub_block_left_message_in = padded_msg[8];
                    sub_block_left_shift_amount = 'd15;
                    sub_block_right_message_in = padded_msg[11];
                    sub_block_right_shift_amount = 'd14;
                end
                8'd6: begin
                    sub_block_left_message_in = padded_msg[12];
                    sub_block_left_shift_amount = 'd9;
                    sub_block_right_message_in = padded_msg[15];
                    sub_block_right_shift_amount = 'd6;
                end
                8'd7: begin
                    sub_block_left_message_in = padded_msg[4];
                    sub_block_left_shift_amount = 'd8;
                    sub_block_right_message_in = padded_msg[0];
                    sub_block_right_shift_amount = 'd14;
                end
                8'd8: begin
                    sub_block_left_message_in = padded_msg[13];
                    sub_block_left_shift_amount = 'd9;
                    sub_block_right_message_in = padded_msg[5];
                    sub_block_right_shift_amount = 'd6;
                end
                8'd9: begin
                    sub_block_left_message_in = padded_msg[3];
                    sub_block_left_shift_amount = 'd14;
                    sub_block_right_message_in = padded_msg[12];
                    sub_block_right_shift_amount = 'd9;
                end
                8'd10: begin
                    sub_block_left_message_in = padded_msg[7];
                    sub_block_left_shift_amount = 'd5;
                    sub_block_right_message_in = padded_msg[2];
                    sub_block_right_shift_amount = 'd12;
                end
                8'd11: begin
                    sub_block_left_message_in = padded_msg[15];
                    sub_block_left_shift_amount = 'd6;
                    sub_block_right_message_in = padded_msg[13];
                    sub_block_right_shift_amount = 'd9;
                end
                8'd12: begin
                    sub_block_left_message_in = padded_msg[14];
                    sub_block_left_shift_amount = 'd8;
                    sub_block_right_message_in = padded_msg[9];
                    sub_block_right_shift_amount = 'd12;
                end
                8'd13: begin
                    sub_block_left_message_in = padded_msg[5];
                    sub_block_left_shift_amount = 'd6;
                    sub_block_right_message_in = padded_msg[7];
                    sub_block_right_shift_amount = 'd5;
                end
                8'd14: begin
                    sub_block_left_message_in = padded_msg[6];
                    sub_block_left_shift_amount = 'd5;
                    sub_block_right_message_in = padded_msg[10];
                    sub_block_right_shift_amount = 'd15;
                end
                8'd15: begin
                    sub_block_left_message_in = padded_msg[2];
                    sub_block_left_shift_amount = 'd12;
                    sub_block_right_message_in = padded_msg[14];
                    sub_block_right_shift_amount = 'd8;
                end
                default: begin
                    sub_block_left_message_in='x;
                    sub_block_left_shift_amount='x;
                    sub_block_right_message_in='x;
                    sub_block_right_shift_amount='x;
                end
            endcase
        end
        if(stage==4) begin
            sub_block_left_K_val = K4;
            sub_block_right_K_val = K4_1;
            unique casez(sub_block_iter_counter)
                8'd0: begin
                    sub_block_left_message_in = padded_msg[4];
                    sub_block_left_shift_amount = 'd9;
                    sub_block_right_message_in = padded_msg[12];
                    sub_block_right_shift_amount = 'd8;
                end
                8'd1: begin
                    sub_block_left_message_in = padded_msg[0];
                    sub_block_left_shift_amount = 'd15;
                    sub_block_right_message_in = padded_msg[15];
                    sub_block_right_shift_amount = 'd5;
                end
                8'd2: begin
                    sub_block_left_message_in = padded_msg[5];
                    sub_block_left_shift_amount = 'd5;
                    sub_block_right_message_in = padded_msg[10];
                    sub_block_right_shift_amount = 'd12;
                end
                8'd3: begin
                    sub_block_left_message_in = padded_msg[9];
                    sub_block_left_shift_amount = 'd11;
                    sub_block_right_message_in = padded_msg[4];
                    sub_block_right_shift_amount = 'd9;
                end
                8'd4: begin
                    sub_block_left_message_in = padded_msg[7];
                    sub_block_left_shift_amount = 'd6;
                    sub_block_right_message_in = padded_msg[1];
                    sub_block_right_shift_amount = 'd12;
                end
                8'd5: begin
                    sub_block_left_message_in = padded_msg[12];
                    sub_block_left_shift_amount = 'd8;
                    sub_block_right_message_in = padded_msg[5];
                    sub_block_right_shift_amount = 'd5;
                end
                8'd6: begin
                    sub_block_left_message_in = padded_msg[2];
                    sub_block_left_shift_amount = 'd13;
                    sub_block_right_message_in = padded_msg[8];
                    sub_block_right_shift_amount = 'd14;
                end
                8'd7: begin
                    sub_block_left_message_in = padded_msg[10];
                    sub_block_left_shift_amount = 'd12;
                    sub_block_right_message_in = padded_msg[7];
                    sub_block_right_shift_amount = 'd6;
                end
                8'd8: begin
                    sub_block_left_message_in = padded_msg[14];
                    sub_block_left_shift_amount = 'd5;
                    sub_block_right_message_in = padded_msg[6];
                    sub_block_right_shift_amount = 'd8;
                end
                8'd9: begin
                    sub_block_left_message_in = padded_msg[1];
                    sub_block_left_shift_amount = 'd12;
                    sub_block_right_message_in = padded_msg[2];
                    sub_block_right_shift_amount = 'd13;
                end
                8'd10: begin
                    sub_block_left_message_in = padded_msg[3];
                    sub_block_left_shift_amount = 'd13;
                    sub_block_right_message_in = padded_msg[13];
                    sub_block_right_shift_amount = 'd6;
                end
                8'd11: begin
                    sub_block_left_message_in = padded_msg[8];
                    sub_block_left_shift_amount = 'd14;
                    sub_block_right_message_in = padded_msg[14];
                    sub_block_right_shift_amount = 'd5;
                end
                8'd12: begin
                    sub_block_left_message_in = padded_msg[11];
                    sub_block_left_shift_amount = 'd11;
                    sub_block_right_message_in = padded_msg[0];
                    sub_block_right_shift_amount = 'd15;
                end
                8'd13: begin
                    sub_block_left_message_in = padded_msg[6];
                    sub_block_left_shift_amount = 'd8;
                    sub_block_right_message_in = padded_msg[3];
                    sub_block_right_shift_amount = 'd13;
                end
                8'd14: begin
                    sub_block_left_message_in = padded_msg[15];
                    sub_block_left_shift_amount = 'd5;
                    sub_block_right_message_in = padded_msg[9];
                    sub_block_right_shift_amount = 'd11;
                end
                8'd15: begin
                    sub_block_left_message_in = padded_msg[13];
                    sub_block_left_shift_amount = 'd6;
                    sub_block_right_message_in = padded_msg[11];
                    sub_block_right_shift_amount = 'd11;
                end
                default: begin
                    sub_block_left_message_in='x;
                    sub_block_left_shift_amount='x;
                    sub_block_right_message_in='x;
                    sub_block_right_shift_amount='x;
                end
            endcase
        end        
    end
    else begin
        sub_block_left_K_val = 'x;
        sub_block_right_K_val='x;
        sub_block_left_message_in = 'x;
        sub_block_left_shift_amount = 'x;
        sub_block_right_message_in='x;
        sub_block_right_shift_amount='x;
    end
end


// always_ff @(posedge clk) begin: iteration_state_machine
//     if (state==INIT) begin: initialize_counter_stage
//         sub_block_iter_counter=0;
//         stage=0;
//         round_out_left={H0,H1,H2,H3,H4};
//         round_out_right={H0,H1,H2,H3,H4};
//     end: initialize_counter_stage
//     if(state==START_HASH) begin
//         if(stage==0) begin
//             unique casez(sub_block_iter_counter)
//             8'd0: begin
//                 round_out_left <= sub_block_left(round_out_left, padded_msg[0], 'd11, K0, stage);
//                 round_out_right <= sub_block_right(round_out_right, padded_msg[5], 'd8, K0_1, stage);
//             end
//             8'd1: begin
//                 round_out_left <= sub_block_left(round_out_left, padded_msg[1], 'd4, K0, stage);
//                 round_out_right <= sub_block_right(round_out_right, padded_msg[14], 'd9, K0_1, stage);
//             end
//             8'd2: begin
//                 round_out_left <= sub_block_left(round_out_left, padded_msg[2], 'd15, K0, stage);
//                 round_out_right <= sub_block_right(round_out_right, padded_msg[7], 'd9, K0_1, stage);
//             end
//             8'd3: begin
//                 round_out_left <= sub_block_left(round_out_left, padded_msg[3], 'd12, K0, stage);
//                 round_out_right <= sub_block_right(round_out_right, padded_msg[0], 'd11, K0_1, stage);
//             end
//             8'd4: begin
//                 round_out_left <= sub_block_left(round_out_left, padded_msg[4], 'd5, K0, stage);
//                 round_out_right <= sub_block_right(round_out_right, padded_msg[9], 'd13, K0_1, stage);
//             end
//             8'd5: begin
//                 round_out_left <= sub_block_left(round_out_left, padded_msg[5], 'd8, K0, stage);
//                 round_out_right <= sub_block_right(round_out_right, padded_msg[2], 'd15, K0_1, stage);
//             end
//             8'd6: begin
//                 round_out_left <= sub_block_left(round_out_left, padded_msg[6], 'd7, K0, stage);
//                 round_out_right <= sub_block_right(round_out_right, padded_msg[11], 'd15, K0_1, stage);
//             end
//             8'd7: begin
//                 round_out_left <= sub_block_left(round_out_left, padded_msg[7], 'd9, K0, stage);
//                 round_out_right <= sub_block_right(round_out_right, padded_msg[4], 'd5, K0_1, stage);
//             end
//             8'd8: begin
//                 round_out_left <= sub_block_left(round_out_left, padded_msg[8], 'd11, K0, stage);
//                 round_out_right <= sub_block_right(round_out_right, padded_msg[13], 'd7, K0_1, stage);
//             end
//             8'd9: begin
//                 round_out_left <= sub_block_left(round_out_left, padded_msg[9], 'd13, K0, stage);
//                 round_out_right <= sub_block_right(round_out_right, padded_msg[6], 'd7, K0_1, stage);
//             end
//             8'd10: begin
//                 round_out_left <= sub_block_left(round_out_left, padded_msg[10], 'd14, K0, stage);
//                 round_out_right <= sub_block_right(round_out_right, padded_msg[15], 'd8, K0_1, stage);
//             end
//             8'd11: begin
//                 round_out_left <= sub_block_left(round_out_left, padded_msg[11], 'd15, K0, stage);
//                 round_out_right <= sub_block_right(round_out_right, padded_msg[8], 'd11, K0_1, stage);
//             end
//             8'd12: begin
//                 round_out_left <= sub_block_left(round_out_left, padded_msg[12], 'd6, K0, stage);
//                 round_out_right <= sub_block_right(round_out_right, padded_msg[1], 'd14, K0_1, stage);
//             end
//             8'd13: begin
//                 round_out_left <= sub_block_left(round_out_left, padded_msg[13], 'd7, K0, stage);
//                 round_out_right <= sub_block_right(round_out_right, padded_msg[10], 'd14, K0_1, stage);
//             end
//             8'd14: begin
//                 round_out_left <= sub_block_left(round_out_left, padded_msg[14], 'd9, K0, stage);
//                 round_out_right <= sub_block_right(round_out_right, padded_msg[3], 'd12, K0_1, stage);
//             end
//             8'd15: begin
//                 round_out_left <= sub_block_left(round_out_left, padded_msg[15], 'd8, K0, stage);
//                 round_out_right <= sub_block_right(round_out_right, padded_msg[12], 'd6, K0_1, stage);
//             end
//             default: begin
//                 round_out_left<='x
//                 round_out_right<='x
//                 end
//             endcase
//         end
//         if(stage==1) begin
//             unique casez(sub_block_iter_counter)
//             8'd0: begin
//                 round_out_left <= sub_block_left(round_out_left, padded_msg[7], 'd7, K1, stage);
//                 round_out_right <= sub_block_right(round_out_right, padded_msg[6], 'd9, K1_1, stage);
//             end
//             8'd1: begin
//                 round_out_left <= sub_block_left(round_out_left, padded_msg[4], 'd6, K1, stage);
//                 round_out_right <= sub_block_right(round_out_right, padded_msg[11], 'd13, K1_1, stage);
//             end
//             8'd2: begin
//                 round_out_left <= sub_block_left(round_out_left, padded_msg[13], 'd8, K1, stage);
//                 round_out_right <= sub_block_right(round_out_right, padded_msg[3], 'd15, K1_1, stage);
//             end
//             8'd3: begin
//                 round_out_left <= sub_block_left(round_out_left, padded_msg[1], 'd13, K1, stage);
//                 round_out_right <= sub_block_right(round_out_right, padded_msg[7], 'd7, K1_1, stage);
//             end
//             8'd4: begin
//                 round_out_left <= sub_block_left(round_out_left, padded_msg[10], 'd11, K1, stage);
//                 round_out_right <= sub_block_right(round_out_right, padded_msg[0], 'd12, K1_1, stage);
//             end
//             8'd5: begin
//                 round_out_left <= sub_block_left(round_out_left, padded_msg[6], 'd9, K1, stage);
//                 round_out_right <= sub_block_right(round_out_right, padded_msg[13], 'd8, K1_1, stage);
//             end
//             8'd6: begin
//                 round_out_left <= sub_block_left(round_out_left, padded_msg[15], 'd7, K1, stage);
//                 round_out_right <= sub_block_right(round_out_right, padded_msg[5], 'd9, K1_1, stage);
//             end
//             8'd7: begin
//                 round_out_left <= sub_block_left(round_out_left, padded_msg[3], 'd15, K1, stage);
//                 round_out_right <= sub_block_right(round_out_right, padded_msg[10], 'd11, K1_1, stage);
//             end
//             8'd8: begin
//                 round_out_left <= sub_block_left(round_out_left, padded_msg[12], 'd7, K1, stage);
//                 round_out_right <= sub_block_right(round_out_right, padded_msg[14], 'd7, K1_1, stage);
//             end
//             8'd9: begin
//                 round_out_left <= sub_block_left(round_out_left, padded_msg[0], 'd12, K1, stage);
//                 round_out_right <= sub_block_right(round_out_right, padded_msg[15], 'd7, K1_1, stage);
//             end
//             8'd10: begin
//                 round_out_left <= sub_block_left(round_out_left, padded_msg[9], 'd15, K1, stage);
//                 round_out_right <= sub_block_right(round_out_right, padded_msg[8], 'd12, K1_1, stage);
//             end
//             8'd11: begin
//                 round_out_left <= sub_block_left(round_out_left, padded_msg[5], 'd9, K1, stage);
//                 round_out_right <= sub_block_right(round_out_right, padded_msg[12], 'd7, K1_1, stage);
//             end
//             8'd12: begin
//                 round_out_left <= sub_block_left(round_out_left, padded_msg[2], 'd11, K1, stage);
//                 round_out_right <= sub_block_right(round_out_right, padded_msg[4], 'd6, K1_1, stage);
//             end
//             8'd13: begin
//                 round_out_left <= sub_block_left(round_out_left, padded_msg[14], 'd7, K1, stage);
//                 round_out_right <= sub_block_right(round_out_right, padded_msg[9], 'd15, K1_1, stage);
//             end
//             8'd14: begin
//                 round_out_left <= sub_block_left(round_out_left, padded_msg[11], 'd13, K1, stage);
//                 round_out_right <= sub_block_right(round_out_right, padded_msg[1], 'd13, K1_1, stage);
//             end
//             8'd15: begin
//                 round_out_left <= sub_block_left(round_out_left, padded_msg[8], 'd12, K1, stage);
//                 round_out_right <= sub_block_right(round_out_right, padded_msg[2], 'd11, K1_1, stage);
//             end
//             default: begin
//                 round_out_left<='x
//                 round_out_right<='x
//                 end
//             endcase
//         end
//         if(stage==2) begin
//             unique casez(sub_block_iter_counter)
//             8'd0: begin
//                 round_out_left <= sub_block_left(round_out_left, padded_msg[3], 'd11, K2, stage);
//                 round_out_right <= sub_block_right(round_out_right, padded_msg[15], 'd9, K2_1, stage);
//             end
//             8'd1: begin
//                 round_out_left <= sub_block_left(round_out_left, padded_msg[10], 'd13, K2, stage);
//                 round_out_right <= sub_block_right(round_out_right, padded_msg[5], 'd7, K2_1, stage);
//             end
//             8'd2: begin
//                 round_out_left <= sub_block_left(round_out_left, padded_msg[14], 'd6, K2, stage);
//                 round_out_right <= sub_block_right(round_out_right, padded_msg[1], 'd15, K2_1, stage);
//             end
//             8'd3: begin
//                 round_out_left <= sub_block_left(round_out_left, padded_msg[4], 'd7, K2, stage);
//                 round_out_right <= sub_block_right(round_out_right, padded_msg[3], 'd11, K2_1, stage);
//             end
//             8'd4: begin
//                 round_out_left <= sub_block_left(round_out_left, padded_msg[9], 'd14, K2, stage);
//                 round_out_right <= sub_block_right(round_out_right, padded_msg[7], 'd8, K2_1, stage);
//             end
//             8'd5: begin
//                 round_out_left <= sub_block_left(round_out_left, padded_msg[15], 'd9, K2, stage);
//                 round_out_right <= sub_block_right(round_out_right, padded_msg[14], 'd6, K2_1, stage);
//             end
//             8'd6: begin
//                 round_out_left <= sub_block_left(round_out_left, padded_msg[8], 'd13, K2, stage);
//                 round_out_right <= sub_block_right(round_out_right, padded_msg[6], 'd6, K2_1, stage);
//             end
//             8'd7: begin
//                 round_out_left <= sub_block_left(round_out_left, padded_msg[1], 'd15, K2, stage);
//                 round_out_right <= sub_block_right(round_out_right, padded_msg[9], 'd14, K2_1, stage);
//             end
//             8'd8: begin
//                 round_out_left <= sub_block_left(round_out_left, padded_msg[2], 'd14, K2, stage);
//                 round_out_right <= sub_block_right(round_out_right, padded_msg[11], 'd12, K2_1, stage);
//             end
//             8'd9: begin
//                 round_out_left <= sub_block_left(round_out_left, padded_msg[7], 'd8, K2, stage);
//                 round_out_right <= sub_block_right(round_out_right, padded_msg[8], 'd13, K2_1, stage);
//             end
//             8'd10: begin
//                 round_out_left <= sub_block_left(round_out_left, padded_msg[0], 'd13, K2, stage);
//                 round_out_right <= sub_block_right(round_out_right, padded_msg[12], 'd5, K2_1, stage);
//             end
//             8'd11: begin
//                 round_out_left <= sub_block_left(round_out_left, padded_msg[6], 'd6, K2, stage);
//                 round_out_right <= sub_block_right(round_out_right, padded_msg[2], 'd14, K2_1, stage);
//             end
//             8'd12: begin
//                 round_out_left <= sub_block_left(round_out_left, padded_msg[13], 'd4, K2, stage);
//                 round_out_right <= sub_block_right(round_out_right, padded_msg[10], 'd13, K2_1, stage);
//             end
//             8'd13: begin
//                 round_out_left <= sub_block_left(round_out_left, padded_msg[11], 'd12, K2, stage);
//                 round_out_right <= sub_block_right(round_out_right, padded_msg[0], 'd13, K2_1, stage);
//             end
//             8'd14: begin
//                 round_out_left <= sub_block_left(round_out_left, padded_msg[5], 'd7, K2, stage);
//                 round_out_right <= sub_block_right(round_out_right, padded_msg[4], 'd7, K2_1, stage);
//             end
//             8'd15: begin
//                 round_out_left <= sub_block_left(round_out_left, padded_msg[12], 'd5, K2, stage);
//                 round_out_right <= sub_block_right(round_out_right, padded_msg[13], 'd5, K2_1, stage);
//             end
//             default: begin
//                 round_out_left<='x
//                 round_out_right<='x
//                 end
//             endcase
//         end
//         if(stage==3) begin
//             unique casez(sub_block_iter_counter)
//             8'd0: begin
//                 round_out_left <= sub_block_left(round_out_left, padded_msg[1], 'd11, K3, stage);
//                 round_out_right <= sub_block_right(round_out_right, padded_msg[8], 'd15, K3_1, stage);
//             end
//             8'd1: begin
//                 round_out_left <= sub_block_left(round_out_left, padded_msg[9], 'd12, K3, stage);
//                 round_out_right <= sub_block_right(round_out_right, padded_msg[6], 'd5, K3_1, stage);
//             end
//             8'd2: begin
//                 round_out_left <= sub_block_left(round_out_left, padded_msg[11], 'd14, K3, stage);
//                 round_out_right <= sub_block_right(round_out_right, padded_msg[4], 'd8, K3_1, stage);
//             end
//             8'd3: begin
//                 round_out_left <= sub_block_left(round_out_left, padded_msg[10], 'd15, K3, stage);
//                 round_out_right <= sub_block_right(round_out_right, padded_msg[1], 'd11, K3_1, stage);
//             end
//             8'd4: begin
//                 round_out_left <= sub_block_left(round_out_left, padded_msg[0], 'd14, K3, stage);
//                 round_out_right <= sub_block_right(round_out_right, padded_msg[3], 'd14, K3_1, stage);
//             end
//             8'd5: begin
//                 round_out_left <= sub_block_left(round_out_left, padded_msg[8], 'd15, K3, stage);
//                 round_out_right <= sub_block_right(round_out_right, padded_msg[11], 'd14, K3_1, stage);
//             end
//             8'd6: begin
//                 round_out_left <= sub_block_left(round_out_left, padded_msg[12], 'd9, K3, stage);
//                 round_out_right <= sub_block_right(round_out_right, padded_msg[15], 'd6, K3_1, stage);
//             end
//             8'd7: begin
//                 round_out_left <= sub_block_left(round_out_left, padded_msg[4], 'd8, K3, stage);
//                 round_out_right <= sub_block_right(round_out_right, padded_msg[0], 'd14, K3_1, stage);
//             end
//             8'd8: begin
//                 round_out_left <= sub_block_left(round_out_left, padded_msg[13], 'd9, K3, stage);
//                 round_out_right <= sub_block_right(round_out_right, padded_msg[5], 'd6, K3_1, stage);
//             end
//             8'd9: begin
//                 round_out_left <= sub_block_left(round_out_left, padded_msg[3], 'd14, K3, stage);
//                 round_out_right <= sub_block_right(round_out_right, padded_msg[12], 'd9, K3_1, stage);
//             end
//             8'd10: begin
//                 round_out_left <= sub_block_left(round_out_left, padded_msg[7], 'd5, K3, stage);
//                 round_out_right <= sub_block_right(round_out_right, padded_msg[2], 'd12, K3_1, stage);
//             end
//             8'd11: begin
//                 round_out_left <= sub_block_left(round_out_left, padded_msg[15], 'd6, K3, stage);
//                 round_out_right <= sub_block_right(round_out_right, padded_msg[13], 'd9, K3_1, stage);
//             end
//             8'd12: begin
//                 round_out_left <= sub_block_left(round_out_left, padded_msg[14], 'd8, K3, stage);
//                 round_out_right <= sub_block_right(round_out_right, padded_msg[9], 'd12, K3_1, stage);
//             end
//             8'd13: begin
//                 round_out_left <= sub_block_left(round_out_left, padded_msg[5], 'd6, K3, stage);
//                 round_out_right <= sub_block_right(round_out_right, padded_msg[7], 'd5, K3_1, stage);
//             end
//             8'd14: begin
//                 round_out_left <= sub_block_left(round_out_left, padded_msg[6], 'd5, K3, stage);
//                 round_out_right <= sub_block_right(round_out_right, padded_msg[10], 'd15, K3_1, stage);
//             end
//             8'd15: begin
//                 round_out_left <= sub_block_left(round_out_left, padded_msg[2], 'd12, K3, stage);
//                 round_out_right <= sub_block_right(round_out_right, padded_msg[14], 'd8, K3_1, stage);
//             end
//             default: begin
//                 round_out_left<='x
//                 round_out_right<='x
//                 end
//             endcase
//         end
//         if(stage==4) begin
//             unique casez(sub_block_iter_counter)
//             8'd0: begin
//                 round_out_left <= sub_block_left(round_out_left, padded_msg[4], 'd9, K4, stage);
//                 round_out_right <= sub_block_right(round_out_right, padded_msg[12], 'd8, K4_1, stage);
//             end
//             8'd1: begin
//                 round_out_left <= sub_block_left(round_out_left, padded_msg[0], 'd15, K4, stage);
//                 round_out_right <= sub_block_right(round_out_right, padded_msg[15], 'd5, K4_1, stage);
//             end
//             8'd2: begin
//                 round_out_left <= sub_block_left(round_out_left, padded_msg[5], 'd5, K4, stage);
//                 round_out_right <= sub_block_right(round_out_right, padded_msg[10], 'd12, K4_1, stage);
//             end
//             8'd3: begin
//                 round_out_left <= sub_block_left(round_out_left, padded_msg[9], 'd11, K4, stage);
//                 round_out_right <= sub_block_right(round_out_right, padded_msg[4], 'd9, K4_1, stage);
//             end
//             8'd4: begin
//                 round_out_left <= sub_block_left(round_out_left, padded_msg[7], 'd6, K4, stage);
//                 round_out_right <= sub_block_right(round_out_right, padded_msg[1], 'd12, K4_1, stage);
//             end
//             8'd5: begin
//                 round_out_left <= sub_block_left(round_out_left, padded_msg[12], 'd8, K4, stage);
//                 round_out_right <= sub_block_right(round_out_right, padded_msg[5], 'd5, K4_1, stage);
//             end
//             8'd6: begin
//                 round_out_left <= sub_block_left(round_out_left, padded_msg[2], 'd13, K4, stage);
//                 round_out_right <= sub_block_right(round_out_right, padded_msg[8], 'd14, K4_1, stage);
//             end
//             8'd7: begin
//                 round_out_left <= sub_block_left(round_out_left, padded_msg[10], 'd12, K4, stage);
//                 round_out_right <= sub_block_right(round_out_right, padded_msg[7], 'd6, K4_1, stage);
//             end
//             8'd8: begin
//                 round_out_left <= sub_block_left(round_out_left, padded_msg[14], 'd5, K4, stage);
//                 round_out_right <= sub_block_right(round_out_right, padded_msg[6], 'd8, K4_1, stage);
//             end
//             8'd9: begin
//                 round_out_left <= sub_block_left(round_out_left, padded_msg[1], 'd12, K4, stage);
//                 round_out_right <= sub_block_right(round_out_right, padded_msg[2], 'd13, K4_1, stage);
//             end
//             8'd10: begin
//                 round_out_left <= sub_block_left(round_out_left, padded_msg[3], 'd13, K4, stage);
//                 round_out_right <= sub_block_right(round_out_right, padded_msg[13], 'd6, K4_1, stage);
//             end
//             8'd11: begin
//                 round_out_left <= sub_block_left(round_out_left, padded_msg[8], 'd14, K4, stage);
//                 round_out_right <= sub_block_right(round_out_right, padded_msg[14], 'd5, K4_1, stage);
//             end
//             8'd12: begin
//                 round_out_left <= sub_block_left(round_out_left, padded_msg[11], 'd11, K4, stage);
//                 round_out_right <= sub_block_right(round_out_right, padded_msg[0], 'd15, K4_1, stage);
//             end
//             8'd13: begin
//                 round_out_left <= sub_block_left(round_out_left, padded_msg[6], 'd8, K4, stage);
//                 round_out_right <= sub_block_right(round_out_right, padded_msg[3], 'd13, K4_1, stage);
//             end
//             8'd14: begin
//                 round_out_left <= sub_block_left(round_out_left, padded_msg[15], 'd5, K4, stage);
//                 round_out_right <= sub_block_right(round_out_right, padded_msg[9], 'd11, K4_1, stage);
//             end
//             8'd15: begin
//                 round_out_left <= sub_block_left(round_out_left, padded_msg[13], 'd6, K4, stage);
//                 round_out_right <= sub_block_right(round_out_right, padded_msg[11], 'd11, K4_1, stage);
//             end
//             default: begin
//                 round_out_left<='x
//                 round_out_right<='x
//                 end
//             endcase
//         end
//         stage <= sub_block_iter_counter == 15 ? stage+1 : stage;
//         sub_block_iter_counter <= sub_block_iter_counter==15 ? 0 : sub_block_iter_counter+1;
//     end
//     else if(state==END) begin
//         Hash_result = { H1^round_out_left[95:64]^round_out_right[63:32],
//                         H2^round_out_left[63:32]^round_out_right[31:0],
//                         H3^round_out_left[31:0]^round_out_right[159:128],
//                         H4^round_out_left[159:128]^round_out_right[127:96],
//                         H0^round_out_left[127:96]^round_out_right[95:64]};
//         valid_out = 1;
//     end
// end: Top_State_machine

// A=data_in[159:128];
// B=data_in[127:96];
// C=data_in[95:64];
// D=data_in[63:32];
// E=data_in[31:0];
endmodule