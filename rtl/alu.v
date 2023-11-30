module alu(
    input CLK,
    input imm,
    input [4:0] rd_i,
    input [63:0] op1,
    input [63:0] op2,
    input [2:0] funct3,
    input [6:0] funct7,
    input write_back,
    input load_flag_i,
    input mem_en_i,
    input word_inst,
    input take_branch,
    input branch_flag_i,
    input [63:0] branch_offset_i,
    input [63:0] PC_i,
    // input stall,
    output reg [63:0] res,
    output reg alu_write_back_en,
    output reg [4:0] rd_o,
    output reg load_flag_o,
    output reg mem_en_o,
    output reg branch_flag_o,
    output reg [63:0] branch_offset_o,
    output reg [63:0] PC_o,
    output reg [2:0] funct3_o
);

wire [5:0] shift;

assign shift = op2[5:0];

wire [31:0] res_add_32;
wire [31:0] res_sub_32;
wire [31:0] res_sll_32;
wire [31:0] res_srl_32;
wire [31:0] res_sra_32;

assign res_add_32 = $signed(op1[31:0]) + $signed(op2[31:0]);
assign res_sub_32 = $signed(op1[31:0]) - $signed(op2[31:0]);
assign res_sll_32 = op1[31:0] << shift[4:0];
assign res_srl_32 = op1[31:0] >> shift[4:0];
assign res_sra_32 = $signed(op1[31:0]) >>> shift[4:0];


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
            if(!word_inst) begin
                if(imm) begin
                    res <= {{(32){res_add_32[31]}},res_add_32};
                end
                else begin
                    if(funct7 == 7'b0100000) begin
                        res <= {{(32){res_sub_32[31]}},res_sub_32};
                    end
                    else begin
                        res <= {{(32){res_add_32[31]}},res_add_32};
                    end
                end
            end
            else begin
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
        end
        else if(funct3 == 3'b001) begin
            if(!word_inst) begin
                /* SLL */
                res <= op1 << shift;
            end
            else begin
                /* SLLW */
                res <= {{(32){res_sll_32[31]}},res_sll_32};
            end
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
                if(!word_inst) begin
                    res <= $signed(op1) >>> shift;
                end
                else begin
                    res <= {{(32){res_sra_32[31]}},res_sra_32};
                end
            end
            else begin
                /* SRL */
                if(!word_inst) begin
                    res <= op1 >> shift;
                end
                else begin
                    res <= {{(32){res_srl_32[31]}},res_srl_32};
                end
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
            res <= {63'b0, op1 == op2};
        end
        else if(funct3 == 3'b001) begin
            /* BNE */
            res <= {63'b0, op1 != op2};
        end
        else if(funct3 == 3'b100) begin
            /* BLT */
            res <= {63'b0, $signed(op1) < $signed(op2)};
        end
        else if(funct3 == 3'b101) begin
            /* BGE */
            res <= {63'b0, $signed(op1) > $signed(op2)};
        end
        else if(funct3 == 3'b110) begin
            /* BLTU */
            res <= {63'b0, $unsigned(op1) < $unsigned(op2)};
        end
        else if(funct3 == 3'b111) begin
            /* BGEU */
            res <= {63'b0, $unsigned(op1) > $unsigned(op2)};
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

    branch_flag_o <= branch_flag_i;
    branch_offset_o <= branch_offset_i;
    PC_o <= PC_i;
    funct3_o <= funct3;
    // end
end

endmodule