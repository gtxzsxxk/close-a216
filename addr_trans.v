module addr_trans(input [31:0] addr,
                  output reg [31:0] addr_trans,
                  output reg rom_flag,
                  output reg ram_flag);

always @(addr) begin
    case(addr[31-:8])
        8'b0: begin
            if (addr[23-:4] >= 4'h0 && addr[23-:4]<4'h1) begin
                addr_trans <= addr[31:0];
                rom_flag   <= 1;
                ram_flag   <= 0;
            end
            else if (addr[23-:4]>= 4'h2 && addr[23-:4]<4'ha) begin
                addr_trans <= {8'b0, addr[23-:4] - 4'h2, addr[19:0]};
                rom_flag   <= 0;
                ram_flag   <= 1;
            end
            else begin
                addr_trans <= 32'bz;
                rom_flag   <= 0;
                ram_flag   <= 0;
            end
        end
        default: begin
            addr_trans <= 32'bz;
            rom_flag   <= 0;
            ram_flag   <= 0;
        end
    endcase
end

endmodule
