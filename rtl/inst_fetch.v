module inst_fetch(
    input CLK,
    input reset,
    input stall,
    input take_branch,
    input [63:0] branch_PC,
    input [63:0] take_branch_offset,
    input [63:0] HRDATA,
    output reg [63:0] HADDR,
    output reg [31:0] inst,
    output reg HTRANS,
    output reg [63:0] PC
);

always @ (posedge CLK or negedge reset) begin
    if(!reset) begin
        PC <= 64'b0;
        HADDR <= 64'b0;
        HTRANS <= 1;
    end
    else begin
        if(stall) begin
            PC <= PC;
            HADDR <= HADDR;
            HTRANS <= 1;
        end
        else begin
            if(take_branch) begin
                PC <= branch_PC + take_branch_offset;
                HADDR <= branch_PC + take_branch_offset;
            end
            else begin
                PC <= PC + 4;
                HADDR <= PC + 4;
            end
            HTRANS <= 1;
        end
    end
end

always @ (negedge CLK) begin
    if(stall) begin
        inst <= inst;
    end
    else begin
        inst <= HRDATA;
    end
end

endmodule