module inst_decode(
    input CLK,
    input [63:0] inst,
    output reg [4:0] rd,
    output reg [4:0] rs1,
    output reg [4:0] rs2,
    output reg [2:0] funct3,
    output reg [6:0] funct7,
    output reg [19:0] imm20,
    output reg [63:0] op1,
    output reg [63:0] op2,
    output reg [63:0] wb
);

parameter ALGORITHM = 7'b0110011;
parameter ALGORITHM_IMM = 7'0010011;

always @ (posedge CLK) begin
    if(inst[6:0]==ALGORITHM) begin
        rd <= inst[6:0];
    end
end

endmodule