module mem_access(
    input CLK,
    input EN,
    input [4:0] rd_i,
    input [63:0] address,
    input LOAD,
    input [63:0] value,
    input [63:0] HRDATA,
    input [63:0] alu_res,
    input write_back,
    input stall,
    output reg [63:0] HADDR,
    output reg [63:0] HWDATA,
    output reg HWRITE,
    output reg HTRANS,
    output reg [63:0] res,
    output reg [4:0] rd_o,
    output reg mem_write_back_en
);

reg refresh_en = 0;
reg [63:0] tmp_res;

always @ (posedge CLK) begin
    if(EN) begin
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
    rd_o <= rd_i;
    mem_write_back_en <= write_back;
end

always @ (negedge CLK) begin
    if(refresh_en) begin
        res <= HRDATA;
    end
    else begin
        res <= tmp_res;
    end
end

endmodule