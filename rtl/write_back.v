module write_back(
    input CLK,
    input EN,
    input [4:0] rd,
    input [63:0] value,
    output reg [4:0] wb_rd,
    output reg [63:0] wb_value,
    output reg wb_en
);

always @ (posedge CLK) begin
    wb_rd <= rd;
    wb_value <= value;
    wb_en <= EN;
end

endmodule