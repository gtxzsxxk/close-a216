module iram(
    input HCLK,
    input HRESET,
    input [63:0] HADDR,
    input [1:0] HTRANS,
    input [63:0] HWDATA,
    input HWRITE,
    output reg [63:0] HRDATA
);

parameter ROM_SIZE = 256;
parameter ROM_START = 64'hff;

reg [7:0] rom[ROM_SIZE-1:0];

integer rst_i;

always @(posedge HCLK or negedge HRESET) begin
    if (HRESET==0) begin
        for(rst_i=0;rst_i<ROM_SIZE;rst_i=rst_i+1) begin
            rom[rst_i] <= 8'b0;
        end
    end
    else begin
        if(HADDR >= ROM_START && HADDR < (ROM_START + ROM_SIZE)) begin
            if(HWRITE) begin
                rom[HADDR-ROM_START] <= HWDATA[7:0];
            end
            else begin
                HRDATA <= rom[HADDR-ROM_START];
            end
        end
    end
end

endmodule