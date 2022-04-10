`timescale 1ns/1ps
module op_dup_test;
    logic clk, rst, put_alu_in1, put_alu_in2, put_alu_out1, put_alu_out2 pop_req, done, error;
    logic [7:0] opcode;
    logic [511:0] data_alu_in1, data_alu_in2, data_alu_out1, data_alu_out2;
    logic [255:0] check_sig_msg;
    AluScript ALU(.*);

    logic [511:0] Stack[$];

    initial begin
        //Stack = new [2];
        //stack_pointer = 1;
        Stack.push_front(511'hDEAD_BEEF)
        //Stack[0] = {511'hDEAD_BEEF};
        clk = 0;
        rst = 1;
        opcode = 'x;
        repeat(2)
            @(posedge clk);
        rst = 0;
        #1;
        drive_dup_opcode();
        rst = 1;
        #10;
        $finish;
    end
    always begin
        #10 clk = ~clk;
    end

    task drive_dup_opcode();
        @(posedge clk & !rst);
        if(Stack.size()>0) begin
            put_alu_in1 = 1;
            data_alu_in1 = Stack.pop_front();
            opcode = `OP_DUP;
            stack_pointer-=1;
        end
        @(posedge clk & (done | error));
        if(error) begin
            $error("@%0t Error in OP_DUP task!!", $time);
            $finish;
        end
        if(put_alu_out1) begin
            Stack.push_front(data_alu_out1);
            if(put_alu_out2)
                Stack.push_front(data_alu_out2);
        end
    endtask

endmodule