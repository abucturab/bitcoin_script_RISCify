module scriptTop 
#(
    parameter STACK DEPTH = 20,
    parameter STACK_WIDTH = 512,
    parameter SIGNATURE_SIZE = 512
)
(
    input logic clk,
    input logic rst,
    input logic [7:0] script_data,
    input logic script_put,
    input logic script_evaluate,
    output logic script_success,
    output logic script_error
);

logic [STACK_DEPTH-1:0][STACK_WIDTH-1:0] stackMem;
logic [clog2(STACK_DEPTH)-1:0] data_stackPointer,opcode_stackPointer;
logic [STACK_DEPTH-1:0][7:0] opcode_stack;
logic [clog2(STACK_WIDTH)-1:0] num_bytes_to_push;
logic [STACK_WIDTH-1:0] data_to_push;
logic data_push_en;
logic op_alu;
logic [clog2(STACK_DEPTH)-1:0] op_rd_ptr;
logic [STACK_WIDTH-1:0] alu_input_a, alu_input_b;
logic [STACK_WIDTH-1:0] alu_to_stack_data1, alu_to_stack_data2;
logic alu_to_stack_push1, alu_to_stack_push2;
logic alu_done;

//Initialize all data structures to 0 on reset
always_ff @(posedge clk) begin
    if(rst) begin
        stackMem = 0;
        data_stackPointer=0;
        opcode_stackPointer=0;
        opcode_stack=0;
        num_bytes_to_push=0;
        data_to_push = 0;
        data_push_en = 0;
        script_success = 0;
        script_error=0;
        op_rd_ptr=0;
        alu_input_a = 'x; //TODO need to sort out initial conditions
        alu_input_b = 'x; //TODO need to sort out initial conditions
        op_alu = 'x; //TODO need to sort out initial conditions
    end
end

/*
    Assemble the data in the script to be pushed to the Data Stack or the opcode stack
    The script is input to module along with a put/enable signale
    if 'h0 < script_data < 'h4b and byte push is not in progress:
        num_bytes_to_push=script_data;
    else if num_bytes_to_push > 0:
        Assemble data
        decrease num_bytes_to_push counter
        if currently reading final byte i.e. num_bytes_to_push==1:
            data_push_en<=1 //Will become 1 in next clk so data will be ready to push then
    else:
        //It is opcode
        push(opcode)
        increament stackPointer

*/
always_ff @(posedge clk && script_put) begin
    if(script_data>'h0 && script_data<='h4b && num_bytes_to_push==0) begin
        num_bytes_to_push <= script_data;
        data_push_en<=0;
    end
    else if(num_bytes_to_push>0) begin
        data_to_push <= data_to_push<<8 | script_data;
        num_bytes_to_push <= num_bytes_to_push-1;
        if(num_bytes_to_push==1)
            data_push_en<=1;
    end
    else begin
        opcode_stack[opcode_stackPointer] = script_data;
        opcode_stackPointer <= opcode_stackPointer + 1;
        data_push_en<=0;
    end
end

//always_ff @(posedge script_evaluate)

//Control block to push data to Data Stack
always_ff @(posedge clk) begin
    if(data_push_en) begin
        stackMem[data_stackPointer]=data_to_push;
        data_stackPointer<=data_stackPointer+1; //TODO need to solve the alignment of stack pointer for reading
    end
end

always_ff @(posedge clk) begin
    if(script_evaluate)
        op_rd_ptr <= opcode_stackPointer;
    else begin
        if(alu_done & (!script_success | !script_error) & !script_put) begin
        op_rd_ptr <= op_rd_ptr - 1;
        end
    end
end

always_comb op_alu = opcode_stack[op_rd_ptr];
always_comb alu_input_a = stackMem[data_stackPointer]
always_comb alu_input_b = data_stackPointer >= 1 ? stackMem[data_stackPointer+1] : 'x;

//Block to push data to stack once opcode completes
always_ff @(posedge clk) begin
    if(alu_done) begin
        if(alu_to_stack_push1 & !alu_to_stack_data2) begin
            stackMem[data_stackPointer] = alu_to_stack_data1;
            data_stackPointer <= data_stackPointer + 1;
        end
        if(alu_to_stack_push1 & alu_to_stack_push2) begin
            stackMem[data_stackPointer] = alu_to_stack_data1;
            stackMem[data_stackPointer+1] = alu_to_stack_data2;
            data_stackPointer <= data_stackPointer+1;
        end
    end
end


AluScript ALU(
    .clk            (clk),
    .rst            (rst),
    .opcode         (op_alu),
    .stack_data1    (alu_input_a), //TODO define
    .stack_data2    (alu_input_b), //TODO define
    .check_sig_msg  (sig_msg), //TODO define
    .push_data1     (alu_to_stack_data1), //TODO define
    .push_data2     (alu_to_stack_data2), //TODO define
    .push_en1       (alu_to_stack_push1), //TODO define
    .push_en2       (alu_to_stack_push2), //TODO define
    .done           (alu_done), //TODO define
    .error          (script_error)
);


endmodule