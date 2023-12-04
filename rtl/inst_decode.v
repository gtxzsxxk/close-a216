module inst_decode(
    input CLK,
    input reset,
    input [31:0] inst,
    input [4:0] wb_rd,
    input [63:0] wb_value,
    input wb_en,
    input stall,
    input [63:0] PC_i,
    input [4:0] alu_rd,
    input [63:0] jalr_forwarding_alu_op1, /* connect with alu res */
    input [4:0] mem_rd,
    input [63:0] jalr_forwarding_mem_op1, /* connect with mem res */
    output reg [4:0] rd,
    output reg [4:0] rs1,
    output reg [4:0] rs2,
    output reg [2:0] funct3,
    output reg [2:0] mem_para,
    output reg [6:0] funct7,
    output reg [19:0] imm20,
    output reg [63:0] op1,
    output reg [63:0] op2,
    output reg write_back,
    output reg imm_flag,
    output reg mem_acc,
    output reg load_flag,
    output reg load_fwd_flag,
    output reg word_inst, /* work on 32bits */
    output reg stall_raise,
    output reg [63:0] branch_offset,
    output reg [63:0] jalr_offset,
    output reg branch_flag,
    output reg [63:0] PC_o,
    output reg [63:0] store_value,
    output reg [4:0] store_reg
);

parameter ARITHMETIC = 7'b0110011;
parameter ARITHMETIC_64 = 7'b0111011;
parameter ARITHMETIC_IMM = 7'b0010011;
parameter ARITHMETIC_IMM_64 = 7'b0011011;
parameter LOAD = 7'b0000011;
parameter BRANCH = 7'b1100011;
parameter STORE = 7'b0100011;
parameter JAL = 7'b1101111;
parameter JALR = 7'b1100111;
parameter LUI = 7'b0110111;
parameter AUIPC = 7'b0010111;

reg [63:0] registers[31:0];

integer rst_i;

function [63:0] get_register_value;
input [4:0] idx;
begin
    if(idx == wb_rd && wb_en && idx != 0) begin
        get_register_value = wb_value;
    end
    else if((inst[6:0] == JALR) && idx == alu_rd) begin
        get_register_value = jalr_forwarding_alu_op1;
    end
    else if(inst[6:0] == JALR && idx == mem_rd) begin
        get_register_value = jalr_forwarding_mem_op1;
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
        get_inst = 32'h00000013;
    end
    else begin
        get_inst = m_inst;
    end
end
endfunction

reg [31:0] instruction = 0;

wire [31:0] inst_two_op = get_inst(inst,stall | judge_stall(neg_inst[6:0],
                inst[19:15], inst[24:20], 0));

wire [31:0] inst_imm = get_inst(inst,stall | judge_stall(neg_inst[6:0],
                inst[19:15], 0, 1));

wire [31:0] inst_load = get_inst(inst,stall | judge_stall(neg_inst[6:0],
                inst[19:15], 0, 1));

wire [63:0] jalr_target_addr = get_register_value(inst[19:15]) +
                    {{(52){inst[31]}},inst[31:20]};


/* judge whether to stall for the last load */
function judge_stall;
input [6:0] last_cmd;
input [4:0] cur_rs1;
input [4:0] cur_rs2;
input imm;
begin
    if(last_cmd == LOAD) begin
        if(imm) begin
            if(cur_rs1 == rd && cur_rs1 != 0) begin
                judge_stall = 1;
            end
            else begin
                judge_stall = 0;
            end
        end
        else begin
            if((cur_rs1 == rd && cur_rs1 != 0) 
                || (cur_rs2 == rd && cur_rs2 != 0)) begin
                judge_stall = 1;
            end
            else begin
                judge_stall = 0;
            end
        end
    end
    else if(inst[6:0] == JALR && rd == cur_rs1) begin
        judge_stall = 1;
    end
    else begin
        judge_stall = 0;
    end
end
endfunction

reg [31:0] inst_reg;
reg [31:0] last_dispatched_inst; /* 上一条成功发射的指令 */
reg [31:0] last_nonop_inst; /* 上一条派遣的非空指令 */
reg [31:0] last_nonop_pc;
reg [1:0] stall_cnt;

/* 前一个指令是load，这一个指令也是load，且发生冲突时，插入两个气泡 */
reg [2:0] load_stall_cnt; 

/* 解决连续两拍stall时的问题 */

reg [2:0] bubble_cnt = 0; /* 统计共有几个nop */

wire [31:0] neg_inst = (!(stall || stall_raise) 
        && stall_cnt >= 1 && bubble_cnt >= 2)
            ? ((last_nonop_inst!=inst_reg && last_nonop_pc != PC_o)
                ? inst_reg : instruction)
            : instruction;

always @ (posedge CLK or negedge reset) begin
    if(!reset) begin
        for(rst_i = 0;rst_i<32;rst_i=rst_i+1) begin
            registers[rst_i] <= 64'd0;
        end
        stall_raise <= 0;
        load_stall_cnt <= 0;
    end
    else begin
        if(wb_en && wb_rd != 0) begin
            registers[wb_rd] <= wb_value;
        end
        registers[0] <= 64'd0;
        registers[3] <= 64'h20200;

        if(stall) begin
            stall_cnt <= stall_cnt + 1;
        end
        else begin
            stall_cnt <= 0;
        end

        if(inst[6:0] == ARITHMETIC || 
            inst[6:0] == BRANCH ||
            inst[6:0] == ARITHMETIC_64 ||
            inst[6:0] == STORE) begin
            stall_raise <= judge_stall(neg_inst[6:0],
                inst[19:15], inst[24:20], 0);
            instruction <= inst_two_op;
        end
        else if(inst[6:0] == ARITHMETIC_IMM ||
            inst[6:0] == ARITHMETIC_IMM_64 ||
            inst[6:0] == JALR) begin
            stall_raise <= judge_stall(neg_inst[6:0],
                inst[19:15], 0, 1);
            instruction <= inst_imm;
            if(inst[6:0] == JALR) begin
                /* immediately compute the address to jump */
                jalr_offset <= {jalr_target_addr[63:1], 1'b0};
            end
        end
        else if(inst[6:0] == LOAD) begin
            if(judge_stall(neg_inst[6:0],
                inst[19:15], 0, 1) && load_stall_cnt == 0) begin
                load_stall_cnt <= 1;
                stall_raise <= 1;
                instruction <= 32'h00000013;
            end

            if(load_stall_cnt > 0) begin
                load_stall_cnt <= load_stall_cnt - 1;
                stall_raise <= 1;
                instruction <= 32'h00000013;
            end
            else begin
                stall_raise <= judge_stall(neg_inst[6:0],
                    inst[19:15], 0, 1);
                instruction <= inst_load;
            end
        end
        else if(inst[6:0] == JAL ||
                inst[6:0] == LUI ||
                inst[6:0] == AUIPC) begin
            stall_raise <= 0;
            instruction <= inst_load;
        end
        else begin
            instruction <= 32'h00000013;
        end
    end

    if(last_dispatched_inst[6:0] == LOAD) begin
        load_fwd_flag <= 1;
    end
    else begin
        load_fwd_flag <= 0;
    end

    if(neg_inst != 32'h00000013) begin
        last_nonop_inst <= neg_inst;
        last_nonop_pc <= PC_o;
    end

    PC_o <= PC_i;
    inst_reg <= inst;
end

always @ (negedge CLK) begin
    if(instruction == 32'h00000013) begin
        bubble_cnt <= bubble_cnt + 1;
    end
    else begin
        bubble_cnt <= 0;
    end
    last_dispatched_inst <= neg_inst;
    if(neg_inst[6:0] == ARITHMETIC ||
        neg_inst[6:0] == ARITHMETIC_64) begin
        rd <= neg_inst[11:7];
        funct3 <= neg_inst[14:12];
        rs1 <= neg_inst[19:15];
        rs2 <= neg_inst[24:20];
        funct7 <= neg_inst[31:25];
        op1 <= get_register_value(neg_inst[19:15]);
        op2 <= get_register_value(neg_inst[24:20]);
        mem_acc <= 0;
        load_flag <= 0;
        write_back <= 1;
        imm_flag <= 0;
        branch_flag <= 0;
        word_inst <= neg_inst[6:0] == ARITHMETIC_64;
        mem_para <= 0;
        store_reg <= 0;
    end
    else if(neg_inst[6:0] == ARITHMETIC_IMM ||
        neg_inst[6:0] == ARITHMETIC_IMM_64) begin
        rd <= neg_inst[11:7];
        funct3 <= neg_inst[14:12];
        rs1 <= neg_inst[19:15];
        /* set rs1 rs2 to avoid forwarding unit */
        rs2 <= 0;
        imm20 <= neg_inst[31:20];
        op1 <= get_register_value(neg_inst[19:15]);
        op2 <= {{(52){neg_inst[31]}},neg_inst[31:20]};
        mem_acc <= 0;
        load_flag <= 0;
        write_back <= 1;
        imm_flag <= 1;
        branch_flag <= 0;
        word_inst <= neg_inst[6:0] == ARITHMETIC_IMM_64;
        mem_para <= 0;
        store_reg <= 0;
    end
    else if(neg_inst[6:0] == LOAD) begin
        rd <= neg_inst[11:7];
        /* let the alu calculate the address. 
         * Here funct3 should be add */
        funct3 <= 3'b000;
        mem_para <= neg_inst[14:12];
        rs1 <= neg_inst[19:15];
        /* set rs1 rs2 to avoid forwarding unit */
        rs2 <= 0;
        imm20 <= neg_inst[31:20];
        op1 <= get_register_value(neg_inst[19:15]);
        op2 <= {{(52){neg_inst[31]}},neg_inst[31:20]};
        mem_acc <= 1;
        load_flag <= 1;
        write_back <= 1;
        imm_flag <= 1;
        branch_flag <= 0;
        word_inst <= 0;
        store_reg <= 0;
    end
    else if(neg_inst[6:0] == STORE) begin
        store_value <= get_register_value(neg_inst[24:20]);
        store_reg <= neg_inst[24:20];
        /* let the alu calculate the address. 
         * Here funct3 should be add */
        funct3 <= 3'b000;
        mem_para <= neg_inst[14:12];
        /* avoid forwarding */
        rd <= 0;
        rs1 <= neg_inst[19:15];
        rs2 <= neg_inst[24:20];
        op1 <= get_register_value(neg_inst[19:15]);
        op2 <= {{(52){neg_inst[31]}},neg_inst[31:25],neg_inst[11:7]};
        mem_acc <= 1;
        load_flag <= 0;
        /* above EN and !LOAD is STORE */
        write_back <= 0;
        imm_flag <= 1;
        branch_flag <= 0;
        word_inst <= 0;
    end
    else if(neg_inst[6:0] == BRANCH) begin
        branch_offset <= {{(51){neg_inst[31]}},neg_inst[31],
            neg_inst[7],neg_inst[30:25],neg_inst[11:8],1'b0};
        funct3 <= neg_inst[14:12];
        /* avoid forwarding */
        rd <= 0;
        rs1 <= neg_inst[19:15];
        rs2 <= neg_inst[24:20];
        op1 <= get_register_value(neg_inst[19:15]);
        op2 <= get_register_value(neg_inst[24:20]);
        mem_acc <= 0;
        load_flag <= 0;
        write_back <= 0;
        imm_flag <= 0;
        branch_flag <= 1;
        word_inst <= 0;
        mem_para <= 0;
        store_reg <= 0;
    end
    else if(neg_inst[6:0] == JAL) begin
        rd <= neg_inst[11:7];
        /* let the alu calculate the address. 
         * Here funct3 should be add */
        funct3 <= 3'b000;
        /* use alu to calc rd */
        op1 <= PC_o;
        op2 <= 64'h4;
        /* Here the decoder only cares about write back the rd
         * jump will be impl in inst fetch
         */

        /* set rs1 rs2 to avoid forwarding unit */
        rs1 <= 0;
        rs2 <= 0;

        mem_acc <= 0;
        load_flag <= 0;
        write_back <= 1;
        imm_flag <= 0;
        branch_flag <= 0;
        word_inst <= 0;
        mem_para <= 0;
        store_reg <= 0;
    end
    else if(neg_inst[6:0] == JALR) begin
        rd <= neg_inst[11:7];
        /* let the alu calculate the PC+4 address. 
         * Here funct3 should be add */
        funct3 <= 3'b000;
        op1 <= PC_o;
        op2 <= 64'h4;

        /* set rs1 rs2 to avoid forwarding unit */
        rs1 <= 0;
        rs2 <= 0;

        mem_acc <= 0;
        load_flag <= 0;
        write_back <= 1;
        imm_flag <= 0;
        branch_flag <= 0;
        word_inst <= 0;
        store_reg <= 0;
    end
    else if(neg_inst[6:0] == LUI ||
            neg_inst[6:0] == AUIPC) begin
        rd <= neg_inst[11:7];
        /* let the alu calculate the address. 
         * Here funct3 should be add */
        funct3 <= 3'b000;
        /* set rs1 rs2 to avoid forwarding unit */
        rs1 <= 0;
        rs2 <= 0;
        op1 <= {{(32){neg_inst[31]}},neg_inst[31:12],12'b0};
        op2 <= neg_inst[6:0] == AUIPC ? PC_o : 0;
        mem_acc <= 0;
        load_flag <= 0;
        write_back <= 1;
        imm_flag <= 0;
        branch_flag <= 0;
        word_inst <= 0;
        store_reg <= 0;
    end
    else begin
        funct3 <= 0;
        rs1 <= 0;
        rs2 <= 0;
        op1 <= 0;
        op2 <= 0;
        mem_acc <= 0;
        load_flag <= 0;
        write_back <= 0;
        imm_flag <= 0;
        branch_flag <= 0;
        word_inst <= 0;
        mem_para <= 0;
        store_reg <= 0;
    end
end

endmodule