module SioATE (
	input					SioClk,
	output reg			SioDat,
	input			[9:0]	SioTest
);

localparam	ST_INIT			= 4'd0;
localparam	ST_SEND_ZEROES	= 4'd1;
localparam	ST_SEND_ONE		= 4'd2;
localparam	ST_SEND_BIT		= 4'd3;

reg	[3:0]	state;
reg	[4:0]	zerocount;
reg	[9:0]	shifter;

always @(posedge SioClk) begin
	case (state)
		ST_INIT: begin
						zerocount	<= 19;
						SioDat		<= 0;
						state			<= ST_SEND_ZEROES;
					end
		ST_SEND_ZEROES: begin
						if (zerocount > 0) begin
							zerocount <= zerocount - 5'd1;
							state <= ST_SEND_ZEROES;
						end else begin
							state <= ST_SEND_ONE;
						end
					end
		ST_SEND_ONE: begin
						SioDat <= 1;
						shifter <= SioTest;
						state <= ST_SEND_BIT;
						zerocount <= 10;
					end
		ST_SEND_BIT: begin
						if (zerocount > 0) begin
							SioDat <= shifter[0];
							shifter <= {1'b0, shifter[9:1]};
							zerocount <= zerocount - 5'd1;
						end else begin
							zerocount <= 20;
							SioDat <= 0;
							state <= ST_SEND_ZEROES;
						end
					end
		default: begin
						state <= ST_INIT;
					end
	endcase
end

endmodule
