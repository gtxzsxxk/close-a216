module alu(
    input CLK,
    input imm,
    input [63:0] op1,
    input [63:0] op2,
    input [2:0] funct3,
    input [6:0] funct7
    output reg [63:0] res
);

wire [5:0] shift;

assign shift = op2[5:0];

always @ (posedge CLK) begin
    if(funct3 == 3'b000) begin
    /* ADD SUB */
        if(imm) begin
            res <= op1 + op2;
        end
        else begin
            if(funct7 == 7'b0100000) begin
                res <= op1 - op2;
            end
            else begin
                res <= op1 + op2;
            end
        end
    end
    else if(funct3 == 3'b001) begin
    /* SLL */
        res <= op1 << shift;
    end
    else if(funct3 == 3'b010) begin
    /* SLT */
        res <= op1 << shift;
    end

end

endmodule