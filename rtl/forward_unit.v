module forward_unit(
    input imm,
    input load_inst, /* 如果上一条指令是load，插入气泡，从mem开始forward */
    input [4:0] alu_rd,
    input [4:0] mem_rd,
    input [4:0] rs1,
    input [4:0] rs2,
    input [4:0] store_reg,
    input [63:0] alu_res,
    input [63:0] mem_res,
    input [63:0] op1_from_id,
    input [63:0] op2_from_id,
    input [63:0] store_value_from_id,
    output reg [63:0] op1_fwd,
    output reg [63:0] op2_fwd,
    output reg [63:0] store_value_fwd
);

always @ (*) begin
    if(!load_inst && rs1 == alu_rd && alu_rd != 0) begin
        op1_fwd <= alu_res;
    end
    else if(rs1 == mem_rd && mem_rd != 0) begin
        op1_fwd <= mem_res;
    end
    else begin
        op1_fwd <= op1_from_id;
    end
    if(!imm) begin
        if(rs2 == alu_rd && alu_rd != 0) begin
            op2_fwd <= alu_res;
        end
        else if(rs2 == mem_rd && mem_rd != 0) begin
            op2_fwd <= mem_res;
        end
        else begin
            op2_fwd <= op2_from_id;
        end
    end
    else begin
        op2_fwd <= op2_from_id;
    end

    if(store_reg == alu_rd && alu_rd != 0) begin
        store_value_fwd <= alu_res;
    end
    else if(store_reg == mem_rd && mem_rd != 0) begin
        store_value_fwd <= mem_res;
    end
    else begin
        store_value_fwd <= store_value_from_id;
    end
end

endmodule