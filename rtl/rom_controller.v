module rom_controller(
    input CLK,
    input clk_bin_div,
    input [31:0] HADDR,
    output [31:0] HRDATA
);

/* TODO: rename this as controller */

parameter ROM_SIZE = 20*1024;
parameter ROM_START = 32'h0;

wire [31:0] addr_rela = HADDR-ROM_START;

/* 右移两位 */
wire [11:0] addr_translation = {2'b0, addr_rela[11:2]};

wire [1:0] addr_offset = addr_rela[1:0];

wire addr_validate = HADDR >= ROM_START && HADDR <= (ROM_START + ROM_SIZE - 4);

wire [31:0] ip_output;

rom_ip ro_i(
    .address(addr_translation),
    .clock(~CLK),
    .q(ip_output)
);

wire [31:0] output_shifted = ip_output >> addr_offset;

assign HRDATA = addr_validate ? output_shifted : 32'bz;

endmodule