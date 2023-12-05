module mem_access(
    input CLK,
    input EN,
    input RESET,
    input [4:0] rd_i,
    input [31:0] address,
    input [2:0] mem_para,
    input LOAD,
    input [31:0] value,
    input [31:0] HRDATA,
    input [31:0] alu_res,
    input write_back,
    input stall,
    input branch_flag_i, /* is the instruction branch */
    input [31:0] branch_offset_i,
    input [31:0] PC_i,
    output reg [31:0] HADDR,
    output reg [31:0] HWDATA,
    output reg HWRITE,
    output reg HTRANS,
    output reg [31:0] res,
    output reg [4:0] rd_o,
    output reg mem_write_back_en,
    output reg take_branch, /* should we take the branch according to alu */
    output reg [31:0] branch_offset_o,
    output reg [31:0] PC_o
);

reg refresh_en = 0;
reg mem_write = 0;
reg [2:0] mem_para_local;
reg [31:0] tmp_res;

reg [1:0] addr_offset;

always @ (posedge CLK or negedge RESET) begin
    if(!RESET) begin
        take_branch <= 0;
        HTRANS <= 0;
    end
    else begin
        if(EN && !take_branch) begin
            if(!LOAD) begin
                /* WRITE ENABLE */
                mem_write <= 1;
                tmp_res <= value;
                HADDR <= {address[31:2],2'b0};
            end
            else begin
                mem_write <= 0;
                HADDR <= address;
            end
            addr_offset <= address[1:0];
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
        if(branch_flag_i && alu_res == 32'b1) begin
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
                res <= {{(24){HRDATA[7]}},HRDATA[7:0]};
            end
            else if(mem_para_local == 3'b001) begin
                /* LH */
                res <= {{(16){HRDATA[15]}},HRDATA[15:0]};
            end
            else if(mem_para_local == 3'b010) begin
                /* LW */
                res <= HRDATA[31:0];
            end
            else if(mem_para_local == 3'b100) begin
                /* LBU */
                res <= {{(24){1'b0}},HRDATA[7:0]};
            end
            else if(mem_para_local == 3'b101) begin
                /* LHU */
                res <= {{(16){1'b0}},HRDATA[15:0]};
            end
            HWRITE <= 0;
        end
        else begin
            if(mem_para_local == 3'b000) begin
                /* SB */
                case(addr_offset) begin
                    2'd0: HWDATA <= (HRDATA & (~32'hff)) | (tmp_res & 32'hff);
                    2'd1: begin
                        HWDATA <= (HRDATA & (~32'hff00)) |
                            {16'b0,tmp_res[7:0],8'b0};
                    end
                    2'd2: begin
                        HWDATA <= (HRDATA & (~32'hff_0000)) |
                            {8'b0,tmp_res[7:0],16'b0}; 
                    end
                    2'd3: begin
                        HWDATA <= (HRDATA & (~32'hff00_0000)) |
                            {tmp_res[7:0],24'b0}; 
                    end
                end
            
            end
            else if(mem_para_local == 3'b001) begin
                /* SH */
                case(addr_offset) begin
                    2'd0: HWDATA <= (HRDATA & (~32'hffff)) | (tmp_res & 32'hffff);
                    2'd2: begin
                        HWDATA <= (HRDATA & (~32'hffff_0000)) |
                            {tmp_res[15:0],16'b0}; 
                    end
                end
            end
            else if(mem_para_local == 3'b010) begin
                /* SW */
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