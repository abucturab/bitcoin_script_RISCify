module scriptTop 
    #(
        parameter STACK_DEPTH = 20,
        parameter STACK_WIDTH = 512,
        parameter SIGNATURE_SIZE = 512,
        parameter MEM_DEPTH = 512
    )
    (
        input logic clk,
        input logic rst,
        output logic done,
        output logic error
    );

    enum logic [2:0] {RST, INIT, READ_TO_STACK, OPCODE_EVAL} state, next_state;

    logic [MEM_DEPTH-1:0][7:0] Mem;
    logic [$clog2(MEM_DEPTH)-1:0] PC,PC_nxt;
    logic [STACK_DEPTH-1:0][$clog2(STACK_WIDTH)-1:0] Stack;
    logic [$clog2(STACK_DEPTH)-1:0] StackPointer, StackPointer_nxt;
    logic [$clog2(STACK_WIDTH)-1:0] mem_rd_cnt, mem_rd_cnt_nxt;
    logic put_alu_in1, put_alu_in2, put_alu_out1, put_alu_out2;
    logic [511:0] data_alu_in1, data_alu_in2, data_alu_out1, data_alu_out2;
    logic [7:0] opcode;
    logic pop_req;
    logic alu_done;
    logic [STACK_WIDTH-1:0] stack_data, stack_data_nxt;


    AluScript ALU(
        .clk(clk),
        .rst(rst),
        .opcode(opcode),
        .put_alu_in1(put_alu_in1),
        .data_alu_in1(data_alu_in1),
        .put_alu_in2(put_alu_in2),
        .data_alu_in2(data_alu_in2),
        .check_sig_msg(),//TODO
        .put_alu_out1(put_alu_out1),
        .data_alu_out1(data_alu_out1),
        .put_alu_out2(put_alu_out2),
        .data_alu_out2(data_alu_out2),
        .pop_req(pop_req),
        .done(alu_done),
        .error(error),
        .branch_taken()
    );

    always_ff @(posedge clk) begin
        if(rst) begin
            PC = 0;
            state = RST;
            mem_rd_cnt = 0;
            StackPointer = 0;
            stack_data = 0;
        end
        else begin
            state <= next_state;
            PC <= PC_nxt;
            mem_rd_cnt <= mem_rd_cnt_nxt;
            StackPointer <= StackPointer_nxt;
            stack_data <= stack_data_nxt;
        end
    end
    //Next state logic
    always_comb begin
        if(state==INIT && Mem[PC] >='h1 && Mem[PC] <= 'h4b) begin
            next_state = READ_TO_STACK;
            PC_nxt = PC+1;
            mem_rd_cnt_nxt = Mem[PC];
        end
        else if(state==INIT && Mem[PC] > 'h4b) begin
            next_state = alu_done ? INIT : OPCODE_EVAL;
            PC_nxt = alu_done ? PC + 1 : PC;
        end
        else if(state==READ_TO_STACK) begin
            next_state = mem_rd_cnt==1 ? INIT : READ_TO_STACK;
            PC_nxt = PC+1;
            mem_rd_cnt_nxt = mem_rd_cnt-1;
            stack_data_nxt = stack_data<<8 | Mem[PC];
            if(mem_rd_cnt==1) begin
                Stack[StackPointer]=stack_data_nxt;
                StackPointer_nxt = StackPointer + 1;
            end
        end
        else if(state == OPCODE_EVAL) begin
            next_state = alu_done ? INIT : OPCODE_EVAL;
            PC_nxt = alu_done ? PC+1 : PC;
            opcode = Mem[PC];
            if(alu_done) begin
                if(put_alu_out1 && !put_alu_out2) begin
                    Stack[StackPointer] = data_alu_out1;
                    StackPointer_nxt = StackPointer + 1;
                end
                else if(put_alu_out1 && put_alu_out2) begin
                    Stack[StackPointer] = data_alu_out1;
                    Stack[StackPointer+1] = data_alu_out2;
                    StackPointer_nxt = StackPointer + 2;
                end
            end
            else if(pop_req) begin
                put_alu_in1 = 1;
                data_alu_in1 = Stack[StackPointer];
                StackPointer_nxt = StackPointer - 1;
            end
            else begin
                put_alu_in1 = 1;
                data_alu_in1 = Stack[StackPointer];
                put_alu_in2 = StackPointer >=1 ? 1 : 0;
                data_alu_in2 = Stack[StackPointer-1];
            end
        end
        else begin
            next_state = INIT;
            PC_nxt = 0;
        end
    end


endmodule