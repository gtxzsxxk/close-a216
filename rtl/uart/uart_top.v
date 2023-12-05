module uart_top(
	input HRESET,
	input CLK,
	input HWRITE,
	input [31:0] PADDR,
	input [31:0] PWDATA,
	input PIN_RX,
	output reg [31:0] PRDATA,
	output reg PIN_TX
);

parameter UART_ADDR = 32'h4001_3800;

reg [31:0] status_register;
parameter sr_offset = 32'd0;

reg [31:0] tx_data_register;
reg [31:0] tx_shift_register;
reg [7:0] tx_shift_mask;
reg tx_start_transmit;
reg tx_frame;
reg tx_clear_start;
reg tx_raise_txe;
reg tx_raise_tc;

reg clear_tc_read_sr;

reg [31:0] rx_data_register;
reg [7:0] rx_shift_mask;
parameter dr_offset = 32'd4;

reg [31:0] baudrate_division;
parameter brr_offset = 32'd8;

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
		rx_data_register <= 0;
		baudrate_division <= 32'd434; /* 默认115200 */
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
			else if(PADDR == UART_ADDR + brr_offset) begin
				baudrate_division <= PWDATA;
			end
		end

		if(tx_clear_start) begin
			tx_start_transmit <= 0;
		end

		if(HWRITE && PADDR == UART_ADDR + dr_offset) begin
			/* 写入时清零 */
			status_register <= (status_register & 32'b0111_1111) &
				(clear_tc_read_sr ? (32'b1011_1111) :
				(32'b1111_1111));
		end
		else begin
			if(tx_raise_txe) begin
				tx_data_register <= tx_shift_register;
			end
			status_register <= status_register |
				((tx_raise_txe ? 32'b1000_0000 : 32'b0) |
				(tx_raise_tc ? 32'b0100_0000 : 32'b0));
		end
	end
end

always @ (*) begin
	if(!HRESET) begin
		clear_tc_read_sr <= 0;
	end
	if(PADDR == UART_ADDR + sr_offset) begin
		PRDATA <= status_register;
		clear_tc_read_sr <= 1;
	end
	else if(PADDR == UART_ADDR + dr_offset) begin
		PRDATA <= rx_data_register;
	end
	else if(PADDR == UART_ADDR + baudrate_division) begin
		PRDATA <= baudrate_division;
	end
	else begin
		PRDATA <= 32'bz;
	end
end

always @ (posedge div_clk or negedge HRESET) begin
	if(!HRESET) begin
		PIN_TX <= 1; /* 空闲状态 */
		tx_clear_start <= 0;
		tx_shift_register <= 0;
		tx_shift_mask <= 0;
		tx_raise_txe <= 0;
		tx_raise_tc <= 0;
		tx_frame <= 0;
	end
	else begin
		if(tx_start_transmit) begin
			/* 设置start bit */
			PIN_TX <= 0;
			tx_shift_register <= tx_data_register;
			/* 设置移位状态 */
			tx_shift_mask <= 8'b1111_1111;
			tx_clear_start <= 1;
			tx_raise_txe <= 0;
			tx_raise_tc <= 0;
			tx_frame <= 1;
		end
		else begin
			if(tx_frame) begin
				if(tx_shift_mask!=0) begin
					PIN_TX = tx_shift_register[0];
					tx_shift_register <= {1'b0, tx_shift_register[7:1]};
					tx_shift_mask <= {1'b0, tx_shift_mask[7:1]};
					tx_raise_txe <= 0;
					tx_raise_tc <= 0;
				end
				else begin
					PIN_TX <= 1;
					/* 传输完成，设置寄存器的flag */
					tx_raise_txe <= 1;
					tx_raise_tc <= 1;
					tx_frame <= 0;
				end
			end
			else begin
				tx_raise_txe <= 0;
				tx_raise_tc <= 0;
			end
			tx_clear_start <= 0;
		end
	end
end

endmodule