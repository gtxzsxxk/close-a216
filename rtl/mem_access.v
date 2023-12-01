module mem_access(
    input CLK,
    input EN,
    input RESET,
    input [4:0] rd_i,
    input [63:0] address,
    input [2:0] mem_para,
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
reg mem_write = 0;
reg [2:0] mem_para_local;
reg [63:0] tmp_res;

always @ (posedge CLK or negedge RESET) begin
    if(!RESET) begin
        take_branch <= 0;
        HTRANS <= 0;
    end
    else begin
        if(EN && !take_branch) begin
            HADDR <= address;
            if(!LOAD) begin
                mem_write <= 1;
                tmp_res <= value;
            end
            else begin
                mem_write <= 0;
            end
            HTRANS <= 1;
            refresh_en <= 1;
        end 
        else begin
            HTRANS <= 0;
            mem_write <= 0;
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
        mem_para_local <= mem_para;
    end
end

always @ (negedge CLK) begin
    if(refresh_en) begin
        if(!mem_write) begin
            if(mem_para_local == 3'b000) begin
                /* LB */
                res <= {{(56){HRDATA[7]}},HRDATA[7:0]};
            end
            else if(mem_para_local == 3'b001) begin
                /* LH */
                res <= {{(48){HRDATA[15]}},HRDATA[15:0]};
            end
            else if(mem_para_local == 3'b010) begin
                /* LW */
                res <= {{(32){HRDATA[31]}},HRDATA[31:0]};
            end
            else if(mem_para_local == 3'b011) begin
                /* LD */
                res <= HRDATA;
            end
            else if(mem_para_local == 3'b100) begin
                /* LBU */
                res <= {{(56){1'b0}},HRDATA[7:0]};
            end
            else if(mem_para_local == 3'b101) begin
                /* LHU */
                res <= {{(48){1'b0}},HRDATA[15:0]};
            end
            else if(mem_para_local == 3'b110) begin
                /* LWU */
                res <= {{(32){1'b0}},HRDATA[31:0]};
            end
            HWRITE <= 0;
        end
        else begin
            if(mem_para_local == 3'b000) begin
                /* SB */
                HWDATA <= (HRDATA & (~64'hff)) | (tmp_res & 64'hff);
            end
            else if(mem_para_local == 3'b001) begin
                /* SH */
                HWDATA <= (HRDATA & (~64'hffff)) | (tmp_res & 64'hffff);
            end
            else if(mem_para_local == 3'b010) begin
                /* SW */
                HWDATA <= (HRDATA & (~64'hffffffff)) | (tmp_res & 64'hffffffff);
            end
            else if(mem_para_local == 3'b011) begin
                /* SD */
                HWDATA <= tmp_res;
            end
            HWRITE <= 1;
        end
    end
    else begin
        res <= tmp_res;
        HWRITE <= 0;
    end
end

endmodule