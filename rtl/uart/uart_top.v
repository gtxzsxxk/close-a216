module uart_top(
	input HRESET,
	input CLK,
	input HWRITE,
	input [64:0] PADDR,
	input [63:0] PWDATA,
	input PIN_RX,
	output reg [64:0] PRDATA,
	output reg PIN_TX
);

parameter UART_ADDR = 64'h4001_3800;

reg [63:0] status_register;
parameter sr_offset = 64'h0;

reg [63:0] tx_data_register;
reg [7:0] tx_shift_mask;
reg tx_start_transmit;
reg tx_clear_start;
reg tx_raise_txe;
reg tx_raise_tc;

reg [63:0] rx_data_register;
reg [7:0] rx_shift_mask;
parameter dr_offset = 64'h8;

reg [63:0] baudrate_division;
parameter dr_offset = 64'h16;

wire div_clk;

uart_clk_divider u_clk_div(
	.HRESET(HRESET),
	.CLK(CLK),
	.baudrate_division(baudrate_division),
	.div_clk(div_clk)
);

always @ (posedge CLK or negedge HRESET) begin
	if(!HRESET) begin
		status_register <= 0;
		tx_data_register <= 0;
		tx_start_transmit <= 0;
		tx_clear_start <= 0;
		rx_data_register <= 0;
		baudrate_division <= 64'd434; /* 默认115200 */
		PIN_TX <= 1; /* 空闲状态 */
	end
	else begin
		if(HWRITE) begin
			if(PADDR == UART_ADDR + sr_offset) begin
				status_register <= PWDATA;
			end
			else if(PADDR == UART_ADDR + dr_offset) begin
				tx_data_register <= PWDATA;
				/* 写入数据，自动发送 */
				tx_start_transmit <= 1;
			end
			else if(PADDR == UART_ADDR + baudrate_division) begin
				baudrate_division <= PWDATA;
			end
		end

		if(tx_clear_start) begin
			tx_start_transmit <= 0;
		end
		if(tx_raise_txe) begin
			status_register <= status_register | 64'b1000_0000;
		end
		if(tx_raise_tc) begin
			status_register <= status_register | 64'b0100_0000;
		end
	end
end

always @ (*) begin
	if(PADDR == UART_ADDR + sr_offset) begin
		PRDATA <= status_register;
	end
	else if(PADDR == UART_ADDR + dr_offset) begin
		PRDATA <= rx_data_register;
	end
	else if(PADDR == UART_ADDR + baudrate_division) begin
		baudrate_division <= PWDATA;
	end
	else begin
		PRDATA <= 64'bz;
	end
end

always @ (posedge div_clk) begin
	if(tx_start_transmit) begin
		/* 设置start bit */
		PIN_TX <= 0;
		/* 设置移位状态 */
		tx_shift_mask <= 8'b1111_1111;
		tx_clear_start <= 1;
		tx_raise_txe <= 0;
		tx_raise_tc <= 0;
	end
	else begin
		if(tx_shift_mask!=0) begin
			PIN_TX = tx_data_register[0];
			tx_data_register <= {1'b0, tx_data_register[7:1]};
			tx_raise_txe <= 0;
			tx_raise_tc <= 0;
		end
		else begin
			PIN_TX <= 1;
			/* 传输完成，设置寄存器的flag */
			tx_raise_txe <= 1;
			tx_raise_tc <= 1;
		end
		tx_clear_start <= 0;
	end
end

endmodule