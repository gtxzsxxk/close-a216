module alu(
    input CLK,
    input imm,
    input [4:0] rd_i,
    input [31:0] op1,
    input [31:0] op2,
    input [2:0] funct3,
    input [2:0] mem_para_i,
    input [6:0] funct7,
    input write_back,
    input load_flag_i,
    input mem_en_i,
    input take_branch,
    input branch_flag_i,
    input [31:0] branch_offset_i,
    input [31:0] PC_i,
    input [31:0] store_value_i,
    // input stall,
    output reg [31:0] res,
    output reg alu_write_back_en,
    output reg [4:0] rd_o,
    output reg load_flag_o,
    output reg mem_en_o,
    output reg branch_flag_o,
    output reg [31:0] branch_offset_o,
    output reg [31:0] PC_o,
    output reg [2:0] mem_para_o,
    output reg [31:0] store_value_o
);

wire [4:0] shift;

assign shift = op2[4:0];

always @ (posedge CLK) begin
    // if(stall) begin
    //     /* addi x0, x0, 0 */
    //     res <= 0;
    //     alu_write_back_en <= 0;
    //     rd_o <= 0;
    //     mem_en_o <= 0;
    // end
    // else begin
    if(!branch_flag_i) begin
        if(funct3 == 3'b000) begin
        /* ADD SUB */
            if(imm) begin
                res <= op1 + op2;
            end
            else begin
                if(funct7 == 7'b0100000) begin
                    res <= op1 - op2;
                end
                else begin
                    res <= op1 + op2;
                end
            end
        end
        else if(funct3 == 3'b001) begin
            /* SLL */
            res <= op1 << shift;
        end
        else if(funct3 == 3'b010) begin
            /* SLT */
            if($signed(op1) < $signed(op2)) begin
                res <= 1;
            end
            else begin
                res <= 0;
            end
        end
        else if(funct3 == 3'b011) begin
            /* SLTU */
            if($unsigned(op1) < $unsigned(op2)) begin
                res <= 1;
            end
            else begin
                res <= 0;
            end
        end
        else if(funct3 == 3'b100) begin
            /* XOR */
            res <= op1 ^ op2;
        end
        else if(funct3 == 3'b101) begin
            if(funct7 == 7'b0100000) begin
                /* SRA */
                res <= $signed(op1) >>> shift;
            end
            else begin
                /* SRL */
                res <= op1 >> shift;
            end
        end
        else if(funct3 == 3'b110) begin
            res <= op1 | op2;
        end
        else if(funct3 == 3'b111) begin
            res <= op1 & op2;
        end
    end
    else begin
        if(funct3 == 3'b000) begin
            /* BEQ */
            res <= {31'b0, op1 == op2};
        end
        else if(funct3 == 3'b001) begin
            /* BNE */
            res <= {31'b0, op1 != op2};
        end
        else if(funct3 == 3'b100) begin
            /* BLT */
            res <= {31'b0, $signed(op1) < $signed(op2)};
        end
        else if(funct3 == 3'b101) begin
            /* BGE */
            res <= {31'b0, $signed(op1) >= $signed(op2)};
        end
        else if(funct3 == 3'b110) begin
            /* BLTU */
            res <= {31'b0, $unsigned(op1) < $unsigned(op2)};
        end
        else if(funct3 == 3'b111) begin
            /* BGEU */
            res <= {31'b0, $unsigned(op1) >= $unsigned(op2)};
        end
    end
    if(take_branch) begin
        alu_write_back_en <= 0;
        rd_o <= 0;
        mem_en_o <= 0;
    end
    else begin
        alu_write_back_en <= write_back;
        rd_o <= rd_i;
        mem_en_o <= mem_en_i;
    end

    load_flag_o <= load_flag_i;
    branch_flag_o <= branch_flag_i;
    branch_offset_o <= branch_offset_i;
    PC_o <= PC_i;
    mem_para_o <= mem_para_i;
    store_value_o <= store_value_i;
    // end
end

endmodule