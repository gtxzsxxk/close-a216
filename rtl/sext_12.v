module sext_12(
    input [11:0] imm,
    output [31:0] out
);

assign out = {{(52)imm[11]},imm};

endmodule