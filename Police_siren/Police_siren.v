module music(clk, speaker);
input clk;
output speaker;

reg [22:0] tone;
always @(posedge clk) tone <= tone+1;

wire [6:0] ramp = (tone[22] ? tone[21:15] : ~tone[21:15]);
wire [14:0] clkdivider = {2'b01, ramp, 6'b000000};

reg [14:0] counter;
always @(posedge clk) if(counter==0) counter <= clkdivider; else counter <= counter-1;

reg speaker;
always @(posedge clk) if(counter==0) speaker <= ~speaker;
endmodule 