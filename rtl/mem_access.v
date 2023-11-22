module mem_access(
    input CLK,
    input [63:0] address,
    input WRITE,
    input [63:0] value,
    output [63:0] res
);

always @ (posedge CLK) begin
    if(WRITE) begin
    end
    else begin
        
    end
end

endmodule