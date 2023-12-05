module ram_controller(
    input CLK,
    input clk_bin_div,
    input HWRITE,
    input [31:0] HADDR,
    input [31:0] HWDATA,
    output [31:0] HRDATA
);

parameter RAM_SIZE = 8*1024;
parameter RAM_START = 32'h0002_0000;

/* TODO: fix the addressing problem */

wire [31:0] addr_rela = HADDR-RAM_START;

/* 右移两位 */
wire [10:0] addr_translation = {2'b0, addr_rela[10:2]};

wire [1:0] addr_offset = addr_rela[1:0];

wire addr_validate = HADDR >= RAM_START && HADDR <= (RAM_START + RAM_SIZE - 4);

wire [31:0] ip_output;

ram_ip r_i(
    .address(addr_translation),
    .clock(~CLK),
    .data(HWDATA),
    .wren(!clk_bin_div & HWRITE & addr_validate),
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