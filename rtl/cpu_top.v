module cpu_top(
    input CLK,
    input UART_RX,
    output UART_TX,
    output PIN_TEST
);

reg reset_flag = 1;
reg clk_bin_div;
parameter clk_bin_div_cmp = 1;
reg clk_bin_div_cnt;

wire HTRANS_1;
wire HTRANS_2;
wire [31:0] HADDR_1;
wire [31:0] HADDR_2;
wire HWRITE_1 = 0;
wire HWRITE_2;
wire [31:0] HWDATA_1 = 0;
wire [31:0] HWDATA_2;
wire [31:0] PADDR;
wire HWRITE;
wire [31:0] PDATA;
wire [31:0] HRDATA;
wire stall_from_pc_and_mem;
wire stall_from_load;
wire stall;

assign stall = stall_from_pc_and_mem | stall_from_load;

reg if_reset = 1;
wire [31:0] inst;
wire h_reset;

mem_controller mc(
    .HTRANS_1(HTRANS_2),
    .HTRANS_2(HTRANS_1),
    .HRESET(if_reset),
    .HADDR_1(HADDR_2),
    .HADDR_2(HADDR_1),
    .HWRITE_1(HWRITE_2),
    .HWRITE_2(HWRITE_1),
    .HWDATA_1(HWDATA_2),
    .HWDATA_2(HWDATA_1),
    .PADDR(PADDR),
    .HWRITE(HWRITE),
    .PDATA(PDATA),
    .stall(stall_from_pc_and_mem),
    .HRESET_o(h_reset)
);

rom_controller irom(
    .CLK(CLK),
    .clk_bin_div(clk_bin_div),
    .HADDR(PADDR),
    .HRDATA(HRDATA)
);

ram_controller iram(
    .CLK(CLK),
    .clk_bin_div(clk_bin_div),
    .HWRITE(HWRITE),
    .HADDR(PADDR),
    .HWDATA(PDATA),
    .HRDATA(HRDATA)
);

uart_top u_controller(
    .HRESET(h_reset),
    .CLK(clk_bin_div),
    .HWRITE(HWRITE),
    .PADDR(PADDR),
    .PWDATA(PDATA),
    .PRDATA(HRDATA),
    .PIN_RX(UART_RX),
    .PIN_TX(UART_TX)
);

pin_output_test pot(
    .HRESET(h_reset),
    .CLK(clk_bin_div),
    .HWRITE(HWRITE),
    .PADDR(PADDR),
    .PWDATA(PDATA),
    .PRDATA(HRDATA),
    .PIN_OUT(PIN_TEST)
);

wire take_branch;
wire [31:0] take_branch_offset;

wire [31:0] mem_PC;

wire [31:0] jalr_offset;

wire [31:0] pc_of_inst;

inst_fetch i_f(
    .CLK(clk_bin_div),
    .reset(if_reset),
    .stall(stall),
    .take_branch(take_branch),
    .branch_PC(mem_PC),
    .take_branch_offset(take_branch_offset),
    .PC_i(jalr_offset),
    .HRDATA(HRDATA),
    .HADDR(HADDR_1),
    .pc_of_inst(pc_of_inst),
    .inst(inst),
    .HTRANS(HTRANS_1)
);

wire [4:0] rd;
wire [4:0] rs1;
wire [4:0] rs2;
wire [2:0] funct3;
wire [6:0] funct7;
wire [19:0] imm20;
wire [31:0] op1;
wire [31:0] op2;
wire id_write_back_en;
wire alu_write_back_en;
wire mem_write_back_en;
wire imm_flag;
wire mem_acc;
wire load_flag;
wire load_fwd_flag;
wire [31:0] alu_res;

wire [4:0] wb_rd;
wire [31:0] wb_value;
wire wb_en;

wire [31:0] id_branch_offset;
wire id_branch_flag;

wire id_stall = stall_from_pc_and_mem | take_branch;

wire [31:0] id_PC;

wire [2:0] id_mem_para;
wire [31:0] id_store_value;
wire [4:0] id_store_reg;

wire [4:0] alu_rd;
wire alu_load_flag;
wire alu_mem_en_flag;

wire [4:0] mem_rd;
wire [31:0] mem_res;

inst_decode i_d(
    .CLK(clk_bin_div),
    .reset(if_reset),
    .inst(inst),
    .wb_rd(wb_rd),
    .wb_value(wb_value),
    .wb_en(wb_en),
    .stall(id_stall),
    .PC_i(pc_of_inst),
    .alu_rd(alu_rd),
    .jalr_forwarding_alu_op1(alu_res),
    .mem_rd(mem_rd),
    .jalr_forwarding_mem_op1(mem_res),
    .rd(rd),
    .rs1(rs1),
    .rs2(rs2),
    .funct3(funct3),
    .mem_para(id_mem_para),
    .funct7(funct7),
    .imm20(imm20),
    .op1(op1),
    .op2(op2),
    .write_back(id_write_back_en),
    .imm_flag(imm_flag),
    .mem_acc(mem_acc),
    .load_flag(load_flag),
    .load_fwd_flag(load_fwd_flag),
    .stall_raise(stall_from_load),
    .branch_offset(id_branch_offset),
    .jalr_offset(jalr_offset),
    .branch_flag(id_branch_flag),
    .PC_o(id_PC),
    .store_value(id_store_value),
    .store_reg(id_store_reg)
);

wire [31:0] op1_fwd;
wire [31:0] op2_fwd;
wire [31:0] store_value_fwd;

wire [31:0] alu_branch_offset;
wire alu_branch_flag;

wire [31:0] alu_PC;

wire [2:0] alu_mem_para;
wire [31:0] alu_store_value;

forward_unit fu(
    .imm(imm_flag),
    .load_inst(load_fwd_flag),
    .alu_rd(alu_rd),
    .mem_rd(mem_rd),
    .rs1(rs1),
    .rs2(rs2),
    .store_reg(id_store_reg),
    .alu_res(alu_res),
    .mem_res(mem_res),
    .op1_from_id(op1),
    .op2_from_id(op2),
    .store_value_from_id(id_store_value),
    .op1_fwd(op1_fwd),
    .op2_fwd(op2_fwd),
    .store_value_fwd(store_value_fwd)
);

alu exec(
    .CLK(clk_bin_div),
    .imm(imm_flag),
    .rd_i(rd),
    .op1(op1_fwd),
    .op2(op2_fwd),
    .funct3(funct3),
    .mem_para_i(id_mem_para),
    .funct7(funct7),
    .write_back(id_write_back_en),
    .load_flag_i(load_flag),
    .mem_en_i(mem_acc),
    .take_branch(take_branch),
    .branch_flag_i(id_branch_flag),
    .branch_offset_i(id_branch_offset),
    .PC_i(id_PC),
    .store_value_i(store_value_fwd),
    // .stall(stall),
    .res(alu_res),
    .alu_write_back_en(alu_write_back_en),
    .rd_o(alu_rd),
    .load_flag_o(alu_load_flag),
    .mem_en_o(alu_mem_en_flag),
    .branch_flag_o(alu_branch_flag),
    .branch_offset_o(alu_branch_offset),
    .PC_o(alu_PC),
    .mem_para_o(alu_mem_para),
    .store_value_o(alu_store_value)
);

mem_access m_a(
    .CLK(clk_bin_div),
    .EN(alu_mem_en_flag),
    .RESET(if_reset),
    .rd_i(alu_rd),
    .address(alu_res),
    .mem_para(alu_mem_para),
    .LOAD(alu_load_flag),
    .value(alu_store_value),
    .HRDATA(HRDATA),
    .alu_res(alu_res),
    .write_back(alu_write_back_en),
    .stall(stall),
    .branch_flag_i(alu_branch_flag),
    .branch_offset_i(alu_branch_offset),
    .PC_i(alu_PC),
    .HADDR(HADDR_2),
    .HWDATA(HWDATA_2),
    .HWRITE(HWRITE_2),
    .HTRANS(HTRANS_2),
    .res(mem_res),
    .rd_o(mem_rd),
    .mem_write_back_en(mem_write_back_en),
    .take_branch(take_branch),
    .branch_offset_o(take_branch_offset),
    .PC_o(mem_PC)
);

write_back w_b(
    .EN(mem_write_back_en),
    .rd(mem_rd),
    .value(mem_res),
    .wb_rd(wb_rd),
    .wb_value(wb_value),
    .wb_en(wb_en)
);

always @ (posedge CLK) begin
    if(reset_flag) begin
        if_reset <= 0;
        reset_flag <= 0;
        clk_bin_div <= 1;
        clk_bin_div_cnt <= 1;
    end
    else begin
        if_reset <= 1;
        if(clk_bin_div_cnt == clk_bin_div_cmp) begin
            clk_bin_div = ~clk_bin_div;
        end
        else begin
            clk_bin_div_cnt <= clk_bin_div_cnt + 1;
        end
    end
end

endmodule