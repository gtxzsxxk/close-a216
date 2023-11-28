module cpu_top(
    input CLK,
    input RESET
);


wire HTRANS_1;
wire HTRANS_2;
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
wire stall_from_pc_and_mem;
wire stall_from_load;
wire stall;

assign stall = stall_from_pc_and_mem | stall_from_load;

reg if_reset = 1;
wire [31:0] inst;

mem_controller mc(
    .HTRANS_1(HTRANS_2),
    .HTRANS_2(HTRANS_1),
    .HADDR_1(HADDR_2),
    .HADDR_2(HADDR_1),
    .HWRITE_1(HWRITE_2),
    .HWRITE_2(HWRITE_1),
    .HWDATA_1(HWDATA_2),
    .HWDATA_2(HWDATA_1),
    .PADDR(PADDR),
    .HWRITE(HWRITE),
    .PDATA(PDATA),
    .stall(stall_from_pc_and_mem)
);

irom internal_rom(
    .HADDR(PADDR),
    .HWDATA(PDATA),
    .HRDATA(HRDATA)
);

inst_fetch i_f(
    .CLK(CLK),
    .reset(if_reset),
    .stall(stall),
    .HRDATA(HRDATA),
    .HADDR(HADDR_1),
    .inst(inst),
    .HTRANS(HTRANS_1)
);

wire [4:0] rd;
wire [4:0] rs1;
wire [4:0] rs2;
wire [2:0] funct3;
wire [6:0] funct7;
wire [19:0] imm20;
wire [63:0] op1;
wire [63:0] op2;
wire id_write_back_en;
wire alu_write_back_en;
wire mem_write_back_en;
wire imm_flag;
wire mem_acc;
wire load_flag;
wire [63:0] alu_res;

wire [4:0] wb_rd;
wire [63:0] wb_value;
wire wb_en;

inst_decode i_d(
    .CLK(CLK),
    .reset(if_reset),
    .inst(inst),
    .wb_rd(wb_rd),
    .wb_value(wb_value),
    .wb_en(wb_en),
    .stall(stall_from_pc_and_mem),
    .rd(rd),
    .rs1(rs1),
    .rs2(rs2),
    .funct3(funct3),
    .funct7(funct7),
    .imm20(imm20),
    .op1(op1),
    .op2(op2),
    .write_back(id_write_back_en),
    .imm_flag(imm_flag),
    .mem_acc(mem_acc),
    .load_flag(load_flag),
    .stall_raise(stall_from_load)
);

wire [4:0] alu_rd;
wire alu_load_flag;
wire alu_mem_en_flag;

wire [63:0] op1_fwd;
wire [63:0] op2_fwd;

wire [4:0] mem_rd;
wire [63:0] mem_res;
wire [63:0] mem_write_value;

forward_unit fu(
    .imm(imm_flag),
    .alu_rd(alu_rd),
    .mem_rd(mem_rd),
    .rs1(rs1),
    .rs2(rs2),
    .alu_res(alu_res),
    .mem_res(mem_res),
    .op1_from_id(op1),
    .op2_from_id(op2),
    .op1_fwd(op1_fwd),
    .op2_fwd(op2_fwd)
);

alu exec(
    .CLK(CLK),
    .imm(imm_flag),
    .rd_i(rd),
    .op1(op1_fwd),
    .op2(op2_fwd),
    .funct3(funct3),
    .funct7(funct7),
    .write_back(id_write_back_en),
    .load_flag_i(load_flag),
    .mem_en_i(mem_acc),
    // .stall(stall),
    .res(alu_res),
    .alu_write_back_en(alu_write_back_en),
    .rd_o(alu_rd),
    .load_flag_o(alu_load_flag),
    .mem_en_o(alu_mem_en_flag)
);

mem_access m_a(
    .CLK(CLK),
    .EN(alu_mem_en_flag),
    .rd_i(alu_rd),
    .address(alu_res),
    .LOAD(alu_load_flag),
    .value(mem_write_value),
    .HRDATA(HRDATA),
    .alu_res(alu_res),
    .write_back(alu_write_back_en),
    .stall(stall),
    .HADDR(HADDR_2),
    .HWDATA(HWDATA_2),
    .HWRITE(HWRITE_2),
    .HTRANS(HTRANS_2),
    .res(mem_res),
    .rd_o(mem_rd),
    .mem_write_back_en(mem_write_back_en)
);

write_back w_b(
    .EN(mem_write_back_en),
    .rd(mem_rd),
    .value(mem_res),
    .wb_rd(wb_rd),
    .wb_value(wb_value),
    .wb_en(wb_en)
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