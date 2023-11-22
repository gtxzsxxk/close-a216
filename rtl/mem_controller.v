module mem_controller(
    input HCLK,
    input HRESET,
    input HTRANS_1,
    input HTRANS_2,
    input [63:0] HADDR_1,
    input [63:0] HADDR_2,
    input HWRITE_1,
    input HWRITE_2,
    input [63:0] HWDATA_1,
    input [63:0] HWDATA_2,
    output [63:0] PADDR,
    output HWRITE,
    output [63:0] PDATA,
    output reg stall
);

always @ (negedge HRESET) begin
    stall <= 0;
end

always @ (posedge HCLK) begin
    if(HTRANS_1 && HTRANS_2) begin
        PADDR <= HADDR_1;
        HWRITE <= HWRITE_1;
        PDATA <= HWDATA_1;
        stall <= 1;
    end
    else if(HTRANS_1 && !HTRANS_2) begin
        PADDR <= HADDR_1;
        HWRITE <= HWRITE_1;
        PDATA <= HWDATA_1;
        stall <= 0;
    end
    else if(!HTRANS_1 && HTRANS_2) begin
        PADDR <= HADDR_2;
        HWRITE <= HWRITE_2;
        PDATA <= HWDATA_2;
        stall <= 0;
    end
end

endmodule