module cpu_top(
    input CLK,
    input RESET
);


wire HTRANS_1;
wire HTRANS_2 = 0;
wire [63:0] HADDR_1;
wire [63:0] HADDR_2;
wire HWRITE_1 = 0;
wire HWRITE_2 = 0;
wire [63:0] HWDATA_1;
wire [63:0] HWDATA_2;
wire [63:0] PADDR;
wire HWRITE;
wire [63:0] PDATA;
wire [63:0] HRDATA;
wire stall;

wire c_zero = 0;

reg if_reset = 1;
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

irom internal_rom(
    .HADDR(PADDR),
    .HWDATA(PDATA),
    .HRDATA(HRDATA),
    .HWRITE(c_zero)
);

inst_fetch i_f(
    .CLK(CLK),
    .reset(if_reset),
    .HRDATA(HRDATA),
    .HADDR(HADDR_1),
    .inst(inst),
    .HTRANS(HTRANS_1)
);

wire [4:0] rd;
wire [4:0] rs1;

inst_decode i_d(
    .CLK(CLK),
    .inst(inst),

);

always @ (posedge CLK or negedge RESET) begin
    if(!RESET) begin
        if_reset <= 0;
    end
    else begin
        if_reset <= 1;
    end
end

endmodule