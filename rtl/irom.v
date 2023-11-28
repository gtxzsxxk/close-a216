module irom(
    input [63:0] HADDR,
    input [63:0] HWDATA,
    output reg [63:0] HRDATA
);

parameter ROM_SIZE = 256;
parameter ROM_START = 64'h0;

reg [7:0] rom[ROM_SIZE-1:0];

integer rst_i;

always @(*) begin
    for(rst_i=16;rst_i<ROM_SIZE;rst_i=rst_i+1) begin
        rom[rst_i] <= rst_i;
    end

    /* add x2,x2,x1 */
    rom[15] = 8'h00;
    rom[14] = 8'h11;
    rom[13] = 8'h01;
    rom[12] = 8'h33;

    /* addi x2,x1,1 */
    rom[11] = 8'h00;
    rom[10] = 8'h10;
    rom[9] = 8'h81;
    rom[8] = 8'h13;

    /* addi x1,x1,1 */
    rom[7] = 8'h00;
    rom[6] = 8'h10;
    rom[5] = 8'h80;
    rom[4] = 8'h93;

    /* ld x1,24(x0) */
    rom[3] = 8'h01;
    rom[2] = 8'h80;
    rom[1] = 8'h30;
    rom[0] = 8'h83;

    // /* addi x3,x3,1 */
    // rom[15] = 8'h00;
    // rom[14] = 8'h11;
    // rom[13] = 8'h81;
    // rom[12] = 8'h93;

    // /* add x3,x1,x2 */
    // rom[11] = 8'h00;
    // rom[10] = 8'h20;
    // rom[9] = 8'h81;
    // rom[8] = 8'hb3;

    // /* addi x2,x0,3 */
    // rom[7] = 8'h00;
    // rom[6] = 8'h30;
    // rom[5] = 8'h01;
    // rom[4] = 8'h13;

    // /* addi x1,x0,4 */
    // rom[3] = 8'h00;
    // rom[2] = 8'h40;
    // rom[1] = 8'h00;
    // rom[0] = 8'h93;
    if(HADDR >= ROM_START && HADDR < (ROM_START + ROM_SIZE - 4)) begin
        HRDATA <= {32'd0,
            rom[HADDR-ROM_START + 3],
            rom[HADDR-ROM_START + 2],
            rom[HADDR-ROM_START + 1],
            rom[HADDR-ROM_START]
            };
    end
end

endmodule