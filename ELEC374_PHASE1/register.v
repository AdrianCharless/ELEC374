module register #(parameter DATA_WIDTH_IN = 32, DATA_WIDTH_OUT = 32, INIT = 0)(
// parameters are just variables you can define so that you dont have to
// keep manually change the number for EVERY instance
	input						clear, clock, enable, 
	input [DATA_WIDTH_IN-1:0] 	RegIn,
	output [DATA_WIDTH_OUT-1:0]	BusMuxIn
);
reg [DATA_WIDTH_IN-1:0]q;
initial q = INIT;
// "q" is internal storage element that models the flip flops in MDR to hold stored value
// needed because MDRReg remembers that stored value that exists between clock cycles
// that stored value can only change on positive clock edge

always @ (posedge clock) begin 
	if (clear) begin
		q <= {DATA_WIDTH_IN{1'b0}};
	end
	else if (enable) begin
		q <= RegIn;
	end
end

assign BusMuxIn = q[DATA_WIDTH_OUT-1:0];

endmodule