module bram_wrapper(
	input clk,
	input resetn,
	
	input ram_valid,
	output reg ram_ready,
	input [31:0] ram_addr,
	input [31:0] ram_wdata,
	input [3:0] ram_wstrb,
	output [31:0] ram_rdata
);

always @(posedge clk or negedge resetn) begin
	if(~resetn)
		ram_ready <= 1'b0;
	else
		ram_ready <= ram_valid;
end

bram32_1k  u_bram32_1k(
	.doa(ram_rdata),
	.dia(ram_wdata),
	.addra(ram_addr[11:2]),
	.cea(ram_valid),
	.clka(clk),
	.wea(ram_wstrb & {4{ram_valid}}),
	.rsta(~resetn)
);

endmodule