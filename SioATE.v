module SioATE (
	input					MCLK,
	input					SioClk,
	input					SioDat,
	output reg	[9:0]	SioTest,
	output reg			StatusLED
);

localparam	ST_INIT			= 4'd0;
localparam	ST_SEND_ZEROES	= 4'd1;
localparam	ST_SEND_BIT		= 4'd2;

reg	[3:0]	state;
reg	[4:0]	zerocount;
reg	[9:0]	shifter;

// data I/O shift register
always @(posedge SioClk) begin
	SioTest <= {SioDat, SioTest[9:1]};
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
