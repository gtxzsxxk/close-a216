module inst_decode(
    input CLK,
    input reset,
    input [31:0] inst,
    input [4:0] wb_rd,
    input [63:0] wb_value,
    input wb_en,
    input stall,
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
    output reg load_flag,
    output reg stall_raise
);

parameter ALGORITHM = 7'b0110011;
parameter ALGORITHM_IMM = 7'b0010011;
parameter LOAD = 7'b0000011;

reg [31:0] inst_last = 32'h00000013;
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

function [31:0] get_inst;
input [31:0] m_inst;
input stall_flag;
begin
    if(stall_flag) begin
        get_inst = inst_last;
    end
    else begin
        get_inst = m_inst;
    end
end
endfunction

wire [31:0] instruction;

assign instruction = get_inst(inst,stall);

/* judge whether to stall for the last load */
function judge_stall;
input [6:0] last_cmd;
input [4:0] cur_rs1;
input [4:0] cur_rs2;
input imm;
begin
    if(last_cmd == LOAD) begin
        if(imm) begin
            if(cur_rs1 == rd) begin
                judge_stall = 1;
            end
            else begin
                judge_stall = 0;
            end
        end
        else begin
            if(cur_rs1 == rd || cur_rs2 == rd) begin
                judge_stall = 1;
            end
            else begin
                judge_stall = 0;
            end
        end
    end
    else begin
        judge_stall = 0;
    end
end
endfunction

always @ (posedge CLK or negedge reset) begin
    if(!reset) begin
        for(rst_i = 0;rst_i<32;rst_i=rst_i+1) begin
            registers[rst_i] <= 64'd0;
        end
        stall_raise <= 0;
        inst_last <= 32'h00000013;
    end
    else begin
        if(wb_en) begin
            registers[wb_rd] <= wb_value;
        end
        registers[0] <= 64'd0;
        if(instruction[6:0] == ALGORITHM) begin
            rd <= instruction[11:7];
            funct3 <= instruction[14:12];
            rs1 <= instruction[19:15];
            rs2 <= instruction[24:20];
            funct7 <= instruction[31:25];
            op1 <= get_register_value(instruction[19:15]);
            op2 <= get_register_value(instruction[24:20]);
            mem_acc <= 0;
            load_flag <= 0;
            write_back <= 1;
            imm_flag <= 0;
            stall_raise <= judge_stall(inst_last[6:0],
                instruction[19:15], instruction[24:20], 0);
        end
        else if(instruction[6:0] == ALGORITHM_IMM) begin
            rd <= instruction[11:7];
            funct3 <= instruction[14:12];
            rs1 <= instruction[19:15];
            imm20 <= instruction[31:20];
            op1 <= get_register_value(instruction[19:15]);
            op2 <= {{(52){instruction[31]}},instruction[31:20]};
            mem_acc <= 0;
            load_flag <= 0;
            write_back <= 1;
            imm_flag <= 1;
            stall_raise <= judge_stall(inst_last[6:0],
                instruction[19:15], 0, 1);
        end
        else if(instruction[6:0] == LOAD) begin
            rd <= instruction[11:7];
            funct3 <= 3'b000;
            rs1 <= instruction[19:15];
            imm20 <= instruction[31:20];
            op1 <= get_register_value(instruction[19:15]);
            op2 <= {{(52){instruction[31]}},instruction[31:20]};
            mem_acc <= 1;
            load_flag <= 1;
            write_back <= 1;
            imm_flag <= 1;
            stall_raise <= 0;
        end
        inst_last <= instruction;
    end
end

endmodule