module sub_block_right (
    input logic [159:0] data_in, 
    input logic [31:0] m, 
    input logic [7:0] s, 
    input logic [31:0] K, 
    input logic [2:0] t, 
    output logic [159:0] right_out
);

function logic [31:0] F1(input logic [31:0] B,C,D);
    F1=B^C^D;
endfunction

function logic [31:0] F2(input logic [31:0] B,C,D);
    F2 = (B&C)|(~B&D);
endfunction

function logic [31:0] F3(input logic [31:0] B,C,D);
    F3 = (B|~C)^D;
endfunction

function logic [31:0] F4(input logic [31:0] B,C,D);
    F4 = (B&D)|(C&~D);
endfunction

function logic [31:0] F5(input logic [31:0] B,C,D);
    F5 = B^(C|~D);
endfunction
    
    /*
        A=data_in[159:128];
        B=data_in[127:96];
        C=data_in[95:64];
        D=data_in[63:32];
        E=data_in[31:0];
    */
    logic [31:0] temp;
    logic [31:0] f_out;
    logic [31:0] A,B,C,D,E;
    always_comb begin
        
        A=data_in[159:128];
        B=data_in[127:96];
        C=data_in[95:64];
        D=data_in[63:32];
        E=data_in[31:0];

        right_out[31:0] = D; //E=D
        right_out[63:32] = {C[21:0],C[31:22]}; //D = C<<10
        right_out[95:64] = B; //C = B
        unique casez(t)
            4'h0: f_out = F5(data_in[127:96], data_in[95:64], data_in[63:32]);
            4'h1: f_out = F4(data_in[127:96], data_in[95:64], data_in[63:32]);
            4'h2: f_out = F3(data_in[127:96], data_in[95:64], data_in[63:32]);
            4'h3: f_out = F2(data_in[127:96], data_in[95:64], data_in[63:32]);
            4'h4: f_out = F1(data_in[127:96], data_in[95:64], data_in[63:32]);
            default: f_out = 'x;
        endcase
        temp = A + m + K + f_out;
        unique casez(s)
            8'd1: right_out[127:96] = {temp[30:0],temp[31]};
            8'd2: right_out[127:96] = {temp[29:0],temp[31:30]};
            8'd3: right_out[127:96] = {temp[28:0],temp[31:29]};
            8'd4: right_out[127:96] = {temp[27:0],temp[31:28]};
            8'd5: right_out[127:96] = {temp[26:0],temp[31:27]};
            8'd6: right_out[127:96] = {temp[25:0],temp[31:26]};
            8'd7: right_out[127:96] = {temp[24:0],temp[31:25]};
            8'd8: right_out[127:96] = {temp[23:0],temp[31:24]};
            8'd9: right_out[127:96] = {temp[22:0],temp[31:23]};
            8'd10: right_out[127:96] = {temp[21:0],temp[31:22]};
            8'd11: right_out[127:96] = {temp[20:0],temp[31:21]};
            8'd12: right_out[127:96] = {temp[19:0],temp[31:20]};
            8'd13: right_out[127:96] = {temp[18:0],temp[31:19]};
            8'd14: right_out[127:96] = {temp[17:0],temp[31:18]};
            8'd15: right_out[127:96] = {temp[16:0],temp[31:17]};
            default: right_out[127:96] = temp;
        endcase
        //right_out[127:96] = {temp[0 +: 32-s], temp[31 -: s]};//{temp[31-s:0],temp[31:32-s]}+E;
        right_out[159:128] = E; //A=E
    end
    
endmodule