module inst_decode(
    input CLK,
    input reset,
    input [31:0] inst,
    input [4:0] wb_rd,
    input [63:0] wb_value,
    input wb_en,
    output reg [4:0] rd,
    output reg [4:0] rs1,
    output reg [4:0] rs2,
    output reg [2:0] funct3,
    output reg [6:0] funct7,
    output reg [19:0] imm20,
    output reg [63:0] op1,
    output reg [63:0] op2,
    output reg write_back,
    output reg imm_flag,
    output reg mem_acc,
    output reg load_flag
);

parameter ALGORITHM = 7'b0110011;
parameter ALGORITHM_IMM = 7'b0010011;
parameter LOAD = 7'b0000011;

reg [63:0] registers[31:0];
integer rst_i;

function [63:0] get_register_value;
input [4:0] idx;
begin
    if(idx == wb_rd && wb_en) begin
        get_register_value = wb_value;
    end
    else begin
        get_register_value = registers[idx];
    end
end
endfunction

always @ (posedge CLK or negedge reset) begin
    if(!reset) begin
        for(rst_i = 0;rst_i<32;rst_i=rst_i+1) begin
            registers[rst_i] <= 64'd0;
        end
    end
    else begin
        if(wb_en) begin
            registers[wb_rd] <= wb_value;
        end
        registers[0] <= 64'd0;
        if(inst[6:0] == ALGORITHM) begin
            rd <= inst[11:7];
            funct3 <= inst[14:12];
            rs1 <= inst[19:15];
            rs2 <= inst[24:20];
            funct7 <= inst[31:25];
            op1 <= get_register_value(inst[19:15]);
            op2 <= get_register_value(inst[24:20]);
            mem_acc <= 0;
            load_flag <= 0;
            write_back <= 1;
            imm_flag <= 0;
        end
        else if(inst[6:0] == ALGORITHM_IMM) begin
            rd <= inst[11:7];
            funct3 <= inst[14:12];
            rs1 <= inst[19:15];
            imm20 <= inst[31:20];
            op1 <= get_register_value(inst[19:15]);
            op2 <= {{(52){inst[31]}},inst[31:20]};
            mem_acc <= 0;
            load_flag <= 0;
            write_back <= 1;
            imm_flag <= 1;
        end
        else if(inst[6:0] == LOAD) begin
            rd <= inst[11:7];
            funct3 <= 3'b000;
            rs1 <= inst[19:15];
            imm20 <= inst[31:20];
            op1 <= get_register_value(inst[19:15]);
            op2 <= {{(52){inst[31]}},inst[31:20]};
            mem_acc <= 1;
            load_flag <= 1;
            write_back <= 1;
            imm_flag <= 1;
        end
    end
end

endmodule