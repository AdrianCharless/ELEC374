// SHRA
`timescale 1ns/10ps
module datapath_tb; 
 reg PCout, ZLOout, MDRout, R0out, R4out; // add any other signals to see in your simulation
 reg MARin, Zin, PCin, MDRin, IRin, Yin; 
 reg IncPC, Read, SHRA, R7in, R0out, R4out;
 reg Clock;
 reg [31:0] Mdatain; 
 parameter Default = 4’b0000, Reg_load1a = 4’b0001, Reg_load1b = 4’b0010, Reg_load2a = 4’b0011, 
 Reg_load2b = 4’b0100, Reg_load3a = 4’b0101, Reg_load3b = 4’b0110, T0 = 4’b0111, 
 T1 = 4’b1000, T2 = 4’b1001, T3 = 4’b1010, T4 = 4’b1011, T5 = 4’b1100;
 reg [3:0] Present_state = Default;
Datapath DUT(PCout, Zlowout, MDRout, R0out, R4out, MARin, Zin, PCin, MDRin, IRin, Yin, IncPC, Read, SHRA, R7in, 
R0in, R4in, Clock, Mdatain);
// add test logic here
initial 
 begin
 Clock = 0;
 forever #10 Clock = ~ Clock;
end
always @(posedge Clock) // finite state machine; if clock rising-edge
 begin
 case (Present_state)
Default : Present_state = Reg_load1a;
Reg_load1a : Present_state = Reg_load1b;
Reg_load1b : Present_state = Reg_load2a;
Reg_load2a : Present_state = Reg_load2b;
Reg_load2b : Present_state = Reg_load3a;
Reg_load3a : Present_state = Reg_load3b;
Reg_load3b : Present_state = T0;
T0 : Present_state = T1;
T1 : Present_state = T2;
T2 : Present_state = T3;
T3 : Present_state = T4;
T4 : Present_state = T5;
 endcase
 end
 
always @(Present_state) // do the required job in each state
 begin
 case (Present_state) // assert the required signals in each clock cycle
Default: begin
PCout <= 0; ZLOout <= 0; MDRout <= 0; // initialize the signals
 R0out <= 0; R4out <= 0; MARin <= 0; Zin <= 0; 
 PCin <=0; MDRin <= 0; IRin <= 0; Yin <= 0; 
 IncPC <= 0; Read <= 0; SHRA <= 0;
 R7in <= 0; R0in <= 0; R4in <= 0; Mdatain <= 32’h00000000;
end
Reg_load1a: begin 
Mdatain <= 32’h00000034;
Read = 0; MDRin = 0; // the first zero is there for completeness
Read <= 1; MDRin <= 1; // Took out #15 for '1', as it may not be needed
#15 Read <= 0; MDRin <= 0; // for your current implementation
end
 Reg_load1b: begin
 MDRout <= 1; R0in <= 1; 
 #15 MDRout <= 0; R0in <= 0; // initialize R0 with the value 0x34 
end
Reg_load2a: begin 
Mdatain <= 32’h00000045;
Read <= 1; MDRin <= 1; 
#15 Read <= 0; MDRin <= 0; 
end
 Reg_load2b: begin
 MDRout <= 1; R4in <= 1; 
 #15 MDRout <= 0; R4in <= 0; // initialize R4 with the value 0x45 
end
Reg_load3a: begin 
Mdatain <= 32’h00000067;
Read <= 1; MDRin <= 1; 
#15 Read <= 0; MDRin <= 0;
end
 Reg_load3b: begin
 MDRout <= 1; R7in <= 1; 
 #15 MDRout <= 0; R7in <= 0; // initialize R7 with the value 0x67 
end
T0: begin // see if you need to de-assert these signals
PCout <= 1; MARin <= 1; IncPC <= 1; Zin <= 1;
end
T1: begin
ZLOout <= 1; PCin <= 1; Read <= 1; MDRin <= 1;
Mdatain <= 32’h2B820000; // opcode for “SHRA R7, R0, R4”
// 0010 1011 1000 0010 0... OPCODE RA RB RC...
end
T2: begin
MDRout <= 1; IRin <= 1; 
10
end
T3: begin
R0out <= 1; Yin <= 1; 
end
T4: begin
R4out <= 1; SHRA <= 1; Zin <= 1; 
end
T5: begin
ZLOout <= 1; R7in <= 1; 
end
 endcase
 end
endmodule






// ROL
`timescale 1ns/10ps
module datapath_tb; 
 reg PCout, ZLOout, MDRout, R0out, R4out; // add any other signals to see in your simulation
 reg MARin, Zin, PCin, MDRin, IRin, Yin; 
 reg IncPC, Read, ROL, R7in, R0out, R4out;
 reg Clock;
 reg [31:0] Mdatain; 
 parameter Default = 4’b0000, Reg_load1a = 4’b0001, Reg_load1b = 4’b0010, Reg_load2a = 4’b0011, 
 Reg_load2b = 4’b0100, Reg_load3a = 4’b0101, Reg_load3b = 4’b0110, T0 = 4’b0111, 
 T1 = 4’b1000, T2 = 4’b1001, T3 = 4’b1010, T4 = 4’b1011, T5 = 4’b1100;
 reg [3:0] Present_state = Default;
Datapath DUT(PCout, Zlowout, MDRout, R0out, R4out, MARin, Zin, PCin, MDRin, IRin, Yin, IncPC, Read, ROL, R7in, 
R0in, R4in, Clock, Mdatain);
// add test logic here
initial 
 begin
 Clock = 0;
 forever #10 Clock = ~ Clock;
end
always @(posedge Clock) // finite state machine; if clock rising-edge
 begin
 case (Present_state)
Default : Present_state = Reg_load1a;
Reg_load1a : Present_state = Reg_load1b;
Reg_load1b : Present_state = Reg_load2a;
Reg_load2a : Present_state = Reg_load2b;
Reg_load2b : Present_state = Reg_load3a;
Reg_load3a : Present_state = Reg_load3b;
Reg_load3b : Present_state = T0;
T0 : Present_state = T1;
T1 : Present_state = T2;
T2 : Present_state = T3;
T3 : Present_state = T4;
T4 : Present_state = T5;
 endcase
 end
 
always @(Present_state) // do the required job in each state
 begin
 case (Present_state) // assert the required signals in each clock cycle
Default: begin
PCout <= 0; ZLOout <= 0; MDRout <= 0; // initialize the signals
 R0out <= 0; R4out <= 0; MARin <= 0; Zin <= 0; 
 PCin <=0; MDRin <= 0; IRin <= 0; Yin <= 0; 
 IncPC <= 0; Read <= 0; ROL <= 0;
 R7in <= 0; R0in <= 0; R4in <= 0; Mdatain <= 32’h00000000;
end
Reg_load1a: begin 
Mdatain <= 32’h00000034;
Read = 0; MDRin = 0; // the first zero is there for completeness
Read <= 1; MDRin <= 1; // Took out #15 for '1', as it may not be needed
#15 Read <= 0; MDRin <= 0; // for your current implementation
end
 Reg_load1b: begin
 MDRout <= 1; R0in <= 1; 
 #15 MDRout <= 0; R0in <= 0; // initialize R0 with the value 0x34 
end
Reg_load2a: begin 
Mdatain <= 32’h00000045;
Read <= 1; MDRin <= 1; 
#15 Read <= 0; MDRin <= 0; 
end
 Reg_load2b: begin
 MDRout <= 1; R4in <= 1; 
 #15 MDRout <= 0; R4in <= 0; // initialize R4 with the value 0x45 
end
Reg_load3a: begin 
Mdatain <= 32’h00000067;
Read <= 1; MDRin <= 1; 
#15 Read <= 0; MDRin <= 0;
end
 Reg_load3b: begin
 MDRout <= 1; R7in <= 1; 
 #15 MDRout <= 0; R7in <= 0; // initialize R7 with the value 0x67 
end
T0: begin // see if you need to de-assert these signals
PCout <= 1; MARin <= 1; IncPC <= 1; Zin <= 1;
end
T1: begin
ZLOout <= 1; PCin <= 1; Read <= 1; MDRin <= 1;
Mdatain <= 32’h43820000; // opcode for “ROL R7, R0, R4”
// 0100 0011 1000 0010 0... OPCODE RA RB RC...
end
T2: begin
MDRout <= 1; IRin <= 1; 
10
end
T3: begin
R0out <= 1; Yin <= 1; 
end
T4: begin
R4out <= 1; ROL <= 1; Zin <= 1; 
end
T5: begin
ZLOout <= 1; R7in <= 1; 
end
 endcase
 end
endmodule






// MUL
`timescale 1ns/10ps
module datapath_tb; 
 reg PCout, ZLOout, MDRout, R3out, R1out; // add any other signals to see in your simulation
 reg MARin, Zin, PCin, MDRin, IRin, Yin; 
 reg IncPC, Read, MUL, ZHIout, LOin, HIin;
 reg Clock;
 reg [31:0] Mdatain; 
 parameter Default = 4’b0000, Reg_load1a = 4’b0001, Reg_load1b = 4’b0010, Reg_load2a = 4’b0011, 
 Reg_load2b = 4’b0100, Reg_load3a = 4’b0101, Reg_load3b = 4’b0110, T0 = 4’b0111, 
 T1 = 4’b1000, T2 = 4’b1001, T3 = 4’b1010, T4 = 4’b1011, T5 = 4’b1100, T6 = 4’b1101;
 reg [3:0] Present_state = Default;
Datapath DUT(PCout, Zlowout, MDRout, R0out, R4out, MARin, Zin, PCin, MDRin, IRin, Yin, IncPC, Read, MUL, R7in, 
R0in, R4in, Clock, Mdatain);
// add test logic here
initial 
 begin
 Clock = 0;
 forever #10 Clock = ~ Clock;
end
always @(posedge Clock) // finite state machine; if clock rising-edge
 begin
 case (Present_state)
Default : Present_state = Reg_load1a;
Reg_load1a : Present_state = Reg_load1b;
Reg_load1b : Present_state = Reg_load2a;
Reg_load2a : Present_state = Reg_load2b;
Reg_load2b : Present_state = Reg_load3a;
Reg_load3a : Present_state = Reg_load3b;
Reg_load3b : Present_state = T0;
T0 : Present_state = T1;
T1 : Present_state = T2;
T2 : Present_state = T3;
T3 : Present_state = T4;
T4 : Present_state = T5;
T5 : Present_state = T6:
 endcase
 end
 
always @(Present_state) // do the required job in each state
 begin
 case (Present_state) // assert the required signals in each clock cycle
Default: begin
PCout <= 0; ZLOout <= 0; MDRout <= 0; // initialize the signals
 R0out <= 0; R4out <= 0; MARin <= 0; Zin <= 0; 
 PCin <=0; MDRin <= 0; IRin <= 0; Yin <= 0; 
 IncPC <= 0; Read <= 0; MUL <= 0;
 R7in <= 0; R0in <= 0; R4in <= 0; Mdatain <= 32’h00000000;
end
Reg_load1a: begin 
Mdatain <= 32’h00000034;
Read = 0; MDRin = 0; // the first zero is there for completeness
Read <= 1; MDRin <= 1; // Took out #15 for '1', as it may not be needed
#15 Read <= 0; MDRin <= 0; // for your current implementation
end
 Reg_load1b: begin
 MDRout <= 1; R0in <= 1; 
 #15 MDRout <= 0; R0in <= 0; // initialize R0 with the value 0x34 
end
Reg_load2a: begin 
Mdatain <= 32’h00000045;
Read <= 1; MDRin <= 1; 
#15 Read <= 0; MDRin <= 0; 
end
 Reg_load2b: begin
 MDRout <= 1; R4in <= 1; 
 #15 MDRout <= 0; R4in <= 0; // initialize R4 with the value 0x45 
end
Reg_load3a: begin 
Mdatain <= 32’h00000067;
Read <= 1; MDRin <= 1; 
#15 Read <= 0; MDRin <= 0;
end
 Reg_load3b: begin
 MDRout <= 1; R7in <= 1; 
 #15 MDRout <= 0; R7in <= 0; // initialize R7 with the value 0x67 
end
T0: begin // see if you need to de-assert these signals
PCout <= 1; MARin <= 1; IncPC <= 1; Zin <= 1;
end
T1: begin
ZLOout <= 1; PCin <= 1; Read <= 1; MDRin <= 1;
Mdatain <= 32’h69880000; // opcode for “MUL R3, R1”
// 0110 1001 1000 1... OPCODE RA RB...
end
T2: begin
MDRout <= 1; IRin <= 1; 
10
end
T3: begin
R0out <= 1; Yin <= 1; 
end
T4: begin
R4out <= 1; MUL <= 1; Zin <= 1; 
end
T5: begin
ZLOout <= 1; R7in <= 1; 
end
 endcase
 end
endmodule
