module colorbar(
                input        clk,
                output       clken,
                output [3:0] vga_r,
                output [3:0] vga_g,
                output [3:0] vga_b,
                output reg   vga_hs,
                output reg   vga_vs
                );
   parameter H_ACTIVE_PIXEL_LIMIT = 640;
   parameter V_ACTIVE_LINE_LIMIT = 480;

   assign clken = 1'b1;

   reg [9:0]                 hs_cnt = 10'd0;
   reg [9:0]                 vs_cnt = 10'd0;
   
   reg                       vga_clk;
   always @(posedge clk) begin
      vga_clk = ~vga_clk;
   end

   reg [26:0] ch_cnt;
   reg        ch_clk;
   always @(posedge clk) begin
      if(ch_cnt == 27'd999999)
        ch_cnt = 27'd0;
      else begin
         if(ch_cnt == 0)begin
            ch_clk = 1'b1;
         end else begin
            ch_clk = 1'b0;
         end
         ch_cnt = ch_cnt + 1;
      end
   end
   reg [9:0] ch_x = 10'd300;
   reg [9:0] ch_y = 10'd300;
   reg [6:0] dy = 7'd1;
   always @(posedge ch_clk ) begin
      if(ch_x > H_ACTIVE_PIXEL_LIMIT - 32)
        ch_x <= 0;
      else begin
         ch_x <= ch_x + 2;
      end
      
      if(dy == 7'd31)
        dy <= 7'd1;
      else begin
         dy <= dy + 7'd1;
      end
      ch_y <= ch_y + dy - 16;
      
   end

   reg [7:0] rg = 8'h00;
   reg [5:0] rg_cnt = 5'd0;
   always @(posedge vga_clk) begin
      // hs_cnt: 0..799
      if(hs_cnt == 10'd799) begin
         hs_cnt <= 10'd0;
         rg <= 8'd0;
      end else begin
         hs_cnt <= hs_cnt + 1;
      end
      // 148..787 (640) 
      if(hs_cnt >= 10'd148 && hs_cnt < 10'd788) begin
         if(rg_cnt >= 6'd24) begin
            rg_cnt <= rg_cnt - 6'd24;
         end else begin
            rg_cnt <= rg_cnt + 6'd16;
         end
         rg <= rg + 8'd1;
      end
   end
   
   always @(posedge vga_clk) begin
      if(hs_cnt == 10'd0)
        vga_hs = 1'b0;
      else if(hs_cnt == 10'd96)
        vga_hs = 1'b1;
   end
   
   always @(posedge vga_clk) begin
      if(hs_cnt == 10'd144)
        i_hdisp = 1'b1;
      else if(hs_cnt == 10'd784)
        i_hdisp = 1'b0;
   end
   
   reg [3:0] b = 4'd0;
   reg [9:0] b_cnt = 10'd0;
   always @(posedge vga_hs) begin
      if(vs_cnt == 10'd520)
        vs_cnt = 10'd0;
      else
        vs_cnt = vs_cnt + 1;
      // V:30..509(480)
      if(vs_cnt >= 10'd30 && vs_cnt < 10'd510) begin
         if(b_cnt >= 480 - 16) begin
            b_cnt = b_cnt + 16 - 480;
            b = b + 1; // 0..15
         end else
           b_cnt = b_cnt + 16;  
      end
   end
   //u
     always @(posedge vga_hs) begin
        if(vs_cnt == 10'd0)
          vga_vs = 1'b0;
        else if(vs_cnt == 10'd2)
          vga_vs = 1'b1;
        else
          vga_vs = vga_hs;
     end
   
   reg i_hdisp, i_vdisp;
   always @(posedge vga_hs) begin
      if(vs_cnt == 10'd31)
        i_vdisp = 1'b1;
      else if(hs_cnt == 10'd511)
        i_vdisp = 1'b0;
   end
   
   wire [9:0]disp_x = hs_cnt - 148;
   wire [9:0] disp_y = vs_cnt - 30;

   reg [31:0] line;
   wire [9:0] spr_y = disp_y - ch_y;
   always @(spr_y) begin
      case (spr_y)
        10'd00: line = 32'b00000000000000111111000000000000;
        10'd01: line = 32'b00000000000011111111110000000000;
        10'd02: line = 32'b00000000000111111111111000000000;
        10'd03: line = 32'b00000000001111111111111100000000;
        10'd04: line = 32'b00000000001111111111111100000000;
        10'd05: line = 32'b00000000001111111111001100111110;
        10'd06: line = 32'b00000000001111111111001101111111;
        10'd07: line = 32'b00000000001111111111111101111111;
        10'd08: line = 32'b00000000001111111111111101111111;
        10'd09: line = 32'b00000000001111111101111101111111;
        10'd10: line = 32'b00000000000111111110000100111110;
        10'd11: line = 32'b00000000000011111111111000111100;
        10'd12: line = 32'b00000000000001111111110001111100;
        10'd13: line = 32'b00000001111111111111111111111100;
        10'd14: line = 32'b00000011111111111111111111111100;
        10'd15: line = 32'b00001111111111111111111111111000;
        10'd16: line = 32'b00011111111111111111111111100000;
        10'd17: line = 32'b00011111111111111111111110000000;
        10'd18: line = 32'b00011111111111111111111100000000;
        10'd19: line = 32'b00011111000111111111111100000000;
        10'd20: line = 32'b00111111100111111111111100000000;
        10'd21: line = 32'b01111111100111111111111111111000;
        10'd22: line = 32'b01111111100111111111111111111100;
        10'd23: line = 32'b00111111000111111111111111111100;
        10'd24: line = 32'b00000000000111111111111111111100;
        10'd25: line = 32'b00000011100111111111110001111110;
        10'd26: line = 32'b00000011111111111000000011111111;
        10'd27: line = 32'b00000011111111111000000011111111;
        10'd28: line = 32'b00000011111111110000000011111111;
        10'd29: line = 32'b00000011111111100000000000000000;
        10'd30: line = 32'b00000011111000000000000000000000;
        10'd31: line = 32'b00000011110000000000000000000000;
        default: line = 32'b00000000000000000000000000000000;
      endcase
   end
   wire [11:0] rgb =
               (disp_x >= ch_x && disp_x < ch_x + 32 && disp_y >= ch_y && disp_y < ch_y + 32 &&
                (line[31 - (disp_x - ch_x)]) ? 12'h00f : {rg, b});
   
   assign vga_r = (i_hdisp && i_vdisp) ? rgb[11:8] : 4'd0;
   assign vga_g = (i_hdisp && i_vdisp) ? rgb[7:4] : 4'd0;
   assign vga_b = (i_hdisp && i_vdisp) ? rgb[3:0] : 4'd0;

endmodule