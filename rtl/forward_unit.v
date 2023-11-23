module forward_unit(
    input imm,
    input [4:0] alu_rd,
    input [4:0] mem_rd,
    input [4:0] rs1,
    input [4:0] rs2,
    input [63:0] alu_res,
    input [63:0] mem_res,
    input [63:0] op1_from_id,
    input [63:0] op2_from_id,
    output reg [63:0] op1_fwd,
    output reg [63:0] op2_fwd
);

always @ (*) begin
    if(rs1 == alu_rd) begin
        op1_fwd <= alu_res;
    end
    else if(rs1 == mem_rd) begin
        op1_fwd <= mem_res;
    end
    else begin
        op1_fwd <= op1_from_id;
    end
    if(!imm) begin
        if(rs2 == alu_rd) begin
            op2_fwd <= alu_res;
        end
        else if(rs2 == mem_rd) begin
            op2_fwd <= mem_res;
        end
        else begin
            op2_fwd <= op2_from_id;
        end
    end
    else begin
        op2_fwd <= op2_from_id;
    end
end

endmodule