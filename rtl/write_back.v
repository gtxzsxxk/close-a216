module write_back(
    input EN,
    input [4:0] rd,
    input [31:0] value,
    output [4:0] wb_rd,
    output [31:0] wb_value,
    output wb_en
);

assign wb_rd = rd;
assign wb_value = value;
assign wb_en = EN;

endmodule