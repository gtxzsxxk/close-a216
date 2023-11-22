module mem_access(
    input CLK,
    input EN,
    input [63:0] address,
    input WRITE,
    input [63:0] value,
    input [63:0] HRDATA,
    output reg [63:0] HADDR,
    output reg [63:0] HWDATA,
    output reg HWRITE,
    output reg [63:0] res
);

always @ (posedge CLK) begin
    if(EN) begin
        HWRITE <= WRITE;
        HADDR <= address;
        if(WRITE) begin
            HWDATA <= value;
        end
        res <= HRDATA;
    end
end

endmodule