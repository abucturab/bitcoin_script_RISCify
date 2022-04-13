`timescale 1ns / 1ps
module testbench;
    logic clk, rst,valid_in, valid_out;
    logic [439:0] message;
    logic [159:0] Hash_result;
    ripemd160 hash_unit(.*);

    initial begin
        clk=0;
        rst=1;
        valid_in=0;
        message = "abcd";
        repeat(5)
            @(posedge clk);
        rst=0;
        repeat(5)
            @(posedge clk);
        valid_in = 1;
        @(posedge valid_out);
        $display("Hash complete ! = %0h", Hash_result);
        #10;
        $finish;
    end
    always begin
        #5 clk = ~clk;
    end


endmodule
