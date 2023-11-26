module write_back(
    input EN,
    input stall,
    input [4:0] rd,
    input [63:0] value,
    output [4:0] wb_rd,
    output [63:0] wb_value,
    output wb_en
);

assign wb_rd = stall ? 0 : rd;
assign wb_value = stall ? 0 : value;
assign wb_en = stall ? 0 : EN;

endmodule