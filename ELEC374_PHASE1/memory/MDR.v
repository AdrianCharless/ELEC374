module MDR(
	input			clear,
    input			clock,

    input			MDRin,
    input			Read,

    input [31:0]	BusMuxOut,
    input [31:0]	Mdatain,	

    output [31:0]	BusMuxIn-MDR
); // all input and output wires in module

wire [31:0] D_to_MDR;	// wire from mux output to register input

MDMux mdmux(		// module_type instance_name (port_connections);
	.BusMuxOut(BusMuxOut),	// take signal BusMuxOut in current module and feed into MDMux port BusMuxOut	
	// .BusMuxOut	= input port of MDMux module
	// (BusMuxOut)	= wire in current module 
	.MDatain(Mdatain),
	.Read(Read),
	.D(D_to_MDR)	// value outputted from MDMux port D, place on wire D_to_MDR
	// .D 			= output port of MDMux
	// (D_to_MDR)	= wire in current module
);

register #(.DATA_WIDTH_IN(32), .DATA_WIDTH_OUT(32), .INIT(0)) mdreg(
	.clear(clear),
	.clock(clock),
	.enable(MDRin),
	.RegIn(D_to_MDR),
	.BusMuxIn(BusMuxIn-MDR)
);

endmodule