module inst_fetch(
    input CLK,
    input reset,
    input [63:0] HRDATA,
    output [63:0] HADDR,
    output HWRITE,
    output reg [63:0] inst
);

reg [63:0] PC;

always @ (posedge CLK or negedge reset) begin
    if(!reset) begin
        PC <= 64'b0;
    end
    else begin
        inst <= HRDATA;
        PC <= PC + 4;
    end
end

endmodule