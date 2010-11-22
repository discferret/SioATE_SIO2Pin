module SioATE (
	input					MCLK,
	input					SioClk,
	output reg			SioDat,
	input			[9:0]	SioTest,
	output reg			StatusLED
);

localparam	ST_INIT			= 4'd0;
localparam	ST_SEND_ZEROES	= 4'd1;
localparam	ST_SEND_BIT		= 4'd2;

reg	[3:0]	state;
reg	[4:0]	zerocount;
reg	[9:0]	shifter;

always @(posedge SioClk) begin
	case (state)
		ST_INIT: begin
						zerocount	<= 20;
						SioDat		<= 0;
						state			<= ST_SEND_ZEROES;
					end
		ST_SEND_ZEROES: begin
						if (zerocount > 0) begin
							// send 20 zeroes
							zerocount <= zerocount - 5'd1;
							SioDat <= 0;
							state <= ST_SEND_ZEROES;
						end else begin
							// send a '1', then start sending data bits
							SioDat <= 1;
							shifter <= SioTest; // 10'h355;
							zerocount <= 10;
							state <= ST_SEND_BIT;
						end
					end
		ST_SEND_BIT: begin
						if (zerocount > 0) begin
							SioDat <= shifter[9];
							shifter <= {shifter[8:0], 1'b0};
							zerocount <= zerocount - 5'd1;
							state <= ST_SEND_BIT;
						end else begin
							SioDat <= 0;
							zerocount <= 20;
							state <= ST_SEND_ZEROES;
						end
					end
		default: begin
						state <= ST_INIT;
					end
	endcase
end

// status LED blinker
reg [31:0] LEDcounter;
always @(posedge MCLK) begin
	if (LEDcounter == 32'd20_000_000) begin
		LEDcounter <= 32'd0;
	end else begin
		LEDcounter <= LEDcounter + 1;
		StatusLED <= (LEDcounter >= 32'd10_000_000);
	end
end

endmodule
