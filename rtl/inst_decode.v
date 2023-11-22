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
parameter 

reg [63:0] registers[31:0];

always @ (posedge CLK) begin
    if(inst[6:0] == ALGORITHM) begin
        rd <= inst[11:7];
        funct3 <= inst[14:12];
        rs1 <= inst[19:15];
        rs2 <= inst[24:20];
        funct7 <= inst[31:25];
        op1 <= registers[inst[19:15]];
        op2 <= registers[inst[24:20]];
    end
    else if(inst[6:0] == ALGORITHM_IMM) begin
        rd <= inst[11:7];
        funct3 <= inst[14:12];
        rs1 <= inst[19:15];
        imm20 <= inst[31:20];
        op1 <= registers[inst[19:15]];
        op2 <= {{(52)inst[31]},inst[31:20]};
    end
end

endmodule