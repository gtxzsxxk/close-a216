module mem_access(
    input CLK,
    input EN,
    input [4:0] rd_i,
    input [63:0] address,
    input [2:0] funct3,
    input LOAD,
    input [63:0] value,
    input [63:0] HRDATA,
    input [63:0] alu_res,
    input write_back,
    input stall,
    input branch_flag_i, /* is the instruction branch */
    input [63:0] branch_offset_i,
    input [63:0] PC_i,
    output reg [63:0] HADDR,
    output reg [63:0] HWDATA,
    output reg HWRITE,
    output reg HTRANS,
    output reg [63:0] res,
    output reg [4:0] rd_o,
    output reg mem_write_back_en,
    output reg take_branch, /* should we take the branch according to alu */
    output reg [63:0] branch_offset_o,
    output reg [63:0] PC_o
);

reg refresh_en = 0;
reg [63:0] tmp_res;

always @ (posedge CLK) begin
    if(EN && !take_branch) begin
        HWRITE <= ~LOAD;
        HADDR <= address;
        if(!LOAD) begin
            HWDATA <= value;
        end
        HTRANS <= 1;
        refresh_en <= 1;
    end 
    else begin
        HTRANS <= 0;
        refresh_en <= 0;
        tmp_res <= alu_res;
    end
    if(take_branch) begin
        rd_o <= 0;
        mem_write_back_en <= 0;
    end
    else begin
        rd_o <= rd_i;
        mem_write_back_en <= write_back;
    end
    branch_offset_o <= branch_offset_i;
    if(branch_flag_i && alu_res == 64'b1) begin
        /* take the branch */
        take_branch <= 1;
    end
    else begin
        take_branch <= 0;
    end
    PC_o <= PC_i;
end

always @ (negedge CLK) begin
    if(refresh_en) begin
        if(funct3 == 3'b000) begin
            /* LB */
            res <= {{(56){HRDATA[7]}},HRDATA[7:0]};
        end
        else if(funct3 == 3'b001) begin
            /* LH */
            res <= {{(48){HRDATA[15]}},HRDATA[15:0]};
        end
        else if(funct3 == 3'b010) begin
            /* LW */
            res <= {{(32){HRDATA[31]}},HRDATA[31:0]};
        end
        else if(funct3 == 3'b011) begin
            /* LD */
            res <= HRDATA[31:0];
        end
        else if(funct3 == 3'b100) begin
            /* LBU */
            res <= {{(56){1'b0}},HRDATA[7:0]};
        end
        else if(funct3 == 3'b101) begin
            /* LHU */
            res <= {{(48){1'b0}},HRDATA[15:0]};
        end
        else if(funct3 == 3'b110) begin
            /* LWU */
            res <= {{(32){1'b0}},HRDATA[31:0]};
        end
    end
    else begin
        res <= tmp_res;
    end
end

endmodule