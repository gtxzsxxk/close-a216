module inst_fetch(
    input CLK,
    input reset,
    input stall,
    input take_branch,
    input [63:0] branch_PC,
    input [63:0] take_branch_offset,
    input [63:0] PC_i,
    input [63:0] HRDATA,
    output wire [63:0] HADDR,
    output reg [31:0] inst,
    output reg HTRANS
);

parameter JAL = 7'b1101111;
parameter JALR = 7'b1100111;

/* use the address by if or by the outside */
reg addr_mux = 0;

reg stall_reg = 0;
reg take_branch_reg = 0;

reg [63:0] PC_tmp;
reg [63:0] PC_jalr;
reg jalr_jump = 0;

assign HADDR = addr_mux ? PC_i : PC_tmp;

function [63:0] get_pc;
    input use_jalr_pc;
    begin
        if(use_jalr_pc) begin
            get_pc = PC_jalr;
        end
        else begin
            get_pc = PC_tmp;
        end
    end
endfunction

always @ (posedge CLK or negedge reset) begin
    if(!reset) begin
        PC_tmp <= 64'b0;
        HTRANS <= 1;
        addr_mux <= 0;
    end
    else begin
        stall_reg <= stall;
        take_branch_reg <= take_branch;
        if(stall && !take_branch) begin
            PC_tmp <= get_pc(jalr_jump);
            HTRANS <= 1;
            addr_mux <= 0;
        end
        else begin
            if(take_branch) begin
                PC_tmp <= branch_PC + take_branch_offset;
                addr_mux <= 0;
            end
            else if(inst[6:0] == JAL) begin
                /* if the last instruction is JALx, jump now */
                PC_tmp <= get_pc(jalr_jump) + {{(43){inst[31]}},inst[31],inst[19:12],
                    inst[20],inst[30:21],1'b0};
                addr_mux <= 0;
            end
            else if(inst[6:0] == JALR) begin
                addr_mux <= 1;
            end
            else begin
                PC_tmp <= get_pc(jalr_jump) + 4;
                addr_mux <= 0;
            end
            HTRANS <= 1;
        end
    end
end

always @ (negedge CLK) begin
    if((stall) && !take_branch_reg) begin
        inst <= inst;
    end
    else begin
        inst <= HRDATA;
        if(inst[6:0] == JALR) begin
            PC_jalr <= PC_i;
            jalr_jump <= 1;
        end
        else begin
            jalr_jump <= 0;
        end
    end
end

endmodule