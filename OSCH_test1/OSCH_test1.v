// Internal RC Oscillator test program (not so accurate, though)
// available frequency: 2.08, 2.46, 3.17, 4.29, 5.54, 7, 8.31
// 9.17, 10.23, 13.3, 14.78, 20.46, 26.6, 29.56, 33.25, 38
// 44.33, 53.2, 66.5, 88.67, 133 MHz

module clktest(output clk);
	defparam OSCH_inst.NOM_FREQ = "7";
OSCH OSCH_inst( .STDBY(1'b0), // 0=Enabled, 1=Disabled
.OSC(osc_clk),
.SEDSTDBY());
	assign clk=osc_clk;
endmodule