// Memory Subsystem: MAR + MDR with MDMux + RAM
// - MAR captures address from BusMuxOut when MARin asserted
// - RAM uses MAR[8:0] as address
// - MDR captures either BusMuxOut (Read=0) or RAM data (Read=1) when MDRin asserted
// - RAM read is asynchronous; RAM write is synchronous
//
// Exposes MDR_Q for the datapath bus as BusMuxInMDR.
module Memory (
    input        clock,
    input        clear,

    // Control
    input        MARin,
    input        MDRin,
    input        Read,
    input        Write,

    // Datapath bus connection
    input  [31:0] BusMuxOut,

    // Outputs back to datapath
    output [31:0] BusMuxInMDR,  // MDR contents -> bus input
    output [31:0] MAR_Q,        // optional debug
    output [31:0] RAM_rdata     // optional debug (this is Mdatain)
);

    // MAR register (loads address from bus)
    Register MAR (clear, clock, MARin, BusMuxOut, MAR_Q);

    // RAM
    RAM ram (
        .clk      (clock),
        .clear    (clear),
        .read_en  (Read),
        .write_en (Write),
        .addr     (MAR_Q[8:0]),
        .wdata    (BusMuxInMDR),
        .rdata    (RAM_rdata)
    );

    // MDR (includes MDMux internally)
    MDR mdr (
        .clear(clear),
        .clock(clock),
        .MDRin(MDRin),
        .Read(Read),
        .BusMuxOut(BusMuxOut),
        .Mdatain(RAM_rdata),
        .BusMuxIn_MDR(BusMuxInMDR)
    );

endmodule