module slow_blink(ck, led, CS);
input ck;
output reg [7:0] led;
output reg [2:0] CS;

reg [23:0] reg_cnt;
reg [2:0] func_cnt;

initial reg_cnt<=0;
initial func_cnt<=0;

always @( posedge ck ) begin
	reg_cnt <= reg_cnt+1'b1;
	if(reg_cnt == 'hffffff)begin
		func_cnt <= func_cnt+1;
		case(func_cnt)
			0: CS=3'b110;
			1: CS=3'b101;
			2: CS=3'b011;
			3: CS=3'b110;
			default:CS=3'b011;
		endcase		
		led<=~led;		
	end
end
endmodule