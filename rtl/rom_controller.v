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

reg [31:0] output_shifted;

assign HRDATA = addr_validate ? output_shifted : 32'bz;

always @(*) begin
    case(addr_offset)
        2'd0: output_shifted <= ip_output;
        2'd1: output_shifted <= {8'b0,ip_output[31:8]};
        2'd2: output_shifted <= {16'b0,ip_output[31:16]};
        2'd3: output_shifted <= {24'b0,ip_output[31:24]};
    endcase
end

endmodule