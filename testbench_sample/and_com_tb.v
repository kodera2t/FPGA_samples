module and_comb_tb;
reg SA, SB;
wire SY;

and_comb and_comb(.A(SA), .B(SB), .Y(SY));

initial begin
		SA=0; SB=0;
#100	SA=1; SB=0;
#100	SA=0; SB=1;
#100	SA=1; SB=1;
#100	$finish;
end

endmodule
		