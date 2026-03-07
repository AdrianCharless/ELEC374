// select encode .v 

module select_encode ( 

	input [31:0] IR, 
	input Gra, 
	input Grb,
	input Grc, 
	input Rin, 
	input Rout, 
	input BAout, 
	input Cout, 
	
	output [15:0] Rin_out,
	output [15:0] Rout_out	
);

	wire [3:0] Ra = IR[26:23];
   wire [3:0] Rb = IR[22:19];
   wire [3:0] Rc = IR[18:15];
	 
	wire [3:0] reg_select = Gra ? Ra :
                           Grb ? Rb :
                           Grc ? Rc :
                           4'b0000;   // default to 0 if none asserted
									 
	wire [15:0] decoder_out;


	assign decoder_out = (reg_select == 4'd0)  ? 16'b0000000000000001 :
                         (reg_select == 4'd1)  ? 16'b0000000000000010 :
                         (reg_select == 4'd2)  ? 16'b0000000000000100 :
                         (reg_select == 4'd3)  ? 16'b0000000000001000 :
                         (reg_select == 4'd4)  ? 16'b0000000000010000 :
                         (reg_select == 4'd5)  ? 16'b0000000000100000 :
                         (reg_select == 4'd6)  ? 16'b0000000001000000 :
                         (reg_select == 4'd7)  ? 16'b0000000010000000 :
                         (reg_select == 4'd8)  ? 16'b0000000100000000 :
                         (reg_select == 4'd9)  ? 16'b0000001000000000 :
                         (reg_select == 4'd10) ? 16'b0000010000000000 :
                         (reg_select == 4'd11) ? 16'b0000100000000000 :
                         (reg_select == 4'd12) ? 16'b0001000000000000 :
                         (reg_select == 4'd13) ? 16'b0010000000000000 :
                         (reg_select == 4'd14) ? 16'b0100000000000000 :
                         (reg_select == 4'd15) ? 16'b1000000000000000 :
                         16'b0000000000000000;  // default
								 
	assign Rin_out  = decoder_out & {16{Rin}};
   assign Rout_out = decoder_out & {16{Rout | BAout}};

endmodule
