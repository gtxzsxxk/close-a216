module cpu_top(
    input CLK
);


wire HTRANS_1;
wire HTRANS_2;
wire [63:0] HADDR_1;
wire [63:0] HADDR_2;
wire HWRITE_1;
wire HWRITE_2;
wire [63:0] HWDATA_1;
wire [63:0] HWDATA_2;
wire PADDR;
wire HWRITE;
wire [63:0] PDATA;
wire stall;

reg if_reset;
wire [31:0] inst;

mem_controller mc(
    .HTRANS_1(HTRANS_1),
    .HTRANS_2(HTRANS_2),
    .HADDR_1(HADDR_1),
    .HADDR_2(HADDR_2),
    .HWRITE_1(HWRITE_1),
    .HWRITE_2(HWRITE_2),
    .HWDATA_1(HWDATA_1),
    .HWDATA_2(HWDATA_2),
    .PADDR(PADDR),
    .HWRITE(HWRITE),
    .PDATA(PDATA),
    .stall(stall)
);

inst_fetch i_f(
    .CLK(CLK),
    .reset(if_reset),
    .HRDATA(PDATA),
    .HADDR(HADDR_1),
    .inst(inst)
);

endmodule