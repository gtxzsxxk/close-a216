module mem_controller(
    input HTRANS_1,
    input HTRANS_2,
    input HRESET,
    input [31:0] HADDR_1,
    input [31:0] HADDR_2,
    input HWRITE_1,
    input HWRITE_2,
    input [31:0] HWDATA_1,
    input [31:0] HWDATA_2,
    output reg [31:0] PADDR,
    output reg HWRITE,
    output reg [31:0] PDATA,
    output reg stall,
    output reg HRESET_o
);

always @ (*) begin
    if(HTRANS_1 && HTRANS_2) begin
        PADDR <= HADDR_1;
        HWRITE <= HWRITE_1;
        PDATA <= HWDATA_1;
    end
    else if(HTRANS_1 && !HTRANS_2) begin
        PADDR <= HADDR_1;
        HWRITE <= HWRITE_1;
        PDATA <= HWDATA_1;
    end
    else if(!HTRANS_1 && HTRANS_2) begin
        PADDR <= HADDR_2;
        HWRITE <= HWRITE_2;
        PDATA <= HWDATA_2;
    end
    else begin
        PADDR <= 32'bz;
        HWRITE <= 32'bz;
        PDATA <= 32'bz;
    end
    stall <= HTRANS_1 & HTRANS_2 & HRESET;
    HRESET_o <= HRESET;
end

endmodule