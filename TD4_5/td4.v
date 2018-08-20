// reference http://d.hatena.ne.jp/propella/20080616/p1
// coding by .h2o (http://d.hatena.ne.jp/dot_h2o2/)
// rev 0.1 init release 
// rev 0.2 update rom using Assembler macro's 
// reference http://d.hatena.ne.jp/propella/20080616/p1
// coding by .h2o (http://d.hatena.ne.jp/dot_h2o2/)
// rev 0.1 init release 
// rev 0.2 update rom using Assembler macro's 
//
// td4.lpf
// LOCATE COMP "clck[3]" SITE "107" ;
// LOCATE COMP "clck[2]" SITE "106" ;
// LOCATE COMP "clck[1]" SITE "105" ;
// LOCATE COMP "clck[0]" SITE "104" ;
//
// LOCATE COMP "led[3]" SITE "100" ;
// LOCATE COMP "led[2]" SITE "99" ;
// LOCATE COMP "led[1]" SITE "98" ;
// LOCATE COMP "led[0]" SITE "97" ;
`timescale 1ns / 1ps
module td4_top (
    output [3:0] clck,
	output [3:0] led,
	input RESET,
	input [3:0] IN,
	output [2:0] CS
	);
	assign CS=3'b110;
	reg [27:0] count;
	wire td4_CLOCK;
	wire [3:0] OUT;
	OSCH #( .NOM_FREQ("2.08")) IOSC
        (
          .STDBY(1'b0),
          .OSC(clk),
          .SEDSTDBY()
        );
	
     always @ (posedge clk)
     begin
		count = count+1;
     end
	 
     assign td4_CLOCK = ~count[20];
	 assign clck = ~count[23:20];
	 assign led = ~OUT;
	 td4_logic td4(td4_CLOCK, RESET, IN, OUT);
endmodule

module td4_logic(
           input CLOCK,
           input RESET,
           input [3:0] IN,
           output reg [3:0] OUT
           );

   reg [3:0] A, B; // Registers
   reg [3:0] PC; // Program Counter
   reg [7:0] ROM [15:0]; //the Instruction memory
   reg C; // Carry flag

   wire Cnext;
   wire [3:0] OP; // Operation code
   wire [3:0] IM; // Immediate data
   wire [3:0] CHANNEL; // Input channel
   wire [3:0] ALU;
   wire LOAD0, LOAD1, LOAD2, LOAD3;
   wire SELECT_A, SELECT_B;

   assign IM = ROM[PC][3:0];
   assign OP = ROM[PC][7:4];

   // Data transfar
   always @(posedge CLOCK) begin
      C   <= RESET ? 0 :  Cnext;
      A   <= RESET ? 0 : ~LOAD0 ? ALU : A;
      B   <= RESET ? 0 : ~LOAD1 ? ALU : B;
      OUT <= RESET ? 0 : ~LOAD2 ? ALU : OUT;
      PC  <= RESET ? 0 : ~LOAD3 ? ALU : PC + 1;
   end
   
   // Opcode decode
   assign SELECT_A = OP[0] | OP[3];
   assign SELECT_B = OP[0];
   assign LOAD0 =  OP[2] |  OP[3];
   assign LOAD1 = ~OP[2] |  OP[3];
   assign LOAD2 =  OP[2] | ~OP[3];
   assign LOAD3 = ~OP[2] | ~OP[3] | (~OP[0] & C);

   // Data selector
   assign CHANNEL = (~SELECT_B & ~SELECT_A) ? A :
                    (~SELECT_B &  SELECT_A) ? B :
                    ( SELECT_B & ~SELECT_A) ? IN :
                    4'b0000;

   // ALU
   assign {Cnext, ALU} = CHANNEL + IM;
   
   // Assembler macro's
   `define MOV_A(ii) ((8'b00110000)+(ii&4'hf))
   `define MOV_B(ii) ((8'b01110000)+(ii&4'hf))
   `define MOV_A_B    (8'b00010000)
   `define MOV_B_A    (8'b01000000)
   `define ADD_A(ii) ((8'b00000000)+(ii&4'hf))
   `define ADD_B(ii) ((8'b01010000)+(ii&4'hf))
   `define IN_A       (8'b00100000)
   `define IN_B       (8'b01100000)
   `define OUT_(ii)  ((8'b10110000)+(ii&4'hf))
   `define OUT_B      (8'b10010000)
   `define JMP_(ii)  ((8'b11110000)+(ii&4'hf))
   `define JNC_(ii)  ((8'b11100000)+(ii&4'hf))

 // Ramen timer
   initial begin
/*
      ROM[0] =  8'b10110111; // OUT 0111   # LED
      ROM[1] =  8'b00000001; // ADD A,0001
      ROM[2] =  8'b11100001; // JNC 0001   # loop 16 times
      ROM[3] =  8'b00000001; // ADD A,0001
      ROM[4] =  8'b11100011; // JNC 0011   # loop 16 times
      ROM[5] =  8'b10110110; // OUT 0110   # LED
      ROM[6] =  8'b00000001; // ADD A,0001
      ROM[7] =  8'b11100110; // JNC 0110   # loop 16 times
      ROM[8] =  8'b00000001; // ADD A,0001 
      ROM[9] =  8'b11101000; // JNC 1000   # loop 16 times
      ROM[10] = 8'b10110000; // OUT 0000   # LED
      ROM[11] = 8'b10110100; // OUT 0100   # LED
      ROM[12] = 8'b00000001; // AND 0001
      ROM[13] = 8'b11101010; // JNC 1010   # loop 16 times
      ROM[14] = 8'b10111000; // OUT 1000   # LED
      ROM[15] = 8'b11111111; // JMP 1111
*/

      ROM[0] =  `OUT_(4'b0111);  //   # LED
      ROM[1] =  `ADD_A(4'b0001);
      ROM[2] =  `JNC_(4'b0001);  //   # loop 16 times
      ROM[3] =  `ADD_A(4'b0001);
      ROM[4] =  `JNC_(4'b0011);  //   # loop 16 times
      ROM[5] =  `OUT_(4'b0110);  //   # LED
      ROM[6] =  `ADD_A(4'b0001);
      ROM[7] =  `JNC_(4'b0110);  //   # loop 16 times
      ROM[8] =  `ADD_A(4'b0001);
      ROM[9] =  `JNC_(4'b1000);  //   # loop 16 times
      ROM[10] = `OUT_(4'b0000);  //   # LED
      ROM[11] = `OUT_(4'b0100);  //   # LED
      ROM[12] = `ADD_A(4'b0001);
      ROM[13] = `JNC_(4'b1010);  //   # loop 16 times
      ROM[14] = `OUT_(4'b1000);  //   # LED
      ROM[15] = `JMP_(4'b1111);  //   stop

   end
endmodule