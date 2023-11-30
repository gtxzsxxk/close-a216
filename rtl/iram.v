module iram(
    input HWRITE,
    input [63:0] HADDR,
    input [63:0] HWDATA,
    output reg [63:0] HRDATA
);

parameter RAM_SIZE = 256;
parameter RAM_START = 64'h1000;

reg [7:0] ram[RAM_SIZE-1:0];



always @(*) begin
    if(HADDR >= RAM_START && HADDR < (RAM_START + RAM_SIZE - 8)) begin
        if(HWRITE) begin
            ram[HADDR-RAM_START] <= HWDATA[7:0];
            ram[HADDR-RAM_START + 1] <= HWDATA[15:8];
            ram[HADDR-RAM_START + 2] <= HWDATA[23:16];
            ram[HADDR-RAM_START + 3] <= HWDATA[31:24];

            ram[HADDR-RAM_START + 4] <= HWDATA[39:32];
            ram[HADDR-RAM_START + 5] <= HWDATA[47:40];
            ram[HADDR-RAM_START + 6] <= HWDATA[55:48];
            ram[HADDR-RAM_START + 7] <= HWDATA[63:56];
        end
        else begin
            HRDATA <= {
                ram[HADDR-RAM_START + 7],
                ram[HADDR-RAM_START + 6],
                ram[HADDR-RAM_START + 5],
                ram[HADDR-RAM_START + 4],
                ram[HADDR-RAM_START + 3],
                ram[HADDR-RAM_START + 2],
                ram[HADDR-RAM_START + 1],
                ram[HADDR-RAM_START]
            };
        end
    end
    else begin
        HRDATA <= 64'bz;
    end
end

endmodule