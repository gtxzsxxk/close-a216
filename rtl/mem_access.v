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

always @ (posedge CLK) begin
    if(stall) begin
        res <= 0;
        HTRANS <= 0;
        rd_o <= 0;
        mem_write_back_en <= 0;
    end
    else begin
        if(EN) begin
            HWRITE <= ~LOAD;
            HADDR <= address;
            if(!LOAD) begin
                HWDATA <= value;
            end
            res <= HRDATA;
            HTRANS <= 1;
        end 
        else begin
            res <= alu_res;
            HTRANS <= 0;
        end
        rd_o <= rd_i;
        mem_write_back_en <= write_back;
    end
end

endmodule