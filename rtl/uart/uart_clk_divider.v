module uart_clk_divider(
	input HRESET,
	input CLK,
	input [31:0] baudrate_division,
	output reg div_clk
);

reg [31:0] div_compare;

always @ (posedge CLK or negedge HRESET) begin
	if(!HRESET) begin
		div_clk <= 0;
		div_compare <= 0;
	end
	else begin
		if(div_compare >= baudrate_division) begin
			div_compare <= 0;
			div_clk <= ~ div_clk;
		end
		else begin
			div_compare <= div_compare + 1;
		end
	end
end

endmodule