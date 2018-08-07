//sample dice program for microwavemont's FPGA board
// reset: P38, dicing: P35

module dice(ck, rst, enable, nSEG, CS);
input	ck, rst, enable;
output [7:0]	nSEG;
output [2:0] CS;
reg		[2:0]	cnt;
assign 	CS = 3'b011;


always @(posedge ck or negedge rst) begin

	if (rst==1'b0)
		cnt <= 3'h1;
	else if (enable==1'b0)
		if(cnt==3'h6)
			cnt<= 3'h1;
		else
			cnt<= cnt + 3'h1;
end

function [7:0] seg;
input	 [2:0] din;
	case(din)
		3'h1: seg = 8'b11111001;
		3'h2: seg = 8'b10100100;
		3'h3: seg = 8'b10110000;
		3'h4: seg = 8'b10011001;
		3'h5: seg = 8'b10010010;
		3'h6: seg = 8'b10000010;
		default:seg=8'bxxxxxxxx;
		endcase
endfunction

assign nSEG = seg(cnt);

endmodule
