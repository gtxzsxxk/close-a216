module irom(
    input [63:0] HADDR,
    input [63:0] HWDATA,
    output reg [63:0] HRDATA
);

parameter ROM_SIZE = 20*1024;
parameter ROM_START = 64'h0;

reg [7:0] rom[ROM_SIZE-1:0];

integer rst_i;

always @(*) begin
    if(HADDR >= ROM_START && HADDR < (ROM_START + ROM_SIZE - 8)) begin
        HRDATA <= {
            rom[HADDR-ROM_START + 7],
            rom[HADDR-ROM_START + 6],
            rom[HADDR-ROM_START + 5],
            rom[HADDR-ROM_START + 4],
            rom[HADDR-ROM_START + 3],
            rom[HADDR-ROM_START + 2],
            rom[HADDR-ROM_START + 1],
            rom[HADDR-ROM_START]
        };
    end
    else begin
        HRDATA <= 64'bz;
    end
end

endmodule