module iram(
    input HRESET,
    input HWRITE,
    input [63:0] HADDR,
    input [63:0] HWDATA,
    output reg [63:0] HRDATA
);

parameter RAM_SIZE = 1*1072;
parameter RAM_START = 64'h0002_0000;

reg [7:0] ram[RAM_SIZE-1:0];

integer rst_i;

always @(*) begin
    if(!HRESET) begin
        for(rst_i = 0;rst_i < RAM_SIZE;rst_i = rst_i + 1) begin
            ram[rst_i] <= 0;
        end
    end
    else begin
        if(HADDR >= RAM_START && HADDR <= (RAM_START + RAM_SIZE - 8)) begin
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
        else begin
            HRDATA <= 64'bz;
        end
    end
end

endmodule