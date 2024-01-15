`timescale 1ns/1ps
module addr_trans_tst();
    
    reg [31:0] addr;
    wire [31:0] addr_translated;
    wire is_rom;
    wire is_ram;
    
    addr_trans a_t(addr,addr_translated,is_rom,is_ram);
    
    /*iverilog */
    initial
    begin
        $dumpfile("wave.vcd");        //生成的vcd文件名称
        $dumpvars(0, addr_trans_tst);     //tb模块名称
    end
    /*iverilog */
    
    initial
    begin
        addr    <= 32'h12345678;
        #1 addr <= 32'h000f_ffff;
        #1 addr <= 32'h0010_0000;
        #1 addr <= 32'h0000_0123;
        #1 addr <= 32'h0020_0123;
        #1 addr <= 32'h0000_0000;
        #1 addr <= 32'h0020_0000;
        #1 addr <= 32'h0040_0000;
        #1 addr <= 32'h009f_ffff;
        #1 addr <= 32'h00a0_0000;
        #1 addr <= 32'h00a0_0001;
        $finish;
    end
    
endmodule
