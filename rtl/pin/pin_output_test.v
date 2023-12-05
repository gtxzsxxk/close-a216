module pin_output_test(
	input HRESET,
	input CLK,
	input HWRITE,
	input [31:0] PADDR,
	input [31:0] PWDATA,
	output reg [31:0] PRDATA,
	output PIN_OUT
);

parameter PIN_OUT_ADDR = 32'h4001_4800;

reg [31:0] data_register;
parameter dr_offset = 32'd0;

wire address_validate = PADDR == PIN_OUT_ADDR + dr_offset;

always @ (posedge CLK or negedge HRESET) begin
	if(!HRESET) begin
		data_register <= 0;
	end
	else begin
		if(HWRITE) begin
			if(address_validate) begin
				data_register <= PWDATA;
			end
		end
	end
end

always @ (*) begin
	if(address_validate) begin
		PRDATA <= data_register;
	end
	else begin
		PRDATA <= 32'bz;
	end
end

assign PIN_OUT = data_register[0];

endmodule